const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Trigger: Run this whenever a NEW message is created
exports.sendChatNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    
    // 1. Get the message data
    const messageData = snapshot.data();
    const receiverId = messageData.receiverId;
    const senderId = messageData.senderId;
    const textContent = messageData.text;

    // 2. Get the Receiver's FCM Token from the 'users' collection
    const userDoc = await admin.firestore().collection("users").doc(receiverId).get();

    if (!userDoc.exists) {
      console.log("No user found for ID:", receiverId);
      return null;
    }

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      console.log("User has no FCM token!");
      return null;
    }

    // 3. Get Sender's Name (Optional, for a nicer notification)
    // You could skip this and just say "New Message", but names are better.
    const senderDoc = await admin.firestore().collection("users").doc(senderId).get();
    const senderName = senderDoc.exists ? senderDoc.data().name : "Someone";

    // 4. Construct the Payload
    const payload = {
      notification: {
        title: senderName,
        body: textContent,
      },
      // Data is what your app reads when the user taps the notification
      data: {
        chatId: context.params.chatId,
        click_action: "FLUTTER_NOTIFICATION_CLICK", // Standard key
        type: "chat",
      },
      token: fcmToken,
    };

    // 5. Send it!
    try {
      await admin.messaging().send(payload);
      console.log("Notification sent successfully!");
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });