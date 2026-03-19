import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/activity.dart';

void main() {
  group('Activity', () {
    test('fromMap creates correct Activity', () {
      final map = {
        'userId': 'user1',
        'actorId': 'actor1',
        'actorName': 'John Doe',
        'actorAvatar': 'https://example.com/avatar.jpg',
        'type': 'comment',
        'targetId': 'recipe1',
        'targetName': 'Pasta',
        'targetImageUrl': 'https://example.com/pasta.jpg',
        'message': 'Great recipe!',
        'isRead': false,
        'createdAt': '2026-03-19T10:00:00.000',
      };

      final activity = Activity.fromMap(map, 'doc1');

      expect(activity.id, 'doc1');
      expect(activity.userId, 'user1');
      expect(activity.actorId, 'actor1');
      expect(activity.actorName, 'John Doe');
      expect(activity.actorAvatar, 'https://example.com/avatar.jpg');
      expect(activity.type, ActivityType.comment);
      expect(activity.targetId, 'recipe1');
      expect(activity.targetName, 'Pasta');
      expect(activity.targetImageUrl, 'https://example.com/pasta.jpg');
      expect(activity.message, 'Great recipe!');
      expect(activity.isRead, false);
      expect(activity.createdAt, DateTime(2026, 3, 19, 10, 0, 0));
    });

    test('toMap produces correct map', () {
      final activity = Activity(
        userId: 'user1',
        actorId: 'actor1',
        actorName: 'Jane',
        type: ActivityType.follow,
        isRead: true,
        createdAt: DateTime(2026, 3, 19, 12, 0, 0),
      );

      final map = activity.toMap();

      expect(map['userId'], 'user1');
      expect(map['actorId'], 'actor1');
      expect(map['actorName'], 'Jane');
      expect(map['type'], 'follow');
      expect(map['isRead'], true);
      expect(map['createdAt'], '2026-03-19T12:00:00.000');
      expect(map['targetId'], null);
      expect(map['message'], null);
    });

    test('fromMap/toMap round-trip preserves data', () {
      final original = Activity(
        userId: 'u1',
        actorId: 'a1',
        actorName: 'Chef',
        actorAvatar: 'url',
        type: ActivityType.rating,
        targetId: 'r1',
        targetName: 'Cake',
        targetImageUrl: 'img',
        message: '5',
        isRead: false,
        createdAt: DateTime(2026, 1, 15, 8, 30),
      );

      final map = original.toMap();
      final restored = Activity.fromMap(map, 'id1');

      expect(restored.userId, original.userId);
      expect(restored.actorId, original.actorId);
      expect(restored.actorName, original.actorName);
      expect(restored.type, original.type);
      expect(restored.targetId, original.targetId);
      expect(restored.targetName, original.targetName);
      expect(restored.message, original.message);
      expect(restored.isRead, original.isRead);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromMap defaults isRead to false', () {
      final map = {
        'userId': 'u1',
        'actorId': 'a1',
        'actorName': 'Test',
        'type': 'follow',
        'createdAt': '2026-03-19T10:00:00.000',
      };

      final activity = Activity.fromMap(map, 'id');
      expect(activity.isRead, false);
    });

    test('fromMap defaults unknown type to follow', () {
      final map = {
        'userId': 'u1',
        'actorId': 'a1',
        'actorName': 'Test',
        'type': 'unknown_type',
        'createdAt': '2026-03-19T10:00:00.000',
      };

      final activity = Activity.fromMap(map, 'id');
      expect(activity.type, ActivityType.follow);
    });

    test('ActivityType enum has all expected values', () {
      expect(ActivityType.values.length, 4);
      expect(ActivityType.values, contains(ActivityType.follow));
      expect(ActivityType.values, contains(ActivityType.comment));
      expect(ActivityType.values, contains(ActivityType.rating));
      expect(ActivityType.values, contains(ActivityType.newRecipe));
    });

    test('toMap stores all ActivityType values correctly', () {
      for (final type in ActivityType.values) {
        final activity = Activity(
          userId: 'u',
          actorId: 'a',
          actorName: 'n',
          type: type,
          createdAt: DateTime.now(),
        );
        expect(activity.toMap()['type'], type.name);
      }
    });
  });
}
