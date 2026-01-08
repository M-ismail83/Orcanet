import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:orcanet/main.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final currentColors = isDarkModeNotifier.value
      ? Utilityclass.darkModeColor
      : Utilityclass.ligthModeColor;

  int currentPageIndex = 0;
  
  bool _isPremium = false;
  bool _loadingPremium = true;

  var colors = <Color>{Colors.red, Colors.green, Colors.blue};
  List<NavigationDestination> get pages => [
    NavigationDestination(
      icon: Icon(
        Icons.home,
        size: 30,
        fontWeight: FontWeight.w600,
        color: currentColors['text'],
      ),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(
        Icons.plus_one,
        size: 30,
        fontWeight: FontWeight.w600,
        color: currentColors['text'],
      ),
      label: 'Post',
    ),
    NavigationDestination(
      icon: Icon(
        Icons.people,
        size: 30,
        fontWeight: FontWeight.w600,
        color: currentColors['text'],
      ),
      label: 'Community',
    ),
    NavigationDestination(
      icon: Icon(
        Icons.search,
        size: 30,
        fontWeight: FontWeight.w600,
        color: currentColors['text'],
      ),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(
        Icons.settings,
        size: 30,
        fontWeight: FontWeight.w600,
        color: currentColors['text'],
      ),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _loadPremiumStatus();

    Callnotifservice(context: context).setupNotification();
    Callnotifservice(context: context).listenForCallEvents();
    Callnotifservice(context: context).checkAndNavigationCallingPage();

    final notifService = InviteNotificationService();

    // 1. Setup Notifications
    notifService.initialize();
    notifService.requestPermissions();

    // 2. Listen to Firestore for NEW invites
    String myUserId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(myUserId)
        .collection('invites') // Assuming invites are stored here
        .where('status', isEqualTo: 'pending') // Only get new ones
        .snapshots()
        .listen((snapshot) {
      // Loop through changes to find ADDED documents
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var data = change.doc.data() as Map<String, dynamic>;

          // TRIGGER THE NOTIFICATION
          notifService.showInviteNotif(
            data['podName'] ?? 'Unknown Pod',
            data['podId'] ?? '0',
            data['inviterName'] ?? 'Someone',
          );
        }
      }
    });

    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        createAndSaveUser(fcmToken: token);
      }
    });
  }

    Future<void> _loadPremiumStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    final data = doc.data() as Map<String, dynamic>?;

    setState(() {
      _isPremium = (data?['isPremium'] ?? false) as bool;
      _loadingPremium = false;
    });
  }   

  void _goToFeed() {
    setState(() {
      currentPageIndex = 0; // Assuming Feed is Index 0
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

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
              style: GoogleFonts.handjet(
                fontSize: 30,
                color: currentColors['text'],
                fontWeight: FontWeight.bold,
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
                backgroundImage: AssetImage(
                  _isPremium
                      ? 'lib/images/premium_logo.png'  
                      : 'lib/images/Logo.png',  
                ),
              ),
            ),

            leadingWidth: 55,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  size: 30,
                ),
                tooltip: 'Your Notifications',
                onPressed: () {
                  // handle the press
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  size: 30,
                ),
                tooltip: 'Open own profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => profilePage(
                        currentColors: currentColors,
                        uid: auth.currentUser!.uid,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return TextStyle(color: currentColors['text'], fontWeight: FontWeight.bold);
      }
      return TextStyle(color: currentColors['text'], fontWeight: FontWeight.normal);
    },
  ),
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            backgroundColor: currentColors['bar'],
            indicatorColor: currentColors['contaionerBorder'],
            destinations: pages,
          ),
          body: <Widget>[
            feedPage(currentColors: currentColors),
            makePostPage(currentColors: currentColors, onPost: _goToFeed),
            chatPage(currentColors: currentColors),
            searchPage(currentColors: currentColors),
            settingsPage(currentColors: currentColors),
          ][currentPageIndex],
        );
      },
    );
  }
}
