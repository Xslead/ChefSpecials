import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/widgets/premium_card.dart';

void main() {
  Widget buildTestWidget({
    Widget child = const Text('Card Content'),
    EdgeInsetsGeometry? padding,
    Gradient? gradient,
    double borderRadius = 18,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PremiumCard(
          padding: padding,
          gradient: gradient,
          borderRadius: borderRadius,
          child: child,
        ),
      ),
    );
  }

  group('PremiumCard', () {
    testWidgets('renders the child widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const Text('Hello World'),
      ));

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('renders a complex child widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Title'),
            Text('Subtitle'),
            Icon(Icons.star),
          ],
        ),
      ));

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('applies padding when provided', (WidgetTester tester) async {
      const testPadding = EdgeInsets.all(24);
      await tester.pumpWidget(buildTestWidget(
        padding: testPadding,
      ));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, testPadding);
    });

    testWidgets('has no padding when not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, isNull);
    });

    testWidgets('has correct default borderRadius of 18',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(18));
    });

    testWidgets('respects custom borderRadius', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(borderRadius: 8));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('renders without error when gradient is provided',
        (WidgetTester tester) async {
      const testGradient = LinearGradient(
        colors: [Colors.blue, Colors.purple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      await tester.pumpWidget(buildTestWidget(gradient: testGradient));

      // Should render without error
      expect(find.byType(PremiumCard), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);

      // Verify the gradient is applied to the decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, testGradient);
    });

    testWidgets('uses white background color when no gradient is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.gradient, isNull);
    });

    testWidgets('does not set color when gradient is provided',
        (WidgetTester tester) async {
      const testGradient = LinearGradient(
        colors: [Colors.red, Colors.orange],
      );

      await tester.pumpWidget(buildTestWidget(gradient: testGradient));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNull);
      expect(decoration.gradient, isNotNull);
    });

    testWidgets('has a border in its decoration', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('has a box shadow in its decoration',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow, isNotEmpty);
    });

    testWidgets('applies symmetric padding correctly',
        (WidgetTester tester) async {
      const testPadding =
          EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      await tester.pumpWidget(buildTestWidget(padding: testPadding));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, testPadding);
    });

    testWidgets('renders with zero borderRadius', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(borderRadius: 0));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumCard),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(0));
    });
  });
}
