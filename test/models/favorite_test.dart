import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/favorite.dart';

void main() {
  group('Favorite', () {
    group('fromMap', () {
      test('creates Favorite with all fields from map and docId', () {
        final map = {
          'userId': 'user123',
          'recipeId': 'recipe456',
          'createdAt': '2024-06-15T10:30:00.000Z',
        };

        final favorite = Favorite.fromMap(map, 'doc789');

        expect(favorite.id, 'doc789');
        expect(favorite.userId, 'user123');
        expect(favorite.recipeId, 'recipe456');
        expect(favorite.createdAt, DateTime.parse('2024-06-15T10:30:00.000Z'));
      });

      test('sets id from docId parameter', () {
        final map = {
          'userId': 'u1',
          'recipeId': 'r1',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final favorite = Favorite.fromMap(map, 'myDocId');
        expect(favorite.id, 'myDocId');
      });

      test('parses ISO 8601 date correctly', () {
        final map = {
          'userId': 'u1',
          'recipeId': 'r1',
          'createdAt': '2024-12-31T23:59:59.999Z',
        };

        final favorite = Favorite.fromMap(map, 'doc1');

        expect(favorite.createdAt.year, 2024);
        expect(favorite.createdAt.month, 12);
        expect(favorite.createdAt.day, 31);
        expect(favorite.createdAt.hour, 23);
        expect(favorite.createdAt.minute, 59);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final now = DateTime(2024, 6, 15, 10, 30);
        final favorite = Favorite(
          id: 'doc123',
          userId: 'user1',
          recipeId: 'recipe1',
          createdAt: now,
        );

        final map = favorite.toMap();

        expect(map['userId'], 'user1');
        expect(map['recipeId'], 'recipe1');
        expect(map['createdAt'], now.toIso8601String());
      });

      test('does not include id in toMap output', () {
        final favorite = Favorite(
          id: 'doc123',
          userId: 'user1',
          recipeId: 'recipe1',
          createdAt: DateTime.now(),
        );

        final map = favorite.toMap();

        expect(map.containsKey('id'), isFalse);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves data', () {
        final originalMap = {
          'userId': 'userABC',
          'recipeId': 'recipeDEF',
          'createdAt': '2024-03-10T14:00:00.000',
        };

        final favorite = Favorite.fromMap(originalMap, 'docXYZ');
        final resultMap = favorite.toMap();

        expect(resultMap['userId'], originalMap['userId']);
        expect(resultMap['recipeId'], originalMap['recipeId']);
        expect(resultMap['createdAt'],
            DateTime.parse(originalMap['createdAt'] as String).toIso8601String());
      });
    });

    group('constructor', () {
      test('allows null id', () {
        final favorite = Favorite(
          userId: 'u1',
          recipeId: 'r1',
          createdAt: DateTime.now(),
        );

        expect(favorite.id, isNull);
      });

      test('stores all required fields', () {
        final dt = DateTime(2024, 1, 1);
        final favorite = Favorite(
          id: 'id1',
          userId: 'user1',
          recipeId: 'recipe1',
          createdAt: dt,
        );

        expect(favorite.id, 'id1');
        expect(favorite.userId, 'user1');
        expect(favorite.recipeId, 'recipe1');
        expect(favorite.createdAt, dt);
      });
    });

    group('edge cases', () {
      test('handles empty string docId', () {
        final map = {
          'userId': 'u1',
          'recipeId': 'r1',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final favorite = Favorite.fromMap(map, '');
        expect(favorite.id, '');
      });

      test('handles empty string userId and recipeId', () {
        final map = {
          'userId': '',
          'recipeId': '',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final favorite = Favorite.fromMap(map, 'doc1');
        expect(favorite.userId, '');
        expect(favorite.recipeId, '');
      });
    });
  });
}
