import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/l10n/generated/app_localizations.dart';
import 'package:chef_specials/screens/cooking_mode/widgets/countdown_timer_widget.dart';

void main() {
  Widget buildTestWidget({int totalSeconds = 90}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: CountdownTimerWidget(totalSeconds: totalSeconds),
      ),
    );
  }

  group('CountdownTimerWidget', () {
    testWidgets('renders initial time in MM:SS format',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 90));

      // 90 seconds = 01:30
      expect(find.text('01:30'), findsOneWidget);
    });

    testWidgets('renders 00:00 format for zero seconds',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 0));

      // 0 seconds means timer is already done
      expect(find.text('Done!'), findsOneWidget);
    });

    testWidgets('renders correctly for exact minutes',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 300));

      // 300 seconds = 05:00
      expect(find.text('05:00'), findsOneWidget);
    });

    testWidgets('shows Start button initially', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 60));

      expect(find.text('Start'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('shows Reset button initially', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 60));

      expect(find.text('Reset'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('Start button changes to Pause when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 60));

      // Tap the Start button
      await tester.tap(find.text('Start'));
      await tester.pump();

      expect(find.text('Pause'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.text('Start'), findsNothing);
    });

    testWidgets('countdown decrements after 1 second',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 10));

      // Start the timer
      await tester.tap(find.text('Start'));
      await tester.pump();

      // Advance 1 second
      await tester.pump(const Duration(seconds: 1));

      // Should show 00:09
      expect(find.text('00:09'), findsOneWidget);
    });

    testWidgets('Pause button stops the countdown',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 10));

      // Start the timer
      await tester.tap(find.text('Start'));
      await tester.pump();

      // Advance 2 seconds
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // Should show 00:08
      expect(find.text('00:08'), findsOneWidget);

      // Pause the timer
      await tester.tap(find.text('Pause'));
      await tester.pump();

      // Verify Start button is back
      expect(find.text('Start'), findsOneWidget);

      // Advance more time - should stay at 00:08
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:08'), findsOneWidget);
    });

    testWidgets('Reset button resets to initial time',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 10));

      // Start the timer
      await tester.tap(find.text('Start'));
      await tester.pump();

      // Advance 3 seconds
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // Should be at 00:07
      expect(find.text('00:07'), findsOneWidget);

      // Tap Reset
      await tester.tap(find.text('Reset'));
      await tester.pump();

      // Should be back at 00:10
      expect(find.text('00:10'), findsOneWidget);
      // Start button should be visible (not Pause)
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('shows Done! when timer reaches 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 3));

      // Start the timer
      await tester.tap(find.text('Start'));
      await tester.pump();

      // Advance 3 seconds to reach 0
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Done!'), findsOneWidget);
    });

    testWidgets('Start/Pause button is hidden when timer is done',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 2));

      // Start the timer
      await tester.tap(find.text('Start'));
      await tester.pump();

      // Advance to completion
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // Start/Pause button should be gone, only Reset visible
      expect(find.text('Start'), findsNothing);
      expect(find.text('Pause'), findsNothing);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('Reset after Done! restores initial time',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 2));

      // Start and run to completion
      await tester.tap(find.text('Start'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Done!'), findsOneWidget);

      // Tap Reset
      await tester.tap(find.text('Reset'));
      await tester.pump();

      // Should be back to initial time
      expect(find.text('00:02'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('renders CircularProgressIndicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(totalSeconds: 60));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('pads single-digit minutes and seconds',
        (WidgetTester tester) async {
      // 65 seconds = 1 min 5 sec = 01:05
      await tester.pumpWidget(buildTestWidget(totalSeconds: 65));

      expect(find.text('01:05'), findsOneWidget);
    });
  });
}
