import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/admin_log.dart';

void main() {
  group('AdminLog', () {
    test('fromMap creates correct AdminLog', () {
      final map = {
        'adminId': 'admin_001',
        'adminName': 'Admin User',
        'action': 'ban_user',
        'targetId': 'user_002',
        'targetName': 'John Doe',
        'details': 'Violated community guidelines',
        'createdAt': '2025-03-01T10:00:00.000',
      };

      final log = AdminLog.fromMap(map, 'log_001');

      expect(log.id, 'log_001');
      expect(log.adminId, 'admin_001');
      expect(log.adminName, 'Admin User');
      expect(log.action, 'ban_user');
      expect(log.targetId, 'user_002');
      expect(log.targetName, 'John Doe');
      expect(log.details, 'Violated community guidelines');
      expect(log.createdAt, DateTime(2025, 3, 1, 10, 0, 0));
    });

    test('toMap produces correct map', () {
      final log = AdminLog(
        adminId: 'admin_001',
        adminName: 'Admin User',
        action: 'ban_user',
        targetId: 'user_002',
        targetName: 'John Doe',
        details: 'Violated community guidelines',
        createdAt: DateTime(2025, 3, 1, 10, 0, 0),
      );

      final map = log.toMap();

      expect(map['adminId'], 'admin_001');
      expect(map['adminName'], 'Admin User');
      expect(map['action'], 'ban_user');
      expect(map['targetId'], 'user_002');
      expect(map['targetName'], 'John Doe');
      expect(map['details'], 'Violated community guidelines');
      expect(map['createdAt'], '2025-03-01T10:00:00.000');
    });

    test('fromMap/toMap round-trip preserves data', () {
      final original = AdminLog(
        adminId: 'admin_001',
        adminName: 'Admin User',
        action: 'delete_recipe',
        targetId: 'recipe_001',
        targetName: 'Bad Recipe',
        details: 'Inappropriate content',
        createdAt: DateTime(2025, 3, 1, 10, 0, 0),
      );

      final map = original.toMap();
      final restored = AdminLog.fromMap(map, 'log_001');

      expect(restored.adminId, original.adminId);
      expect(restored.adminName, original.adminName);
      expect(restored.action, original.action);
      expect(restored.targetId, original.targetId);
      expect(restored.targetName, original.targetName);
      expect(restored.details, original.details);
      expect(restored.createdAt, original.createdAt);
    });

    test('nullable fields are null when missing', () {
      final map = {
        'adminId': 'admin_001',
        'adminName': 'Admin User',
        'action': 'system_update',
        'createdAt': '2025-03-01T10:00:00.000',
      };

      final log = AdminLog.fromMap(map, 'log_001');

      expect(log.targetId, isNull);
      expect(log.targetName, isNull);
      expect(log.details, isNull);
    });
  });
}
