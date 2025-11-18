import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? user = FirebaseAuth.instance.currentUser;
var docRef = FirebaseFirestore.instance.collection('users').doc('${user?.displayName}');

Future<void> createAndSaveUser({required String fcmToken}) async {
  var doc = await docRef.get();

  if (!doc.exists) {
    docRef.set({
      'fcmToken': fcmToken,
      'id': user?.uid,
      'name': user?.displayName,
      'email': user?.email,
    });
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    docRef.update({'fcmToken': newToken});
  });

}

Future<void> sendMessage({
  required String senderId,
  required String receiverId,
  required String chatId,
  required String messageId,
  required String text,
}) async {
  var messageRef = FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc(messageId);

  var chatRef = FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId);

  var chat = await chatRef.get();

  if (!chat.exists) {
    chatRef.set({
      'participants': [senderId, receiverId],
      'lastMessage': text
    });
  }

  await chatRef.update({
    'lastMessage': text
  });

  await messageRef.set({
    'senderId': senderId,
    'receiverId': receiverId,
    'text': text,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Stream<QuerySnapshot> getMessagesStream(String chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();
}


