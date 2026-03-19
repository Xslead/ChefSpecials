import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:chef_specials/services/admin_service.dart';
import 'package:chef_specials/models/admin_log.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AdminService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = AdminService(firestore: fakeFirestore);
  });

  Map<String, dynamic> userMap({
    required String uid,
    String firstName = 'Test',
    String lastName = 'User',
    String role = 'user',
    bool isBanned = false,
  }) {
    return {
      'uid': uid,
      'email': '$uid@test.com',
      'firstName': firstName,
      'lastName': lastName,
      'firstNameLowercase': firstName.toLowerCase(),
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
      'isBanned': isBanned,
    };
  }

  Map<String, dynamic> recipeMap({String title = 'Test Recipe'}) {
    return {
      'title': title,
      'description': 'A test recipe',
      'authorId': 'author1',
      'authorName': 'Chef',
      'category': 'Dinner',
      'servings': 4,
      'prepTimeMinutes': 10,
      'cookTimeMinutes': 20,
      'ingredients': [
        {'name': 'Salt', 'amount': '1', 'unit': 'tsp'},
      ],
      'steps': [
        {'order': 1, 'instruction': 'Cook it'},
      ],
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  group('AdminService', () {
    group('getDashboardStats', () {
      test('returns correct counts', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1'));
        await fakeFirestore
            .collection('users')
            .doc('u2')
            .set(userMap(uid: 'u2'));
        await fakeFirestore.collection('recipes').add(recipeMap());

        final today = DateTime.now();
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        await fakeFirestore.collection('daily_logs').add({
          'date': todayStr,
          'userId': 'u1',
        });

        final stats = await service.getDashboardStats();
        expect(stats['totalUsers'], 2);
        expect(stats['totalRecipes'], 1);
        expect(stats['activeToday'], 1);
      });
    });

    group('getAllUsers', () {
      test('returns users from Firestore', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1', firstName: 'Alice'));
        await fakeFirestore
            .collection('users')
            .doc('u2')
            .set(userMap(uid: 'u2', firstName: 'Bob'));

        final users = await service.getAllUsers();
        expect(users.length, 2);
      });

      test('filters users by search query', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1', firstName: 'Alice'));
        await fakeFirestore
            .collection('users')
            .doc('u2')
            .set(userMap(uid: 'u2', firstName: 'Bob'));

        final users = await service.getAllUsers(searchQuery: 'alice');
        expect(users.length, 1);
        expect(users.first.firstName, 'Alice');
      });
    });

    group('banUser', () {
      test('updates user document correctly', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1'));

        await service.banUser(
          userId: 'u1',
          reason: 'Spam',
          adminId: 'admin1',
        );

        final doc = await fakeFirestore.collection('users').doc('u1').get();
        expect(doc.data()!['isBanned'], true);
        expect(doc.data()!['banReason'], 'Spam');
        expect(doc.data()!['bannedBy'], 'admin1');
        expect(doc.data()!['bannedAt'], isNotNull);
      });
    });

    group('unbanUser', () {
      test('clears ban fields', () async {
        await fakeFirestore.collection('users').doc('u1').set({
          ...userMap(uid: 'u1', isBanned: true),
          'banReason': 'Spam',
          'bannedAt': DateTime.now().toIso8601String(),
          'bannedBy': 'admin1',
        });

        await service.unbanUser('u1');

        final doc = await fakeFirestore.collection('users').doc('u1').get();
        expect(doc.data()!['isBanned'], false);
        expect(doc.data()!['banReason'], isNull);
        expect(doc.data()!['bannedAt'], isNull);
        expect(doc.data()!['bannedBy'], isNull);
      });
    });

    group('setUserRole', () {
      test('updates role field', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1'));

        await service.setUserRole(userId: 'u1', role: 'admin');

        final doc = await fakeFirestore.collection('users').doc('u1').get();
        expect(doc.data()!['role'], 'admin');
      });
    });

    group('deleteRecipeAsAdmin', () {
      test('removes recipe and associated data', () async {
        final recipeRef =
            await fakeFirestore.collection('recipes').add(recipeMap());
        final recipeId = recipeRef.id;

        // Add associated ratings
        await fakeFirestore.collection('ratings').add({
          'recipeId': recipeId,
          'userId': 'u1',
          'stars': 5,
        });

        // Add associated favorites
        await fakeFirestore.collection('favorites').add({
          'recipeId': recipeId,
          'userId': 'u1',
        });

        // Add associated comments (subcollection)
        await fakeFirestore
            .collection('recipes')
            .doc(recipeId)
            .collection('comments')
            .add({
          'text': 'Great!',
          'userId': 'u1',
        });

        await service.deleteRecipeAsAdmin(recipeId);

        final recipeDoc =
            await fakeFirestore.collection('recipes').doc(recipeId).get();
        expect(recipeDoc.exists, false);

        final ratingsSnap = await fakeFirestore
            .collection('ratings')
            .where('recipeId', isEqualTo: recipeId)
            .get();
        expect(ratingsSnap.docs, isEmpty);

        final favSnap = await fakeFirestore
            .collection('favorites')
            .where('recipeId', isEqualTo: recipeId)
            .get();
        expect(favSnap.docs, isEmpty);

        final commentsSnap = await fakeFirestore
            .collection('recipes')
            .doc(recipeId)
            .collection('comments')
            .get();
        expect(commentsSnap.docs, isEmpty);
      });
    });

    group('getCategories', () {
      test('returns categories', () async {
        await fakeFirestore.collection('categories').add({
          'name': 'Dinner',
          'type': 'recipe',
          'createdAt': DateTime.now().toIso8601String(),
        });
        await fakeFirestore.collection('categories').add({
          'name': 'Dairy',
          'type': 'food_item',
          'createdAt': DateTime.now().toIso8601String(),
        });

        final cats = await service.getCategories();
        expect(cats.length, 2);
      });

      test('filters by type', () async {
        await fakeFirestore.collection('categories').add({
          'name': 'Dinner',
          'type': 'recipe',
          'createdAt': DateTime.now().toIso8601String(),
        });
        await fakeFirestore.collection('categories').add({
          'name': 'Dairy',
          'type': 'food_item',
          'createdAt': DateTime.now().toIso8601String(),
        });

        final cats = await service.getCategories(type: 'recipe');
        expect(cats.length, 1);
        expect(cats.first['name'], 'Dinner');
      });
    });

    group('addCategory', () {
      test('creates new category document', () async {
        await service.addCategory(name: 'Breakfast', type: 'recipe');

        final snap = await fakeFirestore.collection('categories').get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['name'], 'Breakfast');
        expect(snap.docs.first.data()['type'], 'recipe');
      });
    });

    group('deleteCategory', () {
      test('removes category', () async {
        final ref = await fakeFirestore.collection('categories').add({
          'name': 'Lunch',
          'type': 'recipe',
        });

        await service.deleteCategory(ref.id);

        final doc =
            await fakeFirestore.collection('categories').doc(ref.id).get();
        expect(doc.exists, false);
      });
    });

    group('seedDefaultCategories', () {
      test('seeds when empty', () async {
        await service.seedDefaultCategories();

        final snap = await fakeFirestore.collection('categories').get();
        // 8 recipe + 10 food_item = 18
        expect(snap.docs.length, 18);
      });

      test('skips when non-empty', () async {
        await fakeFirestore.collection('categories').add({
          'name': 'Existing',
          'type': 'recipe',
        });

        await service.seedDefaultCategories();

        final snap = await fakeFirestore.collection('categories').get();
        expect(snap.docs.length, 1); // Only the existing one
      });
    });

    group('createAnnouncement', () {
      test('saves announcement and creates activities', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1'));
        await fakeFirestore
            .collection('users')
            .doc('u2')
            .set(userMap(uid: 'u2'));

        await service.createAnnouncement(
          title: 'Update',
          body: 'New feature released',
          adminId: 'admin1',
          adminName: 'Admin',
        );

        final annSnap =
            await fakeFirestore.collection('announcements').get();
        expect(annSnap.docs.length, 1);
        expect(annSnap.docs.first.data()['title'], 'Update');

        final actSnap =
            await fakeFirestore.collection('activities').get();
        expect(actSnap.docs.length, 2); // One per user
        expect(actSnap.docs.first.data()['type'], 'announcement');
      });
    });

    group('getAnnouncements', () {
      test('returns announcements', () async {
        await fakeFirestore.collection('announcements').add({
          'title': 'A1',
          'body': 'Body1',
          'authorId': 'admin1',
          'authorName': 'Admin',
          'createdAt': DateTime.now().toIso8601String(),
        });

        final result = await service.getAnnouncements();
        expect(result.length, 1);
        expect(result.first.title, 'A1');
      });
    });

    group('deleteAnnouncement', () {
      test('removes announcement', () async {
        final ref = await fakeFirestore.collection('announcements').add({
          'title': 'A1',
          'body': 'Body1',
          'authorId': 'admin1',
          'authorName': 'Admin',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await service.deleteAnnouncement(ref.id);

        final doc = await fakeFirestore
            .collection('announcements')
            .doc(ref.id)
            .get();
        expect(doc.exists, false);
      });
    });

    group('logAction', () {
      test('saves admin log', () async {
        final log = AdminLog(
          adminId: 'admin1',
          adminName: 'Admin',
          action: 'ban_user',
          targetId: 'u1',
          targetName: 'Test User',
          createdAt: DateTime.now(),
        );

        await service.logAction(log);

        final snap = await fakeFirestore.collection('admin_logs').get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['action'], 'ban_user');
      });
    });

    group('getAuditLogs', () {
      test('returns logs in order', () async {
        final older = DateTime(2024, 1, 1);
        final newer = DateTime(2024, 6, 1);

        await fakeFirestore.collection('admin_logs').add({
          'adminId': 'a1',
          'adminName': 'Admin',
          'action': 'older_action',
          'createdAt': older.toIso8601String(),
        });
        await fakeFirestore.collection('admin_logs').add({
          'adminId': 'a1',
          'adminName': 'Admin',
          'action': 'newer_action',
          'createdAt': newer.toIso8601String(),
        });

        final logs = await service.getAuditLogs();
        expect(logs.length, 2);
        expect(logs.first.action, 'newer_action');
        expect(logs.last.action, 'older_action');
      });
    });

    group('submitAppeal', () {
      test('creates appeal document', () async {
        await service.submitAppeal(
          userId: 'u1',
          userName: 'Test User',
          userEmail: 'test@test.com',
          appealText: 'I was wrongly banned',
        );

        final snap = await fakeFirestore.collection('appeals').get();
        expect(snap.docs.length, 1);
        final data = snap.docs.first.data();
        expect(data['userId'], 'u1');
        expect(data['status'], 'pending');
        expect(data['appealText'], 'I was wrongly banned');
      });
    });

    group('getPendingAppeals', () {
      test('returns only pending', () async {
        await fakeFirestore.collection('appeals').add({
          'userId': 'u1',
          'userName': 'User 1',
          'userEmail': 'u1@test.com',
          'appealText': 'Appeal 1',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        });
        await fakeFirestore.collection('appeals').add({
          'userId': 'u2',
          'userName': 'User 2',
          'userEmail': 'u2@test.com',
          'appealText': 'Appeal 2',
          'status': 'approved',
          'createdAt': DateTime.now().toIso8601String(),
        });

        final appeals = await service.getPendingAppeals();
        expect(appeals.length, 1);
        expect(appeals.first.userId, 'u1');
      });
    });

    group('reviewAppeal', () {
      test('updates status and unbans if approved', () async {
        // Create banned user
        await fakeFirestore.collection('users').doc('u1').set({
          ...userMap(uid: 'u1', isBanned: true),
          'banReason': 'Spam',
          'bannedAt': DateTime.now().toIso8601String(),
          'bannedBy': 'admin1',
        });

        // Create appeal
        final appealRef = await fakeFirestore.collection('appeals').add({
          'userId': 'u1',
          'userName': 'Test User',
          'userEmail': 'u1@test.com',
          'appealText': 'Please unban me',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await service.reviewAppeal(
          appealId: appealRef.id,
          status: 'approved',
          adminId: 'admin1',
          note: 'Approved after review',
        );

        // Check appeal was updated
        final appealDoc = await fakeFirestore
            .collection('appeals')
            .doc(appealRef.id)
            .get();
        expect(appealDoc.data()!['status'], 'approved');
        expect(appealDoc.data()!['reviewedBy'], 'admin1');
        expect(appealDoc.data()!['reviewNote'], 'Approved after review');
        expect(appealDoc.data()!['reviewedAt'], isNotNull);

        // Check user was unbanned
        final userDoc =
            await fakeFirestore.collection('users').doc('u1').get();
        expect(userDoc.data()!['isBanned'], false);
        expect(userDoc.data()!['banReason'], isNull);
      });

      test('rejects without unbanning', () async {
        await fakeFirestore.collection('users').doc('u1').set({
          ...userMap(uid: 'u1', isBanned: true),
          'banReason': 'Spam',
        });

        final appealRef = await fakeFirestore.collection('appeals').add({
          'userId': 'u1',
          'userName': 'Test User',
          'userEmail': 'u1@test.com',
          'appealText': 'Please unban me',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await service.reviewAppeal(
          appealId: appealRef.id,
          status: 'rejected',
          adminId: 'admin1',
        );

        final userDoc =
            await fakeFirestore.collection('users').doc('u1').get();
        expect(userDoc.data()!['isBanned'], true); // Still banned
      });
    });

    group('getUserAppeal', () {
      test('returns pending appeal for user', () async {
        await fakeFirestore.collection('appeals').add({
          'userId': 'u1',
          'userName': 'Test User',
          'userEmail': 'u1@test.com',
          'appealText': 'My appeal',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        });

        final appeal = await service.getUserAppeal('u1');
        expect(appeal, isNotNull);
        expect(appeal!.userId, 'u1');
        expect(appeal.appealText, 'My appeal');
      });

      test('returns null when no pending appeal', () async {
        await fakeFirestore.collection('appeals').add({
          'userId': 'u1',
          'userName': 'Test User',
          'userEmail': 'u1@test.com',
          'appealText': 'Old appeal',
          'status': 'approved',
          'createdAt': DateTime.now().toIso8601String(),
        });

        final appeal = await service.getUserAppeal('u1');
        expect(appeal, isNull);
      });
    });

    group('getAllRecipes', () {
      test('returns recipes from Firestore', () async {
        await fakeFirestore
            .collection('recipes')
            .add(recipeMap(title: 'Pasta'));
        await fakeFirestore
            .collection('recipes')
            .add(recipeMap(title: 'Soup'));

        final recipes = await service.getAllRecipes();
        expect(recipes.length, 2);
      });

      test('filters by search query', () async {
        await fakeFirestore
            .collection('recipes')
            .add(recipeMap(title: 'Pasta'));
        await fakeFirestore
            .collection('recipes')
            .add(recipeMap(title: 'Soup'));

        final recipes = await service.getAllRecipes(searchQuery: 'pasta');
        expect(recipes.length, 1);
        expect(recipes.first.title, 'Pasta');
      });
    });

    group('updateCategory', () {
      test('updates category name', () async {
        final ref = await fakeFirestore.collection('categories').add({
          'name': 'Old Name',
          'type': 'recipe',
        });

        await service.updateCategory(id: ref.id, name: 'New Name');

        final doc =
            await fakeFirestore.collection('categories').doc(ref.id).get();
        expect(doc.data()!['name'], 'New Name');
      });
    });

    group('getAllAppeals', () {
      test('returns all appeals', () async {
        await fakeFirestore.collection('appeals').add({
          'userId': 'u1',
          'userName': 'User 1',
          'userEmail': 'u1@test.com',
          'appealText': 'Appeal 1',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        });
        await fakeFirestore.collection('appeals').add({
          'userId': 'u2',
          'userName': 'User 2',
          'userEmail': 'u2@test.com',
          'appealText': 'Appeal 2',
          'status': 'approved',
          'createdAt': DateTime.now().toIso8601String(),
        });

        final appeals = await service.getAllAppeals();
        expect(appeals.length, 2);
      });
    });
  });
}
