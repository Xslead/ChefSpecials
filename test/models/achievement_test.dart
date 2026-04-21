import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/achievement.dart';

void main() {
  group('Achievement.allAchievements', () {
    test('contains 12 achievements', () {
      expect(Achievement.allAchievements.length, 12);
    });

    test('every achievement has a unique id', () {
      final ids = Achievement.allAchievements.map((a) => a.id).toSet();
      expect(ids.length, Achievement.allAchievements.length);
    });

    test('every achievement has criteria type and target', () {
      for (final a in Achievement.allAchievements) {
        expect(a.criteria['type'], isNotNull, reason: '${a.id} missing type');
        expect(a.criteria['target'], isNotNull,
            reason: '${a.id} missing target');
      }
    });

    test('every achievement has a known category', () {
      const validCategories = {'cooking', 'social', 'health', 'exploration'};
      for (final a in Achievement.allAchievements) {
        expect(validCategories.contains(a.category), isTrue,
            reason: '${a.id} has invalid category ${a.category}');
      }
    });

    test('every achievement has non-empty title and description', () {
      for (final a in Achievement.allAchievements) {
        expect(a.title.isNotEmpty, isTrue);
        expect(a.description.isNotEmpty, isTrue);
      }
    });

    test('byId returns matching achievement', () {
      final result = Achievement.byId('first_recipe');
      expect(result, isNotNull);
      expect(result!.title, 'First Recipe');
    });

    test('byId returns null for unknown id', () {
      expect(Achievement.byId('does_not_exist'), isNull);
    });

    test('icon returns IconData for known icon names', () {
      for (final a in Achievement.allAchievements) {
        expect(a.icon.codePoint, isNonZero);
      }
    });

    test('categories list matches expected values', () {
      expect(Achievement.categories,
          containsAll(['cooking', 'social', 'health', 'exploration']));
    });
  });
}
