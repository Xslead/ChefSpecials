import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/food_item.dart';

void main() {
  Map<String, dynamic> fullMap() {
    return {
      'name': 'Whole Wheat Bread',
      'brand': 'BreadCo',
      'category': 'Bakery',
      'unit': '100g',
      'packetSize': 500.0,
      'barcode': '1234567890123',
      'isVegan': true,
      'isVegetarian': true,
      'isGlutenFree': false,
      'calories': 247.0,
      'protein': 13.0,
      'carbs': 41.0,
      'fat': 3.4,
      'saturatedFat': 0.7,
      'transFat': 0.0,
      'cholesterol': 0.0,
      'fiber': 7.0,
      'sugar': 6.0,
      'sodium': 400.0,
      'salt': 1.0,
      'nutriScore': 'A',
      'novaGroup': 3,
      'allergens': ['wheat', 'soy'],
      'ingredientsText': 'Whole wheat flour, water, yeast, salt',
      'origin': 'USA',
      'servingSize': 50.0,
      'imageUrl': 'https://example.com/bread.jpg',
      'addedBy': 'user1',
      'createdAt': '2024-06-15T10:30:00.000Z',
      'isVerified': true,
    };
  }

  Map<String, dynamic> minimalMap() {
    return {
      'name': 'Apple',
      'category': 'Fruit',
      'unit': '100g',
      'calories': 52,
      'protein': 0.3,
      'carbs': 13.8,
      'fat': 0.2,
      'fiber': 2.4,
      'sugar': 10.4,
      'sodium': 1,
      'addedBy': 'user1',
      'createdAt': '2024-01-01T00:00:00.000Z',
    };
  }

  group('FoodItem', () {
    group('fromMap', () {
      test('creates FoodItem with all fields', () {
        final map = fullMap();
        final item = FoodItem.fromMap(map, 'doc1');

        expect(item.id, 'doc1');
        expect(item.name, 'Whole Wheat Bread');
        expect(item.brand, 'BreadCo');
        expect(item.category, 'Bakery');
        expect(item.unit, '100g');
        expect(item.packetSize, 500.0);
        expect(item.barcode, '1234567890123');
        expect(item.isVegan, isTrue);
        expect(item.isVegetarian, isTrue);
        expect(item.isGlutenFree, isFalse);
        expect(item.calories, 247.0);
        expect(item.protein, 13.0);
        expect(item.carbs, 41.0);
        expect(item.fat, 3.4);
        expect(item.saturatedFat, 0.7);
        expect(item.transFat, 0.0);
        expect(item.cholesterol, 0.0);
        expect(item.fiber, 7.0);
        expect(item.sugar, 6.0);
        expect(item.sodium, 400.0);
        expect(item.salt, 1.0);
        expect(item.nutriScore, 'A');
        expect(item.novaGroup, 3);
        expect(item.allergens, ['wheat', 'soy']);
        expect(item.ingredientsText,
            'Whole wheat flour, water, yeast, salt');
        expect(item.origin, 'USA');
        expect(item.servingSize, 50.0);
        expect(item.imageUrl, 'https://example.com/bread.jpg');
        expect(item.addedBy, 'user1');
        expect(item.createdAt,
            DateTime.parse('2024-06-15T10:30:00.000Z'));
        expect(item.isVerified, isTrue);
      });

      test('creates FoodItem with minimal required fields and defaults', () {
        final map = minimalMap();
        final item = FoodItem.fromMap(map, 'doc2');

        expect(item.id, 'doc2');
        expect(item.name, 'Apple');
        expect(item.brand, isNull);
        expect(item.packetSize, 100.0);
        expect(item.barcode, isNull);
        expect(item.isVegan, isFalse);
        expect(item.isVegetarian, isFalse);
        expect(item.isGlutenFree, isFalse);
        expect(item.saturatedFat, 0.0);
        expect(item.transFat, 0.0);
        expect(item.cholesterol, 0.0);
        expect(item.salt, 0.0);
        expect(item.nutriScore, isNull);
        expect(item.novaGroup, isNull);
        expect(item.allergens, isEmpty);
        expect(item.ingredientsText, isNull);
        expect(item.origin, isNull);
        expect(item.servingSize, isNull);
        expect(item.imageUrl, isNull);
        expect(item.isVerified, isFalse);
      });

      test('defaults packetSize to 100 when missing', () {
        final map = minimalMap();
        final item = FoodItem.fromMap(map, 'doc1');
        expect(item.packetSize, 100.0);
      });

      test('defaults packetSize to 100 when null', () {
        final map = minimalMap();
        map['packetSize'] = null;
        final item = FoodItem.fromMap(map, 'doc1');
        expect(item.packetSize, 100.0);
      });

      test('defaults boolean fields to false', () {
        final map = minimalMap();
        final item = FoodItem.fromMap(map, 'doc1');

        expect(item.isVegan, isFalse);
        expect(item.isVegetarian, isFalse);
        expect(item.isGlutenFree, isFalse);
        expect(item.isVerified, isFalse);
      });

      test('defaults allergens to empty list when null', () {
        final map = minimalMap();
        map['allergens'] = null;
        final item = FoodItem.fromMap(map, 'doc1');
        expect(item.allergens, isEmpty);
      });

      test('defaults allergens to empty list when missing', () {
        final map = minimalMap();
        final item = FoodItem.fromMap(map, 'doc1');
        expect(item.allergens, isEmpty);
      });

      test('converts int nutrition values to double', () {
        final map = minimalMap();
        final item = FoodItem.fromMap(map, 'doc1');

        expect(item.calories, isA<double>());
        expect(item.protein, isA<double>());
        expect(item.carbs, isA<double>());
        expect(item.fat, isA<double>());
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final dt = DateTime(2024, 6, 15, 10, 30);
        final item = FoodItem(
          id: 'doc1',
          name: 'Test Food',
          brand: 'TestBrand',
          category: 'TestCat',
          unit: '100g',
          packetSize: 200.0,
          barcode: '123',
          isVegan: true,
          isVegetarian: true,
          isGlutenFree: true,
          calories: 100.0,
          protein: 10.0,
          carbs: 20.0,
          fat: 5.0,
          saturatedFat: 1.0,
          transFat: 0.5,
          cholesterol: 10.0,
          fiber: 3.0,
          sugar: 5.0,
          sodium: 200.0,
          salt: 0.5,
          nutriScore: 'B',
          novaGroup: 2,
          allergens: ['milk'],
          ingredientsText: 'Test ingredients',
          origin: 'France',
          servingSize: 30.0,
          imageUrl: 'https://example.com/img.jpg',
          addedBy: 'user1',
          createdAt: dt,
          isVerified: true,
        );

        final map = item.toMap();

        expect(map['name'], 'Test Food');
        expect(map['brand'], 'TestBrand');
        expect(map['category'], 'TestCat');
        expect(map['unit'], '100g');
        expect(map['packetSize'], 200.0);
        expect(map['barcode'], '123');
        expect(map['isVegan'], isTrue);
        expect(map['isVegetarian'], isTrue);
        expect(map['isGlutenFree'], isTrue);
        expect(map['calories'], 100.0);
        expect(map['protein'], 10.0);
        expect(map['carbs'], 20.0);
        expect(map['fat'], 5.0);
        expect(map['saturatedFat'], 1.0);
        expect(map['transFat'], 0.5);
        expect(map['cholesterol'], 10.0);
        expect(map['fiber'], 3.0);
        expect(map['sugar'], 5.0);
        expect(map['sodium'], 200.0);
        expect(map['salt'], 0.5);
        expect(map['nutriScore'], 'B');
        expect(map['novaGroup'], 2);
        expect(map['allergens'], ['milk']);
        expect(map['ingredientsText'], 'Test ingredients');
        expect(map['origin'], 'France');
        expect(map['servingSize'], 30.0);
        expect(map['imageUrl'], 'https://example.com/img.jpg');
        expect(map['addedBy'], 'user1');
        expect(map['createdAt'], dt.toIso8601String());
        expect(map['isVerified'], isTrue);
      });

      test('does not include id in toMap output', () {
        final item = FoodItem(
          id: 'doc1',
          name: 'Test',
          category: 'Cat',
          unit: '100g',
          packetSize: 100.0,
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          fiber: 0,
          sugar: 0,
          sodium: 0,
          addedBy: 'u1',
          createdAt: DateTime.now(),
        );

        final map = item.toMap();
        expect(map.containsKey('id'), isFalse);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all fields', () {
        final originalMap = fullMap();
        final item = FoodItem.fromMap(originalMap, 'doc1');
        final resultMap = item.toMap();

        expect(resultMap['name'], originalMap['name']);
        expect(resultMap['brand'], originalMap['brand']);
        expect(resultMap['category'], originalMap['category']);
        expect(resultMap['unit'], originalMap['unit']);
        expect(resultMap['packetSize'], originalMap['packetSize']);
        expect(resultMap['barcode'], originalMap['barcode']);
        expect(resultMap['isVegan'], originalMap['isVegan']);
        expect(resultMap['isVegetarian'], originalMap['isVegetarian']);
        expect(resultMap['isGlutenFree'], originalMap['isGlutenFree']);
        expect(resultMap['calories'], originalMap['calories']);
        expect(resultMap['protein'], originalMap['protein']);
        expect(resultMap['carbs'], originalMap['carbs']);
        expect(resultMap['fat'], originalMap['fat']);
        expect(resultMap['saturatedFat'], originalMap['saturatedFat']);
        expect(resultMap['transFat'], originalMap['transFat']);
        expect(resultMap['cholesterol'], originalMap['cholesterol']);
        expect(resultMap['fiber'], originalMap['fiber']);
        expect(resultMap['sugar'], originalMap['sugar']);
        expect(resultMap['sodium'], originalMap['sodium']);
        expect(resultMap['salt'], originalMap['salt']);
        expect(resultMap['nutriScore'], originalMap['nutriScore']);
        expect(resultMap['novaGroup'], originalMap['novaGroup']);
        expect(resultMap['allergens'], originalMap['allergens']);
        expect(resultMap['ingredientsText'], originalMap['ingredientsText']);
        expect(resultMap['origin'], originalMap['origin']);
        expect(resultMap['servingSize'], originalMap['servingSize']);
        expect(resultMap['imageUrl'], originalMap['imageUrl']);
        expect(resultMap['addedBy'], originalMap['addedBy']);
        expect(resultMap['isVerified'], originalMap['isVerified']);
      });
    });

    group('computed per-packet getters', () {
      late FoodItem item;

      setUp(() {
        item = FoodItem(
          name: 'Test Food',
          category: 'Test',
          unit: '100g',
          packetSize: 250.0,
          calories: 200.0,
          protein: 10.0,
          carbs: 30.0,
          fat: 8.0,
          saturatedFat: 2.0,
          transFat: 0.5,
          cholesterol: 20.0,
          fiber: 5.0,
          sugar: 10.0,
          sodium: 300.0,
          salt: 0.75,
          addedBy: 'user1',
          createdAt: DateTime.now(),
        );
      });

      test('caloriesPerPacket calculates correctly', () {
        expect(item.caloriesPerPacket, 200.0 * 250.0 / 100);
      });

      test('proteinPerPacket calculates correctly', () {
        expect(item.proteinPerPacket, 10.0 * 250.0 / 100);
      });

      test('carbsPerPacket calculates correctly', () {
        expect(item.carbsPerPacket, 30.0 * 250.0 / 100);
      });

      test('fatPerPacket calculates correctly', () {
        expect(item.fatPerPacket, 8.0 * 250.0 / 100);
      });

      test('saturatedFatPerPacket calculates correctly', () {
        expect(item.saturatedFatPerPacket, 2.0 * 250.0 / 100);
      });

      test('transFatPerPacket calculates correctly', () {
        expect(item.transFatPerPacket, 0.5 * 250.0 / 100);
      });

      test('cholesterolPerPacket calculates correctly', () {
        expect(item.cholesterolPerPacket, 20.0 * 250.0 / 100);
      });

      test('fiberPerPacket calculates correctly', () {
        expect(item.fiberPerPacket, 5.0 * 250.0 / 100);
      });

      test('sugarPerPacket calculates correctly', () {
        expect(item.sugarPerPacket, 10.0 * 250.0 / 100);
      });

      test('sodiumPerPacket calculates correctly', () {
        expect(item.sodiumPerPacket, 300.0 * 250.0 / 100);
      });

      test('saltPerPacket calculates correctly', () {
        expect(item.saltPerPacket, 0.75 * 250.0 / 100);
      });

      test('per-packet values are zero when nutrition is zero', () {
        final zeroItem = FoodItem(
          name: 'Water',
          category: 'Beverage',
          unit: 'mL',
          packetSize: 500.0,
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          fiber: 0,
          sugar: 0,
          sodium: 0,
          addedBy: 'u1',
          createdAt: DateTime.now(),
        );

        expect(zeroItem.caloriesPerPacket, 0.0);
        expect(zeroItem.proteinPerPacket, 0.0);
        expect(zeroItem.carbsPerPacket, 0.0);
        expect(zeroItem.fatPerPacket, 0.0);
      });

      test('per-packet getters with packetSize 100 return same as per-100 values', () {
        final item100 = FoodItem(
          name: 'Test',
          category: 'Cat',
          unit: '100g',
          packetSize: 100.0,
          calories: 250,
          protein: 15,
          carbs: 30,
          fat: 10,
          fiber: 5,
          sugar: 8,
          sodium: 200,
          addedBy: 'u1',
          createdAt: DateTime.now(),
        );

        expect(item100.caloriesPerPacket, 250.0);
        expect(item100.proteinPerPacket, 15.0);
        expect(item100.carbsPerPacket, 30.0);
        expect(item100.fatPerPacket, 10.0);
      });
    });

    group('edge cases', () {
      test('handles empty allergens list', () {
        final item = FoodItem(
          name: 'Test',
          category: 'Cat',
          unit: '100g',
          packetSize: 100,
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          fiber: 0,
          sugar: 0,
          sodium: 0,
          allergens: [],
          addedBy: 'u1',
          createdAt: DateTime.now(),
        );

        expect(item.allergens, isEmpty);
      });

      test('handles nutriScore values A through E', () {
        for (final score in ['A', 'B', 'C', 'D', 'E']) {
          final item = FoodItem(
            name: 'Test',
            category: 'Cat',
            unit: '100g',
            packetSize: 100,
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            fiber: 0,
            sugar: 0,
            sodium: 0,
            nutriScore: score,
            addedBy: 'u1',
            createdAt: DateTime.now(),
          );
          expect(item.nutriScore, score);
        }
      });

      test('handles novaGroup values 1 through 4', () {
        for (int group = 1; group <= 4; group++) {
          final item = FoodItem(
            name: 'Test',
            category: 'Cat',
            unit: '100g',
            packetSize: 100,
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            fiber: 0,
            sugar: 0,
            sodium: 0,
            novaGroup: group,
            addedBy: 'u1',
            createdAt: DateTime.now(),
          );
          expect(item.novaGroup, group);
        }
      });

      test('handles very small packetSize', () {
        final item = FoodItem(
          name: 'Saffron',
          category: 'Spice',
          unit: '100g',
          packetSize: 0.5,
          calories: 310,
          protein: 11,
          carbs: 65,
          fat: 6,
          fiber: 4,
          sugar: 0,
          sodium: 148,
          addedBy: 'u1',
          createdAt: DateTime.now(),
        );

        expect(item.caloriesPerPacket, closeTo(1.55, 0.01));
      });
    });
  });
}
