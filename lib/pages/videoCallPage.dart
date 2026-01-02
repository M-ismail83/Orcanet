import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class VideoCallPage extends StatefulWidget {
  final String channelId;
  final String appId = "b45c5a8f53934d0a86fa5a30823097de";
  const VideoCallPage({super.key, required this.channelId});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _isInitialized = false;

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
    var cameraPermission = await Permission.camera.request();
    var micPermission = await Permission.microphone.request();

    if (!cameraPermission.isGranted || !micPermission.isGranted) return;

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
        appId: widget.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication));

    

    await _engine.joinChannel(
      token: "",
      channelId: widget.channelId,
      options: const ChannelMediaOptions(
        autoSubscribeVideo:
            true, // Automatically subscribe to all video streams
        autoSubscribeAudio:
            true, // Automatically subscribe to all audio streams
        publishCameraTrack: true, // Publish camera-captured video
        publishMicrophoneTrack: true, // Publish microphone-captured audio
        // Use clientRoleBroadcaster to act as a host or clientRoleAudience for audience
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          setState(() => _remoteUid = null);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine, // Uses the Agora engine instance
          canvas: VideoCanvas(uid: _remoteUid), // Binds the remote user's video
          connection: RtcConnection(
              channelId: widget.channelId), // Specifies the channel
        ),
      );
    } else {
      return const Text(
        'Waiting for remote user to join...',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _localVideo() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine, // Uses the Agora engine instance
        canvas: const VideoCanvas(
          uid: 0, // Specifies the local user
          renderMode:
              RenderModeType.renderModeHidden, // Sets the video rendering mode
        ),
      ),
    );
  }

  void _onEndCallButtonPressed() async {
    // Before we leave, tell the database we are done
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelId)
        .update({'status': 'ended'});

    await FlutterCallkitIncoming.endAllCalls();

    // Now close our screen
    _onCallEnd();
  }

  void _onCallEnd() {
    // This is your existing leave logic
    if (context.mounted) Navigator.pop(context);
    _engine.leaveChannel();
    _engine.release();
    
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Call"),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Center(child: _isInitialized ? _remoteVideo() : const CircularProgressIndicator()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? _localVideo()
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Row(children: [
                IconButton.filled(
                    icon: Icon(Icons.call_end),
                    onPressed: () => _onEndCallButtonPressed(),
                    color: Colors.red),
                IconButton.filled(
                    icon: Icon(Icons.camera), onPressed: _isInitialized ? _engine.switchCamera : null,
                    color: Colors.greenAccent),
              ]))
        ],
      )),
    );
  }
}
