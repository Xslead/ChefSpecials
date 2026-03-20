import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/food_item_form_provider.dart';
import 'package:chef_specials/models/food_item.dart';

FoodItem _makeFoodItem({
  String name = 'Apple',
  String? brand = 'Brand X',
  String category = 'Fruits',
  String unit = '100g',
  double packetSize = 150,
  String? barcode = '123456',
  bool isVegan = true,
  bool isVegetarian = true,
  bool isGlutenFree = true,
  double calories = 52,
  double protein = 0.3,
  double carbs = 14,
  double fat = 0.2,
  double saturatedFat = 0.1,
  double transFat = 0,
  double cholesterol = 0,
  double fiber = 2.4,
  double sugar = 10.4,
  double sodium = 1,
  double salt = 0.01,
  String? nutriScore = 'A',
  int? novaGroup = 1,
  List<String> allergens = const ['Gluten', 'Milk'],
  String? ingredientsText = 'Apple pulp',
  String? origin = 'Turkey',
  double? servingSize = 80,
}) {
  return FoodItem(
    id: 'food1',
    name: name,
    brand: brand,
    category: category,
    unit: unit,
    packetSize: packetSize,
    barcode: barcode,
    isVegan: isVegan,
    isVegetarian: isVegetarian,
    isGlutenFree: isGlutenFree,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    saturatedFat: saturatedFat,
    transFat: transFat,
    cholesterol: cholesterol,
    fiber: fiber,
    sugar: sugar,
    sodium: sodium,
    salt: salt,
    nutriScore: nutriScore,
    novaGroup: novaGroup,
    allergens: allergens,
    ingredientsText: ingredientsText,
    origin: origin,
    servingSize: servingSize,
    addedBy: 'user1',
    createdAt: DateTime(2025, 1, 1),
  );
}

