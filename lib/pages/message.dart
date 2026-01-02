import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/services/serviceIndex.dart';
import 'package:orcanet/encryption/message_decryptor.dart';

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

  final Map<String, String> _decryptedCache = {};

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
      backgroundColor: widget.currentColors['bg'],
      appBar: AppBar(
        title: Text(widget.kisiAdi),
        backgroundColor: widget.currentColors['bar'],
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
                    final messageId = messages[index].id;
                    final bool isMe =
                        message['senderId'] == _auth.currentUser!.uid;

                    final bool hasPlainText =
                        message.containsKey('text') && message['text'] != null;

                    /// ✅ Use cached decrypted message if available
                    final cachedText = _decryptedCache[messageId];

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isMe
                              ? widget.currentColors['msgBubbleSender']
                              : widget.currentColors['msgBubbleReceiver'],
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: widget.currentColors['title']!
                                  .withAlpha(100),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            width: 2.7,
                            color: isMe
                                ? widget.currentColors['mbsBorder']!.withAlpha(175)
                                : widget.currentColors['mbrBorder']!.withAlpha(175),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasPlainText)
                              Text(
                                message['text'].toString(),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: isMe
                                      ? widget.currentColors['messageSender']
                                      : widget.currentColors['messageReceiver'],
                                ),
                              )
                            else if (cachedText != null)
                              Text(
                                cachedText,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: widget.currentColors['messageSender'],
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
                                  if (snap.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox();
                                  }

                                  if (snap.hasData) {
                                    _decryptedCache[messageId] = snap.data!;
                                    return Text(
                                      snap.data!,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: isMe
                                            ? widget.currentColors['messageSender']
                                            : widget.currentColors['messageReceiver'],
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            const SizedBox(height: 4),
                            Text(
                              isMe ? "You" : widget.kisiAdi,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: isMe
                                  ?widget.currentColors['messageSender']
                                  :widget.currentColors['text']!.withAlpha(200)
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
                    cursorWidth: 3,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 3,
                          color: widget.currentColors['textFieldBorder']!,
                        ),
                        borderRadius: BorderRadius.circular(35.0),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 3,
                          color: widget.currentColors['textFieldBorder']!,
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
                          color: Color.fromRGBO(60, 49, 43, 1),
                        ),
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 0.1, top: 7.0, bottom: 7.0),
                        child: ElevatedButton(
                          onPressed: _sending ? null : handleSend,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.currentColors['bar'],
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12.0),
                            elevation: 2.5,
                          ),
                          child: Icon(
                            shadows: [
                              Shadow(
                                color: widget.currentColors['bar']!,
                                blurRadius: 3,
                              ),
                            ],
                            Icons.send,
                            color: widget.currentColors['text'],
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
