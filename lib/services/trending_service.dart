import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class TrendingService {
  final FirebaseFirestore _firestore;

  TrendingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _recipesRef =>
      _firestore.collection('recipes');

  CollectionReference<Map<String, dynamic>> get _favoritesRef =>
      _firestore.collection('favorites');

  Duration _windowDuration(String timeWindow) {
    switch (timeWindow) {
      case '30d':
        return const Duration(days: 30);
      case 'all':
        return const Duration(days: 365 * 100);
      case '7d':
      default:
        return const Duration(days: 7);
    }
  }

  /// Computes trending recipes from existing recipe + favorite data.
  /// Score = (recentFavorites × 3) + (ratingCount × 2) + (averageRating × 1)
  /// + 5 if created within the last 48 hours.
  Future<List<Recipe>> getTrendingRecipes({
    int limit = 10,
    String timeWindow = '7d',
  }) async {
    final now = DateTime.now();
    final windowStart = now.subtract(_windowDuration(timeWindow));

    final recipeSnap = await _recipesRef.get();
    final recipes = <Recipe>[];
    for (final doc in recipeSnap.docs) {
      try {
        final recipe = Recipe.fromMap(doc.data(), doc.id);
        if (!recipe.isPrivate) recipes.add(recipe);
      } catch (_) {}
    }

    final favoriteCounts = <String, int>{};
    final favoriteSnap = await _favoritesRef.get();
    for (final doc in favoriteSnap.docs) {
      final data = doc.data();
      final recipeId = data['recipeId'] as String?;
      final createdAtStr = data['createdAt'] as String?;
      if (recipeId == null || createdAtStr == null) continue;
      try {
        final createdAt = DateTime.parse(createdAtStr);
        if (createdAt.isAfter(windowStart)) {
          favoriteCounts[recipeId] = (favoriteCounts[recipeId] ?? 0) + 1;
        }
      } catch (_) {}
    }

    final scored = recipes.map((r) {
      final recentFavorites = favoriteCounts[r.id] ?? 0;
      final recencyBonus =
          now.difference(r.createdAt) < const Duration(hours: 48) ? 5.0 : 0.0;
      final score = (recentFavorites * 3) +
          (r.ratingCount * 2) +
          r.averageRating +
          recencyBonus;
      return MapEntry(r, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((e) => e.key).toList();
  }

  /// Maps a 1-12 month number to the matching season tag.
  String seasonForMonth(int month) {
    if (month == 12 || month == 1 || month == 2) return 'Winter';
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    return 'Autumn';
  }

  Future<List<Recipe>> getSeasonalRecipes(
    int month, {
    int limit = 10,
  }) async {
    final season = seasonForMonth(month);
    final snap = await _recipesRef
        .where('dietaryTags', arrayContains: season)
        .get();
    final recipes = <Recipe>[];
    for (final doc in snap.docs) {
      try {
        final recipe = Recipe.fromMap(doc.data(), doc.id);
        if (!recipe.isPrivate) recipes.add(recipe);
      } catch (_) {}
    }
    recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recipes.take(limit).toList();
  }

}
