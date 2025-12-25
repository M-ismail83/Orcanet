import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

Future<void> floodDatabase(int count) async {
  print("🌊 STARTING DATA FLOOD: Generating $count posts...");

  final firestore = FirebaseFirestore.instance;

  final batchLimit = 500; // Firestore allows max 500 writes per batch

  var batch = firestore.batch();

  int currentBatchCount = 0;

  // Dummy Data to mix and match

  final titles = [
    'Flutter is cool',
    'Why I love Dart',
    'Help with Gradle',
    'Orcanet Update',
    'Coffee Break'
  ];

  final subtitles = [
    'This is a test post body.',
    'Lorem ipsum dolor sit amet.',
    'Just testing the infinite scroll.',
    'Anyone else having this bug?',
    'Hello world!'
  ];

  final pods = ['Orcas', 'Dolphins', 'Whales', 'Students'];

  final tags = ['Flutter', 'Dart', 'Bug', 'Feature', 'Life', 'School'];

  final uids = [
    'NZEJ9Q6Dyeb86FoyZB2DH56Bhnf1',
    'yS8v3WFs8YPBxomgkvpZeRMSzdA2',
    '2u6hqirtZTdl7gBI85wUap9qJni1'
  ]; // Use REAL UIDs if you want profiles to load!

  final random = Random();

  for (int i = 0; i < count; i++) {
    // 1. Create a reference for a new empty document

    DocumentReference docRef = firestore.collection('posts').doc();

    // 2. Generate Random Content

    Map<String, dynamic> fakePost = {
      'title': '${titles[random.nextInt(titles.length)]} #${i + 1}',

      'subTitle': subtitles[random.nextInt(subtitles.length)],

      'podName': pods[random.nextInt(pods.length)],

      'senderUid':
          uids[random.nextInt(uids.length)], // Keeping your typo 'sednerUid'

      'tags': [
        tags[random.nextInt(tags.length)],
        tags[random.nextInt(tags.length)]
      ],

      'createdAt': FieldValue.serverTimestamp(), // CRITICAL for your sort order
    };

    // 3. Add to Batch

    batch.set(docRef, fakePost);

    currentBatchCount++;

    // 4. Commit if full (500 limit)

    if (currentBatchCount == batchLimit) {
      await batch.commit();

      batch = firestore.batch(); // Start a new box

      currentBatchCount = 0;

      print("📦 Batch sent! ($i/$count)");
    }
  }

  // 5. Commit any leftovers

  if (currentBatchCount > 0) {
    await batch.commit();
  }

  print("✅ DATA FLOOD COMPLETE!");
}
