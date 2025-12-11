import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/firebase_options.dart';
import 'package:orcanet/feedAndPodsPage.dart';
import 'package:orcanet/feedPage.dart';
import 'package:orcanet/loginPage.dart';
import 'package:orcanet/makePostPage.dart';
import 'package:orcanet/message.dart';
import 'package:orcanet/profilePage.dart';
import 'package:orcanet/utilityClass.dart';
import 'package:orcanet/messagingService.dart';
import 'package:orcanet/homePage.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
            home: FirebaseAuth.instance.currentUser != null ? MyHomePage() : LoginScreen(),
          );
        });
  }
}
