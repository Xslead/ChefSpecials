import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/favorite_provider.dart';
import 'package:chef_specials/services/favorite_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FavoriteService favoriteService;
  late FavoriteProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    favoriteService = FavoriteService(firestore: fakeFirestore);
    provider = FavoriteProvider(favoriteService: favoriteService);
  });

  group('FavoriteProvider', () {
    test('initial state has empty favorite ids', () {
      expect(provider.favoriteRecipeIds, isEmpty);
    });

    test('isFavorite returns false for unknown recipe', () {
      expect(provider.isFavorite('recipe1'), false);
    });

    test('listenToFavorites loads user favorites from Firestore', () async {
      // Pre-populate a favorite
      await fakeFirestore.collection('favorites').add({
        'userId': 'user1',
        'recipeId': 'recipe1',
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.listenToFavorites('user1');
      await Future.delayed(Duration.zero);

      expect(provider.favoriteRecipeIds, contains('recipe1'));
      expect(provider.isFavorite('recipe1'), true);
    });

    test('listenToFavorites ignores other users favorites', () async {
      await fakeFirestore.collection('favorites').add({
        'userId': 'user2',
        'recipeId': 'recipe_other',
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.listenToFavorites('user1');
      await Future.delayed(Duration.zero);

      expect(provider.favoriteRecipeIds, isEmpty);
      expect(provider.isFavorite('recipe_other'), false);
    });

    test('listenToFavorites does not re-subscribe for same user', () async {
      provider.listenToFavorites('user1');
      provider.listenToFavorites('user1'); // should be no-op
      await Future.delayed(Duration.zero);

      expect(provider.favoriteRecipeIds, isEmpty);
    });

    test('listenToFavorites re-subscribes for different user', () async {
      await fakeFirestore.collection('favorites').add({
        'userId': 'user1',
        'recipeId': 'r1',
        'createdAt': DateTime.now().toIso8601String(),
      });
      await fakeFirestore.collection('favorites').add({
        'userId': 'user2',
        'recipeId': 'r2',
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.listenToFavorites('user1');
      await Future.delayed(Duration.zero);
      expect(provider.isFavorite('r1'), true);

      provider.listenToFavorites('user2');
      await Future.delayed(Duration.zero);
      expect(provider.isFavorite('r2'), true);
      expect(provider.isFavorite('r1'), false);
    });

    test('toggleFavorite adds a favorite', () async {
      provider.listenToFavorites('user1');
      await Future.delayed(Duration.zero);

      await provider.toggleFavorite('recipe1');
      await Future.delayed(Duration.zero);

      expect(provider.isFavorite('recipe1'), true);
    });

    test('toggleFavorite removes an existing favorite', () async {
      // Add initial favorite
      await fakeFirestore.collection('favorites').add({
        'userId': 'user1',
        'recipeId': 'recipe1',
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.listenToFavorites('user1');
      await Future.delayed(Duration.zero);
      expect(provider.isFavorite('recipe1'), true);

      // Toggle to remove
      await provider.toggleFavorite('recipe1');
      await Future.delayed(Duration.zero);

      expect(provider.isFavorite('recipe1'), false);
    });

    test('toggleFavorite does nothing when userId is null', () async {
      // Don't call listenToFavorites, so _userId is null
      await provider.toggleFavorite('recipe1');
      expect(provider.favoriteRecipeIds, isEmpty);
    });

    test('notifies listeners when favorites update via stream', () async {
      provider.listenToFavorites('user1');
      await Future.delayed(Duration.zero);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await fakeFirestore.collection('favorites').add({
        'userId': 'user1',
        'recipeId': 'recipe_new',
        'createdAt': DateTime.now().toIso8601String(),
      });
      await Future.delayed(Duration.zero);

      expect(notifyCount, greaterThanOrEqualTo(1));
      expect(provider.isFavorite('recipe_new'), true);
    });

    test('multiple favorites tracked correctly', () async {
      await fakeFirestore.collection('favorites').add({
        'userId': 'user1',
        'recipeId': 'r1',
        'createdAt': DateTime.now().toIso8601String(),
      });
      await fakeFirestore.collection('favorites').add({
        'userId': 'user1',
        'recipeId': 'r2',
        'createdAt': DateTime.now().toIso8601String(),
      });
      await fakeFirestore.collection('favorites').add({
        'userId': 'user1',
        'recipeId': 'r3',
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.listenToFavorites('user1');
      await Future.delayed(Duration.zero);

      expect(provider.favoriteRecipeIds, hasLength(3));
      expect(provider.isFavorite('r1'), true);
      expect(provider.isFavorite('r2'), true);
      expect(provider.isFavorite('r3'), true);
    });
  });
}
