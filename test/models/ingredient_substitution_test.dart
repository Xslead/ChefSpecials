import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/ingredient_substitution.dart';

void main() {
  group('IngredientSubstitution', () {
    group('fromMap', () {
      test('creates instance from full map', () {
        final map = {
          'originalIngredient': 'butter',
          'substituteName': 'Coconut oil',
          'ratio': '1:1',
          'notes': 'Best for baking',
          'dietaryTags': ['Vegan', 'Dairy Free'],
          'submittedBy': 'u1',
          'isVerified': true,
        };

        final sub = IngredientSubstitution.fromMap(map, 'doc1');

        expect(sub.id, 'doc1');
        expect(sub.originalIngredient, 'butter');
        expect(sub.substituteName, 'Coconut oil');
        expect(sub.ratio, '1:1');
        expect(sub.notes, 'Best for baking');
        expect(sub.dietaryTags, ['Vegan', 'Dairy Free']);
        expect(sub.submittedBy, 'u1');
        expect(sub.isVerified, true);
      });

      test('defaults isVerified to false when missing', () {
        final sub = IngredientSubstitution.fromMap({
          'originalIngredient': 'egg',
          'substituteName': 'Flax egg',
          'ratio': '1:1',
          'dietaryTags': <String>[],
        }, 'd');
        expect(sub.isVerified, false);
      });

      test('defaults ratio to "1:1" when missing', () {
        final sub = IngredientSubstitution.fromMap({
          'originalIngredient': 'milk',
          'substituteName': 'Oat milk',
          'dietaryTags': <String>[],
        }, 'd');
        expect(sub.ratio, '1:1');
      });

      test('handles null notes and submittedBy', () {
        final sub = IngredientSubstitution.fromMap({
          'originalIngredient': 'milk',
          'substituteName': 'Oat milk',
          'ratio': '1:1',
          'notes': null,
          'submittedBy': null,
          'dietaryTags': <String>[],
        }, 'd');
        expect(sub.notes, isNull);
        expect(sub.submittedBy, isNull);
      });

      test('dietaryTags defaults to empty list when missing', () {
        final sub = IngredientSubstitution.fromMap({
          'originalIngredient': 'sugar',
          'substituteName': 'Honey',
          'ratio': '3/4 cup per 1 cup',
        }, 'd');
        expect(sub.dietaryTags, isEmpty);
      });
    });

    group('toMap', () {
      test('serializes all fields', () {
        final sub = IngredientSubstitution(
          originalIngredient: 'Butter',
          substituteName: 'Coconut oil',
          ratio: '1:1',
          notes: 'Notes',
          dietaryTags: ['Vegan'],
          submittedBy: 'u1',
          isVerified: true,
        );
        final map = sub.toMap();
        expect(map['substituteName'], 'Coconut oil');
        expect(map['ratio'], '1:1');
        expect(map['notes'], 'Notes');
        expect(map['dietaryTags'], ['Vegan']);
        expect(map['submittedBy'], 'u1');
        expect(map['isVerified'], true);
      });

      test('normalizes originalIngredient to lowercase', () {
        final sub = IngredientSubstitution(
          originalIngredient: '  BUTTER  ',
          substituteName: 'Olive oil',
          ratio: '3/4 cup per 1 cup',
        );
        final map = sub.toMap();
        expect(map['originalIngredient'], 'butter');
      });

      test('excludes id key', () {
        final sub = IngredientSubstitution(
          id: 'doc1',
          originalIngredient: 'egg',
          substituteName: 'Chia egg',
          ratio: '1:1',
        );
        expect(sub.toMap().containsKey('id'), isFalse);
      });
    });

    group('round-trip', () {
      test('fromMap ∘ toMap preserves fields', () {
        final original = IngredientSubstitution(
          originalIngredient: 'flour',
          substituteName: 'Almond flour',
          ratio: '1:1',
          notes: 'Reduce liquid',
          dietaryTags: ['Gluten Free', 'Keto'],
          isVerified: true,
        );
        final map = original.toMap();
        final restored = IngredientSubstitution.fromMap(map, 'newId');

        expect(restored.originalIngredient, 'flour');
        expect(restored.substituteName, 'Almond flour');
        expect(restored.ratio, '1:1');
        expect(restored.notes, 'Reduce liquid');
        expect(restored.dietaryTags, ['Gluten Free', 'Keto']);
        expect(restored.isVerified, true);
      });
    });

    group('normalize', () {
      test('lowercases and trims', () {
        expect(IngredientSubstitution.normalize('  Butter '), 'butter');
        expect(IngredientSubstitution.normalize('SOY SAUCE'), 'soy sauce');
      });
    });

    group('copyWith', () {
      test('returns new instance with overridden fields', () {
        final a = IngredientSubstitution(
          originalIngredient: 'butter',
          substituteName: 'Coconut oil',
          ratio: '1:1',
        );
        final b = a.copyWith(isVerified: true, submittedBy: 'u9');
        expect(b.substituteName, 'Coconut oil');
        expect(b.isVerified, true);
        expect(b.submittedBy, 'u9');
        expect(a.isVerified, false);
      });
    });
  });
}
