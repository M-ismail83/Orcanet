import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sodium/sodium.dart';
import 'sodium_singleton.dart';

final secureStorage = const FlutterSecureStorage();

Future<void> initializeRoomKey(
  String chatId,
  List<String> participantIds,
) async {
  // 1️⃣ Generate symmetric room key
  final roomKeySecure = sodium.crypto.secretBox.keygen();
  final roomKeyBytes = roomKeySecure.extractBytes();

  for (final uid in participantIds) {
    // 2️⃣ load public key
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final publicKeyBytes = base64Decode(userDoc['publicKey']);

    // 3️⃣ seal encrypt
    final encryptedRoomKey = sodium.crypto.box.seal(
      message: roomKeyBytes,
      publicKey: publicKeyBytes,
    );

    // 4️⃣ store in Firestore
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("keys")
        .doc(uid)
        .set({
      "encryptedKey": base64Encode(encryptedRoomKey),
    });
  }

  // free secure memory
  roomKeySecure.dispose();
}

Future<SecureKey> getRoomKey(String chatId, String uid) async {

  try {
            // 1️⃣ Load encrypted room key from Firestore
      final keyDoc = await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatId)
          .collection("keys")
          .doc(uid)
          .get();

      if (!keyDoc.exists) {
        throw Exception("No room key found for user $uid in chat $chatId");
      }

      final encryptedBase64 = keyDoc['encryptedKey'] as String;
      final encrypted = base64Decode(encryptedBase64);

      // 2️⃣ Load user's public key from Firestore
      final userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      final publicKeyBase64 = userDoc['publicKey'] as String;
      final publicKeyBytes = base64Decode(publicKeyBase64);

      // 3️⃣ Load user's private key from secure storage
      final privateKeyBase64 =
          await secureStorage.read(key: "${uid}_privateKey");
      if (privateKeyBase64 == null) {
        throw Exception("Private key not found in secure storage for user $uid");
      }
      final privateKeyBytes = base64Decode(privateKeyBase64);

      // 4️⃣ Convert private key bytes → SecureKey
      final privateKey = SecureKey.fromList(sodium, privateKeyBytes);

      // 5️⃣ Decrypt sealed room key (still bytes)
      final roomKeyBytes = sodium.crypto.box.sealOpen(
        cipherText: encrypted,
        publicKey: publicKeyBytes,
        secretKey: privateKey,
      );

      // 6️⃣ Convert room key bytes → SecureKey to use with secretBox
      final roomKey = SecureKey.fromList(sodium, roomKeyBytes);

      return roomKey;
    } catch (e) {
    throw Exception(
      "Room key mismatch. Chat must be recreated."
    );
  }
}

