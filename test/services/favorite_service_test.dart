import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/favorite_service.dart';
import 'package:chef_specials/models/favorite.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FavoriteService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = FavoriteService(firestore: fakeFirestore);
  });

  group('FavoriteService', () {
    group('toggleFavorite', () {
      test('should add a favorite when it does not exist', () async {
        await service.toggleFavorite('user1', 'recipe1');

        final snapshot = await fakeFirestore
            .collection('favorites')
            .where('userId', isEqualTo: 'user1')
            .where('recipeId', isEqualTo: 'recipe1')
            .get();

        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['userId'], 'user1');
        expect(snapshot.docs.first.data()['recipeId'], 'recipe1');
      });

      test('should remove a favorite when it already exists', () async {
        // Add first
        await service.toggleFavorite('user1', 'recipe1');

        // Toggle again should remove
        await service.toggleFavorite('user1', 'recipe1');

        final snapshot = await fakeFirestore
            .collection('favorites')
            .where('userId', isEqualTo: 'user1')
            .where('recipeId', isEqualTo: 'recipe1')
            .get();

        expect(snapshot.docs, isEmpty);
      });

      test('should toggle independently for different users', () async {
        await service.toggleFavorite('user1', 'recipe1');
        await service.toggleFavorite('user2', 'recipe1');

        final isFav1 = await service.isFavorite('user1', 'recipe1');
        final isFav2 = await service.isFavorite('user2', 'recipe1');

        expect(isFav1, isTrue);
        expect(isFav2, isTrue);

        // Toggle user1 off
        await service.toggleFavorite('user1', 'recipe1');

        final isFav1After = await service.isFavorite('user1', 'recipe1');
        final isFav2After = await service.isFavorite('user2', 'recipe1');

        expect(isFav1After, isFalse);
        expect(isFav2After, isTrue);
      });
    });

    group('isFavorite', () {
      test('should return true when favorite exists', () async {
        await service.toggleFavorite('user1', 'recipe1');

        final result = await service.isFavorite('user1', 'recipe1');
        expect(result, isTrue);
      });

      test('should return false when favorite does not exist', () async {
        final result = await service.isFavorite('user1', 'recipe1');
        expect(result, isFalse);
      });

      test('should return false for wrong user-recipe combination', () async {
        await service.toggleFavorite('user1', 'recipe1');

        final result = await service.isFavorite('user1', 'recipe2');
        expect(result, isFalse);
      });
    });

    group('getUserFavoriteIds', () {
      test('should return list of recipe IDs for a user', () async {
        await service.toggleFavorite('user1', 'recipe1');
        await service.toggleFavorite('user1', 'recipe2');
        await service.toggleFavorite('user1', 'recipe3');

        final ids = await service.getUserFavoriteIds('user1').first;

        expect(ids.length, 3);
        expect(ids, containsAll(['recipe1', 'recipe2', 'recipe3']));
      });

      test('should return empty list for user with no favorites', () async {
        final ids = await service.getUserFavoriteIds('nobody').first;
        expect(ids, isEmpty);
      });

      test('should not include other users favorites', () async {
        await service.toggleFavorite('user1', 'recipe1');
        await service.toggleFavorite('user2', 'recipe2');

        final ids = await service.getUserFavoriteIds('user1').first;
        expect(ids, ['recipe1']);
      });
    });

    group('getUserFavorites', () {
      test('should return list of Favorite objects for a user', () async {
        await service.toggleFavorite('user1', 'recipe1');
        await service.toggleFavorite('user1', 'recipe2');

        final favorites = await service.getUserFavorites('user1').first;

        expect(favorites.length, 2);
        expect(favorites, isA<List<Favorite>>());
        expect(favorites.every((f) => f.userId == 'user1'), isTrue);
      });

      test('should return empty list for user with no favorites', () async {
        final favorites = await service.getUserFavorites('nobody').first;
        expect(favorites, isEmpty);
      });

      test('should include correct recipeIds', () async {
        await service.toggleFavorite('user1', 'recipeA');
        await service.toggleFavorite('user1', 'recipeB');

        final favorites = await service.getUserFavorites('user1').first;
        final recipeIds = favorites.map((f) => f.recipeId).toList();

        expect(recipeIds, containsAll(['recipeA', 'recipeB']));
      });
    });
  });
}
