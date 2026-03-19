import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:chef_specials/services/activity_service.dart';
import 'package:chef_specials/models/activity.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ActivityService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = ActivityService(firestore: fakeFirestore);
  });

  group('ActivityService', () {
    test('createActivity adds document to Firestore', () async {
      final activity = Activity(
        userId: 'user1',
        actorId: 'actor1',
        actorName: 'John',
        type: ActivityType.follow,
        createdAt: DateTime.now(),
      );

      await service.createActivity(activity);

      final snapshot = await fakeFirestore.collection('activities').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['actorName'], 'John');
      expect(snapshot.docs.first.data()['type'], 'follow');
    });

    test('createFollowActivity creates follow activity', () async {
      await service.createFollowActivity(
        targetUserId: 'target',
        actorId: 'actor',
        actorName: 'Jane',
        actorAvatar: 'avatar_url',
      );

      final snapshot = await fakeFirestore.collection('activities').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['userId'], 'target');
      expect(data['actorId'], 'actor');
      expect(data['type'], 'follow');
    });

    test('createCommentActivity skips self-comment', () async {
      await service.createCommentActivity(
        recipeAuthorId: 'user1',
        actorId: 'user1',
        actorName: 'Self',
        recipeId: 'r1',
        recipeName: 'Pasta',
        commentText: 'My own comment',
      );

      final snapshot = await fakeFirestore.collection('activities').get();
      expect(snapshot.docs.length, 0);
    });

    test('createCommentActivity creates activity for different user', () async {
      await service.createCommentActivity(
        recipeAuthorId: 'author1',
        actorId: 'commenter1',
        actorName: 'Commenter',
        recipeId: 'r1',
        recipeName: 'Soup',
        commentText: 'Delicious!',
      );

      final snapshot = await fakeFirestore.collection('activities').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['userId'], 'author1');
      expect(data['type'], 'comment');
      expect(data['message'], 'Delicious!');
    });

    test('createRatingActivity skips self-rating', () async {
      await service.createRatingActivity(
        recipeAuthorId: 'user1',
        actorId: 'user1',
        actorName: 'Self',
        recipeId: 'r1',
        recipeName: 'Cake',
        stars: 5,
      );

      final snapshot = await fakeFirestore.collection('activities').get();
      expect(snapshot.docs.length, 0);
    });

    test('createRatingActivity creates activity for different user', () async {
      await service.createRatingActivity(
        recipeAuthorId: 'author1',
        actorId: 'rater1',
        actorName: 'Rater',
        recipeId: 'r1',
        recipeName: 'Cake',
        stars: 4,
      );

      final snapshot = await fakeFirestore.collection('activities').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['userId'], 'author1');
      expect(data['type'], 'rating');
      expect(data['message'], '4');
    });

    test('createNewRecipeActivity creates activities for all followers',
        () async {
      await service.createNewRecipeActivity(
        recipeId: 'r1',
        recipeName: 'New Recipe',
        authorId: 'author1',
        authorName: 'Chef',
        followerIds: ['f1', 'f2', 'f3'],
      );

      final snapshot = await fakeFirestore.collection('activities').get();
      expect(snapshot.docs.length, 3);

      final userIds = snapshot.docs.map((d) => d.data()['userId']).toSet();
      expect(userIds, {'f1', 'f2', 'f3'});
      expect(snapshot.docs.first.data()['type'], 'newRecipe');
    });

    test('markAllAsRead updates unread activities', () async {
      // Create 2 unread activities
      for (var i = 0; i < 2; i++) {
        await fakeFirestore.collection('activities').add({
          'userId': 'user1',
          'actorId': 'a$i',
          'actorName': 'Actor $i',
          'type': 'follow',
          'isRead': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      // Create 1 already read
      await fakeFirestore.collection('activities').add({
        'userId': 'user1',
        'actorId': 'a3',
        'actorName': 'Actor 3',
        'type': 'follow',
        'isRead': true,
        'createdAt': DateTime.now().toIso8601String(),
      });

      await service.markAllAsRead('user1');

      final snapshot = await fakeFirestore
          .collection('activities')
          .where('userId', isEqualTo: 'user1')
          .get();

      for (final doc in snapshot.docs) {
        expect(doc.data()['isRead'], true);
      }
    });

    test('deleteOldActivities removes activities older than 30 days',
        () async {
      final old = DateTime.now().subtract(const Duration(days: 31));
      final recent = DateTime.now().subtract(const Duration(days: 5));

      await fakeFirestore.collection('activities').add({
        'userId': 'user1',
        'actorId': 'a1',
        'actorName': 'Old',
        'type': 'follow',
        'isRead': true,
        'createdAt': old.toIso8601String(),
      });
      await fakeFirestore.collection('activities').add({
        'userId': 'user1',
        'actorId': 'a2',
        'actorName': 'Recent',
        'type': 'follow',
        'isRead': false,
        'createdAt': recent.toIso8601String(),
      });

      await service.deleteOldActivities('user1');

      final snapshot = await fakeFirestore
          .collection('activities')
          .where('userId', isEqualTo: 'user1')
          .get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['actorName'], 'Recent');
    });
  });
}
