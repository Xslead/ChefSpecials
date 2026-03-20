import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chef_specials/providers/locale_provider.dart';

void main() {
  late LocaleProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    provider = LocaleProvider();
  });

  group('LocaleProvider', () {
    test('initial locale is English', () {
      expect(provider.locale, const Locale('en'));
    });

    test('setLocale changes locale to Turkish', () {
      provider.setLocale(const Locale('tr'));
      expect(provider.locale, const Locale('tr'));
    });

    test('setLocale changes locale to English', () {
      provider.setLocale(const Locale('tr'));
      provider.setLocale(const Locale('en'));
      expect(provider.locale, const Locale('en'));
    });

    test('setLocale does not notify when locale is the same', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setLocale(const Locale('en'));
      expect(notifyCount, 0);
    });

    test('setLocale notifies listeners when locale changes', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setLocale(const Locale('tr'));
      expect(notifyCount, 1);
    });

    test('toggleLocale switches from English to Turkish', () {
      provider.toggleLocale();
      expect(provider.locale, const Locale('tr'));
    });

    test('toggleLocale switches from Turkish to English', () {
      provider.setLocale(const Locale('tr'));
      provider.toggleLocale();
      expect(provider.locale, const Locale('en'));
    });

    test('toggleLocale notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.toggleLocale();
      expect(notifyCount, 1);
    });

    test('double toggle returns to original locale', () {
      provider.toggleLocale();
      provider.toggleLocale();
      expect(provider.locale, const Locale('en'));
    });

    test('setLocale to arbitrary locale works', () {
      provider.setLocale(const Locale('fr'));
      expect(provider.locale, const Locale('fr'));
      // Toggle from non-en should go to English
      provider.toggleLocale();
      expect(provider.locale, const Locale('en'));
    });
  });
}
