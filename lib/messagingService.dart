import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  required String receiverId,
  required String chatId, // Format: "uid1_uid2" (sorted)
  required String text,
}) async {
  final firestore = FirebaseFirestore.instance;
  final chatDocRef = firestore.collection('chats').doc(chatId);

  try {
    
    await firestore.runTransaction((transaction) async {
      DocumentSnapshot chatSnapshot = await transaction.get(chatDocRef);

      int nextId = 0;

      if (!chatSnapshot.exists) {
        // Create the chat document inside the transaction
        transaction.set(chatDocRef, {
          'participants': [senderId, receiverId],
          'lastMessageId': 0, // Start at 0 so next is 1
        });
      } else {
        // Read the last ID
        int currentId = chatSnapshot.get('lastMessageId') ?? 0;
        nextId = currentId + 1;
      }

      DocumentReference messageRef = chatDocRef
          .collection('messages')
          .doc(nextId.toString());

      
      transaction.set(messageRef, {
        'id': nextId, // Save as number for easy sorting later
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      transaction.update(chatDocRef, {
        'lastMessageId': nextId,
        'lastMessage': text,
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


