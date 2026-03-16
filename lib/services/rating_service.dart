import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating.dart';

class RatingService {
  final FirebaseFirestore _db;

  RatingService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  String _docId(String recipeId, String userId) => '${recipeId}_$userId';

  Future<Rating?> getUserRating(String recipeId, String userId) async {
    final doc = await _db
        .collection('ratings')
        .doc(_docId(recipeId, userId))
        .get();
    if (!doc.exists) return null;
    return Rating.fromMap(doc.data()!, doc.id);
  }

  /// Creates or updates a rating, atomically keeping recipe counters in sync.
  /// The transaction reads the rating doc to decide whether this is a new or
  /// existing rating — no client-supplied isUpdate flag needed.
  Future<void> setRating({
    required String recipeId,
    required String userId,
    required int stars,
  }) async {
    final ratingRef = _db.collection('ratings').doc(_docId(recipeId, userId));
    final recipeRef = _db.collection('recipes').doc(recipeId);

    await _db.runTransaction((tx) async {
      final ratingSnap = await tx.get(ratingRef);
      final recipeSnap = await tx.get(recipeRef);

      final data = recipeSnap.data() ?? {};
      final count = (data['ratingCount'] as int? ?? 0);
      final oldAvg = (data['averageRating'] as num?)?.toDouble() ?? 0.0;

      int newCount;
      double newAvg;

      if (ratingSnap.exists) {
        // Update: keep count, recalculate average
        final oldStars = ratingSnap.data()!['stars'] as int;
        newCount = count;
        newAvg = count > 0
            ? (oldAvg * count - oldStars + stars) / count
            : stars.toDouble();
      } else {
        // New rating
        newCount = count + 1;
        newAvg = (oldAvg * count + stars) / newCount;
      }

      tx.set(ratingRef, {
        'recipeId': recipeId,
        'userId': userId,
        'stars': stars,
        'createdAt': DateTime.now().toIso8601String(),
      });
      tx.update(recipeRef, {
        'ratingCount': newCount,
        'averageRating': newAvg,
      });
    });
  }

Future<void> deleteRating({
    required String recipeId,
    required String userId,
  }) async {
    final ratingRef = _db.collection('ratings').doc(_docId(recipeId, userId));
    final recipeRef = _db.collection('recipes').doc(recipeId);

    await _db.runTransaction((tx) async {
      final ratingSnap = await tx.get(ratingRef);
      if (!ratingSnap.exists) return;

      final recipeSnap = await tx.get(recipeRef);
      final data = recipeSnap.data() ?? {};
      final count = (data['ratingCount'] as int? ?? 0);
      final oldAvg = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
      final stars = ratingSnap.data()!['stars'] as int;

      final newCount = (count - 1).clamp(0, 999999);
      final newAvg = newCount > 0 ? (oldAvg * count - stars) / newCount : 0.0;

      tx.delete(ratingRef);
      tx.update(recipeRef, {
        'ratingCount': newCount,
        'averageRating': newAvg,
      });
    });
  }
}
