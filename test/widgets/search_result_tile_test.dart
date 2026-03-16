import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/recipe.dart';
import 'package:chef_specials/models/ingredient.dart';
import 'package:chef_specials/models/recipe_step.dart';
import 'package:chef_specials/screens/search/widgets/search_result_tile.dart';

Recipe _testRecipe({
  String title = 'Grilled Salmon',
  String category = 'Dinner',
  int prepTimeMinutes = 10,
  int cookTimeMinutes = 15,
  int? caloriesPerServing = 280,
  String? imageUrl,
}) {
  return Recipe(
    id: 'recipe_search_001',
    title: title,
    description: 'A test recipe for search results',
    authorId: 'user123',
    authorName: 'Chef Test',
    category: category,
    servings: 2,
    prepTimeMinutes: prepTimeMinutes,
    cookTimeMinutes: cookTimeMinutes,
    imageUrl: imageUrl,
    ingredients: [
      Ingredient(name: 'Salmon', amount: '200', unit: 'g'),
    ],
    steps: [
      RecipeStep(order: 1, instruction: 'Grill the salmon'),
    ],
    caloriesPerServing: caloriesPerServing,
    createdAt: DateTime(2024, 1, 1),
  );
}

void main() {
  Widget buildTestWidget(Recipe recipe) {
    return MaterialApp(
      home: Scaffold(
        body: SearchResultTile(recipe: recipe),
      ),
    );
  }

  group('SearchResultTile', () {
    testWidgets('renders recipe title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe()));

      expect(find.text('Grilled Salmon'), findsOneWidget);
    });

    testWidgets('renders category and cooking time',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(
          category: 'Dinner',
          prepTimeMinutes: 10,
          cookTimeMinutes: 15,
        ),
      ));

      // Format: "Category \u2022 totalTime min"
      expect(find.textContaining('Dinner'), findsOneWidget);
      expect(find.textContaining('25 min'), findsOneWidget);
    });

    testWidgets('renders calorie badge when caloriesPerServing is set',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(caloriesPerServing: 280),
      ));

      expect(find.text('280'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('hides calorie badge when caloriesPerServing is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(caloriesPerServing: null),
      ));

      expect(find.byIcon(Icons.local_fire_department), findsNothing);
    });

    testWidgets('shows placeholder icon when no image URL',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(imageUrl: null),
      ));

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('wraps in GestureDetector for tap handling',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe()));

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('renders with different recipe titles',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(title: 'Veggie Bowl'),
      ));

      expect(find.text('Veggie Bowl'), findsOneWidget);
      expect(find.text('Grilled Salmon'), findsNothing);
    });

    testWidgets('renders with different categories',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(category: 'Breakfast', prepTimeMinutes: 5, cookTimeMinutes: 10),
      ));

      expect(find.textContaining('Breakfast'), findsOneWidget);
      expect(find.textContaining('15 min'), findsOneWidget);
    });

    testWidgets('has correct layout structure with Row',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe()));

      // Main content is a Row with image, text, and optional calorie badge
      expect(find.byType(Row), findsAtLeast(1));
    });

    testWidgets('renders ClipRRect for rounded image corners',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe()));

      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
