import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chef_specials/l10n/generated/app_localizations.dart';
import 'package:chef_specials/screens/home/widgets/category_filter_bar.dart';

void main() {
  Widget buildTestWidget({
    String? selectedCategory,
    Function(String?)? onSelected,
  }) {
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
        body: CategoryFilterBar(
          selectedCategory: selectedCategory,
          onSelected: onSelected ?? (_) {},
        ),
      ),
    );
  }

  group('CategoryFilterBar', () {
    testWidgets('renders All chip', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders all default category chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // All categories should be present (scroll to find them)
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
    });

    testWidgets('can scroll to find more category chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Scroll the horizontal list to reveal later categories
      await tester.drag(find.byType(ListView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // After scrolling, these should be visible
      expect(find.text('Dessert'), findsOneWidget);
    });

    testWidgets('tapping a chip calls onSelected with the category value',
        (WidgetTester tester) async {
      String? selectedValue = 'not_called';

      await tester.pumpWidget(buildTestWidget(
        onSelected: (value) => selectedValue = value,
      ));
      await tester.pumpAndSettle();

      // Tap the Breakfast chip
      await tester.tap(find.text('Breakfast'));
      await tester.pump();

      expect(selectedValue, 'Breakfast');
    });

    testWidgets('tapping All chip calls onSelected with null',
        (WidgetTester tester) async {
      String? selectedValue = 'something';

      await tester.pumpWidget(buildTestWidget(
        selectedCategory: 'Breakfast',
        onSelected: (value) => selectedValue = value,
      ));
      await tester.pumpAndSettle();

      // Tap the All chip
      await tester.tap(find.text('All'));
      await tester.pump();

      expect(selectedValue, isNull);
    });

    testWidgets('renders inside a horizontal ListView',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('widget has a fixed height of 44',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ListView),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.height, 44);
    });

    testWidgets('renders with a selected category',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(selectedCategory: 'Lunch'));
      await tester.pumpAndSettle();

      // The widget should render without errors with a selected category
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders with null selected category (All selected)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(selectedCategory: null));
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('chips use GestureDetector for tap handling',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsWidgets);
    });
  });
}
