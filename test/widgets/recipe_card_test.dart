import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:chef_specials/l10n/generated/app_localizations.dart';
import 'package:chef_specials/models/recipe.dart';
import 'package:chef_specials/models/ingredient.dart';
import 'package:chef_specials/models/recipe_step.dart';
import 'package:chef_specials/models/cooking_log.dart';
import 'package:chef_specials/providers/auth_provider.dart';
import 'package:chef_specials/providers/cooking_log_provider.dart';
import 'package:chef_specials/providers/favorite_provider.dart';
import 'package:chef_specials/screens/home/widgets/recipe_card.dart';

/// A minimal FavoriteProvider for testing that does not connect to Firebase.
class FakeFavoriteProvider extends ChangeNotifier implements FavoriteProvider {
  final Set<String> _ids = {};

  @override
  Set<String> get favoriteRecipeIds => _ids;

  @override
  bool isFavorite(String recipeId) => _ids.contains(recipeId);

  @override
  void listenToFavorites(String userId) {}

  @override
  Future<void> toggleFavorite(String recipeId) async {
    if (_ids.contains(recipeId)) {
      _ids.remove(recipeId);
    } else {
      _ids.add(recipeId);
    }
    notifyListeners();
  }
}

/// A minimal AuthProvider stub for testing.
class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeCookingLogProvider extends ChangeNotifier
    implements CookingLogProvider {
  @override
  List<CookingLog> get cookingHistory => [];
  @override
  bool get isLoading => false;
  @override
  int getCookCountFromCache(String recipeId) => 0;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Recipe _testRecipe({
  String? id,
  String title = 'Test Pasta',
  String authorName = 'Chef Mario',
  String authorId = 'user123',
  String category = 'Dinner',
  int prepTimeMinutes = 10,
  int cookTimeMinutes = 20,
  double averageRating = 4.5,
  int ratingCount = 12,
  int commentCount = 5,
  int? caloriesPerServing = 350,
  double? proteinGrams = 25.0,
  double? carbsGrams = 40.0,
  double? fatGrams = 12.0,
  List<String> dietaryTags = const [],
}) {
  return Recipe(
    id: id ?? 'recipe_001',
    title: title,
    description: 'A delicious test recipe',
    authorId: authorId,
    authorName: authorName,
    category: category,
    servings: 4,
    prepTimeMinutes: prepTimeMinutes,
    cookTimeMinutes: cookTimeMinutes,
    ingredients: [
      Ingredient(name: 'Pasta', amount: '200', unit: 'g'),
    ],
    steps: [
      RecipeStep(order: 1, instruction: 'Boil water'),
    ],
    caloriesPerServing: caloriesPerServing,
    proteinGrams: proteinGrams,
    carbsGrams: carbsGrams,
    fatGrams: fatGrams,
    createdAt: DateTime(2024, 1, 1),
    averageRating: averageRating,
    ratingCount: ratingCount,
    commentCount: commentCount,
    dietaryTags: dietaryTags,
  );
}

void main() {
  Widget buildTestWidget(Recipe recipe) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => FakeFavoriteProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => FakeAuthProvider(),
        ),
        ChangeNotifierProvider<CookingLogProvider>(
          create: (_) => FakeCookingLogProvider(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: RecipeCard(recipe: recipe),
          ),
        ),
      ),
    );
  }

  group('RecipeCard', () {
    testWidgets('renders recipe title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe()));
      await tester.pumpAndSettle();

      expect(find.text('Test Pasta'), findsOneWidget);
    });

    testWidgets('renders author name', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe()));
      await tester.pumpAndSettle();

      expect(find.text('Chef Mario'), findsOneWidget);
    });

    testWidgets('renders category badge', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe(category: 'Dinner')));
      await tester.pumpAndSettle();

      // Category badge shows uppercased localized name
      expect(find.text('DINNER'), findsOneWidget);
    });

    testWidgets('renders total cooking time', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(prepTimeMinutes: 10, cookTimeMinutes: 20),
      ));
      await tester.pumpAndSettle();

      // Total time = 30 min
      expect(find.text('30 min'), findsOneWidget);
    });

    testWidgets('renders rating with star icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(averageRating: 4.5, ratingCount: 12),
      ));
      await tester.pumpAndSettle();

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text(' (12)'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders dash for zero rating', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(averageRating: 0.0, ratingCount: 0),
      ));
      await tester.pumpAndSettle();

      expect(find.text('-'), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('renders comment count', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe(commentCount: 5)));
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('renders favorite icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe()));
      await tester.pumpAndSettle();

      // Should show unfilled favorite icon since not favorited
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('renders nutrition info when caloriesPerServing is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(
          caloriesPerServing: 350,
          proteinGrams: 25.0,
          carbsGrams: 40.0,
          fatGrams: 12.0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('350'), findsOneWidget);
      expect(find.text('25g'), findsOneWidget);
      expect(find.text('40g'), findsOneWidget);
      expect(find.text('12g'), findsOneWidget);
    });

    testWidgets('hides nutrition info when caloriesPerServing is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(caloriesPerServing: null),
      ));
      await tester.pumpAndSettle();

      // Nutrition labels should not be present
      expect(find.text('CALORIES'), findsNothing);
    });

    testWidgets('renders dietary tags when present',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(dietaryTags: ['Vegan', 'Gluten Free']),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Vegan'), findsOneWidget);
      expect(find.text('Gluten Free'), findsOneWidget);
    });

    testWidgets('hides dietary tags section when empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(dietaryTags: []),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Vegan'), findsNothing);
    });

    testWidgets('shows placeholder icon when no image URL',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('renders author initial in CircleAvatar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        _testRecipe(authorName: 'Chef Mario'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('renders with AnimatedScale for press animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(_testRecipe()));
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedScale), findsOneWidget);
    });
  });
}
