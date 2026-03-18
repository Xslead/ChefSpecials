import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/meal_plan.dart';
import 'package:chef_specials/models/planned_meal.dart';

void main() {
  // -------------------------------------------------------------------------
  // PlannedMeal
  // -------------------------------------------------------------------------
  group('PlannedMeal', () {
    group('fromMap', () {
      test('creates PlannedMeal with all fields', () {
        final map = {
          'day': 2,
          'mealType': 'lunch',
          'recipeId': 'r1',
          'recipeName': 'Grilled Chicken',
          'recipeImageUrl': 'https://example.com/chicken.jpg',
          'servings': 3,
        };

        final meal = PlannedMeal.fromMap(map);

        expect(meal.day, 2);
        expect(meal.mealType, 'lunch');
        expect(meal.recipeId, 'r1');
        expect(meal.recipeName, 'Grilled Chicken');
        expect(meal.recipeImageUrl, 'https://example.com/chicken.jpg');
        expect(meal.servings, 3);
      });

      test('defaults servings to 1 when missing', () {
        final map = {
          'day': 0,
          'mealType': 'breakfast',
          'recipeId': 'r1',
          'recipeName': 'Oatmeal',
        };

        final meal = PlannedMeal.fromMap(map);
        expect(meal.servings, 1);
      });

      test('defaults servings to 1 when null', () {
        final map = {
          'day': 0,
          'mealType': 'breakfast',
          'recipeId': 'r1',
          'recipeName': 'Oatmeal',
          'servings': null,
        };

        final meal = PlannedMeal.fromMap(map);
        expect(meal.servings, 1);
      });

      test('handles null recipeImageUrl', () {
        final map = {
          'day': 1,
          'mealType': 'dinner',
          'recipeId': 'r2',
          'recipeName': 'Pasta',
          'recipeImageUrl': null,
          'servings': 2,
        };

        final meal = PlannedMeal.fromMap(map);
        expect(meal.recipeImageUrl, isNull);
      });

      test('parses day boundaries: Monday (0)', () {
        final map = {
          'day': 0,
          'mealType': 'breakfast',
          'recipeId': 'r1',
          'recipeName': 'Eggs',
        };

        final meal = PlannedMeal.fromMap(map);
        expect(meal.day, 0);
      });

      test('parses day boundaries: Sunday (6)', () {
        final map = {
          'day': 6,
          'mealType': 'snack',
          'recipeId': 'r1',
          'recipeName': 'Fruit Bowl',
        };

        final meal = PlannedMeal.fromMap(map);
        expect(meal.day, 6);
      });

      test('parses all valid mealType values', () {
        for (final type in ['breakfast', 'lunch', 'dinner', 'snack']) {
          final map = {
            'day': 0,
            'mealType': type,
            'recipeId': 'r1',
            'recipeName': 'Meal',
          };

          final meal = PlannedMeal.fromMap(map);
          expect(meal.mealType, type);
        }
      });

      test('handles large servings value', () {
        final map = {
          'day': 0,
          'mealType': 'lunch',
          'recipeId': 'r1',
          'recipeName': 'Buffet',
          'servings': 100,
        };

        final meal = PlannedMeal.fromMap(map);
        expect(meal.servings, 100);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final meal = PlannedMeal(
          day: 3,
          mealType: 'dinner',
          recipeId: 'r5',
          recipeName: 'Steak',
          recipeImageUrl: 'https://example.com/steak.jpg',
          servings: 2,
        );

        final map = meal.toMap();

        expect(map['day'], 3);
        expect(map['mealType'], 'dinner');
        expect(map['recipeId'], 'r5');
        expect(map['recipeName'], 'Steak');
        expect(map['recipeImageUrl'], 'https://example.com/steak.jpg');
        expect(map['servings'], 2);
      });

      test('includes null recipeImageUrl in map', () {
        final meal = PlannedMeal(
          day: 0,
          mealType: 'breakfast',
          recipeId: 'r1',
          recipeName: 'Toast',
        );

        final map = meal.toMap();
        expect(map.containsKey('recipeImageUrl'), isTrue);
        expect(map['recipeImageUrl'], isNull);
      });

      test('includes default servings of 1', () {
        final meal = PlannedMeal(
          day: 0,
          mealType: 'breakfast',
          recipeId: 'r1',
          recipeName: 'Toast',
        );

        final map = meal.toMap();
        expect(map['servings'], 1);
      });

      test('contains exactly 6 keys', () {
        final meal = PlannedMeal(
          day: 0,
          mealType: 'breakfast',
          recipeId: 'r1',
          recipeName: 'Toast',
        );

        final map = meal.toMap();
        expect(map.keys.length, 6);
        expect(map.keys, containsAll([
          'day', 'mealType', 'recipeId', 'recipeName',
          'recipeImageUrl', 'servings',
        ]));
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all fields', () {
        final original = PlannedMeal(
          day: 4,
          mealType: 'lunch',
          recipeId: 'r10',
          recipeName: 'Caesar Salad',
          recipeImageUrl: 'https://example.com/salad.jpg',
          servings: 2,
        );

        final map = original.toMap();
        final restored = PlannedMeal.fromMap(map);

        expect(restored.day, original.day);
        expect(restored.mealType, original.mealType);
        expect(restored.recipeId, original.recipeId);
        expect(restored.recipeName, original.recipeName);
        expect(restored.recipeImageUrl, original.recipeImageUrl);
        expect(restored.servings, original.servings);
      });

      test('round-trip preserves null recipeImageUrl', () {
        final original = PlannedMeal(
          day: 0,
          mealType: 'breakfast',
          recipeId: 'r1',
          recipeName: 'Cereal',
        );

        final map = original.toMap();
        final restored = PlannedMeal.fromMap(map);

        expect(restored.recipeImageUrl, isNull);
      });

      test('round-trip preserves default servings', () {
        final original = PlannedMeal(
          day: 1,
          mealType: 'snack',
          recipeId: 'r2',
          recipeName: 'Apple',
        );

        final map = original.toMap();
        final restored = PlannedMeal.fromMap(map);

        expect(restored.servings, 1);
      });
    });
  });

  // -------------------------------------------------------------------------
  // MealPlan
  // -------------------------------------------------------------------------
  group('MealPlan', () {
    final monday = DateTime(2025, 3, 17); // a Monday (local time)

    group('fromMap', () {
      test('creates MealPlan with all fields including meals', () {
        final map = {
          'userId': 'user1',
          'weekStartDate': Timestamp.fromDate(monday),
          'meals': [
            {
              'day': 0,
              'mealType': 'breakfast',
              'recipeId': 'r1',
              'recipeName': 'Oatmeal',
              'recipeImageUrl': null,
              'servings': 1,
            },
            {
              'day': 0,
              'mealType': 'lunch',
              'recipeId': 'r2',
              'recipeName': 'Sandwich',
              'recipeImageUrl': 'https://example.com/sandwich.jpg',
              'servings': 2,
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2025, 3, 17, 10, 0)),
          'updatedAt': Timestamp.fromDate(DateTime(2025, 3, 17, 12, 0)),
        };

        final plan = MealPlan.fromMap(map, 'plan_doc_1');

        expect(plan.id, 'plan_doc_1');
        expect(plan.userId, 'user1');
        expect(plan.weekStartDate, monday);
        expect(plan.meals.length, 2);
        expect(plan.meals[0].recipeName, 'Oatmeal');
        expect(plan.meals[1].recipeName, 'Sandwich');
        expect(plan.createdAt, DateTime(2025, 3, 17, 10, 0));
        expect(plan.updatedAt, DateTime(2025, 3, 17, 12, 0));
      });

      test('defaults meals to empty list when null', () {
        final map = {
          'userId': 'user1',
          'weekStartDate': Timestamp.fromDate(monday),
          'meals': null,
          'createdAt': Timestamp.fromDate(DateTime(2025, 3, 17)),
          'updatedAt': Timestamp.fromDate(DateTime(2025, 3, 17)),
        };

        final plan = MealPlan.fromMap(map, 'plan_doc_2');
        expect(plan.meals, isEmpty);
      });

      test('defaults meals to empty list when missing', () {
        final map = {
          'userId': 'user1',
          'weekStartDate': Timestamp.fromDate(monday),
          'createdAt': Timestamp.fromDate(DateTime(2025, 3, 17)),
          'updatedAt': Timestamp.fromDate(DateTime(2025, 3, 17)),
        };

        final plan = MealPlan.fromMap(map, 'plan_doc_3');
        expect(plan.meals, isEmpty);
      });

      test('parses weekStartDate from Timestamp correctly', () {
        final specificMonday = DateTime(2025, 1, 6);
        final map = {
          'userId': 'user1',
          'weekStartDate': Timestamp.fromDate(specificMonday),
          'meals': <dynamic>[],
          'createdAt': Timestamp.fromDate(DateTime(2025, 1, 6)),
          'updatedAt': Timestamp.fromDate(DateTime(2025, 1, 6)),
        };

        final plan = MealPlan.fromMap(map, 'doc1');
        expect(plan.weekStartDate, specificMonday);
      });

      test('parses PlannedMeal objects within meals list', () {
        final map = {
          'userId': 'user1',
          'weekStartDate': Timestamp.fromDate(monday),
          'meals': [
            {
              'day': 5,
              'mealType': 'dinner',
              'recipeId': 'r99',
              'recipeName': 'Pizza',
              'recipeImageUrl': 'https://example.com/pizza.jpg',
              'servings': 4,
            },
          ],
          'createdAt': Timestamp.fromDate(DateTime(2025, 3, 17)),
          'updatedAt': Timestamp.fromDate(DateTime(2025, 3, 17)),
        };

        final plan = MealPlan.fromMap(map, 'doc1');
        final meal = plan.meals.first;

        expect(meal.day, 5);
        expect(meal.mealType, 'dinner');
        expect(meal.recipeId, 'r99');
        expect(meal.recipeName, 'Pizza');
        expect(meal.recipeImageUrl, 'https://example.com/pizza.jpg');
        expect(meal.servings, 4);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final plan = MealPlan(
          id: 'plan1',
          userId: 'user1',
          weekStartDate: monday,
          meals: [
            PlannedMeal(
              day: 0,
              mealType: 'breakfast',
              recipeId: 'r1',
              recipeName: 'Oatmeal',
              servings: 1,
            ),
          ],
          createdAt: DateTime(2025, 3, 17, 10, 0),
          updatedAt: DateTime(2025, 3, 17, 12, 0),
        );

        final map = plan.toMap();

        expect(map['userId'], 'user1');
        expect(
          (map['weekStartDate'] as Timestamp).toDate(),
          monday,
        );
        expect(map['meals'], isA<List>());
        expect((map['meals'] as List).length, 1);
        expect(
          (map['createdAt'] as Timestamp).toDate(),
          DateTime(2025, 3, 17, 10, 0),
        );
        expect(
          (map['updatedAt'] as Timestamp).toDate(),
          DateTime(2025, 3, 17, 12, 0),
        );
      });

      test('does not include id in toMap output', () {
        final plan = MealPlan(
          id: 'plan1',
          userId: 'user1',
          weekStartDate: monday,
          meals: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = plan.toMap();
        expect(map.containsKey('id'), isFalse);
      });

      test('serializes empty meals list', () {
        final plan = MealPlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = plan.toMap();
        expect(map['meals'], isEmpty);
      });

      test('serializes nested PlannedMeal objects as maps', () {
        final plan = MealPlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [
            PlannedMeal(
              day: 1,
              mealType: 'lunch',
              recipeId: 'r1',
              recipeName: 'Salad',
              servings: 2,
            ),
            PlannedMeal(
              day: 3,
              mealType: 'dinner',
              recipeId: 'r2',
              recipeName: 'Soup',
              recipeImageUrl: 'https://example.com/soup.jpg',
              servings: 1,
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = plan.toMap();
        final mealsList = map['meals'] as List;

        expect(mealsList.length, 2);
        expect(mealsList[0], isA<Map<String, dynamic>>());
        expect(mealsList[0]['recipeName'], 'Salad');
        expect(mealsList[1]['recipeName'], 'Soup');
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves core fields', () {
        final original = MealPlan(
          id: 'plan1',
          userId: 'user1',
          weekStartDate: monday,
          meals: [
            PlannedMeal(
              day: 0,
              mealType: 'breakfast',
              recipeId: 'r1',
              recipeName: 'Eggs',
              servings: 2,
            ),
            PlannedMeal(
              day: 2,
              mealType: 'dinner',
              recipeId: 'r2',
              recipeName: 'Pasta',
              recipeImageUrl: 'https://example.com/pasta.jpg',
              servings: 3,
            ),
          ],
          createdAt: DateTime(2025, 3, 17, 8, 0),
          updatedAt: DateTime(2025, 3, 17, 9, 0),
        );

        final map = original.toMap();
        final restored = MealPlan.fromMap(map, 'plan1');

        expect(restored.id, original.id);
        expect(restored.userId, original.userId);
        expect(restored.weekStartDate, original.weekStartDate);
        expect(restored.meals.length, original.meals.length);
        expect(restored.meals[0].recipeName, 'Eggs');
        expect(restored.meals[1].recipeName, 'Pasta');
        expect(restored.createdAt, original.createdAt);
        expect(restored.updatedAt, original.updatedAt);
      });

      test('round-trip preserves empty meals list', () {
        final original = MealPlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [],
          createdAt: DateTime(2025, 3, 17),
          updatedAt: DateTime(2025, 3, 17),
        );

        final map = original.toMap();
        final restored = MealPlan.fromMap(map, 'doc1');

        expect(restored.meals, isEmpty);
      });

      test('round-trip preserves nested PlannedMeal details', () {
        final original = MealPlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [
            PlannedMeal(
              day: 6,
              mealType: 'snack',
              recipeId: 'r_snack',
              recipeName: 'Granola Bar',
              recipeImageUrl: 'https://example.com/granola.jpg',
              servings: 1,
            ),
          ],
          createdAt: DateTime(2025, 3, 17),
          updatedAt: DateTime(2025, 3, 17),
        );

        final map = original.toMap();
        final restored = MealPlan.fromMap(map, 'doc1');
        final restoredMeal = restored.meals.first;

        expect(restoredMeal.day, 6);
        expect(restoredMeal.mealType, 'snack');
        expect(restoredMeal.recipeId, 'r_snack');
        expect(restoredMeal.recipeName, 'Granola Bar');
        expect(restoredMeal.recipeImageUrl, 'https://example.com/granola.jpg');
        expect(restoredMeal.servings, 1);
      });
    });

    group('copyWith', () {
      late MealPlan original;

      setUp(() {
        original = MealPlan(
          id: 'plan1',
          userId: 'user1',
          weekStartDate: monday,
          meals: [
            PlannedMeal(
              day: 0,
              mealType: 'breakfast',
              recipeId: 'r1',
              recipeName: 'Oatmeal',
              servings: 1,
            ),
          ],
          createdAt: DateTime(2025, 3, 17, 10, 0),
          updatedAt: DateTime(2025, 3, 17, 12, 0),
        );
      });

      test('preserves all fields when no arguments given', () {
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.userId, original.userId);
        expect(copy.weekStartDate, original.weekStartDate);
        expect(copy.meals.length, original.meals.length);
        expect(copy.meals[0].recipeName, 'Oatmeal');
        expect(copy.createdAt, original.createdAt);
        expect(copy.updatedAt, original.updatedAt);
      });

      test('updates id only', () {
        final copy = original.copyWith(id: 'new_plan_id');

        expect(copy.id, 'new_plan_id');
        expect(copy.userId, original.userId);
        expect(copy.weekStartDate, original.weekStartDate);
      });

      test('updates userId only', () {
        final copy = original.copyWith(userId: 'user2');

        expect(copy.userId, 'user2');
        expect(copy.id, original.id);
      });

      test('updates weekStartDate only', () {
        final newMonday = DateTime(2025, 3, 24);
        final copy = original.copyWith(weekStartDate: newMonday);

        expect(copy.weekStartDate, newMonday);
        expect(copy.userId, original.userId);
      });

      test('updates meals list', () {
        final newMeals = [
          PlannedMeal(
            day: 1,
            mealType: 'lunch',
            recipeId: 'r10',
            recipeName: 'Burger',
            servings: 1,
          ),
          PlannedMeal(
            day: 3,
            mealType: 'dinner',
            recipeId: 'r11',
            recipeName: 'Sushi',
            servings: 2,
          ),
        ];

        final copy = original.copyWith(meals: newMeals);

        expect(copy.meals.length, 2);
        expect(copy.meals[0].recipeName, 'Burger');
        expect(copy.meals[1].recipeName, 'Sushi');
      });

      test('updates updatedAt only', () {
        final newTime = DateTime(2025, 4, 1, 15, 30);
        final copy = original.copyWith(updatedAt: newTime);

        expect(copy.updatedAt, newTime);
        expect(copy.createdAt, original.createdAt);
      });

      test('updates multiple fields simultaneously', () {
        final newMonday = DateTime(2025, 3, 24);
        final copy = original.copyWith(
          userId: 'user99',
          weekStartDate: newMonday,
          meals: [],
        );

        expect(copy.userId, 'user99');
        expect(copy.weekStartDate, newMonday);
        expect(copy.meals, isEmpty);
        expect(copy.id, original.id);
      });
    });

    group('edge cases', () {
      test('handles empty meals list', () {
        final plan = MealPlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(plan.meals, isEmpty);
      });

      test('handles null id', () {
        final plan = MealPlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(plan.id, isNull);
      });

      test('handles many meals across all days and types', () {
        final meals = <PlannedMeal>[];
        final types = ['breakfast', 'lunch', 'dinner', 'snack'];
        for (int day = 0; day < 7; day++) {
          for (final type in types) {
            meals.add(PlannedMeal(
              day: day,
              mealType: type,
              recipeId: 'r_${day}_$type',
              recipeName: '$type on day $day',
              servings: 1,
            ));
          }
        }

        final plan = MealPlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: meals,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(plan.meals.length, 28);
      });

      test('weekStartDate stored and read correctly through Timestamp', () {
        final localMonday = DateTime(2025, 6, 2);
        final plan = MealPlan(
          userId: 'user1',
          weekStartDate: localMonday,
          meals: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = plan.toMap();
        final restored = MealPlan.fromMap(map, 'doc1');

        // Timestamp round-trip preserves the same instant in time
        expect(
          restored.weekStartDate.millisecondsSinceEpoch,
          localMonday.millisecondsSinceEpoch,
        );
      });

      test('PlannedMeal with null recipeImageUrl serializes in MealPlan', () {
        final plan = MealPlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [
            PlannedMeal(
              day: 0,
              mealType: 'breakfast',
              recipeId: 'r1',
              recipeName: 'Toast',
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = plan.toMap();
        final mealMap = (map['meals'] as List).first as Map<String, dynamic>;
        expect(mealMap['recipeImageUrl'], isNull);

        final restored = MealPlan.fromMap(map, 'doc1');
        expect(restored.meals.first.recipeImageUrl, isNull);
      });

      test('weekStartDate Timestamp round-trip for different weeks', () {
        final weeks = [
          DateTime(2025, 1, 6),  // January Monday
          DateTime(2025, 6, 30), // June Monday
          DateTime(2025, 12, 29), // December Monday
        ];

        for (final week in weeks) {
          final plan = MealPlan(
            userId: 'user1',
            weekStartDate: week,
            meals: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final map = plan.toMap();
          final restored = MealPlan.fromMap(map, 'doc1');

          expect(
            restored.weekStartDate.millisecondsSinceEpoch,
            week.millisecondsSinceEpoch,
          );
        }
      });

      test('createdAt and updatedAt can differ', () {
        final created = DateTime(2025, 3, 17, 8, 0);
        final updated = DateTime(2025, 3, 18, 15, 30);

        final plan = MealPlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [],
          createdAt: created,
          updatedAt: updated,
        );

        final map = plan.toMap();
        final restored = MealPlan.fromMap(map, 'doc1');

        expect(restored.createdAt, created);
        expect(restored.updatedAt, updated);
        expect(restored.createdAt, isNot(equals(restored.updatedAt)));
      });

      test('multiple PlannedMeals with mixed recipeImageUrl values', () {
        final plan = MealPlan(
          userId: 'user1',
          weekStartDate: monday,
          meals: [
            PlannedMeal(
              day: 0,
              mealType: 'breakfast',
              recipeId: 'r1',
              recipeName: 'With Image',
              recipeImageUrl: 'https://example.com/img.jpg',
              servings: 1,
            ),
            PlannedMeal(
              day: 0,
              mealType: 'lunch',
              recipeId: 'r2',
              recipeName: 'Without Image',
              servings: 2,
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = plan.toMap();
        final restored = MealPlan.fromMap(map, 'doc1');

        expect(restored.meals[0].recipeImageUrl, 'https://example.com/img.jpg');
        expect(restored.meals[1].recipeImageUrl, isNull);
        expect(restored.meals[0].servings, 1);
        expect(restored.meals[1].servings, 2);
      });
    });
  });
}
