import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chef_specials/l10n/generated/app_localizations.dart';
import 'package:chef_specials/providers/auth_provider.dart';
import 'package:chef_specials/providers/reports_provider.dart';
import 'package:chef_specials/services/daily_tracker_service.dart';
import 'package:chef_specials/screens/reports/reports_screen.dart';

class _FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #userModel) {
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}

Future<void> _seedLog(
  FakeFirebaseFirestore firestore, {
  required String userId,
  required String date,
  double calories = 200,
  double protein = 20,
  double carbs = 30,
  double fat = 10,
}) async {
  await firestore.collection('daily_logs').add({
    'userId': userId,
    'date': date,
    'meals': [
      {
        'name': 'Test',
        'mealType': 'breakfast',
        'quantity': 100,
        'unit': 'g',
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      },
    ],
    'waterMl': 0,
  });
}

Widget _buildTestWidget(ReportsProvider reportsProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ReportsProvider>.value(value: reportsProvider),
      ChangeNotifierProvider<AuthProvider>(create: (_) => _FakeAuthProvider()),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReportsScreen(),
    ),
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DailyTrackerService service;
  late ReportsProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = DailyTrackerService(firestore: fakeFirestore);
    provider = ReportsProvider(service: service);
  });

  group('ReportsScreen', () {
    testWidgets('renders header with title', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('renders weekly and monthly tabs', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.text('Weekly'), findsWidgets);
      expect(find.text('Monthly'), findsWidgets);
    });

    testWidgets('renders export icon button in header',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.ios_share_outlined), findsOneWidget);
    });

    testWidgets('shows charts even with no data', (WidgetTester tester) async {
      await provider.loadWeeklyData('user1');
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pumpAndSettle();

      // Charts should always be visible — nutrient pills present
      expect(find.text('Calories'), findsWidgets);
    });

    testWidgets('back button exists', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows bar chart and average card when data exists',
        (WidgetTester tester) async {
      // Seed data for current week
      final monday = provider.weekStart;
      final dateStr =
          '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
      await _seedLog(fakeFirestore, userId: 'user1', date: dateStr);
      await provider.loadWeeklyData('user1');

      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pumpAndSettle();

      // Bar chart nutrient pills should be visible
      expect(find.text('Calories'), findsWidgets);
      expect(find.text('Protein'), findsWidgets);
      expect(find.text('Carbs'), findsWidgets);
      expect(find.text('Fat'), findsWidgets);
    });

    testWidgets(
        'switching to monthly tab with data shows macro distribution and line chart',
        (WidgetTester tester) async {
      // Seed data for current month
      final month = provider.selectedMonth;
      final dateStr =
          '${month.year}-${month.month.toString().padLeft(2, '0')}-05';
      await _seedLog(fakeFirestore, userId: 'user1', date: dateStr);
      await provider.loadMonthlyData('user1');

      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      // The macro distribution and line chart section titles
      expect(find.text('Macro Distribution'), findsOneWidget);
      expect(find.text('Monthly'), findsWidgets); // tab + section title
    });

    testWidgets('shows day circles in weekly header',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pumpAndSettle();

      // Should have chevron navigation icons
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
