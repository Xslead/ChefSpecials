import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/food_item.dart';
import 'package:chef_specials/screens/food_items/widgets/nutrition_facts_table.dart';

FoodItem _testFoodItem({
  double calories = 250.0,
  double protein = 20.0,
  double carbs = 30.0,
  double fat = 10.0,
  double saturatedFat = 3.0,
  double transFat = 0.5,
  double cholesterol = 55.0,
  double fiber = 4.0,
  double sugar = 8.0,
  double sodium = 400.0,
  double salt = 1.0,
  double packetSize = 200.0,
  String unit = '100g',
}) {
  return FoodItem(
    id: 'food_test',
    name: 'Test Food',
    category: 'Protein',
    unit: unit,
    packetSize: packetSize,
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
    addedBy: 'user123',
    createdAt: DateTime(2024, 1, 1),
  );
}

void main() {
  Widget buildTestWidget(FoodItem foodItem) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: NutritionFactsTable(foodItem: foodItem),
        ),
      ),
    );
  }

  group('NutritionFactsTable', () {
    testWidgets('renders Nutrition Facts title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testFoodItem()));

      expect(find.text('Nutrition Facts'), findsOneWidget);
    });

    testWidgets('renders per-unit header', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testFoodItem(unit: '100g')));

      // "Per 100g" appears in header and column headers
      expect(find.textContaining('Per 100g'), findsAtLeast(1));
    });

    testWidgets('renders calorie value per unit', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(calories: 250.0),
      ));

      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('250.0 kcal'), findsOneWidget);
    });

    testWidgets('renders calorie value per packet',
        (WidgetTester tester) async {
      // 250 cal per 100g, packet is 200g -> 500 kcal per packet
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(calories: 250.0, packetSize: 200.0),
      ));

      expect(find.text('500.0 kcal'), findsOneWidget);
    });

    testWidgets('renders protein value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(protein: 20.0),
      ));

      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('20.0 g'), findsAtLeast(1));
    });

    testWidgets('renders carbohydrate value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(carbs: 30.0),
      ));

      expect(find.text('Carbohydrates'), findsOneWidget);
      expect(find.text('30.0 g'), findsAtLeast(1));
    });

    testWidgets('renders fat value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(fat: 10.0),
      ));

      expect(find.text('Fat'), findsOneWidget);
      expect(find.text('10.0 g'), findsAtLeast(1));
    });

    testWidgets('renders sugar as sub-row of carbohydrates',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(sugar: 8.0),
      ));

      expect(find.text('Sugar'), findsOneWidget);
      expect(find.text('8.0 g'), findsAtLeast(1));
    });

    testWidgets('renders fiber as sub-row of carbohydrates',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(fiber: 4.0),
      ));

      expect(find.text('Fiber'), findsOneWidget);
      expect(find.text('4.0 g'), findsAtLeast(1));
    });

    testWidgets('renders saturated fat as sub-row of fat',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(saturatedFat: 3.0),
      ));

      expect(find.text('Saturated Fat'), findsOneWidget);
      expect(find.text('3.0 g'), findsAtLeast(1));
    });

    testWidgets('renders trans fat as sub-row of fat',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(transFat: 0.5),
      ));

      expect(find.text('Trans Fat'), findsOneWidget);
      expect(find.text('0.5 g'), findsAtLeast(1));
    });

    testWidgets('renders sodium value in mg', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(sodium: 400.0),
      ));

      expect(find.text('Sodium'), findsOneWidget);
      expect(find.text('400.0 mg'), findsAtLeast(1));
    });

    testWidgets('renders cholesterol value in mg',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(cholesterol: 55.0),
      ));

      expect(find.text('Cholesterol'), findsOneWidget);
      expect(find.text('55.0 mg'), findsAtLeast(1));
    });

    testWidgets('renders salt value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(salt: 1.0),
      ));

      expect(find.text('Salt'), findsOneWidget);
      expect(find.text('1.0 g'), findsAtLeast(1));
    });

    testWidgets('renders per-packet column header with packet size',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(packetSize: 200.0, unit: '100g'),
      ));

      expect(find.text('Per Packet (200g)'), findsOneWidget);
    });

    testWidgets('renders mL suffix for liquid unit',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(packetSize: 250.0, unit: 'mL'),
      ));

      expect(find.text('Per Packet (250mL)'), findsOneWidget);
    });

    testWidgets('per-packet values are correctly computed',
        (WidgetTester tester) async {
      // protein=20 per 100g, packetSize=150 -> 30.0 per packet
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(protein: 20.0, packetSize: 150.0),
      ));

      expect(find.text('30.0 g'), findsAtLeast(1));
    });

    testWidgets('renders progress bars for macronutrients',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testFoodItem()));

      // There should be LinearProgressIndicators for protein, carbs, fat
      expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
    });

    testWidgets('renders inside a Card widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testFoodItem()));

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
