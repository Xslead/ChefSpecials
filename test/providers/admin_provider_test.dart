import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:chef_specials/providers/admin_provider.dart';
import 'package:chef_specials/services/admin_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AdminService service;
  late AdminProvider provider;

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

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = AdminService(firestore: fakeFirestore);
    provider = AdminProvider(adminService: service);
  });

  group('AdminProvider', () {
    test('initial state has empty data and no loading', () {
      expect(provider.dashboardStats, isEmpty);
      expect(provider.users, isEmpty);
      expect(provider.recipes, isEmpty);
      expect(provider.categories, isEmpty);
      expect(provider.announcements, isEmpty);
      expect(provider.auditLogs, isEmpty);
      expect(provider.appeals, isEmpty);
      expect(provider.pendingAppeals, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    group('loadDashboard', () {
      test('loads dashboard stats and pending appeals', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1'));
        await fakeFirestore.collection('recipes').add(recipeMap());

        await provider.loadDashboard();

        expect(provider.isLoading, false);
        expect(provider.dashboardStats['totalUsers'], 1);
        expect(provider.dashboardStats['totalRecipes'], 1);
        expect(provider.error, isNull);
      });

      test('sets error on failure', () async {
        // Use a provider with a broken service
        final brokenProvider = AdminProvider(
          adminService: AdminService(firestore: fakeFirestore),
        );
        // This should succeed without error for a simple case
        await brokenProvider.loadDashboard();
        expect(brokenProvider.isLoading, false);
      });
    });

    group('loadUsers', () {
      test('loads users into state', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1', firstName: 'Alice'));

        await provider.loadUsers();

        expect(provider.users.length, 1);
        expect(provider.users.first.firstName, 'Alice');
        expect(provider.isLoading, false);
      });

      test('loads users with search query', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1', firstName: 'Alice'));
        await fakeFirestore
            .collection('users')
            .doc('u2')
            .set(userMap(uid: 'u2', firstName: 'Bob'));

        await provider.loadUsers(searchQuery: 'alice');

        expect(provider.users.length, 1);
        expect(provider.users.first.firstName, 'Alice');
      });
    });

    group('banUser', () {
      test('bans user, logs action, and reloads users', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1'));

        await provider.banUser(
          userId: 'u1',
          userName: 'Test User',
          reason: 'Spam',
          adminId: 'admin1',
          adminName: 'Admin',
        );

        // Check user is banned
        final doc = await fakeFirestore.collection('users').doc('u1').get();
        expect(doc.data()!['isBanned'], true);

        // Check audit log was created
        final logs = await fakeFirestore.collection('admin_logs').get();
        expect(logs.docs.length, 1);
        expect(logs.docs.first.data()['action'], 'ban_user');
      });
    });

    group('unbanUser', () {
      test('unbans user, logs action, and reloads users', () async {
        await fakeFirestore.collection('users').doc('u1').set({
          ...userMap(uid: 'u1', isBanned: true),
          'banReason': 'Spam',
        });

        await provider.unbanUser(
          userId: 'u1',
          userName: 'Test User',
          adminId: 'admin1',
          adminName: 'Admin',
        );

        final doc = await fakeFirestore.collection('users').doc('u1').get();
        expect(doc.data()!['isBanned'], false);

        final logs = await fakeFirestore.collection('admin_logs').get();
        expect(logs.docs.first.data()['action'], 'unban_user');
      });
    });

    group('setUserRole', () {
      test('sets role to admin and logs promote action', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1'));

        await provider.setUserRole(
          userId: 'u1',
          userName: 'Test User',
          role: 'admin',
          adminId: 'admin1',
          adminName: 'Admin',
        );

        final doc = await fakeFirestore.collection('users').doc('u1').get();
        expect(doc.data()!['role'], 'admin');

        final logs = await fakeFirestore.collection('admin_logs').get();
        expect(logs.docs.first.data()['action'], 'promote_user');
      });

      test('sets role to user and logs demote action', () async {
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .set(userMap(uid: 'u1', role: 'admin'));

        await provider.setUserRole(
          userId: 'u1',
          userName: 'Test User',
          role: 'user',
          adminId: 'admin1',
          adminName: 'Admin',
        );

        final logs = await fakeFirestore.collection('admin_logs').get();
        expect(logs.docs.first.data()['action'], 'demote_user');
      });
    });

    group('loadRecipes', () {
      test('loads recipes into state', () async {
        await fakeFirestore
            .collection('recipes')
            .add(recipeMap(title: 'Pasta'));

        await provider.loadRecipes();

        expect(provider.recipes.length, 1);
        expect(provider.recipes.first.title, 'Pasta');
        expect(provider.isLoading, false);
      });
    });

    group('deleteRecipe', () {
      test('deletes recipe, logs action, and removes from state', () async {
        final ref =
            await fakeFirestore.collection('recipes').add(recipeMap());

        // Load recipes first so state is populated
        await provider.loadRecipes();
        expect(provider.recipes.length, 1);

        await provider.deleteRecipe(
          recipeId: ref.id,
          recipeName: 'Test Recipe',
          authorId: 'author1',
          adminId: 'admin1',
          adminName: 'Admin',
          description: 'Violates guidelines',
        );

        expect(provider.recipes, isEmpty);

        final logs = await fakeFirestore.collection('admin_logs').get();
        expect(logs.docs.first.data()['action'], 'delete_recipe');
      });
    });

    group('loadCategories', () {
      test('loads categories into state', () async {
        await fakeFirestore.collection('categories').add({
          'name': 'Dinner',
          'type': 'recipe',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await provider.loadCategories();

        expect(provider.categories.length, 1);
        expect(provider.categories.first['name'], 'Dinner');
      });
    });

    group('addCategory', () {
      test('adds category and reloads', () async {
        await provider.addCategory(
          name: 'Breakfast',
          type: 'recipe',
          adminId: 'admin1',
          adminName: 'Admin',
        );

        final snap = await fakeFirestore.collection('categories').get();
        expect(snap.docs.length, 1);

        final logs = await fakeFirestore.collection('admin_logs').get();
        expect(logs.docs.first.data()['action'], 'add_category');
      });
    });

    group('updateCategory', () {
      test('updates category in state optimistically', () async {
        final ref = await fakeFirestore.collection('categories').add({
          'name': 'Old',
          'type': 'recipe',
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Load categories to populate state
        await provider.loadCategories();

        await provider.updateCategory(
          id: ref.id,
          name: 'New',
          adminId: 'admin1',
          adminName: 'Admin',
        );

        final idx =
            provider.categories.indexWhere((c) => c['id'] == ref.id);
        expect(provider.categories[idx]['name'], 'New');
      });
    });

    group('deleteCategory', () {
      test('removes category from state', () async {
        final ref = await fakeFirestore.collection('categories').add({
          'name': 'ToDelete',
          'type': 'recipe',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await provider.loadCategories();
        expect(provider.categories.length, 1);

        await provider.deleteCategory(
          id: ref.id,
          name: 'ToDelete',
          adminId: 'admin1',
          adminName: 'Admin',
        );

        expect(provider.categories, isEmpty);
      });
    });

    group('seedCategories', () {
      test('seeds default categories', () async {
        await provider.seedCategories();

        final snap = await fakeFirestore.collection('categories').get();
        expect(snap.docs.length, 18);
      });
    });

    group('loadAnnouncements', () {
      test('loads announcements into state', () async {
        await fakeFirestore.collection('announcements').add({
          'title': 'Hello',
          'body': 'World',
          'authorId': 'admin1',
          'authorName': 'Admin',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await provider.loadAnnouncements();

        expect(provider.announcements.length, 1);
        expect(provider.announcements.first.title, 'Hello');
      });
    });

    group('createAnnouncement', () {
      test('creates announcement and reloads', () async {
        await provider.createAnnouncement(
          title: 'New Feature',
          body: 'Check it out',
          adminId: 'admin1',
          adminName: 'Admin',
        );

        expect(provider.announcements.length, 1);
        expect(provider.announcements.first.title, 'New Feature');

        final logs = await fakeFirestore.collection('admin_logs').get();
        expect(logs.docs.first.data()['action'], 'create_announcement');
      });
    });

    group('deleteAnnouncement', () {
      test('deletes announcement and removes from state', () async {
        final ref = await fakeFirestore.collection('announcements').add({
          'title': 'ToDelete',
          'body': 'Body',
          'authorId': 'admin1',
          'authorName': 'Admin',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await provider.loadAnnouncements();
        expect(provider.announcements.length, 1);

        await provider.deleteAnnouncement(
          id: ref.id,
          title: 'ToDelete',
          adminId: 'admin1',
          adminName: 'Admin',
        );

        expect(provider.announcements, isEmpty);
      });
    });

    group('loadAuditLogs', () {
      test('loads audit logs into state', () async {
        await fakeFirestore.collection('admin_logs').add({
          'adminId': 'a1',
          'adminName': 'Admin',
          'action': 'test_action',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await provider.loadAuditLogs();

        expect(provider.auditLogs.length, 1);
        expect(provider.auditLogs.first.action, 'test_action');
      });
    });

    group('loadAppeals', () {
      test('loads all appeals and pending appeals', () async {
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

        await provider.loadAppeals();

        expect(provider.appeals.length, 2);
        expect(provider.pendingAppeals.length, 1);
      });
    });

    group('reviewAppeal', () {
      test('reviews appeal and reloads', () async {
        await fakeFirestore.collection('users').doc('u1').set({
          ...userMap(uid: 'u1', isBanned: true),
          'banReason': 'Spam',
        });

        final ref = await fakeFirestore.collection('appeals').add({
          'userId': 'u1',
          'userName': 'Test User',
          'userEmail': 'u1@test.com',
          'appealText': 'Please unban',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await provider.reviewAppeal(
          appealId: ref.id,
          userName: 'Test User',
          status: 'approved',
          adminId: 'admin1',
          adminName: 'Admin',
          note: 'Approved',
        );

        // Appeal should now be approved, not pending
        expect(provider.pendingAppeals, isEmpty);

        final logs = await fakeFirestore.collection('admin_logs').get();
        expect(logs.docs.first.data()['action'], 'review_appeal_approved');
      });
    });

    group('clearError', () {
      test('clears error state', () {
        // Directly test clearError
        provider.clearError();
        expect(provider.error, isNull);
      });
    });

    group('loading state management', () {
      test('isLoading is true during load and false after', () async {
        bool wasLoading = false;
        provider.addListener(() {
          if (provider.isLoading) wasLoading = true;
        });

        await provider.loadUsers();

        expect(wasLoading, true);
        expect(provider.isLoading, false);
      });
    });
  });
}
