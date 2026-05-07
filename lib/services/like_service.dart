import 'package:cloud_firestore/cloud_firestore.dart';

class LikeService {
  final FirebaseFirestore _db;

  LikeService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  String _docId(String userId, String recipeId) => '${userId}_$recipeId';

  Future<bool> isLiked(String recipeId, String userId) async {
    final doc =
        await _db.collection('likes').doc(_docId(userId, recipeId)).get();
    return doc.exists;
  }

  Future<List<String>> getLikedRecipeIds(String userId) async {
    final snap = await _db
        .collection('likes')
        .where('userId', isEqualTo: userId)
        .get();
    return snap.docs
        .map((d) => d.data()['recipeId'] as String)
        .toList();
  }

  Future<void> toggleLike(String recipeId, String userId) async {
    final docRef = _db.collection('likes').doc(_docId(userId, recipeId));
    final recipeRef = _db.collection('recipes').doc(recipeId);

    await _db.runTransaction((tx) async {
      final existing = await tx.get(docRef);
      if (existing.exists) {
        tx.delete(docRef);
        tx.update(recipeRef, {'likeCount': FieldValue.increment(-1)});
      } else {
        tx.set(docRef, {
          'userId': userId,
          'recipeId': recipeId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.update(recipeRef, {'likeCount': FieldValue.increment(1)});
      }
    });
  }
}
