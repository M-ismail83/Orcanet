import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/chatPage.dart';
import 'package:orcanet/firebase_options.dart';
import 'package:orcanet/feedAndPodsPage.dart';
import 'package:orcanet/feedPage.dart';
import 'package:orcanet/loginPage.dart';
import 'package:orcanet/makePostPage.dart';
import 'package:orcanet/message.dart';
import 'package:orcanet/utilityClass.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission(provisional: true);
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDarkMode, _) {
          final currentColors = isDarkMode
              ? Utilityclass.darkModeColor
              : Utilityclass.ligthModeColor;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: currentColors['bg'],
              appBarTheme: AppBarTheme(
                backgroundColor: currentColors['bar'],
                iconTheme: IconThemeData(color: currentColors['text']),
                titleTextStyle: TextStyle(
                  color: currentColors['text'],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            home: MyHomePage(),
          );
        });
  }
}

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
