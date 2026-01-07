import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';

class Utilityclass {
  static Map<String, Color> ligthModeColor = <String, Color>{
  'title':     Color.fromRGBO(0, 0, 0, 1.0),
  'bg':        Color.fromRGBO(247, 242, 240, 1.0),
  'container': Color.fromRGBO(235, 222, 214, 1.0),
  'contaionerBorder': Color.fromRGBO(214, 195, 174, 0.5),
  'bar':       Color.fromRGBO(214, 195, 174, 1.0),
  'selected':  Color.fromRGBO(184, 167, 148, 1.0),
  'text':      Color.fromRGBO(0, 0, 0, 1.0),
  'hintText':  Color.fromRGBO(0, 0, 0, 0.5),
  'acc1':      Color.fromRGBO(187, 124, 250, 1.0),
  'acc2':      Color.fromRGBO(116, 212, 111, 1.0),
  'acc1border': Color.fromRGBO(137, 64, 220, 1.0),
  'acc2border': Color.fromRGBO(66, 162, 61, 1.0),
  'msgBubbleSender': Color.fromRGBO(92, 81, 68, 1.0),
  'msgBubbleReceiver': Color.fromRGBO(240, 232, 230, 1.0),
  'mbsBorder': Color.fromRGBO(60, 49, 43, 1.0),
  'mbrBorder': Color.fromRGBO(240, 232, 230, 1.0),
  'messageSender': Color.fromRGBO(240, 232, 230, 1.0),
  'messageReceiver': Color.fromRGBO(60, 49, 43, 1.0),
  'textFieldBorder': Color.fromRGBO(214, 195, 174, 0.7),
  };

  static Map<String, Color> darkModeColor = {
  'title':     Color.fromRGBO(0, 0, 0, 1.0),
  'bg':        Color.fromRGBO(24, 15, 15, 1.0),
  'container': Color.fromRGBO(57, 45, 32, 1.0),
  'contaionerBorder': Color.fromRGBO(145, 118, 104, 0.7),
  'bar':       Color.fromRGBO(113, 85, 65, 1.0),
  'selected':  Color.fromRGBO(184, 167, 148, 1.0),
  'text':      Color.fromRGBO(240, 232, 230, 1.0),
  'hintText':  Color.fromRGBO(240, 232, 230, 0.5),
  'acc1':      Color.fromRGBO(149, 82, 199, 1.0),
  'acc2':      Color.fromRGBO(17, 123, 77, 1.0),
  'acc1border': Color.fromRGBO(187, 124, 250, 0.5),
  'acc2border': Color.fromRGBO(143, 222, 89, 0.3),
  'msgBubbleSender': Color.fromRGBO(214, 195, 174, 1.0),
  'msgBubbleReceiver': Color.fromRGBO(92, 81, 68, 1.0),
  'mbsBorder': Color.fromRGBO(240, 232, 230, 1.0),
  'mbrBorder': Color.fromRGBO(60, 49, 43, 1.0),
  'messageSender': Color.fromRGBO(60, 49, 43, 1.0),
  'messageReceiver': Color.fromRGBO(240, 232, 230, 1.0),
  'textFieldBorder': Color.fromRGBO(60, 49, 43, 0.7),
  };

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

  Future<void> startChat(BuildContext context, String targetUid, String targetName, String ownUid, Map<String, Color> currentColors) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  String chatId = getChatId(ownUid, [targetUid]);

  DocumentReference chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);

  DocumentSnapshot snapshot = await chatDoc.get();

  if (!snapshot.exists) {
    await chatDoc.set({
      'chatId': chatId,
      'type': 'Orcas', 
      'participants': [currentUser.uid, targetUid],
      'lastMessage': "Chat started",
      'lastMessageId': 0,
      'lastMessageTime': FieldValue.serverTimestamp(),
      
      'chatName': "${targetName.split(' ')[0]} - ${currentUser.displayName?.split(' ')[0]}" , 
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