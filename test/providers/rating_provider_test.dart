import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/rating_provider.dart';
import 'package:chef_specials/services/rating_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RatingService ratingService;
  late RatingProvider provider;

  const recipeId = 'recipe1';
  const userId = 'user1';

  Future<void> createRecipeDoc() async {
    await fakeFirestore.collection('recipes').doc(recipeId).set({
      'title': 'Test Recipe',
      'ratingCount': 0,
      'averageRating': 0.0,
    });
  }

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    ratingService = RatingService(firestore: fakeFirestore);
    provider = RatingProvider(ratingService: ratingService);
  });

  group('RatingProvider', () {
    test('initial state has null userRating and 0 displayStars', () {
      expect(provider.userRating, isNull);
      expect(provider.displayStars, 0);
    });

    test('loadUserRating returns null when no rating exists', () async {
      await provider.loadUserRating(recipeId, userId);

      expect(provider.userRating, isNull);
      expect(provider.displayStars, 0);
    });

    test('loadUserRating loads existing rating', () async {
      await createRecipeDoc();

      // Create a rating via the service
      await ratingService.setRating(
          recipeId: recipeId, userId: userId, stars: 4);

      await provider.loadUserRating(recipeId, userId);

      expect(provider.userRating, isNotNull);
      expect(provider.userRating!.stars, 4);
      expect(provider.displayStars, 4);
    });

    test('selectStars updates displayStars locally', () {
      provider.selectStars(3);
      expect(provider.displayStars, 3);
    });

    test('selectStars notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.selectStars(5);
      expect(notifyCount, 1);
    });

    test('submitRating saves rating to Firestore', () async {
      await createRecipeDoc();

      provider.selectStars(4);
      await provider.submitRating(recipeId: recipeId, userId: userId);

      expect(provider.userRating, isNotNull);
      expect(provider.userRating!.stars, 4);
      expect(provider.displayStars, 4);

      // Verify in Firestore
      final doc = await fakeFirestore
          .collection('ratings')
          .doc('${recipeId}_$userId')
          .get();
      expect(doc.exists, true);
      expect(doc.data()!['stars'], 4);
    });

    test('submitRating does nothing when displayStars is 0', () async {
      await createRecipeDoc();

      await provider.submitRating(recipeId: recipeId, userId: userId);

      expect(provider.userRating, isNull);
    });

    test('submitRating updates recipe averageRating and ratingCount', () async {
      await createRecipeDoc();

      provider.selectStars(5);
      await provider.submitRating(recipeId: recipeId, userId: userId);

      final recipeDoc =
          await fakeFirestore.collection('recipes').doc(recipeId).get();
      expect(recipeDoc.data()!['ratingCount'], 1);
      expect(recipeDoc.data()!['averageRating'], 5.0);
    });

    test('submitRating notifies listeners', () async {
      await createRecipeDoc();

      provider.selectStars(3);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.submitRating(recipeId: recipeId, userId: userId);
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('deleteRating removes rating from Firestore', () async {
      await createRecipeDoc();

      // First submit a rating
      provider.selectStars(4);
      await provider.submitRating(recipeId: recipeId, userId: userId);
      expect(provider.userRating, isNotNull);

      // Load it properly so userRating is set
      await provider.loadUserRating(recipeId, userId);

      await provider.deleteRating(recipeId: recipeId, userId: userId);

      expect(provider.userRating, isNull);
      expect(provider.displayStars, 0);

      // Verify deleted from Firestore
      final doc = await fakeFirestore
          .collection('ratings')
          .doc('${recipeId}_$userId')
          .get();
      expect(doc.exists, false);
    });

    test('deleteRating does nothing when userRating is null', () async {
      // No rating exists
      await provider.deleteRating(recipeId: recipeId, userId: userId);
      expect(provider.userRating, isNull);
      expect(provider.displayStars, 0);
    });

    test('deleteRating is optimistic - clears locally first', () async {
      await createRecipeDoc();

      provider.selectStars(5);
      await provider.submitRating(recipeId: recipeId, userId: userId);
      await provider.loadUserRating(recipeId, userId);

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
        if (notifyCount == 1) {
          // First notification is optimistic clear
          expect(provider.userRating, isNull);
          expect(provider.displayStars, 0);
        }
      });

      await provider.deleteRating(recipeId: recipeId, userId: userId);
    });

    test('deleteRating updates recipe counters', () async {
      await createRecipeDoc();

      provider.selectStars(4);
      await provider.submitRating(recipeId: recipeId, userId: userId);
      await provider.loadUserRating(recipeId, userId);

      await provider.deleteRating(recipeId: recipeId, userId: userId);

      final recipeDoc =
          await fakeFirestore.collection('recipes').doc(recipeId).get();
      expect(recipeDoc.data()!['ratingCount'], 0);
      expect(recipeDoc.data()!['averageRating'], 0.0);
    });

    test('loadUserRating notifies listeners', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.loadUserRating(recipeId, userId);
      expect(notifyCount, 1);
    });
  });
}
