import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chef_specials/l10n/generated/app_localizations.dart';
import 'package:chef_specials/models/ingredient_substitution.dart';
import 'package:chef_specials/providers/auth_provider.dart';
import 'package:chef_specials/services/substitution_service.dart';
import 'package:chef_specials/widgets/substitution_sheet.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
      child: Scaffold(body: child),
    ),
  );
}

Future<void> _openSheet(
  WidgetTester tester, {
  required SubstitutionService service,
  String ingredient = 'butter',
}) async {
  await tester.pumpWidget(_wrap(
    Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () => SubstitutionSheet.show(
          context,
          ingredientName: ingredient,
          service: service,
        ),
        child: const Text('Open'),
      );
    }),
  ));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> _seed(FakeFirebaseFirestore db, IngredientSubstitution s) async {
  await db.collection('substitutions').add(s.toMap());
}

void main() {
  testWidgets('shows header with ingredient name', (tester) async {
    final db = FakeFirebaseFirestore();
    await _seed(
        db,
        IngredientSubstitution(
          originalIngredient: 'butter',
          substituteName: 'Coconut oil',
          ratio: '1:1',
          isVerified: true,
        ));

    await _openSheet(tester, service: SubstitutionService(firestore: db));
    expect(find.text('Substitutes for butter'), findsOneWidget);
  });

  testWidgets('lists substitutions for the given ingredient', (tester) async {
    final db = FakeFirebaseFirestore();
    await _seed(
        db,
        IngredientSubstitution(
          originalIngredient: 'butter',
          substituteName: 'Coconut oil',
          ratio: '1:1',
          notes: 'Best for baking',
          isVerified: true,
        ));
    await _seed(
        db,
        IngredientSubstitution(
          originalIngredient: 'butter',
          substituteName: 'Greek yogurt',
          ratio: '1/2 cup per 1 cup',
        ));

    await _openSheet(tester, service: SubstitutionService(firestore: db));

    expect(find.text('Coconut oil'), findsOneWidget);
    expect(find.text('Greek yogurt'), findsOneWidget);
    expect(find.text('Ratio: 1:1'), findsOneWidget);
    expect(find.text('Best for baking'), findsOneWidget);
  });

  testWidgets('shows empty state when no substitutions exist',
      (tester) async {
    final db = FakeFirebaseFirestore();

    await _openSheet(tester,
        service: SubstitutionService(firestore: db), ingredient: 'unicorn');
    expect(find.text('No substitutions available'), findsOneWidget);
  });

  testWidgets('renders FilterChip row with All + dietary tags',
      (tester) async {
    final db = FakeFirebaseFirestore();
    await _openSheet(tester, service: SubstitutionService(firestore: db));

    expect(find.widgetWithText(FilterChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Vegan'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Gluten Free'), findsOneWidget);
  });

  testWidgets('tapping a filter chip re-queries with tag', (tester) async {
    final db = FakeFirebaseFirestore();
    await _seed(
        db,
        IngredientSubstitution(
          originalIngredient: 'egg',
          substituteName: 'Flax egg',
          ratio: '1:1',
          dietaryTags: ['Vegan'],
        ));
    await _seed(
        db,
        IngredientSubstitution(
          originalIngredient: 'egg',
          substituteName: 'Non-vegan swap',
          ratio: '1:1',
          dietaryTags: [],
        ));

    await _openSheet(tester,
        service: SubstitutionService(firestore: db), ingredient: 'egg');
    expect(find.text('Flax egg'), findsOneWidget);
    expect(find.text('Non-vegan swap'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Vegan'));
    await tester.pumpAndSettle();

    expect(find.text('Flax egg'), findsOneWidget);
    expect(find.text('Non-vegan swap'), findsNothing);
  });

  testWidgets('Suggest button opens the suggestion dialog', (tester) async {
    final db = FakeFirebaseFirestore();
    await _openSheet(tester, service: SubstitutionService(firestore: db));

    await tester.tap(find.text('Suggest a Substitution').first);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Substitute name'), findsOneWidget);
    expect(find.text('Ratio'), findsOneWidget);
  });

  testWidgets('verified entries show the verified icon', (tester) async {
    final db = FakeFirebaseFirestore();
    await _seed(
        db,
        IngredientSubstitution(
          originalIngredient: 'butter',
          substituteName: 'Verified item',
          ratio: '1:1',
          isVerified: true,
        ));
    await _openSheet(tester, service: SubstitutionService(firestore: db));

    expect(find.byIcon(Icons.verified), findsOneWidget);
  });
}
