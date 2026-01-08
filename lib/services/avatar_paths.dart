import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> avatarPaths = [
  'lib/images/avatar1.png',
  'lib/images/avatar2.png',
  'lib/images/avatar3.png',
  'lib/images/avatar4.png',
];

final Map<String, int> _avatarCache = {};

Future<int> getAvatarIndex(String uid) async {
  if (uid.isEmpty) return 0;

  if (_avatarCache.containsKey(uid)) {
    return _avatarCache[uid]!;
  }

  final doc = await FirebaseFirestore.instance
      .collection('profile')
      .doc(uid)
      .get();

  final data = doc.data() as Map<String, dynamic>? ?? {};
  final index = ((data['avatarIndex'] ?? 0) as num).toInt();

  final safeIndex = index.clamp(0, avatarPaths.length - 1);
  _avatarCache[uid] = safeIndex;

  return safeIndex;
}
