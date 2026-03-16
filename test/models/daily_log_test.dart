import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/daily_log.dart';
import 'package:chef_specials/models/meal_entry.dart';

void main() {
  MealEntry makeMealEntry({
    String name = 'Test',
    MealType mealType = MealType.breakfast,
    double calories = 100.0,
    double protein = 10.0,
    double carbs = 20.0,
    double fat = 5.0,
    double quantity = 100.0,
    String unit = 'g',
  }) {
    return MealEntry(
      name: name,
      mealType: mealType,
      quantity: quantity,
      unit: unit,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }

  group('DailyLog', () {
    group('fromMap', () {
      test('creates DailyLog with all fields', () {
        final map = {
          'userId': 'user1',
          'date': '2024-06-15',
          'meals': [
            {
              'name': 'Eggs',
              'mealType': 'breakfast',
              'quantity': 100,
              'unit': 'g',
              'calories': 155,
              'protein': 13,
              'carbs': 1.1,
              'fat': 11,
            }
          ],
          'waterMl': 2000,
        };

        final log = DailyLog.fromMap(map, 'doc1');

        expect(log.id, 'doc1');
        expect(log.userId, 'user1');
        expect(log.date, '2024-06-15');
        expect(log.meals.length, 1);
        expect(log.meals.first.name, 'Eggs');
        expect(log.waterMl, 2000);
      });

      test('defaults meals to empty list when null', () {
        final map = {
          'userId': 'user1',
          'date': '2024-06-15',
          'meals': null,
          'waterMl': 500,
        };

        final log = DailyLog.fromMap(map, 'doc1');

        expect(log.meals, isEmpty);
      });

      test('defaults meals to empty list when missing', () {
        final map = {
          'userId': 'user1',
          'date': '2024-06-15',
        };

        final log = DailyLog.fromMap(map, 'doc1');

        expect(log.meals, isEmpty);
      });

      test('defaults waterMl to 0 when missing', () {
        final map = {
          'userId': 'user1',
          'date': '2024-06-15',
        };

        final log = DailyLog.fromMap(map, 'doc1');

        expect(log.waterMl, 0);
      });

      test('defaults waterMl to 0 when null', () {
        final map = {
          'userId': 'user1',
          'date': '2024-06-15',
          'waterMl': null,
        };

        final log = DailyLog.fromMap(map, 'doc1');

        expect(log.waterMl, 0);
      });

      test('parses multiple meals', () {
        final map = {
          'userId': 'user1',
          'date': '2024-06-15',
          'meals': [
            {
              'name': 'Eggs',
              'mealType': 'breakfast',
              'quantity': 100,
              'unit': 'g',
              'calories': 155,
              'protein': 13,
              'carbs': 1.1,
              'fat': 11,
            },
            {
              'name': 'Salad',
              'mealType': 'lunch',
              'quantity': 200,
              'unit': 'g',
              'calories': 50,
              'protein': 3,
              'carbs': 8,
              'fat': 1,
            },
          ],
          'waterMl': 1500,
        };

        final log = DailyLog.fromMap(map, 'doc1');

        expect(log.meals.length, 2);
        expect(log.meals[0].name, 'Eggs');
        expect(log.meals[1].name, 'Salad');
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final log = DailyLog(
          id: 'doc1',
          userId: 'user1',
          date: '2024-06-15',
          meals: [
            makeMealEntry(name: 'Oatmeal', mealType: MealType.breakfast),
          ],
          waterMl: 3000,
        );

        final map = log.toMap();

        expect(map['userId'], 'user1');
        expect(map['date'], '2024-06-15');
        expect(map['meals'], isA<List>());
        expect((map['meals'] as List).length, 1);
        expect(map['waterMl'], 3000);
      });

      test('does not include id in toMap output', () {
        final log = DailyLog(
          id: 'doc1',
          userId: 'user1',
          date: '2024-06-15',
          meals: [],
          waterMl: 0,
        );

        final map = log.toMap();

        expect(map.containsKey('id'), isFalse);
      });

      test('serializes empty meals list', () {
        final log = DailyLog(
          userId: 'user1',
          date: '2024-06-15',
          meals: [],
        );

        final map = log.toMap();

        expect(map['meals'], isEmpty);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves data', () {
        final originalMap = {
          'userId': 'user1',
          'date': '2024-06-15',
          'meals': [
            {
              'name': 'Toast',
              'mealType': 'breakfast',
              'foodItemId': null,
              'recipeId': null,
              'quantity': 50.0,
              'unit': 'g',
              'calories': 132.0,
              'protein': 4.0,
              'carbs': 25.0,
              'fat': 2.0,
            },
          ],
          'waterMl': 1000,
        };

        final log = DailyLog.fromMap(originalMap, 'doc1');
        final resultMap = log.toMap();

        expect(resultMap['userId'], originalMap['userId']);
        expect(resultMap['date'], originalMap['date']);
        expect(resultMap['waterMl'], originalMap['waterMl']);
        expect((resultMap['meals'] as List).length, 1);
      });
    });

    group('computed getters', () {
      test('totalCalories sums all meal calories', () {
        final log = DailyLog(
          userId: 'u1',
          date: '2024-01-01',
          meals: [
            makeMealEntry(calories: 300),
            makeMealEntry(calories: 500),
            makeMealEntry(calories: 200),
          ],
        );

        expect(log.totalCalories, 1000.0);
      });

      test('totalProtein sums all meal protein', () {
        final log = DailyLog(
          userId: 'u1',
          date: '2024-01-01',
          meals: [
            makeMealEntry(protein: 20),
            makeMealEntry(protein: 30),
          ],
        );

        expect(log.totalProtein, 50.0);
      });

      test('totalCarbs sums all meal carbs', () {
        final log = DailyLog(
          userId: 'u1',
          date: '2024-01-01',
          meals: [
            makeMealEntry(carbs: 40),
            makeMealEntry(carbs: 60),
          ],
        );

        expect(log.totalCarbs, 100.0);
      });

      test('totalFat sums all meal fat', () {
        final log = DailyLog(
          userId: 'u1',
          date: '2024-01-01',
          meals: [
            makeMealEntry(fat: 10),
            makeMealEntry(fat: 15.5),
          ],
        );

        expect(log.totalFat, 25.5);
      });

      test('totalWaterMl returns waterMl', () {
        final log = DailyLog(
          userId: 'u1',
          date: '2024-01-01',
          meals: [],
          waterMl: 2500,
        );

        expect(log.totalWaterMl, 2500);
      });

      test('computed getters return 0 for empty meals', () {
        final log = DailyLog(
          userId: 'u1',
          date: '2024-01-01',
          meals: [],
        );

        expect(log.totalCalories, 0.0);
        expect(log.totalProtein, 0.0);
        expect(log.totalCarbs, 0.0);
        expect(log.totalFat, 0.0);
      });
    });

    group('mealsOfType', () {
      test('filters meals by MealType.breakfast', () {
        final log = DailyLog(
          userId: 'u1',
          date: '2024-01-01',
          meals: [
            makeMealEntry(name: 'Eggs', mealType: MealType.breakfast),
            makeMealEntry(name: 'Salad', mealType: MealType.lunch),
            makeMealEntry(name: 'Toast', mealType: MealType.breakfast),
          ],
        );

        final breakfastMeals = log.mealsOfType(MealType.breakfast);

        expect(breakfastMeals.length, 2);
        expect(breakfastMeals[0].name, 'Eggs');
        expect(breakfastMeals[1].name, 'Toast');
      });

      test('returns empty list when no meals of that type', () {
        final log = DailyLog(
          userId: 'u1',
          date: '2024-01-01',
          meals: [
            makeMealEntry(mealType: MealType.breakfast),
            makeMealEntry(mealType: MealType.lunch),
          ],
        );

        expect(log.mealsOfType(MealType.dinner), isEmpty);
        expect(log.mealsOfType(MealType.snack), isEmpty);
      });

      test('returns empty list for empty meals', () {
        final log = DailyLog(
          userId: 'u1',
          date: '2024-01-01',
          meals: [],
        );

        expect(log.mealsOfType(MealType.breakfast), isEmpty);
      });
    });

    group('caloriesForMeal', () {
      test('sums calories for a specific meal type', () {
        final log = DailyLog(
          userId: 'u1',
          date: '2024-01-01',
          meals: [
            makeMealEntry(
                mealType: MealType.breakfast, calories: 300),
            makeMealEntry(
                mealType: MealType.lunch, calories: 500),
            makeMealEntry(
                mealType: MealType.breakfast, calories: 150),
          ],
        );

        expect(log.caloriesForMeal(MealType.breakfast), 450.0);
        expect(log.caloriesForMeal(MealType.lunch), 500.0);
        expect(log.caloriesForMeal(MealType.dinner), 0.0);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated meals', () {
        final originalMeals = [
          makeMealEntry(name: 'Old meal'),
        ];
        final newMeals = [
          makeMealEntry(name: 'New meal 1'),
          makeMealEntry(name: 'New meal 2'),
        ];

        final original = DailyLog(
          id: 'doc1',
          userId: 'user1',
          date: '2024-06-15',
          meals: originalMeals,
          waterMl: 1000,
        );

        final updated = original.copyWith(meals: newMeals);

        expect(updated.id, 'doc1');
        expect(updated.userId, 'user1');
        expect(updated.date, '2024-06-15');
        expect(updated.meals.length, 2);
        expect(updated.meals[0].name, 'New meal 1');
        expect(updated.waterMl, 1000);
      });

      test('returns new instance with updated waterMl', () {
        final original = DailyLog(
          id: 'doc1',
          userId: 'user1',
          date: '2024-06-15',
          meals: [],
          waterMl: 1000,
        );

        final updated = original.copyWith(waterMl: 2500);

        expect(updated.waterMl, 2500);
        expect(updated.id, 'doc1');
        expect(updated.userId, 'user1');
      });

      test('preserves all fields when no arguments given', () {
        final meals = [makeMealEntry()];
        final original = DailyLog(
          id: 'doc1',
          userId: 'user1',
          date: '2024-06-15',
          meals: meals,
          waterMl: 1500,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.userId, original.userId);
        expect(copy.date, original.date);
        expect(copy.meals, original.meals);
        expect(copy.waterMl, original.waterMl);
      });

      test('can update both meals and waterMl simultaneously', () {
        final original = DailyLog(
          userId: 'user1',
          date: '2024-06-15',
          meals: [],
          waterMl: 0,
        );

        final updated = original.copyWith(
          meals: [makeMealEntry(name: 'New')],
          waterMl: 3000,
        );

        expect(updated.meals.length, 1);
        expect(updated.waterMl, 3000);
      });
    });
  });
}
