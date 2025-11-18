import 'package:flutter/material.dart';
import 'package:orcanet/authLoginandLogout.dart';
import 'package:orcanet/chatPage.dart';
import 'package:orcanet/feedPage.dart';
import 'package:orcanet/loginPage.dart';
import 'package:orcanet/main.dart';
import 'package:orcanet/makePostPage.dart';
import 'package:orcanet/utilityClass.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
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
    NavigationDestination(
      icon: Icon(Icons.exit_to_app), 
      label: 'Logout')
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
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await logOut();
                if (context.mounted) {
                  Utilityclass().navigator(context, const LoginScreen());
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: currentColors['text'],
                backgroundColor: currentColors['bar'],
              ),
              child: Text('Log Out', style: TextStyle(color: currentColors['text']),),
            ),
          ),
        ][currentPageIndex],
      );
    },
  );
}

}
