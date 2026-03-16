import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/recipe_step.dart';

void main() {
  group('RecipeStep', () {
    group('fromMap', () {
      test('creates RecipeStep with all fields', () {
        final map = {
          'order': 1,
          'instruction': 'Preheat oven to 350F',
          'imageUrl': 'https://example.com/step1.jpg',
          'timerSeconds': 600,
        };

        final step = RecipeStep.fromMap(map);

        expect(step.order, 1);
        expect(step.instruction, 'Preheat oven to 350F');
        expect(step.imageUrl, 'https://example.com/step1.jpg');
        expect(step.timerSeconds, 600);
      });

      test('creates RecipeStep with nullable fields as null', () {
        final map = {
          'order': 0,
          'instruction': 'Mix ingredients',
        };

        final step = RecipeStep.fromMap(map);

        expect(step.order, 0);
        expect(step.instruction, 'Mix ingredients');
        expect(step.imageUrl, isNull);
        expect(step.timerSeconds, isNull);
      });

      test('handles explicit null values for optional fields', () {
        final map = {
          'order': 2,
          'instruction': 'Stir well',
          'imageUrl': null,
          'timerSeconds': null,
        };

        final step = RecipeStep.fromMap(map);

        expect(step.imageUrl, isNull);
        expect(step.timerSeconds, isNull);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final step = RecipeStep(
          order: 3,
          instruction: 'Bake for 30 minutes',
          imageUrl: 'https://example.com/img.jpg',
          timerSeconds: 1800,
        );

        final map = step.toMap();

        expect(map['order'], 3);
        expect(map['instruction'], 'Bake for 30 minutes');
        expect(map['imageUrl'], 'https://example.com/img.jpg');
        expect(map['timerSeconds'], 1800);
      });

      test('serializes null optional fields as null', () {
        final step = RecipeStep(
          order: 1,
          instruction: 'Chop onions',
        );

        final map = step.toMap();

        expect(map.containsKey('imageUrl'), isTrue);
        expect(map['imageUrl'], isNull);
        expect(map.containsKey('timerSeconds'), isTrue);
        expect(map['timerSeconds'], isNull);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all fields', () {
        final originalMap = {
          'order': 5,
          'instruction': 'Garnish with parsley',
          'imageUrl': 'https://example.com/garnish.jpg',
          'timerSeconds': 0,
        };

        final step = RecipeStep.fromMap(originalMap);
        final resultMap = step.toMap();

        expect(resultMap['order'], originalMap['order']);
        expect(resultMap['instruction'], originalMap['instruction']);
        expect(resultMap['imageUrl'], originalMap['imageUrl']);
        expect(resultMap['timerSeconds'], originalMap['timerSeconds']);
      });

      test('round-trip preserves null optional fields', () {
        final originalMap = {
          'order': 1,
          'instruction': 'Simple step',
        };

        final step = RecipeStep.fromMap(originalMap);
        final resultMap = step.toMap();

        expect(resultMap['order'], 1);
        expect(resultMap['instruction'], 'Simple step');
        expect(resultMap['imageUrl'], isNull);
        expect(resultMap['timerSeconds'], isNull);
      });
    });

    group('edge cases', () {
      test('handles order of zero', () {
        final step = RecipeStep(order: 0, instruction: 'First step');
        expect(step.order, 0);
      });

      test('handles empty instruction string', () {
        final step = RecipeStep(order: 1, instruction: '');
        expect(step.instruction, '');
      });

      test('handles large timerSeconds value', () {
        final step = RecipeStep(
          order: 1,
          instruction: 'Slow cook',
          timerSeconds: 86400,
        );
        expect(step.timerSeconds, 86400);
      });

      test('handles empty imageUrl string', () {
        final step = RecipeStep(
          order: 1,
          instruction: 'Step',
          imageUrl: '',
        );
        expect(step.imageUrl, '');
      });
    });
  });
}
