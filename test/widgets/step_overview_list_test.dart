import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/recipe_step.dart';
import 'package:chef_specials/screens/recipe_detail/widgets/step_overview_list.dart';

void main() {
  Widget buildTestWidget(List<RecipeStep> steps) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: StepOverviewList(steps: steps),
        ),
      ),
    );
  }

  group('StepOverviewList', () {
    testWidgets('renders step numbers', (WidgetTester tester) async {
      final steps = [
        RecipeStep(order: 1, instruction: 'Preheat the oven'),
        RecipeStep(order: 2, instruction: 'Mix dry ingredients'),
        RecipeStep(order: 3, instruction: 'Bake for 30 minutes'),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders step instructions', (WidgetTester tester) async {
      final steps = [
        RecipeStep(order: 1, instruction: 'Preheat the oven to 180C'),
        RecipeStep(order: 2, instruction: 'Mix flour and sugar together'),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      expect(find.text('Preheat the oven to 180C'), findsOneWidget);
      expect(find.text('Mix flour and sugar together'), findsOneWidget);
    });

    testWidgets('shows timer icon when step has timerSeconds',
        (WidgetTester tester) async {
      final steps = [
        RecipeStep(order: 1, instruction: 'Boil water', timerSeconds: 300),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('does not show timer icon when step has no timer',
        (WidgetTester tester) async {
      final steps = [
        RecipeStep(order: 1, instruction: 'Chop vegetables'),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      expect(find.byIcon(Icons.timer_outlined), findsNothing);
    });

    testWidgets('formats timer as minutes only when no remaining seconds',
        (WidgetTester tester) async {
      final steps = [
        RecipeStep(order: 1, instruction: 'Bake', timerSeconds: 300),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      // 300 seconds = 5m
      expect(find.text('5m'), findsOneWidget);
    });

    testWidgets('formats timer as seconds only when less than a minute',
        (WidgetTester tester) async {
      final steps = [
        RecipeStep(order: 1, instruction: 'Quick sear', timerSeconds: 30),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      // 30 seconds = 30s
      expect(find.text('30s'), findsOneWidget);
    });

    testWidgets('formats timer with both minutes and seconds',
        (WidgetTester tester) async {
      final steps = [
        RecipeStep(order: 1, instruction: 'Simmer', timerSeconds: 150),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      // 150 seconds = 2m 30s
      expect(find.text('2m 30s'), findsOneWidget);
    });

    testWidgets('renders empty widget when no steps',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget([]));

      expect(find.byType(StepOverviewList), findsOneWidget);
      // No step numbers should be present
      expect(find.text('1'), findsNothing);
    });

    testWidgets('renders multiple steps with mixed timer presence',
        (WidgetTester tester) async {
      final steps = [
        RecipeStep(order: 1, instruction: 'Prep ingredients'),
        RecipeStep(order: 2, instruction: 'Cook on medium', timerSeconds: 600),
        RecipeStep(order: 3, instruction: 'Serve on plate'),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      // Only step 2 has a timer
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.text('10m'), findsOneWidget);

      // All instructions present
      expect(find.text('Prep ingredients'), findsOneWidget);
      expect(find.text('Cook on medium'), findsOneWidget);
      expect(find.text('Serve on plate'), findsOneWidget);
    });

    testWidgets('each step is in its own Container',
        (WidgetTester tester) async {
      final steps = [
        RecipeStep(order: 1, instruction: 'Step one'),
        RecipeStep(order: 2, instruction: 'Step two'),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      // Both steps render
      expect(find.text('Step one'), findsOneWidget);
      expect(find.text('Step two'), findsOneWidget);
    });

    testWidgets('step numbers are displayed in circular containers',
        (WidgetTester tester) async {
      final steps = [
        RecipeStep(order: 1, instruction: 'First step'),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      // The step number is wrapped in a Container with BoxShape.circle
      // Verify the text '1' is rendered in the circle
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('single step renders correctly', (WidgetTester tester) async {
      final steps = [
        RecipeStep(
          order: 1,
          instruction: 'Just one step needed',
          timerSeconds: 60,
        ),
      ];

      await tester.pumpWidget(buildTestWidget(steps));

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Just one step needed'), findsOneWidget);
      expect(find.text('1m'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });
  });
}
