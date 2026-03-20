import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/recipe.dart';
import '../models/admin_log.dart';
import '../models/ban_appeal.dart';
import '../models/announcement.dart';
import '../config/constants.dart';

class AdminService {
  final FirebaseFirestore _firestore;

  AdminService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // --- Dashboard ---
  Future<Map<String, int>> getDashboardStats() async {
    int totalUsers = 0;
    int totalRecipes = 0;
    int totalComments = 0;
    int activeToday = 0;

    try {
      final usersSnap =
          await _firestore.collection(AppConstants.usersCollection).get();
      totalUsers = usersSnap.size;
    } catch (_) {}

    try {
      final recipesSnap =
          await _firestore.collection(AppConstants.recipesCollection).get();
      totalRecipes = recipesSnap.size;

      // Sum commentCount from all recipes instead of collectionGroup query
      for (final doc in recipesSnap.docs) {
        totalComments += (doc.data()['commentCount'] as int?) ?? 0;
      }
    } catch (_) {}

    try {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final activeSnap = await _firestore
          .collection('daily_logs')
          .where('date', isEqualTo: todayStr)
          .get();
      activeToday = activeSnap.size;
    } catch (_) {}

    return {
      'totalUsers': totalUsers,
      'totalRecipes': totalRecipes,
      'totalComments': totalComments,
      'activeToday': activeToday,
    };
  }

  // --- Notification helper ---
  Future<void> _notifyUser({
    required String userId,
    required String title,
    required String message,
    String? adminId,
    String? adminName,
  }) async {
    await _firestore.collection(AppConstants.activitiesCollection).add({
      'userId': userId,
      'actorId': adminId ?? 'system',
      'actorName': adminName ?? 'ChefSpecials',
      'actorAvatar': null,
      'type': 'announcement',
      'targetId': null,
      'targetName': title,
      'targetImageUrl': null,
      'message': message,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // --- User Management ---
  Future<List<UserModel>> getAllUsers(
      {String? searchQuery, int limit = 50}) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection(AppConstants.usersCollection);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lower = searchQuery.toLowerCase();
      query = query
          .where('firstNameLowercase', isGreaterThanOrEqualTo: lower)
          .where('firstNameLowercase', isLessThanOrEqualTo: '$lower\uf8ff');
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  Future<void> banUser({
    required String userId,
    required String reason,
    required String adminId,
    String? adminName,
  }) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'isBanned': true,
      'banReason': reason,
      'bannedAt': DateTime.now().toIso8601String(),
      'bannedBy': adminId,
    });

    await _notifyUser(
      userId: userId,
      title: 'Account Suspended',
      message: 'Your account has been suspended. Reason: $reason',
      adminId: adminId,
      adminName: adminName,
    );
  }

