import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _db;

  CommentService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // Comments are stored as a subcollection: recipes/{recipeId}/comments
  // This avoids the need for a composite index on the flat collection.
  CollectionReference _commentsRef(String recipeId) =>
      _db.collection('recipes').doc(recipeId).collection('comments');

  Stream<List<Comment>> getCommentsStream(String recipeId) {
    return _commentsRef(recipeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Comment.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> addComment(Comment comment) async {
    final recipeRef = _db.collection('recipes').doc(comment.recipeId);
    final newCommentRef = _commentsRef(comment.recipeId).doc();

    await _db.runTransaction((tx) async {
      tx.set(newCommentRef, comment.toMap());
      // Only increment commentCount for top-level comments
      if (comment.parentCommentId == null) {
        tx.update(recipeRef, {
          'commentCount': FieldValue.increment(1),
        });
      }
    });
  }

  Future<void> updateCommentText({
    required String commentId,
    required String recipeId,
    required String newText,
    required int newStars,
  }) async {
    await _commentsRef(recipeId).doc(commentId).update({
      'text': newText,
      'stars': newStars,
    });
  }

  Future<void> deleteComment({
    required String commentId,
    required String recipeId,
  }) async {
    final recipeRef = _db.collection('recipes').doc(recipeId);
    final commentRef = _commentsRef(recipeId).doc(commentId);

    await _db.runTransaction((tx) async {
      tx.delete(commentRef);
      tx.update(recipeRef, {
        'commentCount': FieldValue.increment(-1),
      });
    });
  }
}
