import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/recipe_service.dart';
import 'package:chef_specials/models/recipe.dart';
import 'package:chef_specials/models/ingredient.dart';
import 'package:chef_specials/models/recipe_step.dart';

Recipe _makeRecipe({
  String title = 'Test Recipe',
  String authorId = 'user1',
  String authorName = 'Chef Test',
  String category = 'Dinner',
  bool isPrivate = false,
  DateTime? createdAt,
}) {
  return Recipe(
    title: title,
    description: 'A test recipe',
    authorId: authorId,
    authorName: authorName,
    category: category,
    servings: 4,
    prepTimeMinutes: 10,
    cookTimeMinutes: 30,
    ingredients: [
      Ingredient(name: 'Salt', amount: '1', unit: 'tsp'),
    ],
    steps: [
      RecipeStep(order: 1, instruction: 'Mix everything'),
    ],
    createdAt: createdAt ?? DateTime(2024, 1, 1),
    isPrivate: isPrivate,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RecipeService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = RecipeService(firestore: fakeFirestore);
  });

  group('RecipeService', () {
    group('createRecipe', () {
      test('should create a recipe and return its document ID', () async {
        final recipe = _makeRecipe();
        final id = await service.createRecipe(recipe);

        expect(id, isNotEmpty);

        final doc =
            await fakeFirestore.collection('recipes').doc(id).get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['title'], 'Test Recipe');
      });

      test('should store all recipe fields correctly', () async {
        final recipe = _makeRecipe(
          title: 'Full Recipe',
          authorId: 'author1',
          authorName: 'Full Chef',
          category: 'Breakfast',
          isPrivate: true,
        );
        final id = await service.createRecipe(recipe);

        final doc =
            await fakeFirestore.collection('recipes').doc(id).get();
        final data = doc.data()!;
        expect(data['title'], 'Full Recipe');
        expect(data['authorId'], 'author1');
        expect(data['authorName'], 'Full Chef');
        expect(data['category'], 'Breakfast');
        expect(data['isPrivate'], true);
        expect(data['servings'], 4);
        expect(data['prepTimeMinutes'], 10);
        expect(data['cookTimeMinutes'], 30);
        expect((data['ingredients'] as List).length, 1);
        expect((data['steps'] as List).length, 1);
      });
    });

    group('getRecipe', () {
      test('should return a recipe by ID', () async {
        final recipe = _makeRecipe(title: 'Get Me');
        final id = await service.createRecipe(recipe);

        final result = await service.getRecipe(id);

        expect(result, isNotNull);
        expect(result!.id, id);
        expect(result.title, 'Get Me');
      });

      test('should return null for non-existent ID', () async {
        final result = await service.getRecipe('nonexistent');
        expect(result, isNull);
      });
    });

    group('updateRecipe', () {
      test('should update specific fields of a recipe', () async {
        final id = await service.createRecipe(_makeRecipe());

        await service.updateRecipe(id, {'title': 'Updated Title'});

        final result = await service.getRecipe(id);
        expect(result!.title, 'Updated Title');
      });

      test('should update multiple fields at once', () async {
        final id = await service.createRecipe(_makeRecipe());

        await service.updateRecipe(id, {
          'title': 'New Title',
          'servings': 8,
          'isPrivate': true,
        });

        final result = await service.getRecipe(id);
        expect(result!.title, 'New Title');
        expect(result.servings, 8);
        expect(result.isPrivate, true);
      });
    });

    group('deleteRecipe', () {
      test('should delete a recipe by ID', () async {
        final id = await service.createRecipe(_makeRecipe());

        await service.deleteRecipe(id);

        final result = await service.getRecipe(id);
        expect(result, isNull);
      });

      test('should not throw when deleting non-existent ID', () async {
        // Firestore delete on non-existent doc is a no-op
        await expectLater(
          service.deleteRecipe('nonexistent'),
          completes,
        );
      });
    });

    group('getRecipesStream', () {
      test('should return all recipes ordered by createdAt DESC', () async {
        await service.createRecipe(
            _makeRecipe(title: 'Old', createdAt: DateTime(2023, 1, 1)));
        await service.createRecipe(
            _makeRecipe(title: 'New', createdAt: DateTime(2024, 6, 1)));
        await service.createRecipe(
            _makeRecipe(title: 'Mid', createdAt: DateTime(2024, 3, 1)));

        final recipes = await service.getRecipesStream().first;

        expect(recipes.length, 3);
        expect(recipes[0].title, 'New');
        expect(recipes[1].title, 'Mid');
        expect(recipes[2].title, 'Old');
      });

      test('should return empty list when no recipes exist', () async {
        final recipes = await service.getRecipesStream().first;
        expect(recipes, isEmpty);
      });
    });

    group('getRecipesByCategory', () {
      test('should return only recipes matching the category', () async {
        await service
            .createRecipe(_makeRecipe(title: 'Breakfast1', category: 'Breakfast'));
        await service
            .createRecipe(_makeRecipe(title: 'Dinner1', category: 'Dinner'));
        await service
            .createRecipe(_makeRecipe(title: 'Breakfast2', category: 'Breakfast'));

        final recipes =
            await service.getRecipesByCategory('Breakfast').first;

        expect(recipes.length, 2);
        expect(recipes.every((r) => r.category == 'Breakfast'), isTrue);
      });

      test('should return empty list for non-existent category', () async {
        await service.createRecipe(_makeRecipe(category: 'Dinner'));

        final recipes =
            await service.getRecipesByCategory('Dessert').first;
        expect(recipes, isEmpty);
      });
    });

    group('getUserRecipes', () {
      test('should return only recipes by the specified user', () async {
        await service
            .createRecipe(_makeRecipe(title: 'User1 Recipe', authorId: 'user1'));
        await service
            .createRecipe(_makeRecipe(title: 'User2 Recipe', authorId: 'user2'));
        await service.createRecipe(
            _makeRecipe(title: 'User1 Another', authorId: 'user1'));

        final recipes = await service.getUserRecipes('user1').first;

        expect(recipes.length, 2);
        expect(recipes.every((r) => r.authorId == 'user1'), isTrue);
      });

      test('should return empty list for user with no recipes', () async {
        final recipes = await service.getUserRecipes('nobody').first;
        expect(recipes, isEmpty);
      });
    });

    group('getFeedRecipes', () {
      test('should return public recipes from specified authors', () async {
        await service.createRecipe(_makeRecipe(
          title: 'Public',
          authorId: 'a1',
          isPrivate: false,
          createdAt: DateTime(2024, 1, 1),
        ));
        await service.createRecipe(_makeRecipe(
          title: 'Private',
          authorId: 'a1',
          isPrivate: true,
          createdAt: DateTime(2024, 2, 1),
        ));

        final feed = await service.getFeedRecipes(['a1']);

        expect(feed.length, 1);
        expect(feed[0].title, 'Public');
      });

      test('should return empty list when authorIds is empty', () async {
        final feed = await service.getFeedRecipes([]);
        expect(feed, isEmpty);
      });

      test('should respect the limit parameter', () async {
        for (var i = 0; i < 5; i++) {
          await service.createRecipe(_makeRecipe(
            title: 'Recipe $i',
            authorId: 'a1',
            createdAt: DateTime(2024, 1, i + 1),
          ));
        }

        final feed = await service.getFeedRecipes(['a1'], limit: 3);
        expect(feed.length, 3);
      });

      test('should filter by before parameter', () async {
        await service.createRecipe(_makeRecipe(
          title: 'Jan',
          authorId: 'a1',
          createdAt: DateTime(2024, 1, 1),
        ));
        await service.createRecipe(_makeRecipe(
          title: 'Jun',
          authorId: 'a1',
          createdAt: DateTime(2024, 6, 1),
        ));

        final feed = await service.getFeedRecipes(
          ['a1'],
          before: DateTime(2024, 3, 1),
        );

        expect(feed.length, 1);
        expect(feed[0].title, 'Jan');
      });

      test('should sort results by createdAt descending', () async {
        await service.createRecipe(_makeRecipe(
          title: 'Old',
          authorId: 'a1',
          createdAt: DateTime(2024, 1, 1),
        ));
        await service.createRecipe(_makeRecipe(
          title: 'New',
          authorId: 'a1',
          createdAt: DateTime(2024, 6, 1),
        ));

        final feed = await service.getFeedRecipes(['a1']);

        expect(feed[0].title, 'New');
        expect(feed[1].title, 'Old');
      });

      test('should batch authorIds in groups of 10', () async {
        // Create recipes for 12 different authors
        for (var i = 0; i < 12; i++) {
          await service.createRecipe(_makeRecipe(
            title: 'Recipe by author$i',
            authorId: 'author$i',
            createdAt: DateTime(2024, 1, i + 1),
          ));
        }

        final authorIds =
            List.generate(12, (i) => 'author$i');
        final feed = await service.getFeedRecipes(authorIds);

        expect(feed.length, 12);
      });
    });

    group('updateAuthorName', () {
      test('should update authorName on all recipes by a user', () async {
        await service
            .createRecipe(_makeRecipe(authorId: 'u1', authorName: 'Old Name'));
        await service
            .createRecipe(_makeRecipe(authorId: 'u1', authorName: 'Old Name'));
        await service
            .createRecipe(_makeRecipe(authorId: 'u2', authorName: 'Other'));

        await service.updateAuthorName('u1', 'New Name');

        final u1Recipes = await service.getUserRecipes('u1').first;
        for (final r in u1Recipes) {
          expect(r.authorName, 'New Name');
        }

        // Other user's recipes should be unaffected
        final u2Recipes = await service.getUserRecipes('u2').first;
        expect(u2Recipes[0].authorName, 'Other');
      });

      test('should handle user with no recipes gracefully', () async {
        await expectLater(
          service.updateAuthorName('nobody', 'New Name'),
          completes,
        );
      });
    });
  });
}
