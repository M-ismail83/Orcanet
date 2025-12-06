import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/messagingService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key,
      required this.receiverId,
      required this.kisiAdi,
      required this.currentColors,
      required this.chatId});

  final String kisiAdi;
  final String receiverId;
  final Map<String, Color> currentColors;
  final String chatId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void handleSend() {
    if (_controller.text.trim().isEmpty) return;

    // Call the function we defined earlier
    sendMessage(
      senderId: _auth.currentUser!.uid,
      receiverId: widget.receiverId,
      chatId: widget.chatId,
      text: _controller.text.trim(),
    );

    _controller.clear();
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
              child: StreamBuilder(
            stream: getMessagesStream(widget.chatId),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message =
                      messages[index].data() as Map<String, dynamic>;
                  bool isMe = message['senderId'] == _auth.currentUser!.uid;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isMe
                            ? widget.currentColors['msgBubbleSender']
                            : widget.currentColors['msgBubbleReciever'],
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        message['text'],
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          )),
          Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, bottom: 15.0, top: 0.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: widget.currentColors['text']),
                      cursorColor: widget.currentColors['hintText'],
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromRGBO(60, 49, 43, 0.70)),
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
                              color: const Color.fromRGBO(60, 49, 43, 0.70)),
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                              left: 0.1, top: 7.0, bottom: 7.0),
                          child: ElevatedButton(
                            onPressed: handleSend,
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
                                Icons.attach_file),
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              right: 0.1, top: 7.0, bottom: 7.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                sendMessage(
                                    senderId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    receiverId: widget.receiverId,
                                    chatId: widget.chatId,
                                    text: _controller.text);
                                _controller.clear();
                              } else {
                                BottomAppBar(
                                  color: Colors.red,
                                  child: Text('Cannot send empty message',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(184, 167, 148, 1),
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12.0),
                              elevation: 0,
                            ),
                            child: const Icon(
                                color: Color.fromRGBO(60, 49, 43, 1),
                                size: 25,
                                Icons.send),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
