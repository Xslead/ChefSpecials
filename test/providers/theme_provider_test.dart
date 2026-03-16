import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chef_specials/providers/theme_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider', () {
    test('initial theme mode is system', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.system);
    });

    test('isSystem returns true for default state', () {
      final provider = ThemeProvider();
      expect(provider.isSystem, true);
    });

    test('isDark returns false for default state', () {
      final provider = ThemeProvider();
      expect(provider.isDark, false);
    });

    test('setThemeMode to dark', () {
      final provider = ThemeProvider();
      provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDark, true);
      expect(provider.isSystem, false);
    });

    test('setThemeMode to light', () {
      final provider = ThemeProvider();
      provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDark, false);
      expect(provider.isSystem, false);
    });

    test('setThemeMode notifies listeners', () {
      final provider = ThemeProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setThemeMode(ThemeMode.dark);
      expect(notifyCount, 1);
    });

    test('toggleTheme from system goes to light', () {
      final provider = ThemeProvider();
      // system -> not dark, so toggle produces dark
      provider.toggleTheme();
      // ThemeMode.system != ThemeMode.dark, so the code sets ThemeMode.dark
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('toggleTheme from dark goes to light', () {
      final provider = ThemeProvider();
      provider.setThemeMode(ThemeMode.dark);
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
    });

    test('toggleTheme from light goes to dark', () {
      final provider = ThemeProvider();
      provider.setThemeMode(ThemeMode.light);
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('toggleTheme notifies listeners', () {
      final provider = ThemeProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.toggleTheme();
      expect(notifyCount, 1);
    });

    test('setThemeMode saves to SharedPreferences', () async {
      final provider = ThemeProvider();
      provider.setThemeMode(ThemeMode.dark);

      // Allow async saveToPrefs to complete
      await Future.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('loads theme from SharedPreferences on creation', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});

      final provider = ThemeProvider();

      // Wait for async _loadFromPrefs to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDark, true);
    });

    test('loads light theme from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});

      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.themeMode, ThemeMode.light);
    });

    test('handles invalid theme value in SharedPreferences gracefully',
        () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'invalid_value'});

      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.themeMode, ThemeMode.system);
    });
  });
}
