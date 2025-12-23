import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sodium/sodium.dart';
import 'encryption/room_key_service.dart';
import 'encryption/sodium_singleton.dart';

User? user = FirebaseAuth.instance.currentUser;
var docRef = FirebaseFirestore.instance.collection('users').doc('${user?.displayName}');

Future<void> createAndSaveUser({required String fcmToken}) async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) return;

  DocumentReference userRef = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid);

  try {
     await userRef.set({
      'fcmToken': fcmToken, // Always update this
      'id': currentUser.uid,
      'name': currentUser.displayName ?? 'No Name', // Handle null names
      'email': currentUser.email,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    docRef.update({'fcmToken': newToken});
  });
  } catch (e) {
    print("Error $e");
  }
}

Future<void> sendMessage({
  required String senderId,
  required List receiverId,
  required String chatId,
  required String text,
}) async {
  final firestore = FirebaseFirestore.instance;
  final chatDocRef = firestore.collection('chats').doc(chatId);

  try {
    // 1️⃣ Build participants list
    final List<String> participants = [
      senderId,
      ...receiverId.map((e) => e.toString()),
    ];

    // 2️⃣ ENSURE room key exists (THIS MUST COME FIRST)
    final chatSnapshot = await chatDocRef.get();
    if (!chatSnapshot.exists) {
      await initializeRoomKey(chatId, participants);
    } else {
      final keysSnapshot = await chatDocRef.collection('keys').get();
      if (keysSnapshot.docs.isEmpty) {
        await initializeRoomKey(chatId, participants);
      }
    }

    // 3️⃣ Debug private key presence
    final privateKey = await secureStorage.read(
      key: "${senderId}_privateKey",
    );
    if (privateKey == null) {
      throw Exception("Private key missing for user $senderId");
    }

    // 4️⃣ NOW safely get room key
    final roomKey = await getRoomKey(chatId, senderId);

    // 5️⃣ Encrypt message
    final nonce = sodium.randombytes.buf(
      sodium.crypto.secretBox.nonceBytes,
    );

    final cipherText = sodium.crypto.secretBox.easy(
      message: utf8.encode(text),
      nonce: nonce,
      key: roomKey,
    );

    // 6️⃣ Write message
    await firestore.runTransaction((transaction) async {
      final chatSnapshot = await transaction.get(chatDocRef);

      int nextId = 0;
      if (!chatSnapshot.exists) {
        transaction.set(chatDocRef, {
          'participants': participants,
          'lastMessageId': 0,
        });
      } else {
        nextId = (chatSnapshot.get('lastMessageId') ?? 0) + 1;
      }

      final messageRef = chatDocRef
          .collection('messages')
          .doc(nextId.toString());

      transaction.set(messageRef, {
        'id': nextId,
        'senderId': senderId,
        'receiverId': receiverId,
        'cipherText': base64Encode(cipherText),
        'nonce': base64Encode(nonce),
        'timestamp': FieldValue.serverTimestamp(),
      });

      transaction.update(chatDocRef, {
        'lastMessageId': nextId,
        'lastMessage': "<ENCRYPTED>",
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    });
  } catch (e) {
    print("Error sending message: $e");
    rethrow;
  }
}



Stream<QuerySnapshot> getMessagesStream(String chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('id', descending: true)
      .snapshots();
}



