import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/follow_service.dart';

/// Helper to pre-create user docs so batch.update works.
Future<void> _createUserDoc(
  FakeFirebaseFirestore firestore,
  String uid, {
  int followingCount = 0,
  int followersCount = 0,
}) async {
  await firestore.collection('users').doc(uid).set({
    'uid': uid,
    'email': '$uid@test.com',
    'firstName': 'User',
    'lastName': uid,
    'fullName': 'User $uid',
    'createdAt': DateTime(2024, 1, 1).toIso8601String(),
    'followingCount': followingCount,
    'followersCount': followersCount,
  });
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FollowService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = FollowService(firestore: fakeFirestore);
  });

  group('FollowService', () {
    group('follow', () {
      test('should create a follow document', () async {
        await _createUserDoc(fakeFirestore, 'user1');
        await _createUserDoc(fakeFirestore, 'user2');

        await service.follow('user1', 'user2');

        final doc = await fakeFirestore
            .collection('follows')
            .doc('user1_user2')
            .get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['followerId'], 'user1');
        expect(doc.data()!['followedId'], 'user2');
      });

      test('should increment followingCount for the follower', () async {
        await _createUserDoc(fakeFirestore, 'user1');
        await _createUserDoc(fakeFirestore, 'user2');

        await service.follow('user1', 'user2');

        final userDoc =
            await fakeFirestore.collection('users').doc('user1').get();
        expect(userDoc.data()!['followingCount'], 1);
      });

      test('should increment followersCount for the followed user', () async {
        await _createUserDoc(fakeFirestore, 'user1');
        await _createUserDoc(fakeFirestore, 'user2');

        await service.follow('user1', 'user2');

        final userDoc =
            await fakeFirestore.collection('users').doc('user2').get();
        expect(userDoc.data()!['followersCount'], 1);
      });

      test('should handle multiple follows correctly', () async {
        await _createUserDoc(fakeFirestore, 'user1');
        await _createUserDoc(fakeFirestore, 'user2');
        await _createUserDoc(fakeFirestore, 'user3');

        await service.follow('user1', 'user2');
        await service.follow('user1', 'user3');

        final userDoc =
            await fakeFirestore.collection('users').doc('user1').get();
        expect(userDoc.data()!['followingCount'], 2);
      });
    });

    group('unfollow', () {
      test('should delete the follow document', () async {
        await _createUserDoc(fakeFirestore, 'user1');
        await _createUserDoc(fakeFirestore, 'user2');
        await service.follow('user1', 'user2');

        await service.unfollow('user1', 'user2');

        final doc = await fakeFirestore
            .collection('follows')
            .doc('user1_user2')
            .get();
        expect(doc.exists, isFalse);
      });

      test('should decrement followingCount for the follower', () async {
        await _createUserDoc(fakeFirestore, 'user1', followingCount: 0);
        await _createUserDoc(fakeFirestore, 'user2', followersCount: 0);
        await service.follow('user1', 'user2');

        await service.unfollow('user1', 'user2');

        final userDoc =
            await fakeFirestore.collection('users').doc('user1').get();
        expect(userDoc.data()!['followingCount'], 0);
      });

      test('should decrement followersCount for the followed user', () async {
        await _createUserDoc(fakeFirestore, 'user1');
        await _createUserDoc(fakeFirestore, 'user2');
        await service.follow('user1', 'user2');

        await service.unfollow('user1', 'user2');

        final userDoc =
            await fakeFirestore.collection('users').doc('user2').get();
        expect(userDoc.data()!['followersCount'], 0);
      });
    });

    group('watchFollowingIds', () {
      test('should return stream of followed user IDs', () async {
        await _createUserDoc(fakeFirestore, 'user1');
        await _createUserDoc(fakeFirestore, 'user2');
        await _createUserDoc(fakeFirestore, 'user3');

        await service.follow('user1', 'user2');
        await service.follow('user1', 'user3');

        final ids = await service.watchFollowingIds('user1').first;

        expect(ids.length, 2);
        expect(ids, containsAll(['user2', 'user3']));
      });

      test('should return empty list for user following nobody', () async {
        final ids = await service.watchFollowingIds('user1').first;
        expect(ids, isEmpty);
      });
    });

    group('getFollowerIds', () {
      test('should return list of follower user IDs', () async {
        await _createUserDoc(fakeFirestore, 'user1');
        await _createUserDoc(fakeFirestore, 'user2');
        await _createUserDoc(fakeFirestore, 'user3');

        await service.follow('user2', 'user1');
        await service.follow('user3', 'user1');

        final ids = await service.getFollowerIds('user1');

        expect(ids.length, 2);
        expect(ids, containsAll(['user2', 'user3']));
      });

      test('should return empty list for user with no followers', () async {
        final ids = await service.getFollowerIds('user1');
        expect(ids, isEmpty);
      });
    });

    group('getFollowingIds', () {
      test('should return list of followed user IDs', () async {
        await _createUserDoc(fakeFirestore, 'user1');
        await _createUserDoc(fakeFirestore, 'user2');
        await _createUserDoc(fakeFirestore, 'user3');

        await service.follow('user1', 'user2');
        await service.follow('user1', 'user3');

        final ids = await service.getFollowingIds('user1');

        expect(ids.length, 2);
        expect(ids, containsAll(['user2', 'user3']));
      });

      test('should return empty list for user following nobody', () async {
        final ids = await service.getFollowingIds('nobody');
        expect(ids, isEmpty);
      });

      test('should not include users who follow the queried user', () async {
        await _createUserDoc(fakeFirestore, 'user1');
        await _createUserDoc(fakeFirestore, 'user2');

        // user2 follows user1
        await service.follow('user2', 'user1');

        // user1's following list should be empty
        final ids = await service.getFollowingIds('user1');
        expect(ids, isEmpty);
      });
    });
  });
}
