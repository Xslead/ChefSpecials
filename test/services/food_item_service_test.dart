import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/food_item_service.dart';
import 'package:chef_specials/models/food_item.dart';

FoodItem _makeFoodItem({
  String name = 'Apple',
  String category = 'Fruits',
  double calories = 52,
  double protein = 0.3,
  double carbs = 14,
  double fat = 0.2,
  double fiber = 2.4,
  double sugar = 10.4,
  double sodium = 1,
  String addedBy = 'admin',
  DateTime? createdAt,
}) {
  return FoodItem(
    name: name,
    category: category,
    unit: '100g',
    packetSize: 100,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    fiber: fiber,
    sugar: sugar,
    sodium: sodium,
    addedBy: addedBy,
    createdAt: createdAt ?? DateTime(2024, 1, 1),
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FoodItemService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = FoodItemService(firestore: fakeFirestore);
  });

  group('FoodItemService', () {
    group('addFoodItem', () {
      test('should add a food item to Firestore', () async {
        final item = _makeFoodItem(name: 'Banana');
        await service.addFoodItem(item);

        final snapshot =
            await fakeFirestore.collection('food_items').get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['name'], 'Banana');
      });
    });

    group('getFoodItemById', () {
      test('should return a food item by its ID', () async {
        final item = _makeFoodItem(name: 'Carrot');
        await service.addFoodItem(item);

        final snapshot =
            await fakeFirestore.collection('food_items').get();
        final docId = snapshot.docs.first.id;

        final result = await service.getFoodItemById(docId);
        expect(result, isNotNull);
        expect(result!.name, 'Carrot');
        expect(result.id, docId);
      });

      test('should return null for non-existent ID', () async {
        final result = await service.getFoodItemById('nonexistent');
        expect(result, isNull);
      });
    });

    group('getFoodItems', () {
      test('should return all food items ordered by name', () async {
        await service.addFoodItem(_makeFoodItem(name: 'Cherry'));
        await service.addFoodItem(_makeFoodItem(name: 'Apple'));
        await service.addFoodItem(_makeFoodItem(name: 'Banana'));

        final items = await service.getFoodItems().first;

        expect(items.length, 3);
        expect(items[0].name, 'Apple');
        expect(items[1].name, 'Banana');
        expect(items[2].name, 'Cherry');
      });

      test('should return empty list when no items exist', () async {
        final items = await service.getFoodItems().first;
        expect(items, isEmpty);
      });
    });

    group('getFoodItemsByCategory', () {
      test('should return only items matching the category', () async {
        await service.addFoodItem(_makeFoodItem(name: 'Apple', category: 'Fruits'));
        await service.addFoodItem(_makeFoodItem(name: 'Broccoli', category: 'Vegetables'));
        await service.addFoodItem(_makeFoodItem(name: 'Banana', category: 'Fruits'));

        final items =
            await service.getFoodItemsByCategory('Fruits').first;

        expect(items.length, 2);
        expect(items.every((i) => i.category == 'Fruits'), isTrue);
      });

      test('should return empty list for non-existent category', () async {
        await service.addFoodItem(_makeFoodItem(category: 'Fruits'));

        final items =
            await service.getFoodItemsByCategory('Dairy').first;
        expect(items, isEmpty);
      });
    });

    group('searchFoodItems', () {
      test('should find items matching the query (case-insensitive)', () async {
        await service.addFoodItem(_makeFoodItem(name: 'Apple'));
        await service.addFoodItem(_makeFoodItem(name: 'Pineapple'));
        await service.addFoodItem(_makeFoodItem(name: 'Banana'));

        final results = await service.searchFoodItems('apple');

        expect(results.length, 2);
        expect(results.map((r) => r.name), containsAll(['Apple', 'Pineapple']));
      });

      test('should return empty list when no items match', () async {
        await service.addFoodItem(_makeFoodItem(name: 'Apple'));

        final results = await service.searchFoodItems('xyz');
        expect(results, isEmpty);
      });

      test('should match partial names', () async {
        await service.addFoodItem(_makeFoodItem(name: 'Strawberry'));

        final results = await service.searchFoodItems('raw');
        expect(results.length, 1);
        expect(results[0].name, 'Strawberry');
      });
    });

    group('updateFoodItem', () {
      test('should update a food item', () async {
        await service.addFoodItem(_makeFoodItem(name: 'Apple'));
        final snapshot =
            await fakeFirestore.collection('food_items').get();
        final docId = snapshot.docs.first.id;

        final original = await service.getFoodItemById(docId);
        final updated = FoodItem(
          id: docId,
          name: 'Green Apple',
          category: original!.category,
          unit: original.unit,
          packetSize: original.packetSize,
          calories: original.calories,
          protein: original.protein,
          carbs: original.carbs,
          fat: original.fat,
          fiber: original.fiber,
          sugar: original.sugar,
          sodium: original.sodium,
          addedBy: original.addedBy,
          createdAt: original.createdAt,
        );

        await service.updateFoodItem(updated);

        final result = await service.getFoodItemById(docId);
        expect(result!.name, 'Green Apple');
      });
    });

    group('deleteFoodItem', () {
      test('should delete a food item by ID', () async {
        await service.addFoodItem(_makeFoodItem(name: 'ToDelete'));
        final snapshot =
            await fakeFirestore.collection('food_items').get();
        final docId = snapshot.docs.first.id;

        await service.deleteFoodItem(docId);

        final result = await service.getFoodItemById(docId);
        expect(result, isNull);
      });
    });
  });
}
