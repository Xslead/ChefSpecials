import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/utils/unit_converter.dart';

void main() {
  group('convertWeight', () {
    test('g to kg', () {
      expect(UnitConverter.convertWeight(1000, WeightUnit.g, WeightUnit.kg), 1.0);
    });

    test('kg to g', () {
      expect(UnitConverter.convertWeight(2.5, WeightUnit.kg, WeightUnit.g), 2500.0);
    });

    test('g to oz', () {
      expect(
        UnitConverter.convertWeight(28.3495, WeightUnit.g, WeightUnit.oz),
        closeTo(1.0, 0.001),
      );
    });

    test('oz to g', () {
      expect(
        UnitConverter.convertWeight(1, WeightUnit.oz, WeightUnit.g),
        closeTo(28.3495, 0.001),
      );
    });

    test('g to lb', () {
      expect(
        UnitConverter.convertWeight(453.592, WeightUnit.g, WeightUnit.lb),
        closeTo(1.0, 0.001),
      );
    });

    test('lb to g', () {
      expect(
        UnitConverter.convertWeight(1, WeightUnit.lb, WeightUnit.g),
        closeTo(453.592, 0.001),
      );
    });

    test('oz to lb (cross-unit)', () {
      expect(
        UnitConverter.convertWeight(16, WeightUnit.oz, WeightUnit.lb),
        closeTo(1.0, 0.01),
      );
    });

    test('identity', () {
      expect(UnitConverter.convertWeight(500, WeightUnit.g, WeightUnit.g), 500.0);
    });
  });

  group('convertVolume', () {
    test('mL to L', () {
      expect(UnitConverter.convertVolume(1000, VolumeUnit.mL, VolumeUnit.L), 1.0);
    });

    test('L to mL', () {
      expect(UnitConverter.convertVolume(1.5, VolumeUnit.L, VolumeUnit.mL), 1500.0);
    });

    test('mL to cups', () {
      expect(
        UnitConverter.convertVolume(236.588, VolumeUnit.mL, VolumeUnit.cups),
        closeTo(1.0, 0.001),
      );
    });

    test('mL to tbsp', () {
      expect(
        UnitConverter.convertVolume(14.787, VolumeUnit.mL, VolumeUnit.tbsp),
        closeTo(1.0, 0.001),
      );
    });

    test('mL to tsp', () {
      expect(
        UnitConverter.convertVolume(4.929, VolumeUnit.mL, VolumeUnit.tsp),
        closeTo(1.0, 0.001),
      );
    });

    test('mL to flOz', () {
      expect(
        UnitConverter.convertVolume(29.5735, VolumeUnit.mL, VolumeUnit.flOz),
        closeTo(1.0, 0.001),
      );
    });

    test('cups to tbsp (cross-unit)', () {
      expect(
        UnitConverter.convertVolume(1, VolumeUnit.cups, VolumeUnit.tbsp),
        closeTo(16.0, 0.1),
      );
    });

    test('identity', () {
      expect(UnitConverter.convertVolume(250, VolumeUnit.mL, VolumeUnit.mL), 250.0);
    });
  });

  group('convertTemperature', () {
    test('0°C = 32°F', () {
      expect(UnitConverter.convertTemperature(0, TempUnit.celsius, TempUnit.fahrenheit), 32.0);
    });

    test('100°C = 212°F', () {
      expect(UnitConverter.convertTemperature(100, TempUnit.celsius, TempUnit.fahrenheit), 212.0);
    });

    test('-40°C = -40°F', () {
      expect(UnitConverter.convertTemperature(-40, TempUnit.celsius, TempUnit.fahrenheit), -40.0);
    });

    test('32°F = 0°C', () {
      expect(UnitConverter.convertTemperature(32, TempUnit.fahrenheit, TempUnit.celsius), closeTo(0, 0.001));
    });

    test('identity C→C', () {
      expect(UnitConverter.convertTemperature(100, TempUnit.celsius, TempUnit.celsius), 100.0);
    });

    test('identity F→F', () {
      expect(UnitConverter.convertTemperature(72, TempUnit.fahrenheit, TempUnit.fahrenheit), 72.0);
    });
  });

  group('scaleIngredient', () {
    test('scale up', () {
      expect(UnitConverter.scaleIngredient(100, 2, 4), 200.0);
    });

    test('scale down', () {
      expect(UnitConverter.scaleIngredient(100, 4, 2), 50.0);
    });

    test('identity', () {
      expect(UnitConverter.scaleIngredient(100, 4, 4), 100.0);
    });

    test('zero-guard (originalServings = 0)', () {
      expect(UnitConverter.scaleIngredient(100, 0, 4), 100.0);
    });
  });

  group('smartFormat', () {
    test('auto-simplify 1000g → 1 kg', () {
      expect(UnitConverter.smartFormat(1000, 'g'), '1 kg');
    });

    test('auto-simplify 1000mL → 1 L', () {
      expect(UnitConverter.smartFormat(1000, 'mL'), '1 L');
    });

    test('auto-simplify 2500g → 2.5 kg', () {
      expect(UnitConverter.smartFormat(2500, 'g'), '2.5 kg');
    });

    test('strips .0 from whole numbers', () {
      expect(UnitConverter.smartFormat(500, 'g'), '500 g');
    });

    test('keeps decimals when needed', () {
      expect(UnitConverter.smartFormat(250.5, 'g'), '250.5 g');
    });

    test('no simplification for other units', () {
      expect(UnitConverter.smartFormat(3, 'cups'), '3 cups');
    });
  });
}
