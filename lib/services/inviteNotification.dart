import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Add this package!

class InviteNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final String? actionId = response.actionId;
      final String? podId = response.payload;

      final DocumentReference docRef = FirebaseFirestore.instance
          .collection('pods')
          .doc(podId);

      if (podId == null) return;

      // Check which button was pressed
      if (actionId == 'accept_invite') {
        print("User clicked ACCEPT for Pod: $podId");
        docRef.update({
          'members': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
        
      } else if (actionId == 'decline_invite') {
        print("User clicked DECLINE for Pod: $podId");
      
      } else {
        // User clicked the notification body (not a button)
        print("User clicked the notification body");
        // Navigate to the specific page
      }
    },
  );
}

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
  Future<void> showInviteNotif(String podName, String podId, String inviterName) async {
  
  // A. Define the Buttons (Actions)
  final List<AndroidNotificationAction> actions = [
    const AndroidNotificationAction(
      'accept_invite', // actionId (we check this later)
      'Accept',        // Button Text
      titleColor: Colors.green,
      showsUserInterface: true, // true = opens app, false = background task
      cancelNotification: true, // Close notification on click
    ),
    const AndroidNotificationAction(
      'decline_invite',
      'Decline',
      titleColor: Colors.red,
      showsUserInterface: true,
      cancelNotification: true,
    ),
  ];

  // B. Define the Style (Big Text for long messages)
  final BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
    '$inviterName has invited you to join the pod "$podName". Click to respond.',
    htmlFormatBigText: true,
    contentTitle: '<b>Pod Invitation</b>',
    htmlFormatContentTitle: true,
    summaryText: '$inviterName invited you',
    htmlFormatSummaryText: true,
  );

  // C. Build the Details
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'invite_channel',
    'Pod Invites',
    channelDescription: 'Notifications for pod invitations',
    importance: Importance.max,
    priority: Priority.high,
    
    // VISUAL CUSTOMIZATION
    color: const Color(0xFF5C5344), // Your app's primary color (hex)
    styleInformation: bigTextStyle,  // Use the style defined above
    largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'), // Show app icon on the right
    
    // BUTTONS
    actions: actions,
  );

  NotificationDetails platformDetails = 
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Pod Invitation',
    '$inviterName has invited you to join "$podName".',
    platformDetails,
    payload: podId, // We still pass the ID
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
                    .where('creatorId', isEqualTo: currentUserId)
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
