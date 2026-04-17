import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:chef_specials/l10n/generated/app_localizations.dart';
import 'package:chef_specials/models/cooking_log.dart';
import 'package:chef_specials/providers/auth_provider.dart';
import 'package:chef_specials/providers/cooking_log_provider.dart';
import 'package:chef_specials/screens/cooking_history/cooking_history_screen.dart';

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeCookingLogProvider extends ChangeNotifier
    implements CookingLogProvider {
  final List<CookingLog> _logs;
  FakeCookingLogProvider({List<CookingLog>? logs}) : _logs = logs ?? [];

  @override
  List<CookingLog> get cookingHistory => _logs;

  @override
  bool get isLoading => false;

  @override
  int getCookCountFromCache(String recipeId) => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget buildTestWidget(CookingLogProvider cookingLogProvider) {
  final router = GoRouter(
    initialLocation: '/cooking-history',
    routes: [
      GoRoute(
        path: '/cooking-history',
        builder: (_, _) => const CookingHistoryScreen(),
      ),
      GoRoute(
        path: '/recipe/:id',
        builder: (_, _) => const Scaffold(body: Text('Recipe')),
      ),
    ],
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(create: (_) => FakeAuthProvider()),
      ChangeNotifierProvider<CookingLogProvider>.value(
          value: cookingLogProvider),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    ),
  );
}

void main() {
  testWidgets('shows empty state when no logs', (tester) async {
    final provider = FakeCookingLogProvider();
    await tester.pumpWidget(buildTestWidget(provider));
    await tester.pumpAndSettle();
    expect(find.text('No cooking history yet'), findsOneWidget);
  });

  testWidgets('shows Cooking History header', (tester) async {
    final provider = FakeCookingLogProvider();
    await tester.pumpWidget(buildTestWidget(provider));
    await tester.pumpAndSettle();
    expect(find.text('Cooking History'), findsOneWidget);
  });

  testWidgets('shows cooking log cards when logs exist', (tester) async {
    final log = CookingLog(
      id: 'log1',
      recipeId: 'recipe1',
      recipeName: 'Pasta Carbonara',
      userId: 'user1',
      cookedAt: DateTime(2025, 6, 15),
      servings: 2,
    );
    final provider = FakeCookingLogProvider(logs: [log]);
    await tester.pumpWidget(buildTestWidget(provider));
    await tester.pumpAndSettle();
    expect(find.text('Pasta Carbonara'), findsOneWidget);
  });

  testWidgets('shows back button in header', (tester) async {
    final provider = FakeCookingLogProvider();
    await tester.pumpWidget(buildTestWidget(provider));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
  });
}