void main() {
  late FoodItemFormProvider provider;

  setUp(() {
    provider = FoodItemFormProvider();
  });

  group('FoodItemFormProvider', () {
    test('initial state has correct defaults', () {
      expect(provider.name, '');
      expect(provider.brand, isNull);
      expect(provider.category, 'Protein');
      expect(provider.unit, '100g');
      expect(provider.packetSize, 100);
      expect(provider.barcode, isNull);
      expect(provider.isVegan, false);
      expect(provider.isVegetarian, false);
      expect(provider.isGlutenFree, false);
      expect(provider.calories, 0);
      expect(provider.protein, 0);
      expect(provider.carbs, 0);
      expect(provider.fat, 0);
      expect(provider.saturatedFat, 0);
      expect(provider.transFat, 0);
      expect(provider.cholesterol, 0);
      expect(provider.fiber, 0);
      expect(provider.sugar, 0);
      expect(provider.sodium, 0);
      expect(provider.salt, 0);
      expect(provider.nutriScore, isNull);
      expect(provider.novaGroup, isNull);
      expect(provider.allergens, isEmpty);
      expect(provider.ingredientsText, isNull);
      expect(provider.origin, isNull);
      expect(provider.servingSize, isNull);
      expect(provider.isSubmitting, false);
      expect(provider.error, isNull);
      expect(provider.isBaseUnit, true);
    });

    test('setters update values and notify listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setName('Chicken');
      expect(provider.name, 'Chicken');
      expect(notifyCount, 1);

      provider.setBrand('Farm Fresh');
      expect(provider.brand, 'Farm Fresh');
      expect(notifyCount, 2);

      provider.setCalories(165);
      expect(provider.calories, 165);
      expect(notifyCount, 3);

      provider.setProtein(31);
      expect(provider.protein, 31);

      provider.setCarbs(0);
      expect(provider.carbs, 0);

      provider.setFat(3.6);
      expect(provider.fat, 3.6);

      provider.setSaturatedFat(1.0);
      expect(provider.saturatedFat, 1.0);

      provider.setTransFat(0.1);
      expect(provider.transFat, 0.1);

      provider.setCholesterol(85);
      expect(provider.cholesterol, 85);

      provider.setFiber(0);
      expect(provider.fiber, 0);

      provider.setSugar(0);
      expect(provider.sugar, 0);

      provider.setSodium(74);
      expect(provider.sodium, 74);

      provider.setSalt(0.19);
      expect(provider.salt, 0.19);

      provider.setNutriScore('B');
      expect(provider.nutriScore, 'B');

      provider.setNovaGroup(2);
      expect(provider.novaGroup, 2);

      provider.setIngredientsText('Chicken breast');
      expect(provider.ingredientsText, 'Chicken breast');

      provider.setOrigin('USA');
      expect(provider.origin, 'USA');

      provider.setServingSize(100);
      expect(provider.servingSize, 100);

      provider.setBarcode('789012');
      expect(provider.barcode, '789012');

      provider.setPacketSize(250);
      expect(provider.packetSize, 250);
    });

    test('setBrand with empty string sets null', () {
      provider.setBrand('');
      expect(provider.brand, isNull);
    });

    test('setBarcode with empty string sets null', () {
      provider.setBarcode('');
      expect(provider.barcode, isNull);
    });

    test('setOrigin with empty string sets null', () {
      provider.setOrigin('');
      expect(provider.origin, isNull);
    });

    test('setIngredientsText with empty string sets null', () {
      provider.setIngredientsText('');
      expect(provider.ingredientsText, isNull);
    });

    test('setCategory to Beverages auto-sets unit to 100mL', () {
      provider.setCategory('Beverages');
      expect(provider.category, 'Beverages');
      expect(provider.unit, '100mL');
    });

    test('setCategory to non-Beverages does not change unit', () {
      provider.setUnit('oz');
      provider.setCategory('Protein');
      expect(provider.unit, 'oz');
    });

    test('isBaseUnit returns true for 100g and 100mL', () {
      provider.setUnit('100g');
      expect(provider.isBaseUnit, true);

      provider.setUnit('100mL');
      expect(provider.isBaseUnit, true);
    });

    test('isBaseUnit returns false for non-base units', () {
      provider.setUnit('oz');
      expect(provider.isBaseUnit, false);

      provider.setUnit('cups');
      expect(provider.isBaseUnit, false);
    });

    // Allergen toggling
    test('toggleAllergen adds allergen', () {
      provider.toggleAllergen('Gluten');
      expect(provider.allergens, contains('Gluten'));
    });

    test('toggleAllergen removes existing allergen', () {
      provider.toggleAllergen('Gluten');
      provider.toggleAllergen('Gluten');
      expect(provider.allergens, isNot(contains('Gluten')));
    });

    test('toggleAllergen handles multiple allergens', () {
      provider.toggleAllergen('Gluten');
      provider.toggleAllergen('Milk');
      provider.toggleAllergen('Eggs');

      expect(provider.allergens, hasLength(3));
      expect(provider.allergens, containsAll(['Gluten', 'Milk', 'Eggs']));
    });

    test('toggleAllergen notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.toggleAllergen('Soy');
      expect(notifyCount, 1);

      provider.toggleAllergen('Soy');
      expect(notifyCount, 2);
    });

    // Nutrition unit conversion
    test('conversionFactor returns 1.0 for base units', () {
      provider.setUnit('100g');
      expect(provider.conversionFactor(), 1.0);

      provider.setUnit('100mL');
      expect(provider.conversionFactor(), 1.0);
    });

    test('conversionFactor for oz converts to per-100g', () {
      provider.setUnit('oz');
      // 1 oz = 28.3495 g, factor = 100 / 28.3495
      expect(provider.conversionFactor(), closeTo(3.5274, 0.001));
    });

    test('conversionFactor for lb converts to per-100g', () {
      provider.setUnit('lb');
      // 1 lb = 453.592 g, factor = 100 / 453.592
      expect(provider.conversionFactor(), closeTo(0.2205, 0.001));
    });

    test('conversionFactor for kg converts to per-100g', () {
      provider.setUnit('kg');
      // 1 kg = 1000 g, factor = 100 / 1000 = 0.1
      expect(provider.conversionFactor(), closeTo(0.1, 0.001));
    });

    test('conversionFactor for cups converts to per-100mL', () {
      provider.setUnit('cups');
      // 1 cup = 236.588 mL, factor = 100 / 236.588
      expect(provider.conversionFactor(), closeTo(0.4227, 0.001));
    });

    test('conversionFactor for tbsp converts to per-100mL', () {
      provider.setUnit('tbsp');
      // 1 tbsp = 14.787 mL, factor = 100 / 14.787
      expect(provider.conversionFactor(), closeTo(6.7627, 0.001));
    });

    test('conversionFactor for tsp converts to per-100mL', () {
      provider.setUnit('tsp');
      // 1 tsp = 4.929 mL, factor = 100 / 4.929
      expect(provider.conversionFactor(), closeTo(20.288, 0.01));
    });

    test('conversionFactor for fl oz converts to per-100mL', () {
      provider.setUnit('fl oz');
      // 1 fl oz = 29.5735 mL, factor = 100 / 29.5735
      expect(provider.conversionFactor(), closeTo(3.3814, 0.001));
    });

    test('conversionFactor for L converts to per-100mL', () {
      provider.setUnit('L');
      // 1 L = 1000 mL, factor = 100 / 1000 = 0.1
      expect(provider.conversionFactor(), closeTo(0.1, 0.001));
    });

    // loadFromFoodItem
    test('loadFromFoodItem populates all fields', () {
      final item = _makeFoodItem();

      provider.loadFromFoodItem(item);

      expect(provider.name, 'Apple');
      expect(provider.brand, 'Brand X');
      expect(provider.category, 'Fruits');
      expect(provider.unit, '100g');
      expect(provider.packetSize, 150);
      expect(provider.barcode, '123456');
      expect(provider.isVegan, true);
      expect(provider.isVegetarian, true);
      expect(provider.isGlutenFree, true);
      expect(provider.calories, 52);
      expect(provider.protein, 0.3);
      expect(provider.carbs, 14);
      expect(provider.fat, 0.2);
      expect(provider.saturatedFat, 0.1);
      expect(provider.transFat, 0);
      expect(provider.cholesterol, 0);
      expect(provider.fiber, 2.4);
      expect(provider.sugar, 10.4);
      expect(provider.sodium, 1);
      expect(provider.salt, 0.01);
      expect(provider.nutriScore, 'A');
      expect(provider.novaGroup, 1);
      expect(provider.allergens, ['Gluten', 'Milk']);
      expect(provider.ingredientsText, 'Apple pulp');
      expect(provider.origin, 'Turkey');
      expect(provider.servingSize, 80);
    });

    test('loadFromFoodItem notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.loadFromFoodItem(_makeFoodItem());
      expect(notifyCount, 1);
    });

    test('loadFromFoodItem creates independent allergens copy', () {
      final item = _makeFoodItem(allergens: ['Gluten']);
      provider.loadFromFoodItem(item);

      provider.toggleAllergen('Milk');
      expect(provider.allergens, hasLength(2));
      expect(item.allergens, hasLength(1));
    });

    // buildFoodItem
    test('buildFoodItem creates FoodItem with base unit (no conversion)', () {
      provider.setName('Egg');
      provider.setCategory('Protein');
      provider.setUnit('100g');
      provider.setCalories(155);
      provider.setProtein(13);
      provider.setCarbs(1.1);
      provider.setFat(11);
      provider.setFiber(0);
      provider.setSugar(1.1);
      provider.setSodium(124);

      final item = provider.buildFoodItem(userId: 'user123');

      expect(item.name, 'Egg');
      expect(item.category, 'Protein');
      expect(item.unit, '100g');
      expect(item.calories, 155);
      expect(item.protein, 13);
      expect(item.carbs, 1.1);
      expect(item.fat, 11);
      expect(item.addedBy, 'user123');
      expect(item.isVerified, false);
      expect(item.id, isNull);
    });

    test('buildFoodItem applies conversion factor for non-base units', () {
      provider.setUnit('oz');
      provider.setCalories(100);
      provider.setProtein(10);

      final item = provider.buildFoodItem(userId: 'user123');

      // 1 oz = 28.3495 g, factor = 100/28.3495 ~= 3.5274
      expect(item.unit, '100g');
      expect(item.calories, closeTo(352.74, 0.1));
      expect(item.protein, closeTo(35.274, 0.1));
    });

    test('buildFoodItem uses 100mL for volume-based non-base units', () {
      provider.setUnit('cups');
      provider.setCalories(50);

      final item = provider.buildFoodItem(userId: 'user123');

      expect(item.unit, '100mL');
      // 1 cup = 236.588 mL, factor = 100/236.588 ~= 0.4227
      expect(item.calories, closeTo(21.13, 0.1));
    });

    test('buildFoodItem preserves existing item fields in edit mode', () {
      final existing = _makeFoodItem();
      provider.loadFromFoodItem(existing);
      provider.setName('Updated Apple');

      final item = provider.buildFoodItem(
        userId: 'newUser',
        existingItem: existing,
      );

      expect(item.id, 'food1');
      expect(item.name, 'Updated Apple');
      expect(item.addedBy, 'user1');
      expect(item.createdAt, DateTime(2025, 1, 1));
      expect(item.isVerified, false);
    });

    test('buildFoodItem sets new userId when no existing item', () {
      provider.setName('New Item');

      final item = provider.buildFoodItem(userId: 'creator1');

      expect(item.addedBy, 'creator1');
      expect(item.id, isNull);
    });

    // Dietary tag setters
    test('dietary flag setters work correctly', () {
      provider.setIsVegan(true);
      expect(provider.isVegan, true);

      provider.setIsVegetarian(true);
      expect(provider.isVegetarian, true);

      provider.setIsGlutenFree(true);
      expect(provider.isGlutenFree, true);

      provider.setIsVegan(false);
      expect(provider.isVegan, false);
    });

    // Reset
    test('reset restores all defaults', () {
      provider.setName('Modified');
      provider.setBrand('Brand');
      provider.setCategory('Dairy');
      provider.setUnit('oz');
      provider.setPacketSize(250);
      provider.setBarcode('999');
      provider.setIsVegan(true);
      provider.setIsVegetarian(true);
      provider.setIsGlutenFree(true);
      provider.setCalories(200);
      provider.setProtein(20);
      provider.setCarbs(30);
      provider.setFat(10);
      provider.setSaturatedFat(5);
      provider.setTransFat(1);
      provider.setCholesterol(50);
      provider.setFiber(3);
      provider.setSugar(8);
      provider.setSodium(100);
      provider.setSalt(0.5);
      provider.setNutriScore('C');
      provider.setNovaGroup(3);
      provider.toggleAllergen('Gluten');
      provider.setIngredientsText('stuff');
      provider.setOrigin('Italy');
      provider.setServingSize(50);
      provider.setIsSubmitting(true);
      provider.setError('some error');

      provider.reset();

      expect(provider.name, '');
      expect(provider.brand, isNull);
      expect(provider.category, 'Protein');
      expect(provider.unit, '100g');
      expect(provider.packetSize, 100);
      expect(provider.barcode, isNull);
      expect(provider.isVegan, false);
      expect(provider.isVegetarian, false);
      expect(provider.isGlutenFree, false);
      expect(provider.calories, 0);
      expect(provider.protein, 0);
      expect(provider.carbs, 0);
      expect(provider.fat, 0);
      expect(provider.saturatedFat, 0);
      expect(provider.transFat, 0);
      expect(provider.cholesterol, 0);
      expect(provider.fiber, 0);
      expect(provider.sugar, 0);
      expect(provider.sodium, 0);
      expect(provider.salt, 0);
      expect(provider.nutriScore, isNull);
      expect(provider.novaGroup, isNull);
      expect(provider.allergens, isEmpty);
      expect(provider.ingredientsText, isNull);
      expect(provider.origin, isNull);
      expect(provider.servingSize, isNull);
      expect(provider.isSubmitting, false);
      expect(provider.error, isNull);
    });

    test('reset notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.reset();
      expect(notifyCount, 1);
    });

    // Submission state
    test('isSubmitting can be toggled', () {
      provider.setIsSubmitting(true);
      expect(provider.isSubmitting, true);

      provider.setIsSubmitting(false);
      expect(provider.isSubmitting, false);
    });

    test('error can be set and cleared', () {
      provider.setError('Something went wrong');
      expect(provider.error, 'Something went wrong');

      provider.setError(null);
      expect(provider.error, isNull);
    });
  });
}