  Future<void> unbanUser(String userId,
      {String? adminId, String? adminName}) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'isBanned': false,
      'banReason': null,
      'bannedAt': null,
      'bannedBy': null,
    });

    await _notifyUser(
      userId: userId,
      title: 'Your account has been restored',
      message: 'Your ban has been lifted. Welcome back to the community!',
      adminId: adminId,
      adminName: adminName,
    );
  }

  Future<void> setUserRole({
    required String userId,
    required String role,
    String? adminId,
    String? adminName,
  }) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'role': role,
    });

    final title = role == 'admin'
        ? 'You have been promoted to Admin'
        : 'Your admin privileges have been removed';
    final message = role == 'admin'
        ? 'You now have admin access to the app.'
        : 'Your role has been changed back to regular user.';
    await _notifyUser(
      userId: userId,
      title: title,
      message: message,
      adminId: adminId,
      adminName: adminName,
    );
  }

  // --- Recipe Moderation ---
  Future<List<Recipe>> getAllRecipes(
      {String? searchQuery, int limit = 50}) async {
    final snapshot = await _firestore
        .collection(AppConstants.recipesCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final recipes = <Recipe>[];
    for (final doc in snapshot.docs) {
      try {
        final recipe = Recipe.fromMap(doc.data(), doc.id);
        if (searchQuery != null && searchQuery.isNotEmpty) {
          if (recipe.title.toLowerCase().contains(searchQuery.toLowerCase())) {
            recipes.add(recipe);
          }
        } else {
          recipes.add(recipe);
        }
      } catch (_) {}
    }
    return recipes;
  }

  Future<void> deleteRecipeAsAdmin(
    String recipeId, {
    String? authorId,
    String? recipeName,
    String? description,
    String? adminId,
    String? adminName,
  }) async {
    final batch = _firestore.batch();

    // Delete the recipe
    batch.delete(
        _firestore.collection(AppConstants.recipesCollection).doc(recipeId));

    // Delete associated ratings
    final ratings = await _firestore
        .collection(AppConstants.ratingsCollection)
        .where('recipeId', isEqualTo: recipeId)
        .get();
    for (final doc in ratings.docs) {
      batch.delete(doc.reference);
    }

    // Delete associated favorites
    final favorites = await _firestore
        .collection(AppConstants.favoritesCollection)
        .where('recipeId', isEqualTo: recipeId)
        .get();
    for (final doc in favorites.docs) {
      batch.delete(doc.reference);
    }

    // Delete associated comments (subcollection)
    final comments = await _firestore
        .collection(AppConstants.recipesCollection)
        .doc(recipeId)
        .collection(AppConstants.commentsCollection)
        .get();
    for (final doc in comments.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    // Notify the recipe author
    if (authorId != null) {
      await _notifyUser(
        userId: authorId,
        title: 'Your recipe "${recipeName ?? 'Unknown'}" was removed',
        message: description ?? 'Your recipe was removed by an admin.',
        adminId: adminId,
        adminName: adminName,
      );
    }
  }

  // --- Categories ---
  Future<List<Map<String, dynamic>>> getCategories({String? type}) async {
    final snapshot =
        await _firestore.collection(AppConstants.categoriesCollection).get();
    var results = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
    if (type != null) {
      results = results.where((c) => c['type'] == type).toList();
    }
    results.sort((a, b) =>
        (a['name'] as String? ?? '').compareTo(b['name'] as String? ?? ''));
    return results;
  }

  Future<void> addCategory(
      {required String name, required String type}) async {
    await _firestore.collection(AppConstants.categoriesCollection).add({
      'name': name,
      'type': type,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateCategory(
      {required String id, required String name}) async {
    await _firestore
        .collection(AppConstants.categoriesCollection)
        .doc(id)
        .update({
      'name': name,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _firestore
        .collection(AppConstants.categoriesCollection)
        .doc(id)
        .delete();
  }

  Future<void> seedDefaultCategories() async {
    final existing =
        await _firestore.collection(AppConstants.categoriesCollection).get();
    if (existing.docs.isNotEmpty) return; // Already seeded

    final batch = _firestore.batch();

    // Recipe categories
    final recipeCategories = [
      'Breakfast',
      'Lunch',
      'Dinner',
      'Dessert',
      'Snack',
      'Drink',
      'Salad',
      'Soup',
    ];
    for (final cat in recipeCategories) {
      final ref =
          _firestore.collection(AppConstants.categoriesCollection).doc();
      batch.set(ref, {
        'name': cat,
        'type': 'recipe',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    // Food item categories
    final foodCategories = [
      'Dairy',
      'Meat',
      'Vegetables',
      'Fruits',
      'Grains',
      'Beverages',
      'Snacks',
      'Bakery',
      'Seafood',
      'Condiments',
    ];
    for (final cat in foodCategories) {
      final ref =
          _firestore.collection(AppConstants.categoriesCollection).doc();
      batch.set(ref, {
        'name': cat,
        'type': 'food_item',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    await batch.commit();
  }

  // --- Announcements ---
  Future<void> createAnnouncement({
    required String title,
    required String body,
    required String adminId,
    required String adminName,
  }) async {
    // Save announcement
    await _firestore.collection(AppConstants.announcementsCollection).add({
      'title': title,
      'body': body,
      'authorId': adminId,
      'authorName': adminName,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Fan-out: create activity for all users
    final usersSnap =
        await _firestore.collection(AppConstants.usersCollection).get();
    final batch = _firestore.batch();
    for (final userDoc in usersSnap.docs) {
      final ref =
          _firestore.collection(AppConstants.activitiesCollection).doc();
      batch.set(ref, {
        'userId': userDoc.id,
        'actorId': adminId,
        'actorName': adminName,
        'actorAvatar': null,
        'type': 'announcement',
        'targetId': null,
        'targetName': title,
        'targetImageUrl': null,
        'message': body,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit();
  }

  Future<void> createTargetedAnnouncement({
    required String title,
    required String body,
    required String adminId,
    required String adminName,
    required List<String> targetUserIds,
  }) async {
    await _firestore.collection(AppConstants.announcementsCollection).add({
      'title': title,
      'body': body,
      'authorId': adminId,
      'authorName': adminName,
      'targetUserIds': targetUserIds,
      'createdAt': DateTime.now().toIso8601String(),
    });

    final batch = _firestore.batch();
    for (final userId in targetUserIds) {
      final ref =
          _firestore.collection(AppConstants.activitiesCollection).doc();
      batch.set(ref, {
        'userId': userId,
        'actorId': adminId,
        'actorName': adminName,
        'actorAvatar': null,
        'type': 'announcement',
        'targetId': null,
        'targetName': title,
        'targetImageUrl': null,
        'message': body,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final lower = query.toLowerCase();
    final snapshot =
        await _firestore.collection(AppConstants.usersCollection).get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((u) =>
            u.fullName.toLowerCase().contains(lower) ||
            (u.username?.toLowerCase().contains(lower) ?? false) ||
            u.email.toLowerCase().contains(lower))
        .toList();
  }

  Future<List<Announcement>> getAnnouncements() async {
    final snapshot = await _firestore
        .collection(AppConstants.announcementsCollection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Announcement.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestore
        .collection(AppConstants.announcementsCollection)
        .doc(id)
        .delete();
  }

  // --- Audit Log ---
  Future<void> logAction(AdminLog log) async {
    await _firestore
        .collection(AppConstants.adminLogsCollection)
        .add(log.toMap());
  }

  Future<List<AdminLog>> getAuditLogs({int limit = 100}) async {
    final snapshot = await _firestore
        .collection(AppConstants.adminLogsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => AdminLog.fromMap(doc.data(), doc.id))
        .toList();
  }

  // --- Appeals ---
  Future<void> submitAppeal({
    required String userId,
    required String userName,
    required String userEmail,
    required String appealText,
  }) async {
    await _firestore.collection(AppConstants.appealsCollection).add({
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'appealText': appealText,
      'status': 'pending',
      'reviewedBy': null,
      'reviewNote': null,
      'createdAt': DateTime.now().toIso8601String(),
      'reviewedAt': null,
    });
  }

  Future<List<BanAppeal>> getPendingAppeals() async {
    // Fetch all appeals and filter in memory to avoid composite index requirement
    final all = await getAllAppeals();
    return all.where((a) => a.status == 'pending').toList();
  }

  Future<List<BanAppeal>> getAllAppeals() async {
    final snapshot = await _firestore
        .collection(AppConstants.appealsCollection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => BanAppeal.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> reviewAppeal({
    required String appealId,
    required String status,
    required String adminId,
    String? adminName,
    String? note,
  }) async {
    await _firestore
        .collection(AppConstants.appealsCollection)
        .doc(appealId)
        .update({
      'status': status,
      'reviewedBy': adminId,
      'reviewNote': note,
      'reviewedAt': DateTime.now().toIso8601String(),
    });

    // If approved, unban the user
    if (status == 'approved') {
      final appealDoc = await _firestore
          .collection(AppConstants.appealsCollection)
          .doc(appealId)
          .get();
      final userId = appealDoc.data()?['userId'] as String?;
      if (userId != null) {
        await unbanUser(userId,
            adminId: adminId, adminName: adminName);
      }
    }
  }

  Future<BanAppeal?> getUserAppeal(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.appealsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    final pending = snapshot.docs.where((d) => d.data()['status'] == 'pending');
    if (pending.isEmpty) return null;
    return BanAppeal.fromMap(pending.first.data(), pending.first.id);
  }
}
