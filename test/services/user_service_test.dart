import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/user_service.dart';
import 'package:chef_specials/models/user_model.dart';

UserModel _makeUser({
  String uid = 'uid1',
  String email = 'test@test.com',
  String firstName = 'John',
  String lastName = 'Doe',
  String? username,
  int followingCount = 0,
  int followersCount = 0,
}) {
  return UserModel(
    uid: uid,
    email: email,
    firstName: firstName,
    lastName: lastName,
    username: username,
    createdAt: DateTime(2024, 1, 1),
    followingCount: followingCount,
    followersCount: followersCount,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = UserService(firestore: fakeFirestore);
  });

  group('UserService', () {
    group('createUser', () {
      test('should create a user document with uid as document ID', () async {
        final user = _makeUser(uid: 'user123', username: 'johndoe');
        await service.createUser(user);

        final doc =
            await fakeFirestore.collection('users').doc('user123').get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['firstName'], 'John');
        expect(doc.data()!['lastName'], 'Doe');
        expect(doc.data()!['email'], 'test@test.com');
      });

      test('should store lowercase search fields', () async {
        final user = _makeUser(
          uid: 'u1',
          firstName: 'John',
          lastName: 'Doe',
          username: 'JohnDoe',
        );
        await service.createUser(user);

        final doc = await fakeFirestore.collection('users').doc('u1').get();
        expect(doc.data()!['usernameLowercase'], 'johndoe');
        expect(doc.data()!['fullNameLowercase'], 'john doe');
        expect(doc.data()!['firstNameLowercase'], 'john');
        expect(doc.data()!['lastNameLowercase'], 'doe');
      });
    });

    group('getUser', () {
      test('should return a user by uid', () async {
        await service.createUser(_makeUser(uid: 'u1', firstName: 'Alice'));

        final user = await service.getUser('u1');

        expect(user, isNotNull);
        expect(user!.uid, 'u1');
        expect(user.firstName, 'Alice');
      });

      test('should return null for non-existent uid', () async {
        final user = await service.getUser('nonexistent');
        expect(user, isNull);
      });
    });

    group('watchUser', () {
      test('should emit user data as a stream', () async {
        await service.createUser(_makeUser(uid: 'u1', firstName: 'Bob'));

        final user = await service.watchUser('u1').first;

        expect(user, isNotNull);
        expect(user!.firstName, 'Bob');
      });

      test('should emit null for non-existent user', () async {
        final user = await service.watchUser('nonexistent').first;
        expect(user, isNull);
      });
    });

    group('updateUser', () {
      test('should update specific user fields', () async {
        await service.createUser(_makeUser(uid: 'u1'));

        await service.updateUser('u1', {'bio': 'Hello world!'});

        final doc = await fakeFirestore.collection('users').doc('u1').get();
        expect(doc.data()!['bio'], 'Hello world!');
      });

      test('should update multiple fields at once', () async {
        await service.createUser(_makeUser(uid: 'u1'));

        await service.updateUser('u1', {
          'firstName': 'Jane',
          'lastName': 'Smith',
        });

        final user = await service.getUser('u1');
        expect(user!.firstName, 'Jane');
        expect(user.lastName, 'Smith');
      });
    });

    group('isUsernameAvailable', () {
      test('should return true when username is not taken', () async {
        final available = await service.isUsernameAvailable('newuser');
        expect(available, isTrue);
      });

      test('should return false when username is taken', () async {
        // Pre-create the username doc
        await fakeFirestore
            .collection('usernames')
            .doc('takenuser')
            .set({'uid': 'someone'});

        final available = await service.isUsernameAvailable('takenuser');
        expect(available, isFalse);
      });

      test('should be case-insensitive', () async {
        await fakeFirestore
            .collection('usernames')
            .doc('johndoe')
            .set({'uid': 'someone'});

        final available = await service.isUsernameAvailable('JohnDoe');
        expect(available, isFalse);
      });
    });

    group('claimUsername', () {
      test('should claim a username and update the user document', () async {
        // Pre-create the user document so txn.update works
        await service.createUser(_makeUser(uid: 'u1'));

        await service.claimUsername('coolchef', 'u1');

        // Check usernames collection
        final usernameDoc =
            await fakeFirestore.collection('usernames').doc('coolchef').get();
        expect(usernameDoc.exists, isTrue);
        expect(usernameDoc.data()!['uid'], 'u1');

        // Check user document was updated
        final userDoc =
            await fakeFirestore.collection('users').doc('u1').get();
        expect(userDoc.data()!['username'], 'coolchef');
        expect(userDoc.data()!['usernameLowercase'], 'coolchef');
      });

      test('should throw when username is already taken', () async {
        await service.createUser(_makeUser(uid: 'u1'));
        await service.createUser(_makeUser(uid: 'u2', email: 'u2@test.com'));

        // u1 claims the username first
        await service.claimUsername('popular', 'u1');

        // u2 tries to claim the same username
        expect(
          () => service.claimUsername('popular', 'u2'),
          throwsException,
        );
      });
    });

    group('generateAndClaimUsername', () {
      test('should generate username from first and last name', () async {
        await service.createUser(_makeUser(uid: 'u1'));

        final username =
            await service.generateAndClaimUsername('u1', 'John', 'Doe');

        expect(username, 'johndoe');

        // Verify it was claimed
        final doc =
            await fakeFirestore.collection('usernames').doc('johndoe').get();
        expect(doc.exists, isTrue);
      });

      test('should append number if base username is taken', () async {
        await service.createUser(_makeUser(uid: 'u1'));
        await service.createUser(_makeUser(uid: 'u2', email: 'u2@test.com'));

        // Take the base username
        await fakeFirestore
            .collection('usernames')
            .doc('johndoe')
            .set({'uid': 'someone_else'});

        final username =
            await service.generateAndClaimUsername('u1', 'John', 'Doe');

        // Should be johndoe1 since johndoe is taken
        expect(username, 'johndoe1');
      });

      test('should add "user" suffix for short names', () async {
        await service.createUser(_makeUser(uid: 'u1'));

        final username =
            await service.generateAndClaimUsername('u1', 'A', 'B');

        // 'ab' has length 2 which is < 3, so it becomes 'abuser'
        expect(username, 'abuser');
      });
    });

    group('searchUsers', () {
      test('should find users by first name', () async {
        await service.createUser(_makeUser(uid: 'u1', firstName: 'Alice'));
        await service
            .createUser(_makeUser(uid: 'u2', email: 'e2@t.com', firstName: 'Bob'));

        final results = await service.searchUsers('Alice');
        expect(results.length, 1);
        expect(results[0].firstName, 'Alice');
      });

      test('should find users by username', () async {
        await service
            .createUser(_makeUser(uid: 'u1', username: 'chefmaster'));

        final results = await service.searchUsers('chef');
        expect(results.length, 1);
        expect(results[0].username, 'chefmaster');
      });

      test('should be case-insensitive', () async {
        await service.createUser(_makeUser(uid: 'u1', firstName: 'Alice'));

        final results = await service.searchUsers('ALICE');
        expect(results.length, 1);
      });

      test('should strip @ from search query', () async {
        await service
            .createUser(_makeUser(uid: 'u1', username: 'coolchef'));

        final results = await service.searchUsers('@coolchef');
        expect(results.length, 1);
      });

      test('should return empty for empty query', () async {
        await service.createUser(_makeUser(uid: 'u1'));

        final results = await service.searchUsers('');
        expect(results, isEmpty);
      });

      test('should respect the limit parameter', () async {
        for (var i = 0; i < 5; i++) {
          await service.createUser(_makeUser(
            uid: 'u$i',
            email: 'u$i@test.com',
            firstName: 'Test',
            lastName: 'User$i',
          ));
        }

        final results = await service.searchUsers('Test', limit: 3);
        expect(results.length, 3);
      });
    });
  });
}
