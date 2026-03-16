import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/nutrition_goal.dart';

void main() {
  group('NutritionGoal', () {
    group('fromMap', () {
      test('creates NutritionGoal with all fields', () {
        final map = {
          'calorieTarget': 2500.0,
          'proteinTarget': 80.0,
          'carbsTarget': 300.0,
          'fatTarget': 70.0,
          'waterTargetMl': 3000,
        };

        final goal = NutritionGoal.fromMap(map, 'user123');

        expect(goal.userId, 'user123');
        expect(goal.calorieTarget, 2500.0);
        expect(goal.proteinTarget, 80.0);
        expect(goal.carbsTarget, 300.0);
        expect(goal.fatTarget, 70.0);
        expect(goal.waterTargetMl, 3000);
      });

      test('uses default values when fields are missing', () {
        final map = <String, dynamic>{};

        final goal = NutritionGoal.fromMap(map, 'user1');

        expect(goal.calorieTarget, 2000);
        expect(goal.proteinTarget, 50);
        expect(goal.carbsTarget, 250);
        expect(goal.fatTarget, 65);
        expect(goal.waterTargetMl, 2500);
      });

      test('uses default values when fields are null', () {
        final map = {
          'calorieTarget': null,
          'proteinTarget': null,
          'carbsTarget': null,
          'fatTarget': null,
          'waterTargetMl': null,
        };

        final goal = NutritionGoal.fromMap(map, 'user1');

        expect(goal.calorieTarget, 2000);
        expect(goal.proteinTarget, 50);
        expect(goal.carbsTarget, 250);
        expect(goal.fatTarget, 65);
        expect(goal.waterTargetMl, 2500);
      });

      test('converts int values to double for numeric fields', () {
        final map = {
          'calorieTarget': 2000,
          'proteinTarget': 50,
          'carbsTarget': 250,
          'fatTarget': 65,
          'waterTargetMl': 2500,
        };

        final goal = NutritionGoal.fromMap(map, 'user1');

        expect(goal.calorieTarget, isA<double>());
        expect(goal.proteinTarget, isA<double>());
        expect(goal.carbsTarget, isA<double>());
        expect(goal.fatTarget, isA<double>());
        expect(goal.calorieTarget, 2000.0);
      });

      test('userId comes from parameter not map', () {
        final map = {
          'userId': 'wrongUser',
          'calorieTarget': 2000,
        };

        final goal = NutritionGoal.fromMap(map, 'correctUser');

        expect(goal.userId, 'correctUser');
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final goal = NutritionGoal(
          userId: 'user1',
          calorieTarget: 1800.0,
          proteinTarget: 60.0,
          carbsTarget: 220.0,
          fatTarget: 55.0,
          waterTargetMl: 2000,
        );

        final map = goal.toMap();

        expect(map['calorieTarget'], 1800.0);
        expect(map['proteinTarget'], 60.0);
        expect(map['carbsTarget'], 220.0);
        expect(map['fatTarget'], 55.0);
        expect(map['waterTargetMl'], 2000);
      });

      test('does not include userId in toMap output', () {
        final goal = NutritionGoal(
          userId: 'user1',
          calorieTarget: 2000,
          proteinTarget: 50,
          carbsTarget: 250,
          fatTarget: 65,
        );

        final map = goal.toMap();

        expect(map.containsKey('userId'), isFalse);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all fields', () {
        final originalMap = {
          'calorieTarget': 2200.0,
          'proteinTarget': 75.0,
          'carbsTarget': 280.0,
          'fatTarget': 60.0,
          'waterTargetMl': 2800,
        };

        final goal = NutritionGoal.fromMap(originalMap, 'user1');
        final resultMap = goal.toMap();

        expect(resultMap, originalMap);
      });
    });

    group('defaultGoal factory', () {
      test('creates goal with standard default values', () {
        final goal = NutritionGoal.defaultGoal('user1');

        expect(goal.userId, 'user1');
        expect(goal.calorieTarget, 2000);
        expect(goal.proteinTarget, 50);
        expect(goal.carbsTarget, 250);
        expect(goal.fatTarget, 65);
        expect(goal.waterTargetMl, 2500);
      });

      test('sets userId from parameter', () {
        final goal = NutritionGoal.defaultGoal('myUser');
        expect(goal.userId, 'myUser');
      });

      test('default factory produces same values as fromMap with empty map', () {
        final defaultGoal = NutritionGoal.defaultGoal('user1');
        final fromEmptyMap = NutritionGoal.fromMap({}, 'user1');

        expect(defaultGoal.calorieTarget, fromEmptyMap.calorieTarget);
        expect(defaultGoal.proteinTarget, fromEmptyMap.proteinTarget);
        expect(defaultGoal.carbsTarget, fromEmptyMap.carbsTarget);
        expect(defaultGoal.fatTarget, fromEmptyMap.fatTarget);
        expect(defaultGoal.waterTargetMl, fromEmptyMap.waterTargetMl);
      });
    });

    group('constructor', () {
      test('waterTargetMl defaults to 2500', () {
        final goal = NutritionGoal(
          userId: 'user1',
          calorieTarget: 2000,
          proteinTarget: 50,
          carbsTarget: 250,
          fatTarget: 65,
        );

        expect(goal.waterTargetMl, 2500);
      });
    });

    group('edge cases', () {
      test('handles zero values', () {
        final goal = NutritionGoal(
          userId: 'user1',
          calorieTarget: 0,
          proteinTarget: 0,
          carbsTarget: 0,
          fatTarget: 0,
          waterTargetMl: 0,
        );

        expect(goal.calorieTarget, 0);
        expect(goal.proteinTarget, 0);
        expect(goal.carbsTarget, 0);
        expect(goal.fatTarget, 0);
        expect(goal.waterTargetMl, 0);
      });

      test('handles very large values', () {
        final goal = NutritionGoal(
          userId: 'user1',
          calorieTarget: 10000,
          proteinTarget: 500,
          carbsTarget: 1000,
          fatTarget: 500,
          waterTargetMl: 10000,
        );

        expect(goal.calorieTarget, 10000);
        expect(goal.waterTargetMl, 10000);
      });

      test('handles empty string userId', () {
        final goal = NutritionGoal.defaultGoal('');
        expect(goal.userId, '');
      });
    });
  });
}
