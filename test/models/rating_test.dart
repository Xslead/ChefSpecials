import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/rating.dart';

void main() {
  group('Rating', () {
    group('fromMap', () {
      test('creates Rating with all fields', () {
        final map = {
          'recipeId': 'recipe1',
          'userId': 'user1',
          'stars': 5,
          'createdAt': '2024-06-15T10:30:00.000Z',
        };

        final rating = Rating.fromMap(map, 'doc1');

        expect(rating.id, 'doc1');
        expect(rating.recipeId, 'recipe1');
        expect(rating.userId, 'user1');
        expect(rating.stars, 5);
        expect(rating.createdAt, DateTime.parse('2024-06-15T10:30:00.000Z'));
      });

      test('sets id from docId parameter', () {
        final map = {
          'recipeId': 'r1',
          'userId': 'u1',
          'stars': 3,
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final rating = Rating.fromMap(map, 'ratingDoc42');
        expect(rating.id, 'ratingDoc42');
      });

      test('parses createdAt correctly', () {
        final map = {
          'recipeId': 'r1',
          'userId': 'u1',
          'stars': 4,
          'createdAt': '2024-07-04T12:00:00.000Z',
        };

        final rating = Rating.fromMap(map, 'doc1');

        expect(rating.createdAt.year, 2024);
        expect(rating.createdAt.month, 7);
        expect(rating.createdAt.day, 4);
        expect(rating.createdAt.hour, 12);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final dt = DateTime(2024, 6, 15, 10, 30);
        final rating = Rating(
          id: 'doc1',
          recipeId: 'recipe1',
          userId: 'user1',
          stars: 4,
          createdAt: dt,
        );

        final map = rating.toMap();

        expect(map['recipeId'], 'recipe1');
        expect(map['userId'], 'user1');
        expect(map['stars'], 4);
        expect(map['createdAt'], dt.toIso8601String());
      });

      test('does not include id in toMap output', () {
        final rating = Rating(
          id: 'doc1',
          recipeId: 'r1',
          userId: 'u1',
          stars: 5,
          createdAt: DateTime.now(),
        );

        final map = rating.toMap();

        expect(map.containsKey('id'), isFalse);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all fields', () {
        final originalMap = {
          'recipeId': 'recipeABC',
          'userId': 'userDEF',
          'stars': 3,
          'createdAt': '2024-06-15T10:30:00.000',
        };

        final rating = Rating.fromMap(originalMap, 'docXYZ');
        final resultMap = rating.toMap();

        expect(resultMap['recipeId'], originalMap['recipeId']);
        expect(resultMap['userId'], originalMap['userId']);
        expect(resultMap['stars'], originalMap['stars']);
        expect(resultMap['createdAt'],
            DateTime.parse(originalMap['createdAt'] as String).toIso8601String());
      });
    });

    group('constructor', () {
      test('allows null id', () {
        final rating = Rating(
          recipeId: 'r1',
          userId: 'u1',
          stars: 3,
          createdAt: DateTime.now(),
        );

        expect(rating.id, isNull);
      });

      test('stores all required fields', () {
        final dt = DateTime(2024, 1, 1);
        final rating = Rating(
          id: 'id1',
          recipeId: 'recipe1',
          userId: 'user1',
          stars: 5,
          createdAt: dt,
        );

        expect(rating.id, 'id1');
        expect(rating.recipeId, 'recipe1');
        expect(rating.userId, 'user1');
        expect(rating.stars, 5);
        expect(rating.createdAt, dt);
      });
    });

    group('edge cases', () {
      test('handles minimum star value of 1', () {
        final rating = Rating(
          recipeId: 'r1',
          userId: 'u1',
          stars: 1,
          createdAt: DateTime.now(),
        );

        expect(rating.stars, 1);
      });

      test('handles maximum star value of 5', () {
        final rating = Rating(
          recipeId: 'r1',
          userId: 'u1',
          stars: 5,
          createdAt: DateTime.now(),
        );

        expect(rating.stars, 5);
      });

      test('handles all star values from 1 to 5', () {
        for (int i = 1; i <= 5; i++) {
          final rating = Rating(
            recipeId: 'r1',
            userId: 'u1',
            stars: i,
            createdAt: DateTime.now(),
          );
          expect(rating.stars, i);
        }
      });

      test('handles empty string docId', () {
        final map = {
          'recipeId': 'r1',
          'userId': 'u1',
          'stars': 3,
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final rating = Rating.fromMap(map, '');
        expect(rating.id, '');
      });

      test('handles empty recipeId and userId', () {
        final map = {
          'recipeId': '',
          'userId': '',
          'stars': 3,
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final rating = Rating.fromMap(map, 'doc1');
        expect(rating.recipeId, '');
        expect(rating.userId, '');
      });
    });
  });
}
