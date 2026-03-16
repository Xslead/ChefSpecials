import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/search_provider.dart';
import 'package:chef_specials/services/recipe_service.dart';
import 'package:chef_specials/models/recipe.dart';

Recipe _makeRecipe({
  String title = 'Test Recipe',
  String category = 'Breakfast',
  String authorName = 'Chef',
  String description = 'A test recipe',
  List<String> dietaryTags = const [],
}) {
  return Recipe(
    title: title,
    description: description,
    authorId: 'user1',
    authorName: authorName,
    category: category,
    servings: 2,
    prepTimeMinutes: 10,
    cookTimeMinutes: 20,
    ingredients: [],
    steps: [],
    createdAt: DateTime.now(),
    dietaryTags: dietaryTags,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RecipeService recipeService;
  late SearchProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    recipeService = RecipeService(firestore: fakeFirestore);
    provider = SearchProvider(recipeService: recipeService);
  });

  group('SearchProvider', () {
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

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.loadRecipes();
      // At least 2 notifications: isLoading=true, then isLoading=false
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
      await recipeService.createRecipe(
          _makeRecipe(title: 'Eggs', category: 'Breakfast'));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Pasta', category: 'Dinner'));

      await provider.loadRecipes();

      provider.search('dinner');
      expect(provider.results, hasLength(1));
      expect(provider.results.first.title, 'Pasta');
    });

    test('search filters by authorName', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'Eggs', authorName: 'Alice'));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Pasta', authorName: 'Bob'));

      await provider.loadRecipes();

      provider.search('alice');
      expect(provider.results, hasLength(1));
      expect(provider.results.first.authorName, 'Alice');
    });

    test('search filters by description', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'A', description: 'Healthy and delicious'));
      await recipeService.createRecipe(
          _makeRecipe(title: 'B', description: 'Quick and easy'));

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
      await recipeService.createRecipe(
          _makeRecipe(title: 'Pancakes', description: 'fluffy'));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Omelette', description: 'cheesy'));

      await provider.loadRecipes();

      provider.search('pancakes');
      expect(provider.results, hasLength(1));

      provider.search('');
      expect(provider.results, hasLength(2));
      expect(provider.query, '');
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

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.search('test');
      expect(notifyCount, 1);
    });

    test('clear resets query and shows all recipes', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'Pancakes', description: 'fluffy'));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Omelette', description: 'cheesy'));

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

      int notifyCount = 0;
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
}
