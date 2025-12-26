import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';
import '../encryption/message_decryptor.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.kisiAdi,
    required this.currentColors,
    required this.chatId,
  });

  final String kisiAdi;
  final List receiverId;
  final Map<String, Color> currentColors;
  final String chatId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _sending = false;

  Future<void> handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);

    try {
      await sendMessage(
        senderId: _auth.currentUser!.uid,
        receiverId: widget.receiverId,
        chatId: widget.chatId,
        text: text,
      );
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Send failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(60, 49, 43, 1.0),
      appBar: AppBar(
        title: Text(widget.kisiAdi),
        backgroundColor: const Color.fromRGBO(145, 118, 104, 1.0),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_outlined),
            tooltip: 'Opens task menu',
            onPressed: () {
              showModalBottomSheet(
                elevation: 4.0,
                backgroundColor: widget.currentColors['bg'],
                context: context,
                builder: (BuildContext context) {
                  return TaskSection(currentColorsComment: widget.currentColors);
                },
              );
            },
          ),
          if (!(widget.receiverId.length >= 2))
            IconButton(
              icon: const Icon(Icons.camera),
              tooltip: 'Make calls with your friend',
              onPressed: () {
                String channelId =
                    Utilityclass().getChatId(_auth.currentUser!.uid, widget.receiverId);
                FirebaseFirestore.instance.collection('calls').doc(channelId).set({
                  'callerId': _auth.currentUser!.uid,
                  'callerName': _auth.currentUser!.displayName,
                  'receiverId': widget.receiverId,
                  'channelId': channelId,
                  'type': 'video',
                  'status': 'dialing',
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Utilityclass().navigator(context, VideoCallPage(channelId: channelId));
              },
            ),
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: 'Make calls with your friend',
            onPressed: () {
              String channelId =
                  Utilityclass().getChatId(_auth.currentUser!.uid, widget.receiverId);
              FirebaseFirestore.instance.collection('calls').doc(channelId).set({
                'callerId': _auth.currentUser!.uid,
                'callerName': _auth.currentUser!.displayName,
                'receiverId': widget.receiverId,
                'channelId': channelId,
                'type': 'audio',
                'status': 'dialing',
                'timestamp': FieldValue.serverTimestamp(),
              });
              Utilityclass().navigator(
                context,
                VoiceCallPage(channelId: channelId, starterId: _auth.currentUser!.uid),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getMessagesStream(widget.chatId),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final bool isMe = message['senderId'] == _auth.currentUser!.uid;

                    // ✅ If it's an old message (plaintext), show it safely.
                    final bool hasPlainText = message.containsKey('text') && message['text'] != null;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isMe
                              ? widget.currentColors['msgBubbleSender']
                              : widget.currentColors['msgBubbleReciever'],
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasPlainText)
                              Text(
                                message['text'].toString(),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: widget.currentColors["text"],
                                ),
                              )
                            else
                              FutureBuilder<String>(
                                future: decryptMessage(
                                  chatId: widget.chatId,
                                  message: message,
                                  currentUserId: _auth.currentUser!.uid,
                                ),
                                builder: (context, snap) {
                                  if (snap.connectionState == ConnectionState.waiting) {
                                    return Text(
                                      "Decrypting...",
                                      style: TextStyle(color: widget.currentColors["text"]),
                                    );
                                  }
                                  if (snap.hasError) {
                                    // ✅ No crash: show readable error.
                                    return Text(
                                      "🔒 Can't decrypt",
                                      style: TextStyle(color: widget.currentColors["text"]),
                                    );
                                  }
                                  return Text(
                                    snap.data ?? "🔒 Can't decrypt",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: widget.currentColors["text"],
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 4),
                            Text(
                              isMe ? "You" : message['senderName'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: widget.currentColors["text"]?.withAlpha(128),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: widget.currentColors['text']),
                    cursorColor: widget.currentColors['hintText'],
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(60, 49, 43, 0.70),
                        ),
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      filled: true,
                      fillColor: widget.currentColors['container'],
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: widget.currentColors['hintText']),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          style: BorderStyle.solid,
                          color: Color.fromRGBO(60, 49, 43, 0.70),
                        ),
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 0.1, top: 7.0, bottom: 7.0),
                        child: ElevatedButton(
                          onPressed: _sending ? null : handleSend,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(184, 167, 148, 1),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12.0),
                            elevation: 0,
                          ),
                          child: Icon(
                            Icons.send,
                            color: const Color.fromRGBO(60, 49, 43, 1),
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
