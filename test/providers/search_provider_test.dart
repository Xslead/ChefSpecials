import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chef_specials/providers/search_provider.dart';
import 'package:chef_specials/services/recipe_service.dart';
import 'package:chef_specials/models/recipe.dart';
import 'package:chef_specials/models/ingredient.dart';

Recipe _makeRecipe({
  String title = 'Test Recipe',
  String category = 'Breakfast',
  String authorName = 'Chef',
  String description = 'A test recipe',
  List<String> dietaryTags = const [],
  int prepTimeMinutes = 10,
  int cookTimeMinutes = 20,
  int? caloriesPerServing,
  double averageRating = 0.0,
  int ratingCount = 0,
  int commentCount = 0,
  List<Ingredient> ingredients = const [],
  DateTime? createdAt,
}) {
  return Recipe(
    title: title,
    description: description,
    authorId: 'user1',
    authorName: authorName,
    category: category,
    servings: 2,
    prepTimeMinutes: prepTimeMinutes,
    cookTimeMinutes: cookTimeMinutes,
    ingredients: ingredients,
    steps: [],
    createdAt: createdAt ?? DateTime.now(),
    dietaryTags: dietaryTags,
    caloriesPerServing: caloriesPerServing,
    averageRating: averageRating,
    ratingCount: ratingCount,
    commentCount: commentCount,
  );
}

Ingredient _ing(String name) =>
    Ingredient(name: name, amount: '1', unit: 'piece');

