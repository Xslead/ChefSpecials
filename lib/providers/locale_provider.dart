import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'locale';
  static const _supportedCodes = {'en', 'tr'};
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      _locale = Locale(code);
    } else {
      final systemCode = ui.PlatformDispatcher.instance.locale.languageCode;
      _locale = _supportedCodes.contains(systemCode)
          ? Locale(systemCode)
          : const Locale('en');
    }
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (locale != _locale) {
      _locale = locale;
      _save();
      notifyListeners();
    }
  }

  void toggleLocale() {
    _locale = _locale.languageCode == 'en'
        ? const Locale('tr')
        : const Locale('en');
    _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _locale.languageCode);
  }
}
