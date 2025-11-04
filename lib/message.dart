import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String kisiAdi;

  const ChatScreen({super.key, required this.kisiAdi});

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
                    alignment: message['sender'] == 'Me'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: message['sender'] == 'Me'
                            ? const Color.fromRGBO(129, 238, 205, 1)
                            : const Color.fromARGB(255, 26, 119, 86),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        message['text'] ?? '',
                        style: const TextStyle(
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: Color.fromRGBO(240, 232, 230, 0.5)),
                      
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20.0),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}