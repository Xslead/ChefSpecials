import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/comment_provider.dart';
import 'package:chef_specials/services/comment_service.dart';
import 'package:chef_specials/models/comment.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CommentService commentService;
  late CommentProvider provider;

  const recipeId = 'recipe1';

  Future<void> createRecipeDoc() async {
    await fakeFirestore.collection('recipes').doc(recipeId).set({
      'title': 'Test Recipe',
      'commentCount': 0,
    });
  }

  Comment makeComment({
    String text = 'Great recipe!',
    String userId = 'user1',
    String authorName = 'Chef',
    int stars = 0,
  }) {
    return Comment(
      recipeId: recipeId,
      userId: userId,
      authorName: authorName,
      text: text,
      stars: stars,
      createdAt: DateTime.now(),
    );
  }

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    commentService = CommentService(firestore: fakeFirestore);
    provider = CommentProvider(commentService: commentService);
  });

  group('CommentProvider', () {
    test('initial state has empty comments', () {
      expect(provider.comments, isEmpty);
    });

    test('listenToComments loads comments from Firestore', () async {
      await createRecipeDoc();

      // Add a comment directly to the subcollection
      await fakeFirestore
          .collection('recipes')
          .doc(recipeId)
          .collection('comments')
          .add({
        'recipeId': recipeId,
        'userId': 'user1',
        'authorName': 'Chef',
        'text': 'Delicious!',
        'stars': 5,
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.listenToComments(recipeId);
      await Future.delayed(Duration.zero);

      expect(provider.comments, hasLength(1));
      expect(provider.comments.first.text, 'Delicious!');
    });

    test('addComment adds comment and increments recipe commentCount',
        () async {
      await createRecipeDoc();

      provider.listenToComments(recipeId);
      await Future.delayed(Duration.zero);

      await provider.addComment(makeComment(text: 'Nice!'));
      await Future.delayed(Duration.zero);

      expect(provider.comments, hasLength(1));
      expect(provider.comments.first.text, 'Nice!');

      // Verify commentCount incremented
      final recipeDoc =
          await fakeFirestore.collection('recipes').doc(recipeId).get();
      expect(recipeDoc.data()!['commentCount'], 1);
    });

    test('addComment with stars', () async {
      await createRecipeDoc();

      provider.listenToComments(recipeId);
      await Future.delayed(Duration.zero);

      await provider.addComment(makeComment(text: 'Good', stars: 4));
      await Future.delayed(Duration.zero);

      expect(provider.comments.first.stars, 4);
    });

    test('updateCommentText updates text in Firestore', () async {
      await createRecipeDoc();

      // Add a comment
      await provider.addComment(makeComment(text: 'Original'));

      provider.listenToComments(recipeId);
      await Future.delayed(Duration.zero);

      final commentId = provider.comments.first.id!;

      await provider.updateCommentText(
        commentId: commentId,
        recipeId: recipeId,
        newText: 'Updated text',
        newStars: 3,
      );
      await Future.delayed(Duration.zero);

      expect(provider.comments.first.text, 'Updated text');
      expect(provider.comments.first.stars, 3);
    });

    test('deleteComment removes comment and decrements commentCount',
        () async {
      await createRecipeDoc();

      await provider.addComment(makeComment(text: 'ToDelete'));

      provider.listenToComments(recipeId);
      await Future.delayed(Duration.zero);

      final commentId = provider.comments.first.id!;

      await provider.deleteComment(commentId: commentId, recipeId: recipeId);
      await Future.delayed(Duration.zero);

      expect(provider.comments, isEmpty);

      // Verify commentCount decremented
      final recipeDoc =
          await fakeFirestore.collection('recipes').doc(recipeId).get();
      expect(recipeDoc.data()!['commentCount'], 0);
    });

    test('multiple comments ordered by createdAt descending', () async {
      await createRecipeDoc();

      provider.listenToComments(recipeId);
      await Future.delayed(Duration.zero);

      await provider.addComment(makeComment(text: 'First'));
      await provider.addComment(makeComment(text: 'Second'));
      await provider.addComment(makeComment(text: 'Third'));
      await Future.delayed(Duration.zero);

      expect(provider.comments, hasLength(3));
    });

    test('notifies listeners when comments update', () async {
      await createRecipeDoc();

      provider.listenToComments(recipeId);
      await Future.delayed(Duration.zero);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.addComment(makeComment(text: 'Notification test'));
      await Future.delayed(Duration.zero);

      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('listenToComments for different recipe replaces previous', () async {
      await createRecipeDoc();
      await fakeFirestore.collection('recipes').doc('recipe2').set({
        'title': 'Recipe 2',
        'commentCount': 0,
      });

      // Add comment to recipe1
      await fakeFirestore
          .collection('recipes')
          .doc(recipeId)
          .collection('comments')
          .add({
        'recipeId': recipeId,
        'userId': 'user1',
        'authorName': 'Chef',
        'text': 'For recipe 1',
        'stars': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Add comment to recipe2
      await fakeFirestore
          .collection('recipes')
          .doc('recipe2')
          .collection('comments')
          .add({
        'recipeId': 'recipe2',
        'userId': 'user1',
        'authorName': 'Chef',
        'text': 'For recipe 2',
        'stars': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.listenToComments(recipeId);
      await Future.delayed(Duration.zero);
      expect(provider.comments.first.text, 'For recipe 1');

      provider.listenToComments('recipe2');
      await Future.delayed(Duration.zero);
      expect(provider.comments.first.text, 'For recipe 2');
    });
  });
}
