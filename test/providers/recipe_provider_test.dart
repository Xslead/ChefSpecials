import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/recipe_provider.dart';
import 'package:chef_specials/services/recipe_service.dart';
import 'package:chef_specials/models/recipe.dart';

Recipe _makeRecipe({
  String title = 'Test Recipe',
  String authorId = 'user1',
  String authorName = 'Chef',
  String category = 'Breakfast',
  bool isPrivate = false,
}) {
  return Recipe(
    title: title,
    description: 'A test recipe',
    authorId: authorId,
    authorName: authorName,
    category: category,
    servings: 2,
    prepTimeMinutes: 10,
    cookTimeMinutes: 20,
    ingredients: [],
    steps: [],
    createdAt: DateTime.now(),
    isPrivate: isPrivate,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RecipeService recipeService;
  late RecipeProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    recipeService = RecipeService(firestore: fakeFirestore);
    provider = RecipeProvider(recipeService: recipeService);
  });

  group('RecipeProvider', () {
    test('initial state has empty recipes and no loading', () {
      expect(provider.recipes, isEmpty);
      expect(provider.allRecipes, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.selectedCategory, isNull);
    });

    test('ensureInitialized starts listening to recipes', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'Pancakes'));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      expect(provider.recipes, hasLength(1));
      expect(provider.recipes.first.title, 'Pancakes');
    });

    test('ensureInitialized only initializes once', () async {
      await recipeService.createRecipe(_makeRecipe());

      provider.ensureInitialized();
      provider.ensureInitialized(); // second call should be no-op
      await Future.delayed(Duration.zero);

      expect(provider.recipes, hasLength(1));
    });

    test('recipes getter filters out private recipes', () async {
      await recipeService.createRecipe(_makeRecipe(title: 'Public'));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Private', isPrivate: true));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      expect(provider.recipes, hasLength(1));
      expect(provider.recipes.first.title, 'Public');
      expect(provider.allRecipes, hasLength(2));
    });

    test('setCategory filters recipes by category', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'Eggs', category: 'Breakfast'));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Pasta', category: 'Dinner'));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      provider.setCategory('Breakfast');
      expect(provider.selectedCategory, 'Breakfast');
      expect(provider.recipes, hasLength(1));
      expect(provider.recipes.first.title, 'Eggs');
    });

    test('setCategory to null shows all public recipes', () async {
      await recipeService.createRecipe(
          _makeRecipe(title: 'Eggs', category: 'Breakfast'));
      await recipeService.createRecipe(
          _makeRecipe(title: 'Pasta', category: 'Dinner'));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      provider.setCategory('Breakfast');
      expect(provider.recipes, hasLength(1));

      provider.setCategory(null);
      expect(provider.recipes, hasLength(2));
    });

    test('setCategory notifies listeners', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setCategory('Lunch');
      expect(notifyCount, 1);
    });

    test('createRecipe adds recipe to Firestore and returns id', () async {
      final id = await provider.createRecipe(_makeRecipe(title: 'New Recipe'));
      expect(id, isNotEmpty);

      // Verify in Firestore
      final doc =
          await fakeFirestore.collection('recipes').doc(id).get();
      expect(doc.exists, true);
      expect(doc.data()!['title'], 'New Recipe');
    });

    test('updateRecipe updates recipe in Firestore', () async {
      final id = await provider.createRecipe(_makeRecipe(title: 'Original'));

      await provider.updateRecipe(id, {'title': 'Updated'});

      final doc =
          await fakeFirestore.collection('recipes').doc(id).get();
      expect(doc.data()!['title'], 'Updated');
    });

    test('deleteRecipe removes recipe from Firestore', () async {
      final id = await provider.createRecipe(_makeRecipe());

      await provider.deleteRecipe(id);

      final doc =
          await fakeFirestore.collection('recipes').doc(id).get();
      expect(doc.exists, false);
    });

    test('updateAuthorName updates all recipes by author locally', () async {
      await recipeService.createRecipe(
          _makeRecipe(authorId: 'author1', authorName: 'OldName'));
      await recipeService.createRecipe(
          _makeRecipe(authorId: 'author1', authorName: 'OldName'));
      await recipeService.createRecipe(
          _makeRecipe(authorId: 'author2', authorName: 'Other'));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      provider.updateAuthorName('author1', 'NewName');

      final author1Recipes =
          provider.allRecipes.where((r) => r.authorId == 'author1');
      for (final r in author1Recipes) {
        expect(r.authorName, 'NewName');
      }
      final author2Recipes =
          provider.allRecipes.where((r) => r.authorId == 'author2');
      for (final r in author2Recipes) {
        expect(r.authorName, 'Other');
      }
    });

    test('updateAuthorName notifies listeners', () async {
      await recipeService.createRecipe(
          _makeRecipe(authorId: 'a1', authorName: 'Old'));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.updateAuthorName('a1', 'New');
      expect(notifyCount, 1);
    });

    test('stream updates reflect in recipes list', () async {
      provider.ensureInitialized();
      await Future.delayed(Duration.zero);
      expect(provider.recipes, isEmpty);

      // Add a recipe directly to Firestore to trigger stream update
      await fakeFirestore.collection('recipes').add(_makeRecipe(title: 'Streamed').toMap());
      await Future.delayed(Duration.zero);

      expect(provider.recipes, hasLength(1));
      expect(provider.recipes.first.title, 'Streamed');
    });
  });
}
