import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/widgets/serving_size_selector.dart';
import 'package:chef_specials/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('renders Serves X text', (tester) async {
    await tester.pumpWidget(_wrap(
      ServingSizeSelector(
        currentServings: 4,
        onChanged: (_) {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Serves 4'), findsOneWidget);
  });

  testWidgets('plus button increments servings', (tester) async {
    int? result;
    await tester.pumpWidget(_wrap(
      ServingSizeSelector(
        currentServings: 4,
        onChanged: (v) => result = v,
      ),
    ));
    await tester.pumpAndSettle();

    // Tap the plus (add) button
    await tester.tap(find.byIcon(Icons.add));
    expect(result, 5);
  });

  testWidgets('minus button decrements servings', (tester) async {
    int? result;
    await tester.pumpWidget(_wrap(
      ServingSizeSelector(
        currentServings: 4,
        onChanged: (v) => result = v,
      ),
    ));
    await tester.pumpAndSettle();

    // Tap the minus (remove) button
    await tester.tap(find.byIcon(Icons.remove));
    expect(result, 3);
  });

  testWidgets('minus button disabled at min', (tester) async {
    int? result;
    await tester.pumpWidget(_wrap(
      ServingSizeSelector(
        currentServings: 1,
        onChanged: (v) => result = v,
        min: 1,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.remove));
    expect(result, isNull);
  });

  testWidgets('plus button disabled at max', (tester) async {
    int? result;
    await tester.pumpWidget(_wrap(
      ServingSizeSelector(
        currentServings: 20,
        onChanged: (v) => result = v,
        max: 20,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    expect(result, isNull);
  });
}
