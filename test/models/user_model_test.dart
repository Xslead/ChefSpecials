import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/user_model.dart';

void main() {
  Map<String, dynamic> fullMap() {
    return {
      'uid': 'uid123',
      'email': 'john@example.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'phoneNumber': '+1234567890',
      'photoUrl': 'https://example.com/photo.jpg',
      'bio': 'I love cooking!',
      'role': 'admin',
      'createdAt': '2024-01-15T10:00:00.000Z',
      'birthDate': '1990-05-20T00:00:00.000Z',
      'gender': 'male',
      'heightCm': 180.0,
      'weightKg': 75.5,
      'activityLevel': 'moderate',
      'cookingSkillLevel': 'advanced',
      'followingCount': 50,
      'followersCount': 100,
      'username': 'johndoe',
      'isBanned': true,
      'banReason': 'Spam',
      'bannedAt': '2024-06-01T12:00:00.000Z',
      'bannedBy': 'admin_001',
    };
  }

  group('UserModel', () {
    group('fromMap', () {
      test('creates UserModel with all fields', () {
        final map = fullMap();
        final user = UserModel.fromMap(map);

        expect(user.uid, 'uid123');
        expect(user.email, 'john@example.com');
        expect(user.firstName, 'John');
        expect(user.lastName, 'Doe');
        expect(user.phoneNumber, '+1234567890');
        expect(user.photoUrl, 'https://example.com/photo.jpg');
        expect(user.bio, 'I love cooking!');
        expect(user.role, 'admin');
        expect(user.createdAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
        expect(user.birthDate, DateTime.parse('1990-05-20T00:00:00.000Z'));
        expect(user.gender, 'male');
        expect(user.heightCm, 180.0);
        expect(user.weightKg, 75.5);
        expect(user.activityLevel, 'moderate');
        expect(user.cookingSkillLevel, 'advanced');
        expect(user.followingCount, 50);
        expect(user.followersCount, 100);
        expect(user.username, 'johndoe');
        expect(user.isBanned, true);
        expect(user.banReason, 'Spam');
        expect(user.bannedAt, DateTime.parse('2024-06-01T12:00:00.000Z'));
        expect(user.bannedBy, 'admin_001');
      });

      test('defaults role to user when missing', () {
        final map = {
          'uid': 'u1',
          'email': 'test@test.com',
          'firstName': 'Test',
          'lastName': 'User',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = UserModel.fromMap(map);
        expect(user.role, 'user');
      });

      test('defaults isBanned to false when missing', () {
        final map = {
          'uid': 'u1',
          'email': 'test@test.com',
          'firstName': 'Test',
          'lastName': 'User',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };
        final user = UserModel.fromMap(map);
        expect(user.isBanned, false);
        expect(user.banReason, isNull);
        expect(user.bannedAt, isNull);
        expect(user.bannedBy, isNull);
      });

      test('defaults followingCount and followersCount to 0', () {
        final map = {
          'uid': 'u1',
          'email': 'test@test.com',
          'firstName': 'Test',
          'lastName': 'User',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = UserModel.fromMap(map);

        expect(user.followingCount, 0);
        expect(user.followersCount, 0);
      });

      test('parses firstName from fullName when firstName is missing', () {
        final map = {
          'uid': 'u1',
          'email': 'test@test.com',
          'fullName': 'Jane Smith',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = UserModel.fromMap(map);

        expect(user.firstName, 'Jane');
        expect(user.lastName, 'Smith');
      });

      test('parses multi-word lastName from fullName', () {
        final map = {
          'uid': 'u1',
          'email': 'test@test.com',
          'fullName': 'Maria Del Carmen',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = UserModel.fromMap(map);

        expect(user.firstName, 'Maria');
        expect(user.lastName, 'Del Carmen');
      });

      test('handles single word fullName', () {
        final map = {
          'uid': 'u1',
          'email': 'test@test.com',
          'fullName': 'Madonna',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = UserModel.fromMap(map);

        expect(user.firstName, 'Madonna');
        expect(user.lastName, '');
      });

      test('handles missing fullName and firstName/lastName', () {
        final map = {
          'uid': 'u1',
          'email': 'test@test.com',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = UserModel.fromMap(map);

        expect(user.firstName, '');
        expect(user.lastName, '');
      });

      test('prefers firstName/lastName over fullName', () {
        final map = {
          'uid': 'u1',
          'email': 'test@test.com',
          'firstName': 'Explicit',
          'lastName': 'Name',
          'fullName': 'Full Name Ignored',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = UserModel.fromMap(map);

        expect(user.firstName, 'Explicit');
        expect(user.lastName, 'Name');
      });

      test('nullable fields are null when missing', () {
        final map = {
          'uid': 'u1',
          'email': 'test@test.com',
          'firstName': 'Test',
          'lastName': 'User',
          'createdAt': '2024-01-01T00:00:00.000Z',
        };

        final user = UserModel.fromMap(map);

        expect(user.phoneNumber, isNull);
        expect(user.photoUrl, isNull);
        expect(user.bio, isNull);
        expect(user.birthDate, isNull);
        expect(user.gender, isNull);
        expect(user.heightCm, isNull);
        expect(user.weightKg, isNull);
        expect(user.activityLevel, isNull);
        expect(user.cookingSkillLevel, isNull);
        expect(user.username, isNull);
        expect(user.isBanned, false);
        expect(user.banReason, isNull);
        expect(user.bannedAt, isNull);
        expect(user.bannedBy, isNull);
      });

      test('converts int heightCm and weightKg to double', () {
        final map = {
          'uid': 'u1',
          'email': 'test@test.com',
          'firstName': 'Test',
          'lastName': 'User',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'heightCm': 175,
          'weightKg': 70,
        };

        final user = UserModel.fromMap(map);

        expect(user.heightCm, isA<double>());
        expect(user.weightKg, isA<double>());
        expect(user.heightCm, 175.0);
        expect(user.weightKg, 70.0);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final dt = DateTime(2024, 1, 15, 10, 0);
        final bd = DateTime(1990, 5, 20);
        final user = UserModel(
          uid: 'uid1',
          email: 'test@test.com',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
          photoUrl: 'https://example.com/photo.jpg',
          bio: 'Chef',
          role: 'user',
          createdAt: dt,
          birthDate: bd,
          gender: 'male',
          heightCm: 180.0,
          weightKg: 75.0,
          activityLevel: 'high',
          cookingSkillLevel: 'expert',
          followingCount: 10,
          followersCount: 20,
          username: 'johnd',
          isBanned: true,
          banReason: 'Spam',
          bannedAt: dt,
          bannedBy: 'admin_001',
        );

        final map = user.toMap();

        expect(map['uid'], 'uid1');
        expect(map['email'], 'test@test.com');
        expect(map['firstName'], 'John');
        expect(map['lastName'], 'Doe');
        expect(map['fullName'], 'John Doe');
        expect(map['phoneNumber'], '+1234567890');
        expect(map['photoUrl'], 'https://example.com/photo.jpg');
        expect(map['bio'], 'Chef');
        expect(map['role'], 'user');
        expect(map['createdAt'], dt.toIso8601String());
        expect(map['birthDate'], bd.toIso8601String());
        expect(map['gender'], 'male');
        expect(map['heightCm'], 180.0);
        expect(map['weightKg'], 75.0);
        expect(map['activityLevel'], 'high');
        expect(map['cookingSkillLevel'], 'expert');
        expect(map['followingCount'], 10);
        expect(map['followersCount'], 20);
        expect(map['username'], 'johnd');
        expect(map['isBanned'], true);
        expect(map['banReason'], 'Spam');
        expect(map['bannedAt'], dt.toIso8601String());
        expect(map['bannedBy'], 'admin_001');
      });

      test('includes fullName computed from firstName and lastName', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: 'Jane',
          lastName: 'Smith',
          createdAt: DateTime.now(),
        );

        final map = user.toMap();

        expect(map['fullName'], 'Jane Smith');
      });

      test('handles null birthDate serialization', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime.now(),
        );

        final map = user.toMap();

        expect(map['birthDate'], isNull);
      });
    });

    group('fullName getter', () {
      test('combines firstName and lastName', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime.now(),
        );

        expect(user.fullName, 'John Doe');
      });

      test('trims when lastName is empty', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: 'John',
          lastName: '',
          createdAt: DateTime.now(),
        );

        expect(user.fullName, 'John');
      });

      test('trims when firstName is empty', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: '',
          lastName: 'Doe',
          createdAt: DateTime.now(),
        );

        expect(user.fullName, 'Doe');
      });

      test('returns empty string when both names are empty', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: '',
          lastName: '',
          createdAt: DateTime.now(),
        );

        expect(user.fullName, '');
      });
    });

    group('isAdmin getter', () {
      test('returns true when role is admin', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: 'Admin',
          lastName: 'User',
          role: 'admin',
          createdAt: DateTime.now(),
        );
        expect(user.isAdmin, true);
      });

      test('returns false when role is user', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: 'Regular',
          lastName: 'User',
          role: 'user',
          createdAt: DateTime.now(),
        );
        expect(user.isAdmin, false);
      });

      test('returns false with default role', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime.now(),
        );
        expect(user.isAdmin, false);
      });
    });

    group('copyWith', () {
      late UserModel original;

      setUp(() {
        original = UserModel(
          uid: 'uid1',
          email: 'original@test.com',
          firstName: 'Original',
          lastName: 'User',
          phoneNumber: '+111',
          photoUrl: 'https://original.com/photo.jpg',
          bio: 'Original bio',
          role: 'user',
          createdAt: DateTime(2024, 1, 1),
          birthDate: DateTime(1990, 1, 1),
          gender: 'female',
          heightCm: 165.0,
          weightKg: 60.0,
          activityLevel: 'low',
          cookingSkillLevel: 'beginner',
          followingCount: 5,
          followersCount: 10,
          username: 'originaluser',
          isBanned: false,
        );
      });

      test('preserves all fields when no arguments given', () {
        final copy = original.copyWith();

        expect(copy.uid, original.uid);
        expect(copy.email, original.email);
        expect(copy.firstName, original.firstName);
        expect(copy.lastName, original.lastName);
        expect(copy.phoneNumber, original.phoneNumber);
        expect(copy.photoUrl, original.photoUrl);
        expect(copy.bio, original.bio);
        expect(copy.role, original.role);
        expect(copy.createdAt, original.createdAt);
        expect(copy.birthDate, original.birthDate);
        expect(copy.gender, original.gender);
        expect(copy.heightCm, original.heightCm);
        expect(copy.weightKg, original.weightKg);
        expect(copy.activityLevel, original.activityLevel);
        expect(copy.cookingSkillLevel, original.cookingSkillLevel);
        expect(copy.followingCount, original.followingCount);
        expect(copy.followersCount, original.followersCount);
        expect(copy.username, original.username);
      });

      test('updates firstName only', () {
        final copy = original.copyWith(firstName: 'NewFirst');

        expect(copy.firstName, 'NewFirst');
        expect(copy.lastName, original.lastName);
        expect(copy.uid, original.uid);
        expect(copy.email, original.email);
      });

      test('updates lastName only', () {
        final copy = original.copyWith(lastName: 'NewLast');

        expect(copy.lastName, 'NewLast');
        expect(copy.firstName, original.firstName);
      });

      test('updates multiple fields simultaneously', () {
        final copy = original.copyWith(
          firstName: 'Updated',
          lastName: 'Name',
          bio: 'New bio',
          role: 'admin',
          followingCount: 100,
          followersCount: 200,
          username: 'newuser',
        );

        expect(copy.firstName, 'Updated');
        expect(copy.lastName, 'Name');
        expect(copy.bio, 'New bio');
        expect(copy.role, 'admin');
        expect(copy.followingCount, 100);
        expect(copy.followersCount, 200);
        expect(copy.username, 'newuser');
      });

      test('does not allow changing uid or email via copyWith', () {
        final copy = original.copyWith(firstName: 'Changed');

        expect(copy.uid, original.uid);
        expect(copy.email, original.email);
        expect(copy.createdAt, original.createdAt);
      });

      test('updates physical attributes', () {
        final copy = original.copyWith(
          heightCm: 170.0,
          weightKg: 65.0,
          gender: 'male',
        );

        expect(copy.heightCm, 170.0);
        expect(copy.weightKg, 65.0);
        expect(copy.gender, 'male');
      });

      test('updates ban fields', () {
        final bannedAt = DateTime(2024, 6, 1);
        final copy = original.copyWith(
          isBanned: true,
          banReason: 'Violation',
          bannedAt: bannedAt,
          bannedBy: 'admin_001',
        );
        expect(copy.isBanned, true);
        expect(copy.banReason, 'Violation');
        expect(copy.bannedAt, bannedAt);
        expect(copy.bannedBy, 'admin_001');
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all fields', () {
        final originalMap = fullMap();
        final user = UserModel.fromMap(originalMap);
        final resultMap = user.toMap();

        expect(resultMap['uid'], originalMap['uid']);
        expect(resultMap['email'], originalMap['email']);
        expect(resultMap['firstName'], originalMap['firstName']);
        expect(resultMap['lastName'], originalMap['lastName']);
        expect(resultMap['phoneNumber'], originalMap['phoneNumber']);
        expect(resultMap['photoUrl'], originalMap['photoUrl']);
        expect(resultMap['bio'], originalMap['bio']);
        expect(resultMap['role'], originalMap['role']);
        expect(resultMap['gender'], originalMap['gender']);
        expect(resultMap['heightCm'], originalMap['heightCm']);
        expect(resultMap['weightKg'], originalMap['weightKg']);
        expect(resultMap['activityLevel'], originalMap['activityLevel']);
        expect(resultMap['cookingSkillLevel'], originalMap['cookingSkillLevel']);
        expect(resultMap['followingCount'], originalMap['followingCount']);
        expect(resultMap['followersCount'], originalMap['followersCount']);
        expect(resultMap['username'], originalMap['username']);
        expect(resultMap['isBanned'], originalMap['isBanned']);
        expect(resultMap['banReason'], originalMap['banReason']);
        expect(resultMap['bannedAt'], originalMap['bannedAt']);
        expect(resultMap['bannedBy'], originalMap['bannedBy']);
      });
    });

    group('edge cases', () {
      test('handles empty string firstName and lastName', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: '',
          lastName: '',
          createdAt: DateTime.now(),
        );

        expect(user.firstName, '');
        expect(user.lastName, '');
        expect(user.fullName, '');
      });

      test('handles zero followingCount and followersCount', () {
        final user = UserModel(
          uid: 'u1',
          email: 'test@test.com',
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime.now(),
          followingCount: 0,
          followersCount: 0,
        );

        expect(user.followingCount, 0);
        expect(user.followersCount, 0);
      });
    });
  });
}
