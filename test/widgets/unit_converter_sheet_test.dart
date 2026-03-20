import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/widgets/unit_converter_sheet.dart';
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
  testWidgets('default state renders with Weight selected', (tester) async {
    await tester.pumpWidget(_wrap(
      Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => UnitConverterSheet.show(context),
          child: const Text('Open'),
        );
      }),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Unit Converter'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Result'), findsOneWidget);
  });

  testWidgets('category switching shows correct unit dropdowns', (tester) async {
    await tester.pumpWidget(_wrap(
      Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => UnitConverterSheet.show(context),
          child: const Text('Open'),
        );
      }),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Default is Weight — should show g, kg etc.
    expect(find.text('g'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);

    // Switch to Volume
    await tester.tap(find.text('Volume'));
    await tester.pumpAndSettle();

    expect(find.text('mL'), findsOneWidget);
    expect(find.text('L'), findsOneWidget);

    // Switch to Temperature
    await tester.tap(find.text('Temperature'));
    await tester.pumpAndSettle();

    expect(find.text('°C'), findsOneWidget);
    expect(find.text('°F'), findsOneWidget);
  });

  testWidgets('input + conversion produces correct result', (tester) async {
    await tester.pumpWidget(_wrap(
      Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => UnitConverterSheet.show(context),
          child: const Text('Open'),
        );
      }),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Default: g → kg, enter 1000
    final input = find.byType(TextField);
    await tester.enterText(input, '1000');
    await tester.pumpAndSettle();

    // 1000g = 1 kg
    expect(find.text('1 kg'), findsOneWidget);
  });

  testWidgets('pre-fill from ingredient populates fields', (tester) async {
    await tester.pumpWidget(_wrap(
      Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => UnitConverterSheet.show(
            context,
            initialValue: 500,
            initialUnit: 'mL',
          ),
          child: const Text('Open'),
        );
      }),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Should auto-detect Volume category
    // Input should have 500.0
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, '500.0');

    // Should show a result (500mL = 0.5L)
    expect(find.text('0.5 L'), findsOneWidget);
  });
}
