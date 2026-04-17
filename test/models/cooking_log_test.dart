import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/cooking_log.dart';

void main() {
  final testDate = DateTime(2025, 6, 15, 12, 30);

  Map<String, dynamic> makeTestMap({String docId = 'log1'}) => {
        'recipeId': 'recipe1',
        'recipeName': 'Pasta Carbonara',
        'recipeImageUrl': 'https://example.com/img.jpg',
        'userId': 'user1',
        'cookedAt': Timestamp.fromDate(testDate),
        'personalRating': 4,
        'notes': 'Added extra garlic',
        'photoUrl': 'https://example.com/result.jpg',
        'servings': 2,
      };

  group('CookingLog.fromMap', () {
    test('parses all fields correctly', () {
      final log = CookingLog.fromMap(makeTestMap(), 'log1');
      expect(log.id, 'log1');
      expect(log.recipeId, 'recipe1');
      expect(log.recipeName, 'Pasta Carbonara');
      expect(log.recipeImageUrl, 'https://example.com/img.jpg');
      expect(log.userId, 'user1');
      expect(log.cookedAt, testDate);
      expect(log.personalRating, 4);
      expect(log.notes, 'Added extra garlic');
      expect(log.photoUrl, 'https://example.com/result.jpg');
      expect(log.servings, 2);
    });

    test('handles null optional fields', () {
      final map = {
        'recipeId': 'recipe1',
        'recipeName': 'Pasta',
        'recipeImageUrl': null,
        'userId': 'user1',
        'cookedAt': Timestamp.fromDate(testDate),
        'personalRating': null,
        'notes': null,
        'photoUrl': null,
        'servings': null,
      };
      final log = CookingLog.fromMap(map, 'log2');
      expect(log.recipeImageUrl, isNull);
      expect(log.personalRating, isNull);
      expect(log.notes, isNull);
      expect(log.photoUrl, isNull);
      expect(log.servings, 1);
    });
  });

  group('CookingLog.toMap', () {
    test('serializes all fields', () {
      final log = CookingLog(
        id: 'log1',
        recipeId: 'recipe1',
        recipeName: 'Pasta Carbonara',
        recipeImageUrl: 'https://example.com/img.jpg',
        userId: 'user1',
        cookedAt: testDate,
        personalRating: 4,
        notes: 'Added extra garlic',
        photoUrl: 'https://example.com/result.jpg',
        servings: 2,
      );
      final map = log.toMap();
      expect(map['recipeId'], 'recipe1');
      expect(map['recipeName'], 'Pasta Carbonara');
      expect(map['userId'], 'user1');
      expect(map['personalRating'], 4);
      expect(map['notes'], 'Added extra garlic');
      expect(map['servings'], 2);
      expect(map['cookedAt'], isA<Timestamp>());
    });

    test('round-trip preserves data', () {
      final original = CookingLog.fromMap(makeTestMap(), 'log1');
      final map = original.toMap();
      final copy = CookingLog.fromMap(map, 'log1');
      expect(copy.recipeId, original.recipeId);
      expect(copy.recipeName, original.recipeName);
      expect(copy.personalRating, original.personalRating);
      expect(copy.servings, original.servings);
    });
  });

  group('CookingLog.copyWith', () {
    test('copies with updated fields', () {
      final log = CookingLog.fromMap(makeTestMap(), 'log1');
      final updated = log.copyWith(personalRating: 5, notes: 'Perfect!');
      expect(updated.personalRating, 5);
      expect(updated.notes, 'Perfect!');
      expect(updated.recipeId, log.recipeId);
      expect(updated.userId, log.userId);
    });

    test('preserves unchanged fields', () {
      final log = CookingLog.fromMap(makeTestMap(), 'log1');
      final copy = log.copyWith();
      expect(copy.recipeId, log.recipeId);
      expect(copy.servings, log.servings);
      expect(copy.cookedAt, log.cookedAt);
    });
  });
}
