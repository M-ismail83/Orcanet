import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Add this package!

class InviteNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. Initialize the plugin (Call this in main.dart or your home page initState)
  Future<void> initialize() async {
    // Android Setup: Make sure 'ic_launcher' exists in android/app/src/main/res/drawable
    // If not, use '@mipmap/ic_launcher'
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle what happens when user taps the notification
        if (response.payload != null) {
          print('User tapped notification for Pod ID: ${response.payload}');
          // You can use Navigator here to go to the specific Pod page
        }
      },
    );
  }

  // 2. Request Permission (Required for Android 13+)
  Future<void> requestPermissions() async {
    // Using permission_handler package
    await Permission.notification.request();

    // OR using the plugin's built-in method:
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  // 3. Show the Notification
  Future<void> showInviteNotif(
      String podName, String podId, String inviterName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'invite_channel',
      'Pod Invites',
      channelDescription: 'Notifications for pod invitations',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true, // Shows the time
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID (Use a unique random number if you want multiple notifications to stack)
      'Pod Invitation',
      '$inviterName has invited you to join "$podName".',
      platformChannelSpecifics,
      payload: podId,
    );
  }

  Future<void> sendInvite({
    required BuildContext context,
    required String targetUserId, // The ID of the person you are looking at
    required String podId, // The ID of the pod you are inviting them to
    required String podName, // The Name of the pod
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // 1. Get My Name (Inviter Name)
      // Optimization: You might already have this stored in a provider or variable
      DocumentSnapshot myProfile = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      String myName = myProfile.get('name') ?? 'Unknown';

      // 2. Create the Invite Document in the TARGET's subcollection
      // Path: users -> {targetID} -> invites -> {randomID}
      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .collection('invites')
          .add({
        'inviterId': currentUser.uid,
        'inviterName': myName,
        'podId': podId,
        'podName': podName,
        'status': 'pending', // pending, accepted, rejected
        'timestamp':
            FieldValue.serverTimestamp(), // CRITICAL for your Node.js check
      });

      // 3. Success Feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invite sent to $podName!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      ;
    } catch (e) {
      print("Error sending invite: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send invite.')),
        );
      }
    }
  }

  void showPodSelectionDialog(BuildContext context, String targetUserId) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select a Pod",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              // List YOUR pods where you are an admin/member
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pods')
                    .where('members',
                        arrayContains:
                            currentUserId) // Or 'adminId' == currentUserId
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  var myPods = snapshot.data!.docs;

                  if (myPods.isEmpty) {
                    return Text("You don't have any pods yet.");
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: myPods.length,
                    itemBuilder: (context, index) {
                      var pod = myPods[index];
                      return ListTile(
                        title: Text(pod['podName']),
                        trailing: Icon(Icons.send),
                        onTap: () {
                          // CALL THE FUNCTION HERE
                          Navigator.pop(context); // Close the sheet
                          sendInvite(
                            context: context,
                            targetUserId: targetUserId,
                            podId: pod.id,
                            podName: pod['podName'],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
