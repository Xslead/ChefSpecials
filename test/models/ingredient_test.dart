import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/ingredient.dart';

void main() {
  group('Ingredient', () {
    group('fromMap', () {
      test('creates Ingredient with all fields', () {
        final map = {
          'name': 'Flour',
          'amount': '200',
          'unit': 'g',
          'foodItemId': 'food123',
          'caloriesPer100': 364.0,
          'proteinPer100': 10.3,
          'carbsPer100': 76.3,
          'fatPer100': 1.0,
        };

        final ingredient = Ingredient.fromMap(map);

        expect(ingredient.name, 'Flour');
        expect(ingredient.amount, '200');
        expect(ingredient.unit, 'g');
        expect(ingredient.foodItemId, 'food123');
        expect(ingredient.caloriesPer100, 364.0);
        expect(ingredient.proteinPer100, 10.3);
        expect(ingredient.carbsPer100, 76.3);
        expect(ingredient.fatPer100, 1.0);
      });

      test('creates Ingredient with only required fields', () {
        final map = {
          'name': 'Salt',
          'amount': '1',
        };

        final ingredient = Ingredient.fromMap(map);

        expect(ingredient.name, 'Salt');
        expect(ingredient.amount, '1');
        expect(ingredient.unit, isNull);
        expect(ingredient.foodItemId, isNull);
        expect(ingredient.caloriesPer100, isNull);
        expect(ingredient.proteinPer100, isNull);
        expect(ingredient.carbsPer100, isNull);
        expect(ingredient.fatPer100, isNull);
      });

      test('converts int nutrition values to double', () {
        final map = {
          'name': 'Sugar',
          'amount': '50',
          'caloriesPer100': 387,
          'proteinPer100': 0,
          'carbsPer100': 100,
          'fatPer100': 0,
        };

        final ingredient = Ingredient.fromMap(map);

        expect(ingredient.caloriesPer100, 387.0);
        expect(ingredient.proteinPer100, 0.0);
        expect(ingredient.carbsPer100, 100.0);
        expect(ingredient.fatPer100, 0.0);
      });

      test('handles explicit null optional fields', () {
        final map = {
          'name': 'Water',
          'amount': '500',
          'unit': null,
          'foodItemId': null,
          'caloriesPer100': null,
          'proteinPer100': null,
          'carbsPer100': null,
          'fatPer100': null,
        };

        final ingredient = Ingredient.fromMap(map);

        expect(ingredient.unit, isNull);
        expect(ingredient.foodItemId, isNull);
        expect(ingredient.caloriesPer100, isNull);
      });
    });

    group('toMap', () {
      test('serializes all fields', () {
        final ingredient = Ingredient(
          name: 'Butter',
          amount: '100',
          unit: 'g',
          foodItemId: 'fi1',
          caloriesPer100: 717.0,
          proteinPer100: 0.85,
          carbsPer100: 0.06,
          fatPer100: 81.11,
        );

        final map = ingredient.toMap();

        expect(map['name'], 'Butter');
        expect(map['amount'], '100');
        expect(map['unit'], 'g');
        expect(map['foodItemId'], 'fi1');
        expect(map['caloriesPer100'], 717.0);
        expect(map['proteinPer100'], 0.85);
        expect(map['carbsPer100'], 0.06);
        expect(map['fatPer100'], 81.11);
      });

      test('includes null keys in map', () {
        final ingredient = Ingredient(
          name: 'Pepper',
          amount: '1',
        );

        final map = ingredient.toMap();

        expect(map.containsKey('unit'), isTrue);
        expect(map.containsKey('foodItemId'), isTrue);
        expect(map.containsKey('caloriesPer100'), isTrue);
        expect(map['unit'], isNull);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all populated fields', () {
        final originalMap = {
          'name': 'Chicken Breast',
          'amount': '250',
          'unit': 'g',
          'foodItemId': 'chicken001',
          'caloriesPer100': 165.0,
          'proteinPer100': 31.0,
          'carbsPer100': 0.0,
          'fatPer100': 3.6,
        };

        final ingredient = Ingredient.fromMap(originalMap);
        final resultMap = ingredient.toMap();

        expect(resultMap, originalMap);
      });

      test('round-trip preserves null fields', () {
        final originalMap = {
          'name': 'Pinch of salt',
          'amount': '1',
          'unit': null,
          'foodItemId': null,
          'caloriesPer100': null,
          'proteinPer100': null,
          'carbsPer100': null,
          'fatPer100': null,
        };

        final ingredient = Ingredient.fromMap(originalMap);
        final resultMap = ingredient.toMap();

        expect(resultMap, originalMap);
      });
    });

    group('edge cases', () {
      test('handles empty name', () {
        final ingredient = Ingredient(name: '', amount: '1');
        expect(ingredient.name, '');
      });

      test('handles empty amount', () {
        final ingredient = Ingredient(name: 'Salt', amount: '');
        expect(ingredient.amount, '');
      });

      test('handles zero nutrition values', () {
        final ingredient = Ingredient(
          name: 'Water',
          amount: '250',
          unit: 'mL',
          caloriesPer100: 0.0,
          proteinPer100: 0.0,
          carbsPer100: 0.0,
          fatPer100: 0.0,
        );

        expect(ingredient.caloriesPer100, 0.0);
        expect(ingredient.proteinPer100, 0.0);
        expect(ingredient.carbsPer100, 0.0);
        expect(ingredient.fatPer100, 0.0);
      });

      test('handles very large nutrition values', () {
        final ingredient = Ingredient(
          name: 'Concentrated oil',
          amount: '10',
          caloriesPer100: 9999.99,
          proteinPer100: 0.0,
          carbsPer100: 0.0,
          fatPer100: 99.99,
        );

        expect(ingredient.caloriesPer100, 9999.99);
        expect(ingredient.fatPer100, 99.99);
      });
    });
  });
}
