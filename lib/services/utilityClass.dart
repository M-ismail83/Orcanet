import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';

class Utilityclass {
  static Map<String, Color> ligthModeColor = {
    'title': Color.fromRGBO(0, 0, 0, 1.0),
    'bg': Color.fromRGBO(247, 242, 240, 1.0),
    'container': Color.fromRGBO(235, 222, 214, 1.0),
    'bar': Color.fromRGBO(214, 195, 174, 1.0),
    'selected': Color.fromRGBO(184, 167, 148, 1.0),
    'text': Color.fromRGBO(0, 0, 0, 1.0),
    'hintText': Color.fromRGBO(0, 0, 0, 0.5),
    'acc1': Color.fromRGBO(187, 124, 250, 1.0),
    'acc2': Color.fromRGBO(116, 212, 111, 1.0),
    'msgBubbleSender': Color.fromRGBO(92, 81, 68, 1.0),
    'msgBubbleReciever': Color.fromRGBO(214, 195, 174, 1.0)
  };

  static Map<String, Color> darkModeColor = {
    'title': Color.fromRGBO(0, 0, 0, 1.0),
    'bg': Color.fromRGBO(60, 49, 43, 1.0),
    'container': Color.fromRGBO(92, 81, 68, 1.0),
    'bar': Color.fromRGBO(145, 118, 104, 1.0),
    'selected': Color.fromRGBO(184, 167, 148, 1.0),
    'text': Color.fromRGBO(240, 232, 230, 1.0),
    'hintText': Color.fromRGBO(240, 232, 230, 0.5),
    'acc1': Color.fromRGBO(149, 82, 199, 1),
    'acc2': Color.fromRGBO(17, 123, 77, 1.0),
    'msgBubbleSender': Color.fromRGBO(214, 195, 174, 1.0),
    'msgBubbleReciever': Color.fromRGBO(92, 81, 68, 1.0)
  };

  static launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void navigator(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  String getChatId(String uid1, List uid2) {
    List<String> ids = List<String>.from(uid2);
    ids.add(uid1);
    ids.sort();
    String channelId = ids.join("_");
    var bytes = utf8.encode(channelId);
    var digest = md5.convert(bytes);

    return digest.toString();
  }

  Future<void> startChat(
      BuildContext context,
      String targetUid,
      String targetName,
      String ownUid,
      Map<String, Color> currentColors) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String chatId = getChatId(ownUid, [targetUid]);

    DocumentReference chatDoc =
        FirebaseFirestore.instance.collection('chats').doc(chatId);

    DocumentSnapshot snapshot = await chatDoc.get();

    if (!snapshot.exists) {
      await chatDoc.set({
        'chatId': chatId,
        'type': 'Orcas',
        'participants': [currentUser.uid, targetUid],
        'lastMessage': "Chat started",
        'lastMessageId': 0,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'chatName':
            "${targetName.split(' ')[0]} - ${currentUser.displayName?.split(' ')[0]}",
        'createdBy': currentUser.uid,
      });
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: chatId,
            receiverId: [targetUid],
            kisiAdi: targetName,
            currentColors: currentColors,
          ),
        ),
      );
    }
  }
}
