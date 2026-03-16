import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/food_item_provider.dart';
import 'package:chef_specials/services/food_item_service.dart';
import 'package:chef_specials/models/food_item.dart';

FoodItem _makeFoodItem({
  String name = 'Apple',
  String category = 'Fruits',
  double calories = 52,
  double protein = 0.3,
  double carbs = 14,
  double fat = 0.2,
  bool isVegan = false,
  bool isVegetarian = false,
  bool isGlutenFree = false,
  String? nutriScore,
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
    fiber: 2.4,
    sugar: 10.4,
    sodium: 1,
    addedBy: 'user1',
    createdAt: DateTime.now(),
    isVegan: isVegan,
    isVegetarian: isVegetarian,
    isGlutenFree: isGlutenFree,
    nutriScore: nutriScore,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FoodItemService foodItemService;
  late FoodItemProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    foodItemService = FoodItemService(firestore: fakeFirestore);
    provider = FoodItemProvider(foodItemService: foodItemService);
  });

  group('FoodItemProvider', () {
    test('initial state', () {
      expect(provider.foodItems, isEmpty);
      expect(provider.searchResults, isEmpty);
      expect(provider.selectedCategory, 'All');
      expect(provider.isLoading, false);
      expect(provider.searchQuery, '');
    });

    test('ensureInitialized loads food items', () async {
      await foodItemService.addFoodItem(_makeFoodItem(name: 'Apple'));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      expect(provider.foodItems, hasLength(1));
      expect(provider.foodItems.first.name, 'Apple');
    });

    test('ensureInitialized only initializes once', () async {
      await foodItemService.addFoodItem(_makeFoodItem());

      provider.ensureInitialized();
      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      expect(provider.foodItems, hasLength(1));
    });

    test('setCategory changes category and reloads items', () async {
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Apple', category: 'Fruits'));
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Chicken', category: 'Meat'));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);
      expect(provider.foodItems, hasLength(2));

      provider.setCategory('Fruits');
      await Future.delayed(Duration.zero);

      expect(provider.selectedCategory, 'Fruits');
      expect(provider.foodItems, hasLength(1));
      expect(provider.foodItems.first.name, 'Apple');
    });

    test('searchFoodItems filters by name', () async {
      await foodItemService.addFoodItem(_makeFoodItem(name: 'Apple'));
      await foodItemService.addFoodItem(_makeFoodItem(name: 'Banana'));
      await foodItemService.addFoodItem(_makeFoodItem(name: 'Apricot'));

      await provider.searchFoodItems('ap');

      expect(provider.searchResults, hasLength(2));
      expect(provider.searchQuery, 'ap');
    });

    test('searchFoodItems with empty query clears results', () async {
      await foodItemService.addFoodItem(_makeFoodItem(name: 'Apple'));
      await provider.searchFoodItems('apple');
      expect(provider.searchResults, hasLength(1));

      await provider.searchFoodItems('');
      expect(provider.searchResults, isEmpty);
      expect(provider.searchQuery, '');
    });

    test('addFoodItem adds item to Firestore', () async {
      final item = _makeFoodItem(name: 'NewItem');
      await provider.addFoodItem(item);

      final snapshot = await fakeFirestore.collection('food_items').get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.data()['name'], 'NewItem');
    });

    // Filter tests
    test('setFilterVegan filters vegan items', () async {
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Apple', isVegan: true));
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Chicken', isVegan: false));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      provider.setFilterVegan(true);
      expect(provider.filterVegan, true);
      expect(provider.foodItems, hasLength(1));
      expect(provider.foodItems.first.name, 'Apple');
    });

    test('setFilterVegetarian filters vegetarian items', () async {
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Tofu', isVegetarian: true));
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Steak', isVegetarian: false));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      provider.setFilterVegetarian(true);
      expect(provider.filterVegetarian, true);
      expect(provider.foodItems, hasLength(1));
      expect(provider.foodItems.first.name, 'Tofu');
    });

    test('setFilterGlutenFree filters gluten free items', () async {
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Rice', isGlutenFree: true));
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Bread', isGlutenFree: false));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      provider.setFilterGlutenFree(true);
      expect(provider.filterGlutenFree, true);
      expect(provider.foodItems, hasLength(1));
      expect(provider.foodItems.first.name, 'Rice');
    });

    test('setFilterNutriScore filters by nutriScore', () async {
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Apple', nutriScore: 'A'));
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Chips', nutriScore: 'D'));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      provider.setFilterNutriScore('A');
      expect(provider.filterNutriScore, 'A');
      expect(provider.foodItems, hasLength(1));
      expect(provider.foodItems.first.name, 'Apple');
    });

    test('activeFilterCount reflects active filters', () {
      expect(provider.activeFilterCount, 0);

      provider.setFilterVegan(true);
      expect(provider.activeFilterCount, 1);

      provider.setFilterVegetarian(true);
      expect(provider.activeFilterCount, 2);

      provider.setFilterGlutenFree(true);
      expect(provider.activeFilterCount, 3);

      provider.setFilterNutriScore('A');
      expect(provider.activeFilterCount, 4);
    });

    test('clearFilters resets all filters', () {
      provider.setFilterVegan(true);
      provider.setFilterVegetarian(true);
      provider.setFilterGlutenFree(true);
      provider.setFilterNutriScore('B');
      provider.setSortBy('calories');

      provider.clearFilters();

      expect(provider.filterVegan, false);
      expect(provider.filterVegetarian, false);
      expect(provider.filterGlutenFree, false);
      expect(provider.filterNutriScore, isNull);
      expect(provider.sortBy, 'name');
      expect(provider.activeFilterCount, 0);
    });

    test('setSortBy changes sort order', () async {
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Banana', calories: 89, protein: 1.1));
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Apple', calories: 52, protein: 0.3));
      await foodItemService.addFoodItem(
          _makeFoodItem(name: 'Chicken', calories: 165, protein: 31));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      // Default sort: name ascending
      expect(provider.foodItems.first.name, 'Apple');

      provider.setSortBy('calories');
      expect(provider.foodItems.first.name, 'Apple'); // 52 cal lowest

      provider.setSortBy('protein');
      expect(provider.foodItems.first.name, 'Chicken'); // 31g highest (desc)
    });

    test('multiple filters combine correctly', () async {
      await foodItemService.addFoodItem(_makeFoodItem(
          name: 'Tofu', isVegan: true, isGlutenFree: true));
      await foodItemService.addFoodItem(_makeFoodItem(
          name: 'Bread', isVegan: true, isGlutenFree: false));
      await foodItemService.addFoodItem(_makeFoodItem(
          name: 'Steak', isVegan: false, isGlutenFree: true));

      provider.ensureInitialized();
      await Future.delayed(Duration.zero);

      provider.setFilterVegan(true);
      provider.setFilterGlutenFree(true);

      expect(provider.foodItems, hasLength(1));
      expect(provider.foodItems.first.name, 'Tofu');
    });

    test('filter notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setFilterVegan(true);
      expect(notifyCount, 1);

      provider.setFilterVegetarian(true);
      expect(notifyCount, 2);

      provider.clearFilters();
      expect(notifyCount, 3);
    });
  });
}
