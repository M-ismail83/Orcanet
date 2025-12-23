import 'dart:convert';
import 'package:sodium/sodium.dart';
import 'sodium_singleton.dart';

String decryptMessage({
  required String cipherTextBase64,
  required String nonceBase64,
  required SecureKey roomKey,
}) {
  final cipherText = base64Decode(cipherTextBase64);
  final nonce = base64Decode(nonceBase64);

  final plainBytes = sodium.crypto.secretBox.openEasy(
    cipherText: cipherText,
    nonce: nonce,
    key: roomKey,
  );

  return utf8.decode(plainBytes);
}
