import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:uuid/uuid.dart';

class CallService {
  
  // 1. Show the Full Screen Call UI
  static Future<void> showIncomingCall({
    required String uuid, // Use the channelId here
    required String callerName,
    required String callerId,
    required bool hasVideo,
  }) async {
    
    CallKitParams callKitParams = CallKitParams(
      id: uuid,
      nameCaller: callerName,
      appName: 'Orcanet',
      handle: callerId, // The number/ID displayed below name
      type: hasVideo ? 1 : 0, // 0 = Audio, 1 = Video
      duration: 30000, // Ring for 30 seconds then timeout
      textAccept: 'Accept',
      textDecline: 'Decline',
      
      // Android Specifics
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa', // Your brand color
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  // 2. End the call (Remove UI)
  static Future<void> endCall(String uuid) async {
    await FlutterCallkitIncoming.endCall(uuid);
  }
}