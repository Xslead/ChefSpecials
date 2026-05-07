import 'package:cloud_firestore/cloud_firestore.dart';

class BlockService {
  final FirebaseFirestore _db;

  BlockService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  String _docId(String blockerId, String blockedId) =>
      '${blockerId}_$blockedId';

  Future<void> blockUser(String blockerId, String blockedId) async {
    await _db
        .collection('blocks')
        .doc(_docId(blockerId, blockedId))
        .set({
      'blockerId': blockerId,
      'blockedId': blockedId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unblockUser(String blockerId, String blockedId) async {
    await _db
        .collection('blocks')
        .doc(_docId(blockerId, blockedId))
        .delete();
  }

  Future<bool> isBlocked(String blockerId, String blockedId) async {
    final doc = await _db
        .collection('blocks')
        .doc(_docId(blockerId, blockedId))
        .get();
    return doc.exists;
  }

  Future<List<String>> getBlockedUserIds(String userId) async {
    final snap = await _db
        .collection('blocks')
        .where('blockerId', isEqualTo: userId)
        .get();
    return snap.docs
        .map((d) => d.data()['blockedId'] as String)
        .toList();
  }
}
