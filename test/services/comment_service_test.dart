import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/comment_service.dart';
import 'package:chef_specials/models/comment.dart';

/// Helper to pre-create a recipe doc so transactions can update commentCount.
Future<void> _createRecipeDoc(
  FakeFirebaseFirestore firestore,
  String recipeId, {
  int commentCount = 0,
}) async {
  await firestore.collection('recipes').doc(recipeId).set({
    'title': 'Test Recipe',
    'description': 'desc',
    'authorId': 'author1',
    'authorName': 'Chef',
    'category': 'Dinner',
    'servings': 4,
    'prepTimeMinutes': 10,
    'cookTimeMinutes': 30,
    'ingredients': [],
    'steps': [],
    'createdAt': DateTime(2024, 1, 1).toIso8601String(),
    'commentCount': commentCount,
  });
}

Comment _makeComment({
  String recipeId = 'recipe1',
  String userId = 'user1',
  String authorName = 'Chef Test',
  String text = 'Great recipe!',
  int stars = 0,
  DateTime? createdAt,
}) {
  return Comment(
    recipeId: recipeId,
    userId: userId,
    authorName: authorName,
    text: text,
    stars: stars,
    createdAt: createdAt ?? DateTime(2024, 6, 1),
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CommentService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = CommentService(firestore: fakeFirestore);
  });

  group('CommentService', () {
    group('addComment', () {
      test('should add a comment to the recipe subcollection', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        final comment = _makeComment(text: 'Looks delicious!');
        await service.addComment(comment);

        final snapshot = await fakeFirestore
            .collection('recipes')
            .doc('recipe1')
            .collection('comments')
            .get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['text'], 'Looks delicious!');
      });

      test('should increment commentCount on the recipe doc', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1', commentCount: 0);

        await service.addComment(_makeComment());

        final recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['commentCount'], 1);
      });

      test('should increment commentCount for each comment added', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1', commentCount: 0);

        await service.addComment(_makeComment(userId: 'u1', text: 'First'));
        await service.addComment(_makeComment(userId: 'u2', text: 'Second'));

        final recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['commentCount'], 2);
      });

      test('should store all comment fields correctly', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        final comment = _makeComment(
          userId: 'user42',
          authorName: 'Pro Chef',
          text: 'Amazing flavors',
          stars: 5,
        );
        await service.addComment(comment);

        final snapshot = await fakeFirestore
            .collection('recipes')
            .doc('recipe1')
            .collection('comments')
            .get();
        final data = snapshot.docs.first.data();
        expect(data['userId'], 'user42');
        expect(data['authorName'], 'Pro Chef');
        expect(data['text'], 'Amazing flavors');
        expect(data['stars'], 5);
        expect(data['recipeId'], 'recipe1');
      });
    });

    group('getCommentsStream', () {
      test('should return comments ordered by createdAt DESC', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        await service.addComment(_makeComment(
          text: 'Old comment',
          createdAt: DateTime(2024, 1, 1),
        ));
        await service.addComment(_makeComment(
          text: 'New comment',
          createdAt: DateTime(2024, 6, 1),
        ));

        final comments = await service.getCommentsStream('recipe1').first;

        expect(comments.length, 2);
        expect(comments[0].text, 'New comment');
        expect(comments[1].text, 'Old comment');
      });

      test('should return empty list when no comments exist', () async {
        final comments = await service.getCommentsStream('recipe1').first;
        expect(comments, isEmpty);
      });

      test('should only return comments for the specified recipe', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');
        await _createRecipeDoc(fakeFirestore, 'recipe2');

        await service
            .addComment(_makeComment(recipeId: 'recipe1', text: 'For R1'));
        await service
            .addComment(_makeComment(recipeId: 'recipe2', text: 'For R2'));

        final comments = await service.getCommentsStream('recipe1').first;
        expect(comments.length, 1);
        expect(comments[0].text, 'For R1');
      });
    });

    group('updateCommentText', () {
      test('should update the text and stars of a comment', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        await service.addComment(_makeComment(text: 'Original', stars: 3));

        final snapshot = await fakeFirestore
            .collection('recipes')
            .doc('recipe1')
            .collection('comments')
            .get();
        final commentId = snapshot.docs.first.id;

        await service.updateCommentText(
          commentId: commentId,
          recipeId: 'recipe1',
          newText: 'Updated text',
          newStars: 5,
        );

        final updatedDoc = await fakeFirestore
            .collection('recipes')
            .doc('recipe1')
            .collection('comments')
            .doc(commentId)
            .get();
        expect(updatedDoc.data()!['text'], 'Updated text');
        expect(updatedDoc.data()!['stars'], 5);
      });

      test('should not affect other comment fields', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        await service.addComment(_makeComment(
          userId: 'user1',
          authorName: 'Chef',
          text: 'Original',
        ));

        final snapshot = await fakeFirestore
            .collection('recipes')
            .doc('recipe1')
            .collection('comments')
            .get();
        final commentId = snapshot.docs.first.id;

        await service.updateCommentText(
          commentId: commentId,
          recipeId: 'recipe1',
          newText: 'Changed',
          newStars: 4,
        );

        final updatedDoc = await fakeFirestore
            .collection('recipes')
            .doc('recipe1')
            .collection('comments')
            .doc(commentId)
            .get();
        // Other fields should remain unchanged
        expect(updatedDoc.data()!['userId'], 'user1');
        expect(updatedDoc.data()!['authorName'], 'Chef');
      });
    });

    group('deleteComment', () {
      test('should delete the comment document', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        await service.addComment(_makeComment(text: 'To be deleted'));

        final snapshot = await fakeFirestore
            .collection('recipes')
            .doc('recipe1')
            .collection('comments')
            .get();
        final commentId = snapshot.docs.first.id;

        await service.deleteComment(
            commentId: commentId, recipeId: 'recipe1');

        final deletedDoc = await fakeFirestore
            .collection('recipes')
            .doc('recipe1')
            .collection('comments')
            .doc(commentId)
            .get();
        expect(deletedDoc.exists, isFalse);
      });

      test('should decrement commentCount on the recipe doc', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1', commentCount: 0);

        await service.addComment(_makeComment());
        await service.addComment(_makeComment(userId: 'u2', text: 'Another'));

        // commentCount should be 2
        var recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['commentCount'], 2);

        // Delete one comment
        final snapshot = await fakeFirestore
            .collection('recipes')
            .doc('recipe1')
            .collection('comments')
            .get();
        final commentId = snapshot.docs.first.id;

        await service.deleteComment(
            commentId: commentId, recipeId: 'recipe1');

        recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['commentCount'], 1);
      });
    });
  });
}
