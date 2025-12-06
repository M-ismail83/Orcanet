import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.kisiAdi, required this.currentColors});

  final String kisiAdi;
  final Map<String, Color> currentColors;
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // I already have all the necessary functions in another file so no shared preference??????????
  // Firestore should hanlde the storing and shit like that
  // I have no idea tbh
  // Really tho how do I get the other person's uid??
  // Maybe store it in Firestore and get it by searching the user with this name????
  // That doesn't sound too secure tho. Plus Cihat already talked about security

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesAsString = _messages
        .map((message) => '${message['sender']}:${message['text']}')
        .toList();
    await prefs.setStringList(widget.kisiAdi, messagesAsString);
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesAsString = prefs.getStringList(widget.kisiAdi) ?? [];
    setState(() {
      _messages.addAll(messagesAsString.map((str) {
        final parts = str.split(':');
        return {'sender': parts[0], 'text': parts.sublist(1).join(':')};
      }));
    });
  }

  void _sendMessage() async{
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({'text': _controller.text.trim(), 'sender': 'Me'});
      });
      /*
      await FirebaseFirestore.instance.collection('messages').add({
        "userID": userID,
        "chat": [{'text': _controller.text.trim(), 'sender': userID}]
      });*/
      _saveMessages();
      _controller.clear();
    }
  }

  void _pickAttachment() async{
    print("pick an attachment");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(60, 49, 43, 1.0),
      appBar: AppBar(
        title: Text(widget.kisiAdi),
        backgroundColor: const Color.fromRGBO(145, 118, 104, 1.0),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 20.0),
                  child: Align(
                    alignment: message['sender'] == 'Me' // This will change with firebase user uis
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                        
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: message['sender'] == 'Me'
                            ? widget.currentColors['msgBubbleSender']
                            : widget.currentColors['msgBubbleReciever'],
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        message['text'] ?? '',
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 15.0, top: 0.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: widget.currentColors['text']
                    ),
                    cursorColor: widget.currentColors['hintText'],
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color.fromRGBO(60, 49, 43, 0.70)
                        ),
                        borderRadius: BorderRadius.circular(35.0),
                      ),

                      filled: true,
                      fillColor: widget.currentColors['container'],
                      hintText: 'Type a message',
                      hintStyle: TextStyle(
                        color: widget.currentColors['hintText'],
                      
                      ),

                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.solid,
                          color: const Color.fromRGBO(60, 49, 43, 0.70)
                        ),
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),

                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 0.1, top: 7.0, bottom: 7.0),
                          child: ElevatedButton(
                            onPressed: _pickAttachment,
                            style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(184, 167, 148, 1), 
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12.0),
                            elevation: 0,
                            ), 
                            child: const Icon(
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(60, 49, 43, 1),
                              size: 25.0,
                              Icons.attach_file
                              ),
                          ),
                        ),
                        
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 0.1, top: 7.0, bottom: 7.0),
                        child: ElevatedButton(
                          onPressed: _sendMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(184, 167, 148, 1),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12.0),
                            elevation: 0,
                          ),
                          child: const Icon(
                            color: Color.fromRGBO(60, 49, 43, 1),
                            size: 25,
                            Icons.send
                            ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}