import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/recipe.dart';
import 'package:chef_specials/providers/trending_provider.dart';
import 'package:chef_specials/services/trending_service.dart';

Recipe _makeRecipe({
  required String id,
  int ratingCount = 0,
  double averageRating = 0.0,
  List<String> dietaryTags = const [],
}) {
  return Recipe(
    id: id,
    title: id,
    description: '',
    authorId: 'u1',
    authorName: 'U',
    category: 'Dinner',
    servings: 2,
    prepTimeMinutes: 10,
    cookTimeMinutes: 20,
    ingredients: const [],
    steps: const [],
    createdAt: DateTime(2024, 1, 1),
    averageRating: averageRating,
    ratingCount: ratingCount,
    dietaryTags: dietaryTags,
  );
}

Future<void> _saveRecipe(FakeFirebaseFirestore db, Recipe r) async {
  final data = {
    ...r.toMap(),
    'averageRating': r.averageRating,
    'ratingCount': r.ratingCount,
    'commentCount': r.commentCount,
  };
  await db.collection('recipes').doc(r.id).set(data);
}

void main() {
  late FakeFirebaseFirestore firestore;
  late TrendingService service;
  late TrendingProvider provider;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = TrendingService(firestore: firestore);
    provider = TrendingProvider(service: service);
  });

  group('TrendingProvider', () {
    test('initial state is empty', () {
      expect(provider.trendingRecipes, isEmpty);
      expect(provider.loading, isFalse);
      expect(provider.lastRefreshed, isNull);
    });

    test('loadTrending populates trendingRecipes and timestamp', () async {
      await _saveRecipe(firestore, _makeRecipe(id: 'r1', ratingCount: 5));

      await provider.loadTrending();

      expect(provider.trendingRecipes.length, 1);
      expect(provider.trendingRecipes.first.id, 'r1');
      expect(provider.lastRefreshed, isNotNull);
      expect(provider.loading, isFalse);
    });

    test('trendingIds and rankOf reflect loaded order', () async {
      await _saveRecipe(firestore, _makeRecipe(id: 'r1', ratingCount: 1));
      await _saveRecipe(firestore, _makeRecipe(id: 'r2', ratingCount: 10));

      await provider.loadTrending();

      expect(provider.trendingIds, {'r1', 'r2'});
      expect(provider.rankOf('r2'), 1);
      expect(provider.rankOf('r1'), 2);
      expect(provider.rankOf('missing'), isNull);
    });

    test('cache prevents re-fetch within cache window', () async {
      await _saveRecipe(firestore, _makeRecipe(id: 'r1', ratingCount: 1));

      await provider.loadTrending();
      final firstRefresh = provider.lastRefreshed;

      // Add another recipe and reload; cached result should still stand.
      await _saveRecipe(firestore, _makeRecipe(id: 'r2', ratingCount: 100));

      await provider.loadTrending();
      expect(provider.trendingRecipes.length, 1);
      expect(provider.lastRefreshed, firstRefresh);
    });

    test('force=true bypasses cache and re-fetches', () async {
      await _saveRecipe(firestore, _makeRecipe(id: 'r1', ratingCount: 1));
      await provider.loadTrending();
      expect(provider.trendingRecipes.length, 1);

      await _saveRecipe(firestore, _makeRecipe(id: 'r2', ratingCount: 100));

      await provider.loadTrending(force: true);
      expect(provider.trendingRecipes.length, 2);
    });

    test('changing timeWindow re-fetches even when cache is fresh', () async {
      await _saveRecipe(firestore, _makeRecipe(id: 'r1', ratingCount: 1));

      await provider.loadTrending(timeWindow: '7d');
      expect(provider.currentTimeWindow, '7d');

      await provider.loadTrending(timeWindow: '30d');
      expect(provider.currentTimeWindow, '30d');
    });

    test('refresh forces reload of trending', () async {
      await _saveRecipe(firestore, _makeRecipe(id: 'r1', ratingCount: 1));
      await provider.loadTrending();

      await _saveRecipe(firestore, _makeRecipe(id: 'r2', ratingCount: 100));

      await provider.refresh();
      expect(provider.trendingRecipes.length, 2);
    });

    test('notifies listeners on loadTrending', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.loadTrending();
      // One notify when loading=true, one when loading=false.
      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });
}
