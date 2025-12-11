import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:orcanet/authLoginandLogout.dart';
import 'package:orcanet/chatPage.dart';
import 'package:orcanet/feedPage.dart';
import 'package:orcanet/loginPage.dart';
import 'package:orcanet/main.dart';
import 'package:orcanet/makePostPage.dart';
import 'package:orcanet/messagingService.dart';
import 'package:orcanet/profilePage.dart';
import 'package:orcanet/utilityClass.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final currentColors = isDarkModeNotifier.value
      ? Utilityclass.darkModeColor
      : Utilityclass.ligthModeColor;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  int currentPageIndex = 0;

  var colors = <Color>{Colors.red, Colors.green, Colors.blue};
  List<NavigationDestination> pages = [
    NavigationDestination(
      selectedIcon: Icon(Icons.home),
      icon: Icon(Icons.home_outlined),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.plus_one),
      label: 'Post',
    ),
    NavigationDestination(
      icon: Icon(Icons.people),
      label: 'Community',
    ),
    NavigationDestination(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.coffee),
      label: 'Donation',
    ),
  ];

  @override
  void initState() {
    super.initState();

    setupNotification();
    FirebaseMessaging.instance.getToken().then((token) {
    if (token != null) {
      createAndSaveUser(fcmToken: token);
    }
  });
  }
  
  void setupNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/notif_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // This handles when a user taps on a LOCAL notification (Foreground)
        print("Tapped local notification: ${details.payload}");
      },
    );

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.', 
        importance: Importance.max,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }



    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.notification?.body);

      if (message.notification != null && Platform.isAndroid) {
        flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              icon: '@mipmap/notif_icon', // Your icon
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("I just tapped a notification wtf just happened?!!?!!");
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("App launched from Terminated state by notification!");
        // Navigate to the chat screen
        // Note: You might need to delay this slightly or use a global navigator key
        // if your Context isn't fully ready yet.
      }
    });

  }

  @override
Widget build(BuildContext context) {
  return ValueListenableBuilder<bool>(
    valueListenable: isDarkModeNotifier,
    builder: (context, isDarkMode, _) {
      final currentColors = isDarkMode
          ? Utilityclass.darkModeColor
          : Utilityclass.ligthModeColor;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: currentColors['bar'],
          title: Text(
            "ORCA/NET",
            style: TextStyle(
              fontSize: 17,
              color: currentColors['text'],
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: InkWell(
            onTap: () {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;
            },
            splashColor: Colors.transparent,
            radius: 15,
            child: CircleAvatar(
              backgroundColor: currentColors['bar'],
              backgroundImage: Image.asset("lib/images/Logo.png", fit: BoxFit.fill,).image
            ),
          ),
          leadingWidth: 55,

          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Your Notifications',
              onPressed: () {
                // handle the press
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_2),
              tooltip: 'Open shopping cart',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => profilePage(currentColors: currentColors),
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          backgroundColor: currentColors['bar'],
          indicatorColor: currentColors['selected'],
          destinations: pages,
        ),
        body: <Widget>[
          feedPage(currentColors: currentColors),
          makePostPage(currentColors: currentColors),
          chatPage(currentColors: currentColors),
          Center(
            child: Text('Search Page (WORK IN PROGRESS)', style: TextStyle(fontSize: 20, color: currentColors['text']),),
          ),
          Center(
            child: Text('Donation Page (WORK IN PROGRESS)', style: TextStyle(fontSize: 20, color: currentColors['text'])),
          ),
        ][currentPageIndex],
      );
    },
  );
 }
}
  