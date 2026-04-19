import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/recipe.dart';
import 'package:chef_specials/services/trending_service.dart';

Recipe _makeRecipe({
  required String id,
  String title = 'R',
  double averageRating = 0.0,
  int ratingCount = 0,
  DateTime? createdAt,
  bool isPrivate = false,
  List<String> dietaryTags = const [],
}) {
  return Recipe(
    id: id,
    title: title,
    description: '',
    authorId: 'u1',
    authorName: 'U',
    category: 'Dinner',
    servings: 2,
    prepTimeMinutes: 10,
    cookTimeMinutes: 20,
    ingredients: const [],
    steps: const [],
    createdAt: createdAt ?? DateTime(2024, 1, 1),
    averageRating: averageRating,
    ratingCount: ratingCount,
    isPrivate: isPrivate,
    dietaryTags: dietaryTags,
  );
}

Future<void> _addRecipe(FakeFirebaseFirestore db, Recipe r) async {
  // Recipe.toMap omits rating counters (they're written server-side), so
  // merge them in here so the service sees the values we set up.
  final data = {
    ...r.toMap(),
    'averageRating': r.averageRating,
    'ratingCount': r.ratingCount,
    'commentCount': r.commentCount,
  };
  await db.collection('recipes').doc(r.id).set(data);
}

Future<void> _addFavorite(
  FakeFirebaseFirestore db, {
  required String userId,
  required String recipeId,
  required DateTime createdAt,
}) async {
  await db.collection('favorites').add({
    'userId': userId,
    'recipeId': recipeId,
    'createdAt': createdAt.toIso8601String(),
  });
}

void main() {
  late FakeFirebaseFirestore firestore;
  late TrendingService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = TrendingService(firestore: firestore);
  });

  group('TrendingService.getTrendingRecipes', () {
    test('scores and sorts recipes by combined formula', () async {
      final old = DateTime.now().subtract(const Duration(days: 30));
      await _addRecipe(firestore,
          _makeRecipe(id: 'r1', averageRating: 4.0, ratingCount: 2, createdAt: old));
      await _addRecipe(firestore,
          _makeRecipe(id: 'r2', averageRating: 3.0, ratingCount: 10, createdAt: old));
      await _addRecipe(firestore,
          _makeRecipe(id: 'r3', averageRating: 5.0, ratingCount: 0, createdAt: old));

      final result = await service.getTrendingRecipes();

      // r2 score = 0 + 20 + 3 = 23
      // r1 score = 0 + 4 + 4 = 8
      // r3 score = 0 + 0 + 5 = 5
      expect(result.map((r) => r.id).toList(), ['r2', 'r1', 'r3']);
    });

    test('recentFavorites weighted x3 within time window', () async {
      final old = DateTime.now().subtract(const Duration(days: 30));
      await _addRecipe(firestore, _makeRecipe(id: 'r1', createdAt: old));
      await _addRecipe(firestore, _makeRecipe(id: 'r2', createdAt: old));

      // 3 recent favorites on r1, 0 on r2
      for (var i = 0; i < 3; i++) {
        await _addFavorite(firestore,
            userId: 'u$i',
            recipeId: 'r1',
            createdAt: DateTime.now().subtract(const Duration(days: 2)));
      }

      final result = await service.getTrendingRecipes();
      expect(result.first.id, 'r1');
    });

    test('favorites outside time window are ignored', () async {
      final old = DateTime.now().subtract(const Duration(days: 30));
      await _addRecipe(firestore, _makeRecipe(id: 'r1', createdAt: old));

      // Favorite created 20 days ago; with default 7d window it shouldn't count.
      await _addFavorite(firestore,
          userId: 'u1',
          recipeId: 'r1',
          createdAt: DateTime.now().subtract(const Duration(days: 20)));

      final result = await service.getTrendingRecipes();
      expect(result.length, 1);
      // No favorites counted → score 0.
      // Sanity: same result under 30d window would rank r1 higher.
      final result30 = await service.getTrendingRecipes(timeWindow: '30d');
      expect(result30.first.id, 'r1');
    });

    test('48h recency bonus applies to freshly created recipes', () async {
      await _addRecipe(firestore,
          _makeRecipe(id: 'r_old', averageRating: 4.0, ratingCount: 2,
              createdAt: DateTime.now().subtract(const Duration(days: 10))));
      await _addRecipe(firestore,
          _makeRecipe(id: 'r_new', averageRating: 0.0, ratingCount: 0,
              createdAt: DateTime.now().subtract(const Duration(hours: 2))));

      final result = await service.getTrendingRecipes();
      // r_old = 0 + 4 + 4 = 8; r_new = 0 + 0 + 0 + 5 = 5
      expect(result.map((r) => r.id).toList(), ['r_old', 'r_new']);

      // Boost the new recipe with a rating — should jump past r_old via bonus.
      await firestore.collection('recipes').doc('r_new').update({
        'ratingCount': 2,
        'averageRating': 4.0,
      });
      final result2 = await service.getTrendingRecipes();
      // r_new = 0 + 4 + 4 + 5 = 13 > r_old 8
      expect(result2.first.id, 'r_new');
    });

    test('excludes private recipes', () async {
      await _addRecipe(firestore,
          _makeRecipe(id: 'r_priv', ratingCount: 100, isPrivate: true));
      await _addRecipe(firestore,
          _makeRecipe(id: 'r_pub', ratingCount: 1));

      final result = await service.getTrendingRecipes();
      expect(result.map((r) => r.id).toList(), ['r_pub']);
    });

    test('respects limit parameter', () async {
      for (var i = 0; i < 15; i++) {
        await _addRecipe(firestore, _makeRecipe(id: 'r$i', ratingCount: i));
      }
      final result = await service.getTrendingRecipes(limit: 5);
      expect(result.length, 5);
    });
  });

  group('TrendingService.seasonForMonth', () {
    test('maps months to seasons correctly', () {
      expect(service.seasonForMonth(12), 'Winter');
      expect(service.seasonForMonth(1), 'Winter');
      expect(service.seasonForMonth(2), 'Winter');
      expect(service.seasonForMonth(3), 'Spring');
      expect(service.seasonForMonth(4), 'Spring');
      expect(service.seasonForMonth(5), 'Spring');
      expect(service.seasonForMonth(6), 'Summer');
      expect(service.seasonForMonth(7), 'Summer');
      expect(service.seasonForMonth(8), 'Summer');
      expect(service.seasonForMonth(9), 'Autumn');
      expect(service.seasonForMonth(10), 'Autumn');
      expect(service.seasonForMonth(11), 'Autumn');
    });
  });

  group('TrendingService.getSeasonalRecipes', () {
    test('returns only recipes tagged with the matching season', () async {
      await _addRecipe(firestore,
          _makeRecipe(id: 'r_summer', dietaryTags: ['Summer']));
      await _addRecipe(firestore,
          _makeRecipe(id: 'r_winter', dietaryTags: ['Winter']));
      await _addRecipe(firestore,
          _makeRecipe(id: 'r_both', dietaryTags: ['Summer', 'Vegan']));

      final june = await service.getSeasonalRecipes(6);
      final ids = june.map((r) => r.id).toSet();
      expect(ids, {'r_summer', 'r_both'});
    });

    test('excludes private recipes', () async {
      await _addRecipe(firestore,
          _makeRecipe(id: 'r1', dietaryTags: ['Summer'], isPrivate: true));
      await _addRecipe(firestore,
          _makeRecipe(id: 'r2', dietaryTags: ['Summer']));

      final result = await service.getSeasonalRecipes(7);
      expect(result.map((r) => r.id), ['r2']);
    });
  });

}
