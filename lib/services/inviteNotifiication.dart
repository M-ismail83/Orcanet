import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:orcanet/services/callService.dart';
import 'package:orcanet/index/pageIndex.dart';
import 'package:orcanet/index/serviceIndex.dart';

class Invitenotification {
  final dynamic context;
  const Invitenotification({required this.context});

  Future<void> showInviteNotif(String podName, String podId, String inviterName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'invite_channel', // id
      'Pod Invites', // title
      channelDescription: 'Notifications for pod invitations', // description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Pod Invitation',
      '$inviterName has invited you to join the pod "$podName".',
      platformChannelSpecifics,
      payload: podId, // You can use payload to pass the podId
    );
  }
}