import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/ban_appeal.dart';

void main() {
  group('BanAppeal', () {
    test('fromMap creates correct BanAppeal', () {
      final map = {
        'userId': 'user_002',
        'userName': 'John Doe',
        'userEmail': 'john@example.com',
        'appealText': 'I believe my ban was a mistake.',
        'status': 'pending',
        'reviewedBy': 'admin_001',
        'reviewNote': 'Under review',
        'createdAt': '2025-03-05T14:00:00.000',
        'reviewedAt': '2025-03-06T10:00:00.000',
      };

      final appeal = BanAppeal.fromMap(map, 'appeal_001');

      expect(appeal.id, 'appeal_001');
      expect(appeal.userId, 'user_002');
      expect(appeal.userName, 'John Doe');
      expect(appeal.userEmail, 'john@example.com');
      expect(appeal.appealText, 'I believe my ban was a mistake.');
      expect(appeal.status, 'pending');
      expect(appeal.reviewedBy, 'admin_001');
      expect(appeal.reviewNote, 'Under review');
      expect(appeal.createdAt, DateTime(2025, 3, 5, 14, 0, 0));
      expect(appeal.reviewedAt, DateTime(2025, 3, 6, 10, 0, 0));
    });

    test('toMap produces correct map', () {
      final appeal = BanAppeal(
        userId: 'user_002',
        userName: 'John Doe',
        userEmail: 'john@example.com',
        appealText: 'I believe my ban was a mistake.',
        status: 'pending',
        createdAt: DateTime(2025, 3, 5, 14, 0, 0),
      );

      final map = appeal.toMap();

      expect(map['userId'], 'user_002');
      expect(map['userName'], 'John Doe');
      expect(map['userEmail'], 'john@example.com');
      expect(map['appealText'], 'I believe my ban was a mistake.');
      expect(map['status'], 'pending');
      expect(map['reviewedBy'], isNull);
      expect(map['reviewNote'], isNull);
      expect(map['createdAt'], '2025-03-05T14:00:00.000');
      expect(map['reviewedAt'], isNull);
    });

    test('fromMap/toMap round-trip preserves data', () {
      final original = BanAppeal(
        userId: 'user_002',
        userName: 'John Doe',
        userEmail: 'john@example.com',
        appealText: 'Please reconsider.',
        status: 'rejected',
        reviewedBy: 'admin_001',
        reviewNote: 'Violation confirmed',
        createdAt: DateTime(2025, 3, 5, 14, 0, 0),
        reviewedAt: DateTime(2025, 3, 6, 10, 0, 0),
      );

      final map = original.toMap();
      final restored = BanAppeal.fromMap(map, 'appeal_001');

      expect(restored.userId, original.userId);
      expect(restored.userName, original.userName);
      expect(restored.userEmail, original.userEmail);
      expect(restored.appealText, original.appealText);
      expect(restored.status, original.status);
      expect(restored.reviewedBy, original.reviewedBy);
      expect(restored.reviewNote, original.reviewNote);
      expect(restored.createdAt, original.createdAt);
      expect(restored.reviewedAt, original.reviewedAt);
    });

    test('defaults status to pending when missing', () {
      final map = {
        'userId': 'user_002',
        'userName': 'John Doe',
        'userEmail': 'john@example.com',
        'appealText': 'Please unban me.',
        'createdAt': '2025-03-05T14:00:00.000',
      };

      final appeal = BanAppeal.fromMap(map, 'appeal_001');

      expect(appeal.status, 'pending');
    });

    test('copyWith updates specific fields', () {
      final appeal = BanAppeal(
        id: 'appeal_001',
        userId: 'user_002',
        userName: 'John Doe',
        userEmail: 'john@example.com',
        appealText: 'I believe my ban was a mistake.',
        status: 'pending',
        createdAt: DateTime(2025, 3, 5, 14, 0, 0),
      );

      final reviewedAt = DateTime(2025, 3, 6, 10, 0, 0);
      final updated = appeal.copyWith(
        status: 'approved',
        reviewedBy: 'admin_001',
        reviewNote: 'Ban lifted',
        reviewedAt: reviewedAt,
      );

      expect(updated.status, 'approved');
      expect(updated.reviewedBy, 'admin_001');
      expect(updated.reviewNote, 'Ban lifted');
      expect(updated.reviewedAt, reviewedAt);
    });

    test('copyWith preserves unchanged fields', () {
      final appeal = BanAppeal(
        id: 'appeal_001',
        userId: 'user_002',
        userName: 'John Doe',
        userEmail: 'john@example.com',
        appealText: 'I believe my ban was a mistake.',
        status: 'pending',
        createdAt: DateTime(2025, 3, 5, 14, 0, 0),
      );

      final updated = appeal.copyWith(status: 'rejected');

      expect(updated.id, appeal.id);
      expect(updated.userId, appeal.userId);
      expect(updated.userName, appeal.userName);
      expect(updated.userEmail, appeal.userEmail);
      expect(updated.appealText, appeal.appealText);
      expect(updated.createdAt, appeal.createdAt);
    });
  });
}
