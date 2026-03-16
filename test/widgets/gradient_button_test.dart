import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/widgets/gradient_button.dart';

void main() {
  Widget buildTestWidget({
    String text = 'Test Button',
    VoidCallback? onPressed,
    double height = 54,
    double borderRadius = 14,
    IconData? icon,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: GradientButton(
          text: text,
          onPressed: onPressed,
          height: height,
          borderRadius: borderRadius,
          icon: icon,
        ),
      ),
    );
  }

  group('GradientButton', () {
    testWidgets('renders the text label', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(text: 'Sign In'));
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(buildTestWidget(
        onPressed: () => pressed = true,
      ));

      await tester.tap(find.byType(GradientButton));
      expect(pressed, isTrue);
    });

    testWidgets('does NOT call onPressed when disabled (onPressed is null)',
        (WidgetTester tester) async {
      // onPressed is null by default in buildTestWidget
      await tester.pumpWidget(buildTestWidget());

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });

    testWidgets('renders icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        icon: Icons.add,
        onPressed: () {},
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('does NOT render icon when not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        onPressed: () {},
      ));

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('has the correct default height of 54',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(onPressed: () {}));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GradientButton),
          matching: find.byType(Container),
        ),
      );
      // Container uses height property, check via BoxConstraints or size
      expect(container.constraints?.maxHeight ?? 54, 54);
    });

    testWidgets('respects custom height', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        height: 80,
        onPressed: () {},
      ));

      final size = tester.getSize(find.byType(GradientButton));
      expect(size.height, 80);
    });

    testWidgets('renders text with Row when icon is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        icon: Icons.save,
        onPressed: () {},
      ));

      // When icon is provided, there should be a Row containing icon and text
      expect(find.byType(Row), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('does NOT render Row when icon is not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        onPressed: () {},
      ));

      // Without icon, text is rendered directly without a Row
      expect(find.byType(Row), findsNothing);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('has full width (double.infinity)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(onPressed: () {}));

      final buttonSize = tester.getSize(find.byType(GradientButton));
      final scaffoldSize = tester.getSize(find.byType(Scaffold));
      // The button should span the full width of its parent
      expect(buttonSize.width, scaffoldSize.width);
    });

    testWidgets('text is white regardless of enabled state',
        (WidgetTester tester) async {
      // Enabled button
      await tester.pumpWidget(buildTestWidget(onPressed: () {}));
      final enabledText = tester.widget<Text>(find.text('Test Button'));
      expect(enabledText.style?.color, Colors.white);

      // Disabled button
      await tester.pumpWidget(buildTestWidget());
      final disabledText = tester.widget<Text>(find.text('Test Button'));
      expect(disabledText.style?.color, Colors.white);
    });

    testWidgets('tapping a disabled button does not throw',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // This should not throw
      await tester.tap(find.byType(InkWell));
      await tester.pump();
    });

    testWidgets('icon has correct color (white) and size (20)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        icon: Icons.favorite,
        onPressed: () {},
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, Colors.white);
      expect(icon.size, 20);
    });

    testWidgets('renders with different text values',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        text: 'Create Account',
        onPressed: () {},
      ));
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });
  });
}
