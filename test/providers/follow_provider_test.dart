import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/follow_provider.dart';
import 'package:chef_specials/services/follow_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FollowService followService;
  late FollowProvider provider;

  Future<void> createUserDoc(String userId) async {
    await fakeFirestore.collection('users').doc(userId).set({
      'name': 'User $userId',
      'followingCount': 0,
      'followersCount': 0,
    });
  }

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    followService = FollowService(firestore: fakeFirestore);
    provider = FollowProvider(followService: followService);
  });

  group('FollowProvider', () {
    test('initial state has empty following ids', () {
      expect(provider.followingIds, isEmpty);
      expect(provider.followingList, isEmpty);
    });

    test('isFollowing returns false for unknown user', () {
      expect(provider.isFollowing('user2'), false);
    });

    test('initialize starts listening to following ids', () async {
      // Pre-create follow doc
      await fakeFirestore.collection('follows').doc('user1_user2').set({
        'followerId': 'user1',
        'followedId': 'user2',
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.initialize('user1');
      await Future.delayed(Duration.zero);

      expect(provider.isFollowing('user2'), true);
      expect(provider.followingIds, contains('user2'));
    });

    test('initialize does not re-subscribe for same user', () async {
      provider.initialize('user1');
      provider.initialize('user1'); // should be no-op
      await Future.delayed(Duration.zero);

      expect(provider.followingIds, isEmpty);
    });

    test('initialize re-subscribes for different user', () async {
      await fakeFirestore.collection('follows').doc('user1_user3').set({
        'followerId': 'user1',
        'followedId': 'user3',
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.initialize('user1');
      await Future.delayed(Duration.zero);
      expect(provider.isFollowing('user3'), true);

      provider.initialize('user2');
      await Future.delayed(Duration.zero);
      expect(provider.isFollowing('user3'), false);
    });

    test('follow adds target to following (optimistic)', () async {
      await createUserDoc('user1');
      await createUserDoc('user2');

      provider.initialize('user1');
      await Future.delayed(Duration.zero);

      await provider.follow('user2');

      // Optimistic: should be in set immediately
      expect(provider.isFollowing('user2'), true);

      // Verify in Firestore
      final doc =
          await fakeFirestore.collection('follows').doc('user1_user2').get();
      expect(doc.exists, true);
    });

    test('follow does nothing when userId is null', () async {
      // Don't call initialize
      await provider.follow('user2');
      expect(provider.followingIds, isEmpty);
    });

    test('unfollow removes target from following (optimistic)', () async {
      await createUserDoc('user1');
      await createUserDoc('user2');

      provider.initialize('user1');
      await Future.delayed(Duration.zero);

      await provider.follow('user2');
      expect(provider.isFollowing('user2'), true);

      await provider.unfollow('user2');

      // Optimistic: should be removed immediately
      expect(provider.isFollowing('user2'), false);
    });

    test('unfollow does nothing when userId is null', () async {
      await provider.unfollow('user2');
      expect(provider.followingIds, isEmpty);
    });

    test('follow updates user counters in Firestore', () async {
      await createUserDoc('user1');
      await createUserDoc('user2');

      provider.initialize('user1');
      await Future.delayed(Duration.zero);

      await provider.follow('user2');

      final user1Doc =
          await fakeFirestore.collection('users').doc('user1').get();
      final user2Doc =
          await fakeFirestore.collection('users').doc('user2').get();

      expect(user1Doc.data()!['followingCount'], 1);
      expect(user2Doc.data()!['followersCount'], 1);
    });

    test('unfollow updates user counters in Firestore', () async {
      await createUserDoc('user1');
      await createUserDoc('user2');

      provider.initialize('user1');
      await Future.delayed(Duration.zero);

      await provider.follow('user2');
      await provider.unfollow('user2');

      final user1Doc =
          await fakeFirestore.collection('users').doc('user1').get();
      final user2Doc =
          await fakeFirestore.collection('users').doc('user2').get();

      expect(user1Doc.data()!['followingCount'], 0);
      expect(user2Doc.data()!['followersCount'], 0);
    });

    test('follow notifies listeners', () async {
      await createUserDoc('user1');
      await createUserDoc('user2');

      provider.initialize('user1');
      await Future.delayed(Duration.zero);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.follow('user2');
      // At least 1 notification from optimistic update
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('followingList returns list form of followingIds', () async {
      await fakeFirestore.collection('follows').doc('user1_user2').set({
        'followerId': 'user1',
        'followedId': 'user2',
        'createdAt': DateTime.now().toIso8601String(),
      });

      provider.initialize('user1');
      await Future.delayed(Duration.zero);

      expect(provider.followingList, isA<List<String>>());
      expect(provider.followingList, contains('user2'));
    });
  });
}
