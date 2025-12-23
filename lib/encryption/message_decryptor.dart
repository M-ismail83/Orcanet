import 'dart:convert';
import 'package:sodium/sodium.dart';
import 'room_key_service.dart';
import 'sodium_singleton.dart';

Future<String> decryptMessage({
  required String chatId,
  required Map<String, dynamic> message,
  required String currentUserId,
}) async {
  final cipherText = base64Decode(message['cipherText']);
  final nonce = base64Decode(message['nonce']);

  final roomKey = await getRoomKey(chatId, currentUserId);

  final decryptedBytes = sodium.crypto.secretBox.openEasy(
    cipherText: cipherText,
    nonce: nonce,
    key: roomKey,
  );

  return utf8.decode(decryptedBytes);
}
