import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chef_specials/l10n/generated/app_localizations.dart';
import 'package:chef_specials/providers/connectivity_provider.dart';
import 'package:chef_specials/widgets/connectivity_indicator.dart';

class _FakeConnectivityProvider extends ChangeNotifier
    implements ConnectivityProvider {
  @override
  bool isOnline;
  @override
  bool isSyncing;

  _FakeConnectivityProvider({
    this.isOnline = true,
    this.isSyncing = false,
  });

  @override
  Future<void> init() async {}

  @override
  Future<void> syncQueue(String userId) async {}
}

Widget _buildTestWidget(_FakeConnectivityProvider provider) {
  return ChangeNotifierProvider<ConnectivityProvider>.value(
    value: provider,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: Column(
          children: const [ConnectivityIndicator()],
        ),
      ),
    ),
  );
}

void main() {
  group('ConnectivityIndicator', () {
    testWidgets('renders without error when online and not syncing',
        (tester) async {
      final provider = _FakeConnectivityProvider();
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pump();

      expect(find.byType(ConnectivityIndicator), findsOneWidget);
      expect(find.text("You're Offline"), findsNothing);
      expect(find.text('Back Online — Syncing...'), findsNothing);
    });

    testWidgets('shows offline bar when offline', (tester) async {
      final provider =
          _FakeConnectivityProvider(isOnline: false, isSyncing: false);
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pump();

      expect(find.text("You're Offline"), findsOneWidget);
      expect(find.text('Changes will sync when connected'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('shows back-online banner when syncing', (tester) async {
      final provider =
          _FakeConnectivityProvider(isOnline: true, isSyncing: true);
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pump();

      expect(find.text('Back Online — Syncing...'), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    });

    testWidgets('transitions from offline to syncing state', (tester) async {
      final provider = _FakeConnectivityProvider(isOnline: false);
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pump();

      expect(find.text("You're Offline"), findsOneWidget);

      provider.isOnline = true;
      provider.isSyncing = true;
      provider.notifyListeners();
      await tester.pump();

      expect(find.text('Back Online — Syncing...'), findsOneWidget);
      expect(find.text("You're Offline"), findsNothing);
    });

    testWidgets('offline state shows wifi_off icon and no sync icon',
        (tester) async {
      final provider = _FakeConnectivityProvider(isOnline: false);
      await tester.pumpWidget(_buildTestWidget(provider));
      await tester.pump();

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsNothing);
    });
  });
}
