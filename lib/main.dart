import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/firebase_options.dart';
import 'package:orcanet/loginPage.dart';
import 'package:orcanet/utilityClass.dart';
import 'package:orcanet/messagingService.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);
  final fcmToken = await FirebaseMessaging.instance.getToken();
  createAndSaveUser(fcmToken: fcmToken ?? "");
  if (kDebugMode) {
    print("FCM Token: $fcmToken");
  }
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
            home: LoginScreen(),
          );
        });
  }
}