import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UnitSystem { metric, imperial }

class UnitPreferenceProvider extends ChangeNotifier {
  static const _key = 'unit_system';

  UnitSystem _unitSystem = UnitSystem.metric;

  UnitSystem get unitSystem => _unitSystem;
  bool get isMetric => _unitSystem == UnitSystem.metric;

  UnitPreferenceProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      _unitSystem = UnitSystem.values.firstWhere(
        (s) => s.name == value,
        orElse: () => UnitSystem.metric,
      );
      notifyListeners();
    }
  }

  Future<void> setUnitSystem(UnitSystem system) async {
    _unitSystem = system;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, system.name);
  }

  void toggleUnitSystem() {
    setUnitSystem(
      _unitSystem == UnitSystem.metric ? UnitSystem.imperial : UnitSystem.metric,
    );
  }
}
