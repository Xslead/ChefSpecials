import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  final FirebaseFirestore _db;

  FollowService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  String _docId(String followerId, String followedId) =>
      '${followerId}_$followedId';

  Future<void> follow(String followerId, String followedId) async {
    final batch = _db.batch();
    batch.set(
      _db.collection('follows').doc(_docId(followerId, followedId)),
      {
        'followerId': followerId,
        'followedId': followedId,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
    batch.update(_db.collection('users').doc(followerId),
        {'followingCount': FieldValue.increment(1)});
    batch.update(_db.collection('users').doc(followedId),
        {'followersCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> unfollow(String followerId, String followedId) async {
    final batch = _db.batch();
    batch.delete(
        _db.collection('follows').doc(_docId(followerId, followedId)));
    batch.update(_db.collection('users').doc(followerId),
        {'followingCount': FieldValue.increment(-1)});
    batch.update(_db.collection('users').doc(followedId),
        {'followersCount': FieldValue.increment(-1)});
    await batch.commit();
  }

  Stream<List<String>> watchFollowingIds(String userId) {
    return _db
        .collection('follows')
        .where('followerId', isEqualTo: userId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => d.data()['followedId'] as String).toList());
  }

  Future<List<String>> getFollowerIds(String userId) async {
    final snap = await _db
        .collection('follows')
        .where('followedId', isEqualTo: userId)
        .get();
    return snap.docs.map((d) => d.data()['followerId'] as String).toList();
  }

  Future<List<String>> getFollowingIds(String userId) async {
    final snap = await _db
        .collection('follows')
        .where('followerId', isEqualTo: userId)
        .get();
    return snap.docs.map((d) => d.data()['followedId'] as String).toList();
  }
}
