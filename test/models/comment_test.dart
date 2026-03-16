import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/comment.dart';

void main() {
  group('Comment', () {
    group('fromMap', () {
      test('creates Comment with all fields', () {
        final map = {
          'recipeId': 'recipe1',
          'userId': 'user1',
          'authorName': 'John Doe',
          'text': 'Great recipe!',
          'stars': 5,
          'createdAt': '2024-06-15T10:30:00.000Z',
        };

        final comment = Comment.fromMap(map, 'doc1');

        expect(comment.id, 'doc1');
        expect(comment.recipeId, 'recipe1');
        expect(comment.userId, 'user1');
        expect(comment.authorName, 'John Doe');
        expect(comment.text, 'Great recipe!');
        expect(comment.stars, 5);
        expect(comment.createdAt, DateTime.parse('2024-06-15T10:30:00.000Z'));
      });

      test('defaults stars to 0 when missing', () {
        final map = {
          'recipeId': 'recipe1',
          'userId': 'user1',
          'authorName': 'Jane',
          'text': 'Nice!',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final comment = Comment.fromMap(map, 'doc1');

        expect(comment.stars, 0);
      });

      test('defaults stars to 0 when null', () {
        final map = {
          'recipeId': 'recipe1',
          'userId': 'user1',
          'authorName': 'Jane',
          'text': 'Nice!',
          'stars': null,
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final comment = Comment.fromMap(map, 'doc1');

        expect(comment.stars, 0);
      });

      test('sets id from docId parameter', () {
        final map = {
          'recipeId': 'r1',
          'userId': 'u1',
          'authorName': 'Test',
          'text': 'Test',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final comment = Comment.fromMap(map, 'myDocId123');
        expect(comment.id, 'myDocId123');
      });

      test('parses ISO 8601 date correctly', () {
        final map = {
          'recipeId': 'r1',
          'userId': 'u1',
          'authorName': 'Test',
          'text': 'Test',
          'createdAt': '2024-12-25T14:30:00.000Z',
        };

        final comment = Comment.fromMap(map, 'doc1');

        expect(comment.createdAt.year, 2024);
        expect(comment.createdAt.month, 12);
        expect(comment.createdAt.day, 25);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final now = DateTime(2024, 6, 15, 10, 30);
        final comment = Comment(
          id: 'doc1',
          recipeId: 'recipe1',
          userId: 'user1',
          authorName: 'John Doe',
          text: 'Delicious!',
          stars: 4,
          createdAt: now,
        );

        final map = comment.toMap();

        expect(map['recipeId'], 'recipe1');
        expect(map['userId'], 'user1');
        expect(map['authorName'], 'John Doe');
        expect(map['text'], 'Delicious!');
        expect(map['stars'], 4);
        expect(map['createdAt'], now.toIso8601String());
      });

      test('does not include id in toMap output', () {
        final comment = Comment(
          id: 'doc1',
          recipeId: 'r1',
          userId: 'u1',
          authorName: 'Test',
          text: 'Test',
          createdAt: DateTime.now(),
        );

        final map = comment.toMap();

        expect(map.containsKey('id'), isFalse);
      });

      test('includes stars even when 0', () {
        final comment = Comment(
          recipeId: 'r1',
          userId: 'u1',
          authorName: 'Test',
          text: 'Comment without rating',
          stars: 0,
          createdAt: DateTime.now(),
        );

        final map = comment.toMap();

        expect(map['stars'], 0);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all fields', () {
        final originalMap = {
          'recipeId': 'recipeABC',
          'userId': 'userDEF',
          'authorName': 'Chef Mike',
          'text': 'Amazing flavor combination!',
          'stars': 5,
          'createdAt': '2024-06-15T10:30:00.000',
        };

        final comment = Comment.fromMap(originalMap, 'docXYZ');
        final resultMap = comment.toMap();

        expect(resultMap['recipeId'], originalMap['recipeId']);
        expect(resultMap['userId'], originalMap['userId']);
        expect(resultMap['authorName'], originalMap['authorName']);
        expect(resultMap['text'], originalMap['text']);
        expect(resultMap['stars'], originalMap['stars']);
        expect(resultMap['createdAt'],
            DateTime.parse(originalMap['createdAt'] as String).toIso8601String());
      });
    });

    group('constructor', () {
      test('allows null id', () {
        final comment = Comment(
          recipeId: 'r1',
          userId: 'u1',
          authorName: 'Test',
          text: 'Test',
          createdAt: DateTime.now(),
        );

        expect(comment.id, isNull);
      });

      test('defaults stars to 0', () {
        final comment = Comment(
          recipeId: 'r1',
          userId: 'u1',
          authorName: 'Test',
          text: 'Test',
          createdAt: DateTime.now(),
        );

        expect(comment.stars, 0);
      });
    });

    group('edge cases', () {
      test('handles empty text', () {
        final comment = Comment(
          recipeId: 'r1',
          userId: 'u1',
          authorName: 'Test',
          text: '',
          createdAt: DateTime.now(),
        );

        expect(comment.text, '');
      });

      test('handles star values from 0 to 5', () {
        for (int i = 0; i <= 5; i++) {
          final comment = Comment(
            recipeId: 'r1',
            userId: 'u1',
            authorName: 'Test',
            text: 'Test',
            stars: i,
            createdAt: DateTime.now(),
          );
          expect(comment.stars, i);
        }
      });

      test('handles empty authorName', () {
        final comment = Comment(
          recipeId: 'r1',
          userId: 'u1',
          authorName: '',
          text: 'Anon comment',
          createdAt: DateTime.now(),
        );

        expect(comment.authorName, '');
      });

      test('handles long text content', () {
        final longText = 'A' * 10000;
        final comment = Comment(
          recipeId: 'r1',
          userId: 'u1',
          authorName: 'Test',
          text: longText,
          createdAt: DateTime.now(),
        );

        expect(comment.text.length, 10000);
      });
    });
  });
}
