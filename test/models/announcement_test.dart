import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/announcement.dart';

void main() {
  group('Announcement', () {
    test('fromMap creates correct Announcement', () {
      final map = {
        'title': 'Welcome to ChefSpecials!',
        'body': 'We are excited to announce new features.',
        'authorId': 'admin_001',
        'authorName': 'Admin User',
        'createdAt': '2025-03-10T09:00:00.000',
      };

      final announcement = Announcement.fromMap(map, 'ann_001');

      expect(announcement.id, 'ann_001');
      expect(announcement.title, 'Welcome to ChefSpecials!');
      expect(announcement.body, 'We are excited to announce new features.');
      expect(announcement.authorId, 'admin_001');
      expect(announcement.authorName, 'Admin User');
      expect(announcement.createdAt, DateTime(2025, 3, 10, 9, 0, 0));
    });

    test('toMap produces correct map', () {
      final announcement = Announcement(
        title: 'Welcome to ChefSpecials!',
        body: 'We are excited to announce new features.',
        authorId: 'admin_001',
        authorName: 'Admin User',
        createdAt: DateTime(2025, 3, 10, 9, 0, 0),
      );

      final map = announcement.toMap();

      expect(map['title'], 'Welcome to ChefSpecials!');
      expect(map['body'], 'We are excited to announce new features.');
      expect(map['authorId'], 'admin_001');
      expect(map['authorName'], 'Admin User');
      expect(map['createdAt'], '2025-03-10T09:00:00.000');
    });

    test('fromMap/toMap round-trip preserves data', () {
      final original = Announcement(
        title: 'New Feature',
        body: 'Check out our new meal planner!',
        authorId: 'admin_002',
        authorName: 'Another Admin',
        createdAt: DateTime(2025, 3, 15, 12, 30, 0),
      );

      final map = original.toMap();
      final restored = Announcement.fromMap(map, 'ann_002');

      expect(restored.title, original.title);
      expect(restored.body, original.body);
      expect(restored.authorId, original.authorId);
      expect(restored.authorName, original.authorName);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
