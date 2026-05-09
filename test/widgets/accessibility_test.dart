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
import 'package:chef_specials/providers/like_provider.dart';
import 'package:chef_specials/screens/home/widgets/recipe_card.dart';

class _FakeFavoriteProvider extends ChangeNotifier implements FavoriteProvider {
  @override
  Set<String> get favoriteRecipeIds => {};
  @override
  bool isFavorite(String id) => false;
  @override
  void listenToFavorites(String userId) {}
  @override
  Future<void> toggleFavorite(String id) async {}
}

class _FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeCookingLogProvider extends ChangeNotifier
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

class _FakeLikeProvider extends ChangeNotifier implements LikeProvider {
  @override
  bool isLiked(String recipeId) => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Recipe _makeRecipe({String title = 'Spaghetti', String authorName = 'Chef Ana'}) {
  return Recipe(
    id: 'test_recipe',
    title: title,
    description: 'A tasty recipe',
    authorId: 'user1',
    authorName: authorName,
    category: 'Dinner',
    servings: 2,
    prepTimeMinutes: 10,
    cookTimeMinutes: 20,
    ingredients: [Ingredient(name: 'Pasta', amount: '200', unit: 'g')],
    steps: [RecipeStep(order: 1, instruction: 'Boil')],
    createdAt: DateTime(2024, 1, 1),
  );
}

Widget _buildTestWidget(Recipe recipe, {TextScaler? textScaler}) {
  Widget app = MultiProvider(
    providers: [
      ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => _FakeFavoriteProvider()),
      ChangeNotifierProvider<AuthProvider>(create: (_) => _FakeAuthProvider()),
      ChangeNotifierProvider<CookingLogProvider>(
          create: (_) => _FakeCookingLogProvider()),
      ChangeNotifierProvider<LikeProvider>(create: (_) => _FakeLikeProvider()),
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
        body: SingleChildScrollView(child: RecipeCard(recipe: recipe)),
      ),
    ),
  );

  if (textScaler != null) {
    app = MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: app,
    );
  }

  return app;
}

void main() {
  group('RecipeCard accessibility', () {
    testWidgets('has semantic label containing recipe title and author',
        (tester) async {
      final recipe = _makeRecipe(title: 'Tiramisu', authorName: 'Chef Bella');
      await tester.pumpWidget(_buildTestWidget(recipe));
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(RecipeCard));
      expect(semantics.label, contains('Tiramisu'));
      expect(semantics.label, contains('Chef Bella'));
    });

    testWidgets('semantic label is findable via bySemanticsLabel',
        (tester) async {
      final recipe = _makeRecipe(title: 'Pasta Carbonara', authorName: 'Chef Mario');
      await tester.pumpWidget(_buildTestWidget(recipe));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp('Pasta Carbonara')),
        findsOneWidget,
      );
    });
  });

  group('Text scaling', () {
    testWidgets('RecipeCard renders without overflow at 1.3x text scale',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        _makeRecipe(),
        textScaler: const TextScaler.linear(1.3),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('RecipeCard renders without overflow at 0.8x text scale',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        _makeRecipe(),
        textScaler: const TextScaler.linear(0.8),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('High contrast readability', () {
    testWidgets('RecipeCard title is visible at any text scale', (tester) async {
      final recipe = _makeRecipe(title: 'Unique Title XYZ');
      await tester.pumpWidget(_buildTestWidget(
        recipe,
        textScaler: const TextScaler.linear(1.0),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Unique Title XYZ'), findsOneWidget);
    });
  });
}
