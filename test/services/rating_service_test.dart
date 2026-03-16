import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/rating_service.dart';

/// Helper to pre-create a recipe doc so transactions can read/update it.
Future<void> _createRecipeDoc(
  FakeFirebaseFirestore firestore,
  String recipeId, {
  int ratingCount = 0,
  double averageRating = 0.0,
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
    'ratingCount': ratingCount,
    'averageRating': averageRating,
  });
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RatingService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = RatingService(firestore: fakeFirestore);
  });

  group('RatingService', () {
    group('getUserRating', () {
      test('should return null when no rating exists', () async {
        final rating = await service.getUserRating('recipe1', 'user1');
        expect(rating, isNull);
      });

      test('should return the rating when it exists', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');
        await service.setRating(
            recipeId: 'recipe1', userId: 'user1', stars: 4);

        final rating = await service.getUserRating('recipe1', 'user1');

        expect(rating, isNotNull);
        expect(rating!.stars, 4);
        expect(rating.recipeId, 'recipe1');
        expect(rating.userId, 'user1');
      });
    });

    group('setRating', () {
      test('should create a new rating and update recipe counters', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        await service.setRating(
            recipeId: 'recipe1', userId: 'user1', stars: 5);

        // Check rating doc
        final ratingDoc = await fakeFirestore
            .collection('ratings')
            .doc('recipe1_user1')
            .get();
        expect(ratingDoc.exists, isTrue);
        expect(ratingDoc.data()!['stars'], 5);

        // Check recipe counters
        final recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['ratingCount'], 1);
        expect(recipeDoc.data()!['averageRating'], 5.0);
      });

      test('should correctly average multiple ratings', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        await service.setRating(
            recipeId: 'recipe1', userId: 'user1', stars: 5);
        await service.setRating(
            recipeId: 'recipe1', userId: 'user2', stars: 3);

        final recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['ratingCount'], 2);
        expect(recipeDoc.data()!['averageRating'], 4.0);
      });

      test('should update an existing rating and recalculate average',
          () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        // Initial rating
        await service.setRating(
            recipeId: 'recipe1', userId: 'user1', stars: 3);

        // Update rating
        await service.setRating(
            recipeId: 'recipe1', userId: 'user1', stars: 5);

        // Rating count should still be 1
        final recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['ratingCount'], 1);
        expect(recipeDoc.data()!['averageRating'], 5.0);
      });

      test('should update average correctly with existing ratings', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        // Two users rate
        await service.setRating(
            recipeId: 'recipe1', userId: 'user1', stars: 4);
        await service.setRating(
            recipeId: 'recipe1', userId: 'user2', stars: 2);

        // Average should be (4+2)/2 = 3.0
        var recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['averageRating'], 3.0);

        // user1 updates from 4 to 5
        await service.setRating(
            recipeId: 'recipe1', userId: 'user1', stars: 5);

        // Average should be (3.0*2 - 4 + 5) / 2 = 3.5
        recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['ratingCount'], 2);
        expect(recipeDoc.data()!['averageRating'], 3.5);
      });
    });

    group('deleteRating', () {
      test('should delete the rating and update recipe counters', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');
        await service.setRating(
            recipeId: 'recipe1', userId: 'user1', stars: 4);

        await service.deleteRating(recipeId: 'recipe1', userId: 'user1');

        // Rating doc should be gone
        final ratingDoc = await fakeFirestore
            .collection('ratings')
            .doc('recipe1_user1')
            .get();
        expect(ratingDoc.exists, isFalse);

        // Recipe counters should be reset
        final recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['ratingCount'], 0);
        expect(recipeDoc.data()!['averageRating'], 0.0);
      });

      test('should do nothing when rating does not exist', () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        // Should not throw
        await expectLater(
          service.deleteRating(recipeId: 'recipe1', userId: 'user1'),
          completes,
        );
      });

      test('should recalculate average after deleting one of multiple ratings',
          () async {
        await _createRecipeDoc(fakeFirestore, 'recipe1');

        await service.setRating(
            recipeId: 'recipe1', userId: 'user1', stars: 5);
        await service.setRating(
            recipeId: 'recipe1', userId: 'user2', stars: 3);

        // Average is 4.0 with count 2
        // Delete user1's rating (5 stars)
        await service.deleteRating(recipeId: 'recipe1', userId: 'user1');

        final recipeDoc =
            await fakeFirestore.collection('recipes').doc('recipe1').get();
        expect(recipeDoc.data()!['ratingCount'], 1);
        // (4.0 * 2 - 5) / 1 = 3.0
        expect(recipeDoc.data()!['averageRating'], 3.0);
      });
    });
  });
}
