import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/recipe.dart';
import '../models/admin_log.dart';
import '../models/ban_appeal.dart';
import '../models/announcement.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService;

  AdminProvider({AdminService? adminService})
      : _adminService = adminService ?? AdminService();

  Map<String, int> _dashboardStats = {};
  List<UserModel> _users = [];
  List<Recipe> _recipes = [];
  List<Map<String, dynamic>> _categories = [];
  List<Announcement> _announcements = [];
  List<AdminLog> _auditLogs = [];
  List<BanAppeal> _appeals = [];
  List<BanAppeal> _pendingAppeals = [];
  bool _isLoading = false;
  String? _error;

  Map<String, int> get dashboardStats => _dashboardStats;
  List<UserModel> get users => _users;
  List<Recipe> get recipes => _recipes;
  List<Map<String, dynamic>> get categories => _categories;
  List<Announcement> get announcements => _announcements;
  List<AdminLog> get auditLogs => _auditLogs;
  List<BanAppeal> get appeals => _appeals;
  List<BanAppeal> get pendingAppeals => _pendingAppeals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- Dashboard ---
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _dashboardStats = await _adminService.getDashboardStats();
      _pendingAppeals = await _adminService.getPendingAppeals();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- Users ---
  Future<void> loadUsers({String? searchQuery}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _adminService.getAllUsers(searchQuery: searchQuery);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> banUser({
    required String userId,
    required String userName,
    required String reason,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await _adminService.banUser(
          userId: userId,
          reason: reason,
          adminId: adminId,
          adminName: adminName);
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: 'ban_user',
        targetId: userId,
        targetName: userName,
        details: reason,
        createdAt: DateTime.now(),
      ));
      await loadUsers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> unbanUser({
    required String userId,
    required String userName,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await _adminService.unbanUser(userId,
          adminId: adminId, adminName: adminName);
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: 'unban_user',
        targetId: userId,
        targetName: userName,
        createdAt: DateTime.now(),
      ));
      await loadUsers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setUserRole({
    required String userId,
    required String userName,
    required String role,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await _adminService.setUserRole(
          userId: userId,
          role: role,
          adminId: adminId,
          adminName: adminName);
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: role == 'admin' ? 'promote_user' : 'demote_user',
        targetId: userId,
        targetName: userName,
        details: 'Set role to $role',
        createdAt: DateTime.now(),
      ));
      await loadUsers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // --- Recipes ---
  Future<void> loadRecipes({String? searchQuery}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _recipes = await _adminService.getAllRecipes(searchQuery: searchQuery);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteRecipe({
    required String recipeId,
    required String recipeName,
    required String authorId,
    required String adminId,
    required String adminName,
    required String description,
  }) async {
    try {
      await _adminService.deleteRecipeAsAdmin(
        recipeId,
        authorId: authorId,
        recipeName: recipeName,
        description: description,
        adminId: adminId,
        adminName: adminName,
      );
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: 'delete_recipe',
        targetId: recipeId,
        targetName: recipeName,
        details: description,
        createdAt: DateTime.now(),
      ));
      _recipes.removeWhere((r) => r.id == recipeId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // --- Categories ---
  Future<void> loadCategories({String? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _adminService.getCategories(type: type);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory({
    required String name,
    required String type,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await _adminService.addCategory(name: name, type: type);
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: 'add_category',
        targetName: name,
        details: 'Type: $type',
        createdAt: DateTime.now(),
      ));
      await loadCategories(type: type);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await _adminService.updateCategory(id: id, name: name);
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: 'update_category',
        targetId: id,
        targetName: name,
        createdAt: DateTime.now(),
      ));
      final idx = _categories.indexWhere((c) => c['id'] == id);
      if (idx != -1) {
        _categories[idx] = {..._categories[idx], 'name': name};
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCategory({
    required String id,
    required String name,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await _adminService.deleteCategory(id);
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: 'delete_category',
        targetId: id,
        targetName: name,
        createdAt: DateTime.now(),
      ));
      _categories.removeWhere((c) => c['id'] == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> seedCategories() async {
    try {
      await _adminService.seedDefaultCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // --- Announcements ---
  Future<void> loadAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _announcements = await _adminService.getAnnouncements();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createAnnouncement({
    required String title,
    required String body,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await _adminService.createAnnouncement(
        title: title,
        body: body,
        adminId: adminId,
        adminName: adminName,
      );
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: 'create_announcement',
        targetName: title,
        createdAt: DateTime.now(),
      ));
      await loadAnnouncements();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createTargetedAnnouncement({
    required String title,
    required String body,
    required String adminId,
    required String adminName,
    required List<String> targetUserIds,
    required List<String> targetUserNames,
  }) async {
    try {
      await _adminService.createTargetedAnnouncement(
        title: title,
        body: body,
        adminId: adminId,
        adminName: adminName,
        targetUserIds: targetUserIds,
      );
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: 'create_targeted_announcement',
        targetName: title,
        details: 'Sent to: ${targetUserNames.join(", ")}',
        createdAt: DateTime.now(),
      ));
      await loadAnnouncements();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    return _adminService.searchUsers(query);
  }

  Future<void> deleteAnnouncement({
    required String id,
    required String title,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await _adminService.deleteAnnouncement(id);
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: 'delete_announcement',
        targetId: id,
        targetName: title,
        createdAt: DateTime.now(),
      ));
      _announcements.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // --- Audit Log ---
  Future<void> loadAuditLogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _auditLogs = await _adminService.getAuditLogs();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- Appeals ---
  Future<void> loadAppeals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _appeals = await _adminService.getAllAppeals();
      _pendingAppeals = await _adminService.getPendingAppeals();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> reviewAppeal({
    required String appealId,
    required String userName,
    required String status,
    required String adminId,
    required String adminName,
    String? note,
  }) async {
    try {
      await _adminService.reviewAppeal(
        appealId: appealId,
        status: status,
        adminId: adminId,
        adminName: adminName,
        note: note,
      );
      await _adminService.logAction(AdminLog(
        adminId: adminId,
        adminName: adminName,
        action: 'review_appeal_$status',
        targetId: appealId,
        targetName: userName,
        details: note,
        createdAt: DateTime.now(),
      ));
      await loadAppeals();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