// Writes a recipe directly to Firestore including stats fields that Recipe.toMap() omits.
Future<void> _addRecipeDirect(
  FakeFirebaseFirestore firestore,
  Recipe recipe, {
  int ratingCount = 0,
  int commentCount = 0,
  double averageRating = 0.0,
}) async {
  await firestore.collection('recipes').add({
    ...recipe.toMap(),
    'ratingCount': ratingCount,
    'commentCount': commentCount,
    'averageRating': averageRating,
  });
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RecipeService recipeService;
  late SearchProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeFirestore = FakeFirebaseFirestore();
    recipeService = RecipeService(firestore: fakeFirestore);
    provider = SearchProvider(recipeService: recipeService);
  });

  // ─────────────────────────────────────────────
  // Existing tests
  // ─────────────────────────────────────────────
  group('SearchProvider — basic search', () {
    test('initial state', () {
      expect(provider.query, '');
      expect(provider.results, isEmpty);
      expect(provider.isLoading, false);
    });

    test('loadRecipes loads all recipes from Firestore', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'Pancakes'));
      await recipeService.createRecipe(_makeRecipe(title: 'Omelette'));

      await provider.loadRecipes();

      expect(provider.results, hasLength(2));
      expect(provider.isLoading, false);
    });

    test('loadRecipes notifies listeners', () async {
      await recipeService.createRecipe(_makeRecipe());

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.loadRecipes();
      expect(notifyCount, greaterThanOrEqualTo(2));
    });

    test('search filters by title', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'Pancakes'));
      await recipeService.createRecipe(_makeRecipe(title: 'Omelette'));
      await recipeService.createRecipe(_makeRecipe(title: 'Pasta'));

      await provider.loadRecipes();

      provider.search('pan');
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'Pancakes');
      expect(provider.query, 'pan');
    });

    test('search filters by category', () async {
      await recipeService
          .createRecipe(_makeRecipe(title: 'Eggs', category: 'Breakfast'));
      await recipeService
          .createRecipe(_makeRecipe(title: 'Pasta', category: 'Dinner'));

      await provider.loadRecipes();

      provider.search('dinner');
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'Pasta');
    });

    test('search filters by authorName', () async {
      await recipeService
          .createRecipe(_makeRecipe(title: 'Eggs', authorName: 'Alice'));
      await recipeService
          .createRecipe(_makeRecipe(title: 'Pasta', authorName: 'Bob'));

      await provider.loadRecipes();

      provider.search('alice');
      expect(provider.results, hasLength(1));
      expect(provider.results.first.authorName, 'Alice');
    });

    test('search filters by description', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'A', description: 'Healthy and delicious'));
      await recipeService
          .createRecipe(_makeRecipe(title: 'B', description: 'Quick and easy'));

      await provider.loadRecipes();

      provider.search('healthy');
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'A');
    });

    test('search filters by dietaryTags', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'Salad', dietaryTags: ['vegan', 'gluten-free']));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Steak', dietaryTags: ['high-protein']));

      await provider.loadRecipes();

      provider.search('vegan');
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'Salad');
    });

    test('search with empty query returns all recipes', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'Pancakes'));
      await recipeService.createRecipe(_makeRecipe(title: 'Omelette'));

      await provider.loadRecipes();

      provider.search('pancakes');
      expect(provider.results, hasLength(1));

      provider.search('');
      expect(provider.results, hasLength(2));
    });

    test('search is case insensitive', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'PANCAKES'));

      await provider.loadRecipes();

      provider.search('pancakes');
      expect(provider.results, hasLength(1));

      provider.search('PANCAKES');
      expect(provider.results, hasLength(1));
    });

    test('search notifies listeners', () async {
      await recipeService.createRecipe(_makeRecipe());
      await provider.loadRecipes();

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.search('test');
      expect(notifyCount, 1);
    });

    test('clear resets query and shows all recipes', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'Pancakes'));
      await recipeService.createRecipe(_makeRecipe(title: 'Omelette'));

      await provider.loadRecipes();

      provider.search('pancakes');
      expect(provider.results, hasLength(1));

      provider.clear();
      expect(provider.query, '');
      expect(provider.results, hasLength(2));
    });

    test('clear notifies listeners', () async {
      await recipeService.createRecipe(_makeRecipe());
      await provider.loadRecipes();

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.clear();
      expect(notifyCount, 1);
    });

    test('search with no matches returns empty list', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'Pancakes'));

      await provider.loadRecipes();

      provider.search('zzzzzzz');
      expect(provider.results, isEmpty);
    });
  });

  // ─────────────────────────────────────────────
  // Cook time filter
  // ─────────────────────────────────────────────
  group('SearchProvider — cook time filter', () {
    test('filters by cook time range', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'Quick', cookTimeMinutes: 10));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Long', cookTimeMinutes: 90));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: const RangeValues(0, 30),
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'Quick');
    });

    test('120+ upper bound means no upper limit', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'VeryLong', cookTimeMinutes: 200));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Short', cookTimeMinutes: 5));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: const RangeValues(60, 120),
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      // 200 min should still match since end==120 means no upper limit
      expect(provider.results.any((r) => r.title == 'VeryLong'), isTrue);
      expect(provider.results.any((r) => r.title == 'Short'), isFalse);
    });

    test('null cook time range shows all', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'A', cookTimeMinutes: 5));
      await recipeService.createRecipe(
          _makeRecipe(title: 'B', cookTimeMinutes: 120));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      expect(provider.results, hasLength(2));
    });
  });

  // ─────────────────────────────────────────────
  // Calorie range filter
  // ─────────────────────────────────────────────
  group('SearchProvider — calorie range filter', () {
    test('filters by calorie range', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'LowCal', caloriesPerServing: 200));
      await recipeService.createRecipe(
          _makeRecipe(title: 'HighCal', caloriesPerServing: 800));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: const RangeValues(0, 400),
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'LowCal');
    });

    test('1000+ calorie upper bound means no upper limit', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'UltraHighCal', caloriesPerServing: 5000));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: const RangeValues(0, 1000),
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      expect(provider.results.any((r) => r.title == 'UltraHighCal'), isTrue);
    });

    test('recipes without calories pass through calorie filter with 0 cal',
        () async {
      await recipeService
          .createRecipe(_makeRecipe(title: 'NoCal', caloriesPerServing: null));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: const RangeValues(0, 500),
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      // null calories is treated as 0
      expect(provider.results.any((r) => r.title == 'NoCal'), isTrue);
    });
  });

  // ─────────────────────────────────────────────
  // Difficulty filter
  // ─────────────────────────────────────────────
  group('SearchProvider — difficulty filter', () {
    test('filters by Easy difficulty (total time <= 20 min)', () async {
      // Easy: prep+cook <= 20
      await recipeService.createRecipe(
          _makeRecipe(title: 'EasyDish', prepTimeMinutes: 5, cookTimeMinutes: 10));
      // Medium: prep+cook 21-45
      await recipeService.createRecipe(
          _makeRecipe(title: 'MediumDish', prepTimeMinutes: 10, cookTimeMinutes: 25));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: 'Easy',
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'EasyDish');
    });

    test('filters by Medium difficulty', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'Easy', prepTimeMinutes: 5, cookTimeMinutes: 10));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Medium', prepTimeMinutes: 10, cookTimeMinutes: 30));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Hard', prepTimeMinutes: 20, cookTimeMinutes: 60));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: 'Medium',
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'Medium');
    });

    test('filters by Hard difficulty (total time > 45 min)', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'Easy', prepTimeMinutes: 5, cookTimeMinutes: 10));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Hard', prepTimeMinutes: 20, cookTimeMinutes: 60));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: 'Hard',
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'Hard');
    });

    test('null difficulty shows all recipes', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'A'));
      await recipeService.createRecipe(_makeRecipe(title: 'B'));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      expect(provider.results, hasLength(2));
    });
  });

  // ─────────────────────────────────────────────
  // Max ingredients filter
  // ─────────────────────────────────────────────
  group('SearchProvider — max ingredients filter', () {
    test('filters by max ingredient count', () async {
      await recipeService.createRecipe(_makeRecipe(
        title: 'Simple',
        ingredients: [_ing('egg'), _ing('salt')],
      ));
      await recipeService.createRecipe(_makeRecipe(
        title: 'Complex',
        ingredients: [
          _ing('a'), _ing('b'), _ing('c'),
          _ing('d'), _ing('e'), _ing('f'),
        ],
      ));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: 3,
        sortBy: 'newest',
      );
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'Simple');
    });

    test('null max ingredients shows all recipes', () async {
      await recipeService.createRecipe(_makeRecipe(
        title: 'A', ingredients: [_ing('x'), _ing('y')],
      ));
      await recipeService.createRecipe(_makeRecipe(
        title: 'B',
        ingredients: List.generate(10, (i) => _ing('ing$i')),
      ));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      expect(provider.results, hasLength(2));
    });
  });

  // ─────────────────────────────────────────────
  // Sort options
  // ─────────────────────────────────────────────
  group('SearchProvider — sort options', () {
    test('sort by newest (default)', () async {
      final old = DateTime(2023, 1, 1);
      final recent = DateTime(2024, 6, 1);
      await recipeService
          .createRecipe(_makeRecipe(title: 'Old', createdAt: old));
      await recipeService
          .createRecipe(_makeRecipe(title: 'Recent', createdAt: recent));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      expect(provider.results.first.title, 'Recent');
    });

    test('sort by popular (ratingCount + commentCount)', () async {
      await _addRecipeDirect(fakeFirestore, _makeRecipe(title: 'Popular'),
          ratingCount: 100, commentCount: 50);
      await _addRecipeDirect(fakeFirestore, _makeRecipe(title: 'Unpopular'),
          ratingCount: 1, commentCount: 0);

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'popular',
      );
      expect(provider.results.first.title, 'Popular');
    });

    test('sort by rating (averageRating desc)', () async {
      await _addRecipeDirect(fakeFirestore, _makeRecipe(title: 'TopRated'),
          averageRating: 4.9);
      await _addRecipeDirect(fakeFirestore, _makeRecipe(title: 'LowRated'),
          averageRating: 2.0);

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'rating',
      );
      expect(provider.results.first.title, 'TopRated');
    });

    test('sort by cookTime (ascending)', () async {
      await recipeService
          .createRecipe(_makeRecipe(title: 'Fast', cookTimeMinutes: 5));
      await recipeService
          .createRecipe(_makeRecipe(title: 'Slow', cookTimeMinutes: 90));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'cookTime',
      );
      expect(provider.results.first.title, 'Fast');
    });

    test('sort by calories (ascending)', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'LowCal', caloriesPerServing: 100));
      await recipeService.createRecipe(
          _makeRecipe(title: 'HighCal', caloriesPerServing: 900));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'calories',
      );
      expect(provider.results.first.title, 'LowCal');
    });
  });

  // ─────────────────────────────────────────────
  // clearFilters
  // ─────────────────────────────────────────────
  group('SearchProvider — clearFilters', () {
    test('clearFilters resets all filter state', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'A'));
      await recipeService.createRecipe(
          _makeRecipe(title: 'B', cookTimeMinutes: 90));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: const RangeValues(0, 30),
        calorieRange: null,
        difficultyLevel: 'Easy',
        maxIngredientCount: 5,
        sortBy: 'rating',
      );

      provider.clearFilters();

      expect(provider.cookTimeRange, isNull);
      expect(provider.difficultyLevel, isNull);
      expect(provider.maxIngredientCount, isNull);
      expect(provider.sortBy, 'newest');
      expect(provider.activeFilterCount, 0);
    });

    test('activeFilterCount counts correctly', () async {
      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: const RangeValues(0, 60),
        calorieRange: const RangeValues(0, 500),
        difficultyLevel: 'Easy',
        maxIngredientCount: 5,
        sortBy: 'rating',
      );
      expect(provider.activeFilterCount, 5);

      provider.clearFilters();
      expect(provider.activeFilterCount, 0);
    });
  });

  // ─────────────────────────────────────────────
  // Multi-filter combos
  // ─────────────────────────────────────────────
  group('SearchProvider — multi-filter combos', () {
    test('query + cookTime filter combined', () async {
      await recipeService.createRecipe(_makeRecipe(
          title: 'Quick Pasta', category: 'Dinner', cookTimeMinutes: 15));
      await recipeService.createRecipe(_makeRecipe(
          title: 'Long Pasta', category: 'Dinner', cookTimeMinutes: 90));
      await recipeService.createRecipe(_makeRecipe(
          title: 'Quick Soup', category: 'Soup', cookTimeMinutes: 10));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: const RangeValues(0, 20),
        calorieRange: null,
        difficultyLevel: null,
        maxIngredientCount: null,
        sortBy: 'newest',
      );
      provider.search('pasta');

      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'Quick Pasta');
    });

    test('difficulty + max ingredients combined', () async {
      await recipeService.createRecipe(_makeRecipe(
        title: 'SimpleEasy',
        prepTimeMinutes: 5,
        cookTimeMinutes: 10,
        ingredients: [_ing('egg')],
      ));
      await recipeService.createRecipe(_makeRecipe(
        title: 'ComplexEasy',
        prepTimeMinutes: 5,
        cookTimeMinutes: 10,
        ingredients: List.generate(8, (i) => _ing('ing$i')),
      ));
      await recipeService.createRecipe(_makeRecipe(
        title: 'SimpleMedium',
        prepTimeMinutes: 15,
        cookTimeMinutes: 20,
        ingredients: [_ing('egg')],
      ));

      await provider.loadRecipes();

      provider.applyFilters(
        cookTimeRange: null,
        calorieRange: null,
        difficultyLevel: 'Easy',
        maxIngredientCount: 3,
        sortBy: 'newest',
      );
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'SimpleEasy');
    });
  });

  // ─────────────────────────────────────────────
  // Search history
  // ─────────────────────────────────────────────
  group('SearchProvider — search history', () {
    test('loadHistory loads empty list initially', () async {
      await provider.loadHistory();
      expect(provider.searchHistory, isEmpty);
    });

    test('commitSearch adds to history', () async {
      await provider.loadHistory();
      await provider.commitSearch('chicken');
      expect(provider.searchHistory, contains('chicken'));
    });

    test('commitSearch trims whitespace and skips empty', () async {
      await provider.loadHistory();
      await provider.commitSearch('  ');
      expect(provider.searchHistory, isEmpty);
    });

    test('commitSearch keeps most recent first', () async {
      await provider.loadHistory();
      await provider.commitSearch('apple');
      await provider.commitSearch('banana');
      expect(provider.searchHistory.first, 'banana');
    });

    test('commitSearch deduplicates — moves existing to front', () async {
      await provider.loadHistory();
      await provider.commitSearch('chicken');
      await provider.commitSearch('pasta');
      await provider.commitSearch('chicken');
      expect(provider.searchHistory.first, 'chicken');
      expect(provider.searchHistory.where((h) => h == 'chicken').length, 1);
    });

    test('history is capped at 10 entries', () async {
      await provider.loadHistory();
      for (var i = 0; i < 15; i++) {
        await provider.commitSearch('query$i');
      }
      expect(provider.searchHistory.length, 10);
    });

    test('removeFromHistory removes entry', () async {
      await provider.loadHistory();
      await provider.commitSearch('chicken');
      await provider.commitSearch('pasta');

      await provider.removeFromHistory('chicken');

      expect(provider.searchHistory, isNot(contains('chicken')));
      expect(provider.searchHistory, contains('pasta'));
    });

    test('history persists across provider instances', () async {
      await provider.loadHistory();
      await provider.commitSearch('storedQuery');

      final provider2 = SearchProvider(recipeService: recipeService);
      await provider2.loadHistory();
      expect(provider2.searchHistory, contains('storedQuery'));
    });
  });

  // ─────────────────────────────────────────────
  // Suggestions
  // ─────────────────────────────────────────────
  group('SearchProvider — suggestions', () {
    test('no suggestions for query shorter than 2 chars', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'Pancakes'));
      await provider.loadRecipes();

      provider.search('p');
      expect(provider.suggestions, isEmpty);
    });

    test('suggestions match recipe titles', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'Pancakes'));
      await recipeService.createRecipe(_makeRecipe(title: 'Pasta'));
      await recipeService.createRecipe(_makeRecipe(title: 'Omelette'));
      await provider.loadRecipes();

      provider.search('pa');
      expect(provider.suggestions, contains('Pancakes'));
      expect(provider.suggestions, contains('Pasta'));
      expect(provider.suggestions, isNot(contains('Omelette')));
    });

    test('suggestions include matching history entries', () async {
      await provider.loadHistory();
      await provider.commitSearch('pasta bolognese');

      await recipeService.createRecipe(_makeRecipe(title: 'Pancakes'));
      await provider.loadRecipes();

      provider.search('pas');
      expect(provider.suggestions, contains('pasta bolognese'));
    });

    test('clear resets suggestions', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'Pancakes'));
      await provider.loadRecipes();

      provider.search('pan');
      expect(provider.suggestions, isNotEmpty);

      provider.clear();
      expect(provider.suggestions, isEmpty);
    });
  });

  // ─────────────────────────────────────────────
  // Ingredient-based search
  // ─────────────────────────────────────────────
  group('SearchProvider — ingredient mode', () {
    test('setIngredientMode switches mode', () async {
      await provider.loadRecipes();

      expect(provider.isIngredientMode, isFalse);
      provider.setIngredientMode(true);
      expect(provider.isIngredientMode, isTrue);
    });

    test('addIngredient adds to filter list', () async {
      await provider.loadRecipes();
      provider.setIngredientMode(true);

      provider.addIngredient('chicken');
      expect(provider.ingredientFilters, contains('chicken'));
    });

    test('addIngredient ignores duplicates', () async {
      await provider.loadRecipes();
      provider.setIngredientMode(true);

      provider.addIngredient('chicken');
      provider.addIngredient('chicken');
      expect(provider.ingredientFilters.length, 1);
    });

    test('addIngredient ignores empty string', () async {
      await provider.loadRecipes();
      provider.setIngredientMode(true);

      provider.addIngredient('  ');
      expect(provider.ingredientFilters, isEmpty);
    });

    test('removeIngredient removes entry', () async {
      await provider.loadRecipes();
      provider.setIngredientMode(true);

      provider.addIngredient('chicken');
      provider.addIngredient('garlic');
      provider.removeIngredient('chicken');
      expect(provider.ingredientFilters, isNot(contains('chicken')));
      expect(provider.ingredientFilters, contains('garlic'));
    });

    test('ingredient search returns recipes containing ALL ingredients',
        () async {
      await recipeService.createRecipe(_makeRecipe(
        title: 'Chicken Soup',
        ingredients: [_ing('chicken'), _ing('onion'), _ing('garlic')],
      ));
      await recipeService.createRecipe(_makeRecipe(
        title: 'Pasta',
        ingredients: [_ing('pasta'), _ing('garlic'), _ing('tomato')],
      ));
      await recipeService.createRecipe(_makeRecipe(
        title: 'Salad',
        ingredients: [_ing('lettuce'), _ing('tomato')],
      ));

      await provider.loadRecipes();
      provider.setIngredientMode(true);

      provider.addIngredient('chicken');
      provider.addIngredient('garlic');

      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'Chicken Soup');
    });

    test('ingredient search is case insensitive', () async {
      await recipeService.createRecipe(_makeRecipe(
        title: 'Dish',
        ingredients: [_ing('Chicken'), _ing('Garlic')],
      ));

      await provider.loadRecipes();
      provider.setIngredientMode(true);
      provider.addIngredient('chicken');

      expect(provider.results, hasLength(1));
    });

    test('ingredient search: no match returns empty list', () async {
      await recipeService.createRecipe(_makeRecipe(
        title: 'Pasta',
        ingredients: [_ing('pasta'), _ing('tomato')],
      ));

      await provider.loadRecipes();
      provider.setIngredientMode(true);
      provider.addIngredient('unicorn');

      expect(provider.results, isEmpty);
    });

    test('ingredient search: empty filters shows all recipes', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'A'));
      await recipeService.createRecipe(_makeRecipe(title: 'B'));

      await provider.loadRecipes();
      provider.setIngredientMode(true);

      expect(provider.results, hasLength(2));
    });

    test('turning off ingredient mode clears filters and switches to text mode',
        () async {
      await recipeService.createRecipe(_makeRecipe(title: 'A'));
      await provider.loadRecipes();

      provider.setIngredientMode(true);
      provider.addIngredient('chicken');
      provider.setIngredientMode(false);

      expect(provider.isIngredientMode, isFalse);
      expect(provider.ingredientFilters, isEmpty);
    });
  });
}
