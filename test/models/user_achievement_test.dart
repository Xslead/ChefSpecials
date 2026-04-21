import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/user_achievement.dart';

void main() {
  final testDate = DateTime(2025, 6, 15, 12, 30);

  group('UserAchievement.fromMap', () {
    test('parses fields correctly with Timestamp', () {
      final ua = UserAchievement.fromMap({
        'achievementId': 'first_recipe',
        'userId': 'user1',
        'unlockedAt': Timestamp.fromDate(testDate),
      }, 'doc1');
      expect(ua.id, 'doc1');
      expect(ua.achievementId, 'first_recipe');
      expect(ua.userId, 'user1');
      expect(ua.unlockedAt, testDate);
    });

    test('parses ISO string unlockedAt as fallback', () {
      final ua = UserAchievement.fromMap({
        'achievementId': 'streak_7',
        'userId': 'user2',
        'unlockedAt': testDate.toIso8601String(),
      }, 'doc2');
      expect(ua.unlockedAt, testDate);
    });
  });

  group('UserAchievement.toMap', () {
    test('serializes fields correctly', () {
      final ua = UserAchievement(
        id: 'doc1',
        achievementId: 'first_recipe',
        userId: 'user1',
        unlockedAt: testDate,
      );
      final map = ua.toMap();
      expect(map['achievementId'], 'first_recipe');
      expect(map['userId'], 'user1');
      expect(map['unlockedAt'], isA<Timestamp>());
      expect((map['unlockedAt'] as Timestamp).toDate(), testDate);
    });
  });

  test('round-trip preserves data', () {
    final original = UserAchievement(
      achievementId: 'home_chef',
      userId: 'u1',
      unlockedAt: testDate,
    );
    final map = original.toMap();
    final copy = UserAchievement.fromMap(map, 'doc1');
    expect(copy.achievementId, original.achievementId);
    expect(copy.userId, original.userId);
    expect(copy.unlockedAt, original.unlockedAt);
  });

  test('copyWith updates fields', () {
    final ua = UserAchievement(
      achievementId: 'a',
      userId: 'u',
      unlockedAt: testDate,
    );
    final updated = ua.copyWith(id: 'newId');
    expect(updated.id, 'newId');
    expect(updated.achievementId, 'a');
  });
}
