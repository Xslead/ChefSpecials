import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/recipe.dart';
import 'package:chef_specials/models/ingredient.dart';
import 'package:chef_specials/models/recipe_step.dart';

void main() {
  Map<String, dynamic> fullMap() {
    return {
      'title': 'Spaghetti Carbonara',
      'description': 'Classic Italian pasta dish',
      'authorId': 'author1',
      'authorName': 'Chef Mario',
      'category': 'Pasta',
      'servings': 4,
      'prepTimeMinutes': 15,
      'cookTimeMinutes': 20,
      'imageUrl': 'https://example.com/carbonara.jpg',
      'ingredients': [
        {
          'name': 'Spaghetti',
          'amount': '400',
          'unit': 'g',
          'foodItemId': null,
          'caloriesPer100': 157.0,
          'proteinPer100': 5.8,
          'carbsPer100': 30.9,
          'fatPer100': 0.9,
        },
        {
          'name': 'Eggs',
          'amount': '4',
          'unit': null,
          'foodItemId': null,
          'caloriesPer100': null,
          'proteinPer100': null,
          'carbsPer100': null,
          'fatPer100': null,
        },
      ],
      'steps': [
        {
          'order': 1,
          'instruction': 'Cook the spaghetti',
          'imageUrl': null,
          'timerSeconds': 600,
        },
        {
          'order': 2,
          'instruction': 'Mix eggs with cheese',
          'imageUrl': null,
          'timerSeconds': null,
        },
      ],
      'caloriesPerServing': 550,
      'proteinGrams': 25.0,
      'carbsGrams': 65.0,
      'fatGrams': 20.0,
      'createdAt': '2024-06-15T10:30:00.000Z',
      'averageRating': 4.5,
      'ratingCount': 120,
      'commentCount': 35,
      'isPrivate': false,
      'dietaryTags': ['vegetarian'],
    };
  }

  Map<String, dynamic> minimalMap() {
    return {
      'title': 'Simple Salad',
      'description': 'Quick salad',
      'authorId': 'a1',
      'authorName': 'Chef',
      'category': 'Salad',
      'servings': 2,
      'prepTimeMinutes': 5,
      'cookTimeMinutes': 0,
      'ingredients': [
        {
          'name': 'Lettuce',
          'amount': '100',
        },
      ],
      'steps': [
        {
          'order': 1,
          'instruction': 'Wash and chop lettuce',
        },
      ],
      'createdAt': '2024-01-01T00:00:00.000Z',
    };
  }

  group('Recipe', () {
    group('fromMap', () {
      test('creates Recipe with all fields', () {
        final map = fullMap();
        final recipe = Recipe.fromMap(map, 'doc1');

        expect(recipe.id, 'doc1');
        expect(recipe.title, 'Spaghetti Carbonara');
        expect(recipe.description, 'Classic Italian pasta dish');
        expect(recipe.authorId, 'author1');
        expect(recipe.authorName, 'Chef Mario');
        expect(recipe.category, 'Pasta');
        expect(recipe.servings, 4);
        expect(recipe.prepTimeMinutes, 15);
        expect(recipe.cookTimeMinutes, 20);
        expect(recipe.imageUrl, 'https://example.com/carbonara.jpg');
        expect(recipe.ingredients.length, 2);
        expect(recipe.steps.length, 2);
        expect(recipe.caloriesPerServing, 550);
        expect(recipe.proteinGrams, 25.0);
        expect(recipe.carbsGrams, 65.0);
        expect(recipe.fatGrams, 20.0);
        expect(
            recipe.createdAt, DateTime.parse('2024-06-15T10:30:00.000Z'));
        expect(recipe.averageRating, 4.5);
        expect(recipe.ratingCount, 120);
        expect(recipe.commentCount, 35);
        expect(recipe.isPrivate, isFalse);
        expect(recipe.dietaryTags, ['vegetarian']);
      });

      test('creates Recipe with minimal fields and defaults', () {
        final map = minimalMap();
        final recipe = Recipe.fromMap(map, 'doc2');

        expect(recipe.id, 'doc2');
        expect(recipe.imageUrl, isNull);
        expect(recipe.caloriesPerServing, isNull);
        expect(recipe.proteinGrams, isNull);
        expect(recipe.carbsGrams, isNull);
        expect(recipe.fatGrams, isNull);
        expect(recipe.averageRating, 0.0);
        expect(recipe.ratingCount, 0);
        expect(recipe.commentCount, 0);
        expect(recipe.isPrivate, isFalse);
        expect(recipe.dietaryTags, isEmpty);
      });

      test('defaults averageRating to 0.0 when missing', () {
        final map = minimalMap();
        final recipe = Recipe.fromMap(map, 'doc1');
        expect(recipe.averageRating, 0.0);
      });

      test('defaults ratingCount to 0 when missing', () {
        final map = minimalMap();
        final recipe = Recipe.fromMap(map, 'doc1');
        expect(recipe.ratingCount, 0);
      });

      test('defaults commentCount to 0 when missing', () {
        final map = minimalMap();
        final recipe = Recipe.fromMap(map, 'doc1');
        expect(recipe.commentCount, 0);
      });

      test('defaults isPrivate to false when missing', () {
        final map = minimalMap();
        final recipe = Recipe.fromMap(map, 'doc1');
        expect(recipe.isPrivate, isFalse);
      });

      test('defaults dietaryTags to empty list when missing', () {
        final map = minimalMap();
        final recipe = Recipe.fromMap(map, 'doc1');
        expect(recipe.dietaryTags, isEmpty);
      });

      test('defaults dietaryTags to empty list when null', () {
        final map = minimalMap();
        map['dietaryTags'] = null;
        final recipe = Recipe.fromMap(map, 'doc1');
        expect(recipe.dietaryTags, isEmpty);
      });

      test('defaults photos to empty list when missing', () {
        final map = minimalMap();
        final recipe = Recipe.fromMap(map, 'doc1');
        expect(recipe.photos, isEmpty);
      });

      test('defaults photos to empty list when null', () {
        final map = minimalMap();
        map['photos'] = null;
        final recipe = Recipe.fromMap(map, 'doc1');
        expect(recipe.photos, isEmpty);
      });

      test('parses photos list correctly', () {
        final map = fullMap();
        map['photos'] = [
          'https://example.com/photo1.jpg',
          'https://example.com/photo2.jpg',
        ];
        final recipe = Recipe.fromMap(map, 'doc1');
        expect(recipe.photos.length, 2);
        expect(recipe.photos[0], 'https://example.com/photo1.jpg');
        expect(recipe.photos[1], 'https://example.com/photo2.jpg');
      });

      test('parses nested ingredients correctly', () {
        final map = fullMap();
        final recipe = Recipe.fromMap(map, 'doc1');

        expect(recipe.ingredients[0].name, 'Spaghetti');
        expect(recipe.ingredients[0].amount, '400');
        expect(recipe.ingredients[0].unit, 'g');
        expect(recipe.ingredients[1].name, 'Eggs');
        expect(recipe.ingredients[1].amount, '4');
      });

      test('parses nested steps correctly', () {
        final map = fullMap();
        final recipe = Recipe.fromMap(map, 'doc1');

        expect(recipe.steps[0].order, 1);
        expect(recipe.steps[0].instruction, 'Cook the spaghetti');
        expect(recipe.steps[0].timerSeconds, 600);
        expect(recipe.steps[1].order, 2);
        expect(recipe.steps[1].timerSeconds, isNull);
      });

      test('converts int nutrition to double for proteinGrams', () {
        final map = minimalMap();
        map['proteinGrams'] = 25;
        final recipe = Recipe.fromMap(map, 'doc1');
        expect(recipe.proteinGrams, isA<double>());
        expect(recipe.proteinGrams, 25.0);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final dt = DateTime(2024, 6, 15, 10, 30);
        final recipe = Recipe(
          id: 'doc1',
          title: 'Test Recipe',
          description: 'Test description',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Appetizer',
          servings: 2,
          prepTimeMinutes: 10,
          cookTimeMinutes: 15,
          imageUrl: 'https://example.com/img.jpg',
          ingredients: [
            Ingredient(name: 'Salt', amount: '1', unit: 'tsp'),
          ],
          steps: [
            RecipeStep(order: 1, instruction: 'Add salt'),
          ],
          caloriesPerServing: 100,
          proteinGrams: 5.0,
          carbsGrams: 10.0,
          fatGrams: 3.0,
          createdAt: dt,
          averageRating: 3.5,
          ratingCount: 10,
          commentCount: 5,
          isPrivate: true,
          dietaryTags: ['vegan', 'gluten-free'],
        );

        final map = recipe.toMap();

        expect(map['title'], 'Test Recipe');
        expect(map['description'], 'Test description');
        expect(map['authorId'], 'a1');
        expect(map['authorName'], 'Chef');
        expect(map['category'], 'Appetizer');
        expect(map['servings'], 2);
        expect(map['prepTimeMinutes'], 10);
        expect(map['cookTimeMinutes'], 15);
        expect(map['imageUrl'], 'https://example.com/img.jpg');
        expect(map['ingredients'], isA<List>());
        expect((map['ingredients'] as List).length, 1);
        expect(map['steps'], isA<List>());
        expect((map['steps'] as List).length, 1);
        expect(map['caloriesPerServing'], 100);
        expect(map['proteinGrams'], 5.0);
        expect(map['carbsGrams'], 10.0);
        expect(map['fatGrams'], 3.0);
        expect(map['createdAt'], dt.toIso8601String());
        expect(map['isPrivate'], isTrue);
        expect(map['dietaryTags'], ['vegan', 'gluten-free']);
        expect(map['photos'], isEmpty);
      });

      test('serializes photos list correctly', () {
        final recipe = Recipe(
          title: 'T',
          description: 'D',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Cat',
          servings: 1,
          prepTimeMinutes: 5,
          cookTimeMinutes: 5,
          ingredients: [],
          steps: [],
          createdAt: DateTime.now(),
          photos: [
            'https://example.com/p1.jpg',
            'https://example.com/p2.jpg',
          ],
        );
        final map = recipe.toMap();
        expect(map['photos'], ['https://example.com/p1.jpg', 'https://example.com/p2.jpg']);
      });

      test('does not include id in toMap output', () {
        final recipe = Recipe(
          id: 'doc1',
          title: 'Test',
          description: 'Desc',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Cat',
          servings: 1,
          prepTimeMinutes: 5,
          cookTimeMinutes: 5,
          ingredients: [],
          steps: [],
          createdAt: DateTime.now(),
        );

        final map = recipe.toMap();
        expect(map.containsKey('id'), isFalse);
      });

      test('does not include averageRating, ratingCount, commentCount in toMap', () {
        final recipe = Recipe(
          id: 'doc1',
          title: 'Test',
          description: 'Desc',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Cat',
          servings: 1,
          prepTimeMinutes: 5,
          cookTimeMinutes: 5,
          ingredients: [],
          steps: [],
          createdAt: DateTime.now(),
          averageRating: 4.0,
          ratingCount: 10,
          commentCount: 5,
        );

        final map = recipe.toMap();
        expect(map.containsKey('averageRating'), isFalse);
        expect(map.containsKey('ratingCount'), isFalse);
        expect(map.containsKey('commentCount'), isFalse);
      });

      test('serializes nested ingredients as maps', () {
        final recipe = Recipe(
          title: 'Test',
          description: 'Desc',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Cat',
          servings: 1,
          prepTimeMinutes: 5,
          cookTimeMinutes: 5,
          ingredients: [
            Ingredient(name: 'Flour', amount: '200', unit: 'g'),
          ],
          steps: [],
          createdAt: DateTime.now(),
        );

        final map = recipe.toMap();
        final ingredientsList = map['ingredients'] as List;

        expect(ingredientsList[0], isA<Map<String, dynamic>>());
        expect(ingredientsList[0]['name'], 'Flour');
        expect(ingredientsList[0]['amount'], '200');
      });

      test('serializes nested steps as maps', () {
        final recipe = Recipe(
          title: 'Test',
          description: 'Desc',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Cat',
          servings: 1,
          prepTimeMinutes: 5,
          cookTimeMinutes: 5,
          ingredients: [],
          steps: [
            RecipeStep(order: 1, instruction: 'Step 1'),
          ],
          createdAt: DateTime.now(),
        );

        final map = recipe.toMap();
        final stepsList = map['steps'] as List;

        expect(stepsList[0], isA<Map<String, dynamic>>());
        expect(stepsList[0]['order'], 1);
        expect(stepsList[0]['instruction'], 'Step 1');
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves core fields', () {
        final originalMap = fullMap();
        final recipe = Recipe.fromMap(originalMap, 'doc1');
        final resultMap = recipe.toMap();

        expect(resultMap['title'], originalMap['title']);
        expect(resultMap['description'], originalMap['description']);
        expect(resultMap['authorId'], originalMap['authorId']);
        expect(resultMap['authorName'], originalMap['authorName']);
        expect(resultMap['category'], originalMap['category']);
        expect(resultMap['servings'], originalMap['servings']);
        expect(resultMap['prepTimeMinutes'], originalMap['prepTimeMinutes']);
        expect(resultMap['cookTimeMinutes'], originalMap['cookTimeMinutes']);
        expect(resultMap['imageUrl'], originalMap['imageUrl']);
        expect(resultMap['caloriesPerServing'],
            originalMap['caloriesPerServing']);
        expect(resultMap['proteinGrams'], originalMap['proteinGrams']);
        expect(resultMap['carbsGrams'], originalMap['carbsGrams']);
        expect(resultMap['fatGrams'], originalMap['fatGrams']);
        expect(resultMap['isPrivate'], originalMap['isPrivate']);
        expect(resultMap['dietaryTags'], originalMap['dietaryTags']);
      });

      test('round-trip preserves nested ingredients', () {
        final originalMap = fullMap();
        final recipe = Recipe.fromMap(originalMap, 'doc1');
        final resultMap = recipe.toMap();

        final originalIngredients =
            originalMap['ingredients'] as List;
        final resultIngredients =
            resultMap['ingredients'] as List;

        expect(resultIngredients.length, originalIngredients.length);
        expect(resultIngredients[0]['name'],
            originalIngredients[0]['name']);
        expect(resultIngredients[0]['amount'],
            originalIngredients[0]['amount']);
      });
    });

    group('copyWith', () {
      late Recipe original;

      setUp(() {
        original = Recipe(
          id: 'doc1',
          title: 'Original Title',
          description: 'Original description',
          authorId: 'a1',
          authorName: 'Chef Original',
          category: 'Main',
          servings: 4,
          prepTimeMinutes: 15,
          cookTimeMinutes: 30,
          imageUrl: 'https://original.com/img.jpg',
          ingredients: [
            Ingredient(name: 'Rice', amount: '200', unit: 'g'),
          ],
          steps: [
            RecipeStep(order: 1, instruction: 'Cook rice'),
          ],
          caloriesPerServing: 300,
          proteinGrams: 8.0,
          carbsGrams: 60.0,
          fatGrams: 2.0,
          createdAt: DateTime(2024, 1, 1),
          averageRating: 4.0,
          ratingCount: 50,
          commentCount: 10,
          isPrivate: false,
          dietaryTags: ['vegan'],
        );
      });

      test('preserves all fields when no arguments given', () {
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.title, original.title);
        expect(copy.description, original.description);
        expect(copy.authorId, original.authorId);
        expect(copy.authorName, original.authorName);
        expect(copy.category, original.category);
        expect(copy.servings, original.servings);
        expect(copy.prepTimeMinutes, original.prepTimeMinutes);
        expect(copy.cookTimeMinutes, original.cookTimeMinutes);
        expect(copy.imageUrl, original.imageUrl);
        expect(copy.ingredients, original.ingredients);
        expect(copy.steps, original.steps);
        expect(copy.caloriesPerServing, original.caloriesPerServing);
        expect(copy.proteinGrams, original.proteinGrams);
        expect(copy.carbsGrams, original.carbsGrams);
        expect(copy.fatGrams, original.fatGrams);
        expect(copy.createdAt, original.createdAt);
        expect(copy.averageRating, original.averageRating);
        expect(copy.ratingCount, original.ratingCount);
        expect(copy.commentCount, original.commentCount);
        expect(copy.isPrivate, original.isPrivate);
        expect(copy.dietaryTags, original.dietaryTags);
      });

      test('updates title only', () {
        final copy = original.copyWith(title: 'New Title');

        expect(copy.title, 'New Title');
        expect(copy.description, original.description);
        expect(copy.id, original.id);
      });

      test('updates servings only', () {
        final copy = original.copyWith(servings: 8);

        expect(copy.servings, 8);
        expect(copy.title, original.title);
      });

      test('updates ingredients list', () {
        final newIngredients = [
          Ingredient(name: 'Pasta', amount: '500', unit: 'g'),
          Ingredient(name: 'Sauce', amount: '200', unit: 'mL'),
        ];

        final copy = original.copyWith(ingredients: newIngredients);

        expect(copy.ingredients.length, 2);
        expect(copy.ingredients[0].name, 'Pasta');
        expect(copy.ingredients[1].name, 'Sauce');
      });

      test('updates steps list', () {
        final newSteps = [
          RecipeStep(order: 1, instruction: 'New step 1'),
          RecipeStep(order: 2, instruction: 'New step 2'),
          RecipeStep(order: 3, instruction: 'New step 3'),
        ];

        final copy = original.copyWith(steps: newSteps);

        expect(copy.steps.length, 3);
        expect(copy.steps[2].instruction, 'New step 3');
      });

      test('updates isPrivate', () {
        final copy = original.copyWith(isPrivate: true);
        expect(copy.isPrivate, isTrue);
      });

      test('updates dietaryTags', () {
        final copy =
            original.copyWith(dietaryTags: ['vegan', 'gluten-free']);

        expect(copy.dietaryTags, ['vegan', 'gluten-free']);
      });

      test('updates photos', () {
        final copy = original.copyWith(
            photos: ['https://example.com/p1.jpg']);
        expect(copy.photos, ['https://example.com/p1.jpg']);
      });

      test('updates multiple fields simultaneously', () {
        final copy = original.copyWith(
          title: 'Updated Recipe',
          category: 'Dessert',
          servings: 6,
          averageRating: 4.8,
          ratingCount: 200,
        );

        expect(copy.title, 'Updated Recipe');
        expect(copy.category, 'Dessert');
        expect(copy.servings, 6);
        expect(copy.averageRating, 4.8);
        expect(copy.ratingCount, 200);
      });

      test('can update id', () {
        final copy = original.copyWith(id: 'newDoc');
        expect(copy.id, 'newDoc');
      });
    });

    group('edge cases', () {
      test('handles empty ingredients list', () {
        final recipe = Recipe(
          title: 'Empty',
          description: 'No ingredients',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Cat',
          servings: 1,
          prepTimeMinutes: 0,
          cookTimeMinutes: 0,
          ingredients: [],
          steps: [],
          createdAt: DateTime.now(),
        );

        expect(recipe.ingredients, isEmpty);
        expect(recipe.steps, isEmpty);
      });

      test('handles zero servings', () {
        final recipe = Recipe(
          title: 'Test',
          description: 'Desc',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Cat',
          servings: 0,
          prepTimeMinutes: 0,
          cookTimeMinutes: 0,
          ingredients: [],
          steps: [],
          createdAt: DateTime.now(),
        );

        expect(recipe.servings, 0);
      });

      test('handles zero prepTime and cookTime', () {
        final recipe = Recipe(
          title: 'No Cook',
          description: 'Raw dish',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Raw',
          servings: 2,
          prepTimeMinutes: 0,
          cookTimeMinutes: 0,
          ingredients: [],
          steps: [],
          createdAt: DateTime.now(),
        );

        expect(recipe.prepTimeMinutes, 0);
        expect(recipe.cookTimeMinutes, 0);
      });

      test('handles empty dietaryTags', () {
        final recipe = Recipe(
          title: 'Test',
          description: 'Desc',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Cat',
          servings: 1,
          prepTimeMinutes: 5,
          cookTimeMinutes: 5,
          ingredients: [],
          steps: [],
          createdAt: DateTime.now(),
          dietaryTags: [],
        );

        expect(recipe.dietaryTags, isEmpty);
      });

      test('handles null id', () {
        final recipe = Recipe(
          title: 'Test',
          description: 'Desc',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Cat',
          servings: 1,
          prepTimeMinutes: 5,
          cookTimeMinutes: 5,
          ingredients: [],
          steps: [],
          createdAt: DateTime.now(),
        );

        expect(recipe.id, isNull);
      });

      test('handles many ingredients and steps', () {
        final ingredients = List.generate(
          50,
          (i) => Ingredient(name: 'Ingredient $i', amount: '${i + 1}'),
        );
        final steps = List.generate(
          30,
          (i) => RecipeStep(order: i + 1, instruction: 'Step ${i + 1}'),
        );

        final recipe = Recipe(
          title: 'Complex Recipe',
          description: 'Many steps',
          authorId: 'a1',
          authorName: 'Chef',
          category: 'Complex',
          servings: 10,
          prepTimeMinutes: 120,
          cookTimeMinutes: 240,
          ingredients: ingredients,
          steps: steps,
          createdAt: DateTime.now(),
        );

        expect(recipe.ingredients.length, 50);
        expect(recipe.steps.length, 30);
      });
    });
  });
}
