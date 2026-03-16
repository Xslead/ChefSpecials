import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/recipe_collection.dart';

void main() {
  group('RecipeCollection', () {
    group('fromMap', () {
      test('creates RecipeCollection with all fields', () {
        final map = {
          'userId': 'user1',
          'name': 'Quick Meals',
          'description': 'Meals under 30 minutes',
          'recipeIds': ['r1', 'r2', 'r3'],
          'coverImageUrl': 'https://example.com/cover.jpg',
          'createdAt': '2024-06-15T10:00:00.000Z',
          'updatedAt': '2024-06-16T14:30:00.000Z',
        };

        final collection = RecipeCollection.fromMap(map, 'doc1');

        expect(collection.id, 'doc1');
        expect(collection.userId, 'user1');
        expect(collection.name, 'Quick Meals');
        expect(collection.description, 'Meals under 30 minutes');
        expect(collection.recipeIds, ['r1', 'r2', 'r3']);
        expect(collection.coverImageUrl, 'https://example.com/cover.jpg');
        expect(collection.createdAt,
            DateTime.parse('2024-06-15T10:00:00.000Z'));
        expect(collection.updatedAt,
            DateTime.parse('2024-06-16T14:30:00.000Z'));
      });

      test('creates RecipeCollection with minimal fields', () {
        final map = {
          'userId': 'user1',
          'name': 'Favorites',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final collection = RecipeCollection.fromMap(map, 'doc2');

        expect(collection.id, 'doc2');
        expect(collection.name, 'Favorites');
        expect(collection.description, isNull);
        expect(collection.recipeIds, isEmpty);
        expect(collection.coverImageUrl, isNull);
      });

      test('defaults recipeIds to empty list when null', () {
        final map = {
          'userId': 'user1',
          'name': 'Empty',
          'recipeIds': null,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final collection = RecipeCollection.fromMap(map, 'doc1');
        expect(collection.recipeIds, isEmpty);
      });

      test('defaults recipeIds to empty list when missing', () {
        final map = {
          'userId': 'user1',
          'name': 'Empty',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final collection = RecipeCollection.fromMap(map, 'doc1');
        expect(collection.recipeIds, isEmpty);
      });

      test('sets id from docId parameter', () {
        final map = {
          'userId': 'user1',
          'name': 'Test',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final collection = RecipeCollection.fromMap(map, 'myDoc123');
        expect(collection.id, 'myDoc123');
      });

      test('parses dates correctly', () {
        final map = {
          'userId': 'user1',
          'name': 'Test',
          'createdAt': '2024-12-31T23:59:59.999Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
        };

        final collection = RecipeCollection.fromMap(map, 'doc1');

        expect(collection.createdAt.year, 2024);
        expect(collection.createdAt.month, 12);
        expect(collection.updatedAt.year, 2025);
        expect(collection.updatedAt.month, 1);
      });

      test('handles null description', () {
        final map = {
          'userId': 'user1',
          'name': 'Test',
          'description': null,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final collection = RecipeCollection.fromMap(map, 'doc1');
        expect(collection.description, isNull);
      });

      test('handles null coverImageUrl', () {
        final map = {
          'userId': 'user1',
          'name': 'Test',
          'coverImageUrl': null,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final collection = RecipeCollection.fromMap(map, 'doc1');
        expect(collection.coverImageUrl, isNull);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final createdAt = DateTime(2024, 6, 15, 10, 0);
        final updatedAt = DateTime(2024, 6, 16, 14, 30);

        final collection = RecipeCollection(
          id: 'doc1',
          userId: 'user1',
          name: 'Weekend Recipes',
          description: 'For lazy weekends',
          recipeIds: ['r1', 'r2'],
          coverImageUrl: 'https://example.com/img.jpg',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final map = collection.toMap();

        expect(map['userId'], 'user1');
        expect(map['name'], 'Weekend Recipes');
        expect(map['description'], 'For lazy weekends');
        expect(map['recipeIds'], ['r1', 'r2']);
        expect(map['coverImageUrl'], 'https://example.com/img.jpg');
        expect(map['createdAt'], createdAt.toIso8601String());
        expect(map['updatedAt'], updatedAt.toIso8601String());
      });

      test('does not include id in toMap output', () {
        final collection = RecipeCollection(
          id: 'doc1',
          userId: 'user1',
          name: 'Test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = collection.toMap();
        expect(map.containsKey('id'), isFalse);
      });

      test('serializes empty recipeIds list', () {
        final collection = RecipeCollection(
          userId: 'user1',
          name: 'Empty',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = collection.toMap();
        expect(map['recipeIds'], isEmpty);
      });

      test('serializes null optional fields', () {
        final collection = RecipeCollection(
          userId: 'user1',
          name: 'Minimal',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = collection.toMap();
        expect(map['description'], isNull);
        expect(map['coverImageUrl'], isNull);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all populated fields', () {
        final originalMap = {
          'userId': 'user1',
          'name': 'Keto Recipes',
          'description': 'Low carb collection',
          'recipeIds': ['r1', 'r2', 'r3'],
          'coverImageUrl': 'https://example.com/keto.jpg',
          'createdAt': '2024-06-15T10:00:00.000',
          'updatedAt': '2024-06-15T10:00:00.000',
        };

        final collection = RecipeCollection.fromMap(originalMap, 'doc1');
        final resultMap = collection.toMap();

        expect(resultMap['userId'], originalMap['userId']);
        expect(resultMap['name'], originalMap['name']);
        expect(resultMap['description'], originalMap['description']);
        expect(resultMap['recipeIds'], originalMap['recipeIds']);
        expect(resultMap['coverImageUrl'], originalMap['coverImageUrl']);
      });

      test('round-trip preserves empty recipeIds', () {
        final originalMap = {
          'userId': 'user1',
          'name': 'Empty',
          'recipeIds': <String>[],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final collection = RecipeCollection.fromMap(originalMap, 'doc1');
        final resultMap = collection.toMap();

        expect(resultMap['recipeIds'], isEmpty);
      });
    });

    group('constructor', () {
      test('allows null id', () {
        final collection = RecipeCollection(
          userId: 'user1',
          name: 'Test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(collection.id, isNull);
      });

      test('defaults recipeIds to empty list', () {
        final collection = RecipeCollection(
          userId: 'user1',
          name: 'Test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(collection.recipeIds, isEmpty);
      });
    });

    group('edge cases', () {
      test('handles empty name', () {
        final collection = RecipeCollection(
          userId: 'user1',
          name: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(collection.name, '');
      });

      test('handles many recipeIds', () {
        final ids = List.generate(100, (i) => 'recipe_$i');

        final collection = RecipeCollection(
          userId: 'user1',
          name: 'Large Collection',
          recipeIds: ids,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(collection.recipeIds.length, 100);
      });

      test('handles empty string docId', () {
        final map = {
          'userId': 'user1',
          'name': 'Test',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final collection = RecipeCollection.fromMap(map, '');
        expect(collection.id, '');
      });

      test('createdAt and updatedAt can differ', () {
        final created = DateTime(2024, 1, 1);
        final updated = DateTime(2024, 6, 15);

        final collection = RecipeCollection(
          userId: 'user1',
          name: 'Test',
          createdAt: created,
          updatedAt: updated,
        );

        expect(collection.createdAt, created);
        expect(collection.updatedAt, updated);
        expect(collection.updatedAt.isAfter(collection.createdAt), isTrue);
      });
    });
  });
}
