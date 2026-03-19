import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity.dart';

class ActivityService {
  final FirebaseFirestore _firestore;

  ActivityService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final String _collection = 'activities';

  Future<void> createActivity(Activity activity) async {
    await _firestore.collection(_collection).add(activity.toMap());
  }

  Stream<List<Activity>> getActivitiesStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Activity.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteOldActivities(String userId) async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('createdAt', isLessThan: cutoff.toIso8601String())
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> createFollowActivity({
    required String targetUserId,
    required String actorId,
    required String actorName,
    String? actorAvatar,
  }) async {
    final activity = Activity(
      userId: targetUserId,
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
      type: ActivityType.follow,
      createdAt: DateTime.now(),
    );
    await createActivity(activity);
  }

  Future<void> createCommentActivity({
    required String recipeAuthorId,
    required String actorId,
    required String actorName,
    String? actorAvatar,
    required String recipeId,
    required String recipeName,
    String? recipeImageUrl,
    required String commentText,
  }) async {
    if (actorId == recipeAuthorId) return;

    final activity = Activity(
      userId: recipeAuthorId,
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
      type: ActivityType.comment,
      targetId: recipeId,
      targetName: recipeName,
      targetImageUrl: recipeImageUrl,
      message: commentText,
      createdAt: DateTime.now(),
    );
    await createActivity(activity);
  }

  Future<void> createRatingActivity({
    required String recipeAuthorId,
    required String actorId,
    required String actorName,
    String? actorAvatar,
    required String recipeId,
    required String recipeName,
    String? recipeImageUrl,
    required int stars,
  }) async {
    if (actorId == recipeAuthorId) return;

    final activity = Activity(
      userId: recipeAuthorId,
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
      type: ActivityType.rating,
      targetId: recipeId,
      targetName: recipeName,
      targetImageUrl: recipeImageUrl,
      message: stars.toString(),
      createdAt: DateTime.now(),
    );
    await createActivity(activity);
  }

  Future<void> createNewRecipeActivity({
    required String recipeId,
    required String recipeName,
    String? recipeImageUrl,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required List<String> followerIds,
  }) async {
    for (var i = 0; i < followerIds.length; i += 500) {
      final batchIds = followerIds.sublist(
        i,
        i + 500 > followerIds.length ? followerIds.length : i + 500,
      );
      final batch = _firestore.batch();
      for (final followerId in batchIds) {
        final activity = Activity(
          userId: followerId,
          actorId: authorId,
          actorName: authorName,
          actorAvatar: authorAvatar,
          type: ActivityType.newRecipe,
          targetId: recipeId,
          targetName: recipeName,
          targetImageUrl: recipeImageUrl,
          createdAt: DateTime.now(),
        );
        final ref = _firestore.collection(_collection).doc();
        batch.set(ref, activity.toMap());
      }
      await batch.commit();
    }
  }
}
