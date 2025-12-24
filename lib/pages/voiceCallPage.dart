import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class VoiceCallPage extends StatefulWidget {
  final String channelId;
  final String starterId;
  final String appId = "b45c5a8f53934d0a86fa5a30823097de";
  const VoiceCallPage({super.key, required this.channelId, required this.starterId});

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  Set<int> _remoteUsers = {};
  bool _localUserJoined = false;
  bool _isInitialized = false;
  late RtcEngine _engine;

  StreamSubscription<DocumentSnapshot>? _callSubscription;

  @override
  void initState() {
    super.initState();
    initializeAgora();
    _listenForCallEnd();
  }

  void _listenForCallEnd() {
    // logic: Watch the specific document for this call
    _callSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelId)
        .snapshots()
        .listen((snapshot) {
      // If the document says "ended", leave immediately
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;
        if (data['status'] == 'ended') {
          print("--> Call ended by remote user.");
          _onCallEnd(); // Re-use your cleanup function
        }
      }
    });
  }

  Future<void> initializeAgora() async {
    try {
      var micPermission = await Permission.microphone.request();

    if (!micPermission.isGranted) return;

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
        appId: widget.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));

    await _engine.joinChannel(
      token: "",
      channelId: widget.channelId,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          if (mounted) setState(() => _localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          if (mounted) setState(() => _remoteUsers.add(remoteUid));
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          if (mounted) setState(() => _remoteUsers.remove(remoteUid));
        },
      ),
    );

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
    } catch (e) {
      debugPrint("Error initializing: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"))
        );
      }
    }
  }

  void _onEndCallButtonPressed() async {
    
    if (widget.starterId == FirebaseAuth.instance.currentUser!.uid) {
      await FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelId)
        .update({'status': 'ended'});
    }
    
    await FlutterCallkitIncoming.endAllCalls();
    _onCallEnd();
  }

  void _onCallEnd() {
    // This is your existing leave logic
    if (_isInitialized) {
      _engine.leaveChannel();
      _engine.release();
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    if (_isInitialized) {
        _engine.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Agora Voice Call'),
        ),
        body: Column(
          children: [
            Expanded(
                child: _isInitialized 
                ? GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 people per row
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                    ),
                    // Add +1 for "You" (Local User)
                    itemCount: _remoteUsers.length + 1, 
                    itemBuilder: (context, index) {
                        // First item is always YOU
                        if (index == 0) {
                            return _buildUserAvatar("Me", true);
                        }
                        // Other items are Remote Users
                        // (index - 1) because index 0 is taken
                        int uid = _remoteUsers.elementAt(index - 1);
                        return _buildUserAvatar("User $uid", false);
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
              ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  IconButton.filled(
                      icon: Icon(Icons.call_end),
                      onPressed: () => _onEndCallButtonPressed(),
                      color: Colors.red,
                      style: ButtonStyle(
                        iconSize: WidgetStateProperty.all(40.0),
                      ),)
                ]))
          ],
        ));
  }

  Widget _buildUserAvatar(String label, bool isMe) {
      return Container(
          decoration: BoxDecoration(
              color: isMe ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
              border: isMe ? Border.all(color: Colors.blue, width: 2) : null,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  CircleAvatar(
                      radius: 30,
                      backgroundColor: isMe ? Colors.blue : Colors.grey,
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  // Audio waves animation could go here later
                  const Icon(Icons.graphic_eq, size: 16, color: Colors.green),
              ],
          ),
      );
  }
}
