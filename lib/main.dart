import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] == 'call_offer') {
      // Wakes up phone and shows UI
      await CallService.showIncomingCall(
            uuid: message.data['uuid'],
            callerName: message.data['callerName'] ?? "UnknownId",
            callerId: message.data['callerId'] ?? "000",
            hasVideo: message.data['hasVideo'] == 'true',
      );
  }
}

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
            home: FirebaseAuth.instance.currentUser != null ? MyHomePage() : LoginScreen(currentColors: currentColors,),
          );
        });
  }
}
