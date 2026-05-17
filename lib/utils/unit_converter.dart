enum WeightUnit { g, kg, oz, lb }

enum VolumeUnit { mL, L, cups, tbsp, tsp, flOz }

enum TempUnit { celsius, fahrenheit }

class UnitConverter {
  static const _weightToGrams = {
    WeightUnit.g: 1.0,
    WeightUnit.kg: 1000.0,
    WeightUnit.oz: 28.3495,
    WeightUnit.lb: 453.592,
  };

  static const _volumeToMl = {
    VolumeUnit.mL: 1.0,
    VolumeUnit.L: 1000.0,
    VolumeUnit.cups: 236.588,
    VolumeUnit.tbsp: 14.787,
    VolumeUnit.tsp: 4.929,
    VolumeUnit.flOz: 29.5735,
  };

  static double convertWeight(double value, WeightUnit from, WeightUnit to) {
    if (from == to) return value;
    final grams = value * _weightToGrams[from]!;
    return grams / _weightToGrams[to]!;
  }

  static double convertVolume(double value, VolumeUnit from, VolumeUnit to) {
    if (from == to) return value;
    final ml = value * _volumeToMl[from]!;
    return ml / _volumeToMl[to]!;
  }

  static double convertTemperature(double value, TempUnit from, TempUnit to) {
    if (from == to) return value;
    if (from == TempUnit.celsius) return value * 9 / 5 + 32;
    return (value - 32) * 5 / 9;
  }

  static double scaleIngredient(
    double originalAmount,
    int originalServings,
    int newServings,
  ) {
    if (originalServings <= 0) return originalAmount;
    return originalAmount * newServings / originalServings;
  }

  static String smartFormat(double value, String unit) {
    final lowerUnit = unit.toLowerCase();

    if (lowerUnit == 'g' && value >= 1000) {
      return '${_stripTrailingZeros(value / 1000)} kg';
    }
    if (lowerUnit == 'ml' && value >= 1000) {
      return '${_stripTrailingZeros(value / 1000)} L';
    }

    return '${_stripTrailingZeros(value)} $unit';
  }

  static String _stripTrailingZeros(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    final s = value.toStringAsFixed(2);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static String weightUnitLabel(WeightUnit unit) {
    switch (unit) {
      case WeightUnit.g:
        return 'g';
      case WeightUnit.kg:
        return 'kg';
      case WeightUnit.oz:
        return 'oz';
      case WeightUnit.lb:
        return 'lb';
    }
  }

  static String volumeUnitLabel(VolumeUnit unit) {
    switch (unit) {
      case VolumeUnit.mL:
        return 'mL';
      case VolumeUnit.L:
        return 'L';
      case VolumeUnit.cups:
        return 'cups';
      case VolumeUnit.tbsp:
        return 'tbsp';
      case VolumeUnit.tsp:
        return 'tsp';
      case VolumeUnit.flOz:
        return 'fl oz';
    }
  }

  static String tempUnitLabel(TempUnit unit) {
    switch (unit) {
      case TempUnit.celsius:
        return '°C';
      case TempUnit.fahrenheit:
        return '°F';
    }
  }

  static const _volumeUnitLabels = {'100mL', 'mL', 'ml', 'cups', 'cup', 'tbsp', 'tsp', 'fl oz', 'floz', 'L', 'l'};

  static bool isVolumeUnit(String unit) => _volumeUnitLabels.contains(unit);

  static const _weightUnitLabels = {'g', 'kg', 'oz', 'lb', 'gram', 'grams'};

  static String formatWithPreference(double amount, String unit, bool isMetric) {
    final lower = unit.toLowerCase().trim();

    if (_weightUnitLabels.contains(lower)) {
      final grams = switch (lower) {
        'kg' => amount * 1000,
        'oz' => amount * 28.3495,
        'lb' => amount * 453.592,
        _ => amount,
      };
      if (isMetric) return smartFormat(grams, 'g');
      final oz = grams / 28.3495;
      if (oz >= 16) return '${_stripTrailingZeros(oz / 16)} lb';
      return '${_stripTrailingZeros(oz)} oz';
    }

    if (_volumeUnitLabels.contains(lower)) {
      final ml = switch (lower) {
        'l' => amount * 1000,
        'cups' || 'cup' => amount * 236.588,
        'tbsp' => amount * 14.787,
        'tsp' => amount * 4.929,
        'fl oz' || 'floz' => amount * 29.5735,
        _ => amount,
      };
      if (isMetric) return smartFormat(ml, 'mL');
      final flOz = ml / 29.5735;
      if (flOz >= 8) return '${_stripTrailingZeros(flOz / 8)} cups';
      return '${_stripTrailingZeros(flOz)} fl oz';
    }

    return unit.isNotEmpty ? '${_stripTrailingZeros(amount)} $unit' : _stripTrailingZeros(amount);
  }
}
