import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chef_specials/l10n/generated/app_localizations.dart';
import 'package:chef_specials/models/food_item.dart';
import 'package:chef_specials/screens/food_items/widgets/food_item_card.dart';

FoodItem _testFoodItem({
  String name = 'Chicken Breast',
  String? brand = 'FarmFresh',
  String category = 'Protein',
  double calories = 165.0,
  double protein = 31.0,
  double carbs = 0.0,
  double fat = 3.6,
  double fiber = 0.0,
  double sugar = 0.0,
  double sodium = 74.0,
  double packetSize = 200.0,
  String unit = '100g',
  bool isVegan = false,
  bool isVerified = false,
}) {
  return FoodItem(
    id: 'food_001',
    name: name,
    brand: brand,
    category: category,
    unit: unit,
    packetSize: packetSize,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    fiber: fiber,
    sugar: sugar,
    sodium: sodium,
    isVegan: isVegan,
    isVerified: isVerified,
    addedBy: 'user123',
    createdAt: DateTime(2024, 1, 1),
  );
}

void main() {
  Widget buildTestWidget(FoodItem foodItem) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: FoodItemCard(foodItem: foodItem),
      ),
    );
  }

  group('FoodItemCard', () {
    testWidgets('renders food item name', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testFoodItem()));
      await tester.pumpAndSettle();

      expect(find.text('Chicken Breast'), findsOneWidget);
    });

    testWidgets('renders brand and category when brand is present',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(brand: 'FarmFresh', category: 'Protein'),
      ));
      await tester.pumpAndSettle();

      // Brand and category are combined with a bullet separator
      expect(find.textContaining('FarmFresh'), findsOneWidget);
      expect(find.textContaining('Protein'), findsOneWidget);
    });

    testWidgets('renders only category when brand is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(brand: null, category: 'Vegetables'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Vegetables'), findsOneWidget);
    });

    testWidgets('renders calorie count', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(calories: 165.0),
      ));
      await tester.pumpAndSettle();

      // Calories are displayed as integer (toStringAsFixed(0))
      expect(find.text('165'), findsOneWidget);
      expect(find.text('kcal'), findsOneWidget);
    });

    testWidgets('shows vegan badge when item is vegan',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(isVegan: true),
      ));
      await tester.pumpAndSettle();

      expect(find.text('V'), findsOneWidget);
    });

    testWidgets('does not show vegan badge when item is not vegan',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(isVegan: false),
      ));
      await tester.pumpAndSettle();

      expect(find.text('V'), findsNothing);
    });

    testWidgets('shows verified icon when item is verified',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(isVerified: true),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    });

    testWidgets('does not show verified icon when item is not verified',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(isVerified: false),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified_outlined), findsNothing);
    });

    testWidgets('renders protein value in nutrition bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(protein: 31.0),
      ));
      await tester.pumpAndSettle();

      expect(find.text('31.0g'), findsOneWidget);
    });

    testWidgets('renders carbs value in nutrition bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(carbs: 15.5),
      ));
      await tester.pumpAndSettle();

      expect(find.text('15.5g'), findsOneWidget);
    });

    testWidgets('renders fat value in nutrition bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(fat: 3.6),
      ));
      await tester.pumpAndSettle();

      expect(find.text('3.6g'), findsOneWidget);
    });

    testWidgets('renders packet size with correct unit suffix',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(packetSize: 200.0, unit: '100g'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('200g'), findsOneWidget);
    });

    testWidgets('renders mL suffix for liquid items',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(packetSize: 250.0, unit: 'mL'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('250mL'), findsOneWidget);
    });

    testWidgets('wraps in GestureDetector for tap handling',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testFoodItem()));
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('renders category-specific icon for Protein',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(category: 'Protein'),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.egg_outlined), findsOneWidget);
    });

    testWidgets('renders category-specific icon for Vegetables',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(category: 'Vegetables'),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.eco_outlined), findsOneWidget);
    });

    testWidgets('renders category-specific icon for Beverages',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testFoodItem(category: 'Beverages'),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_cafe_outlined), findsOneWidget);
    });
  });
}
