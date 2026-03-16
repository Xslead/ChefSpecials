import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<UserModel?>? _userSub;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider({AuthService? authService, UserService? userService})
      : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _firebaseUser = user;
    _userSub?.cancel();
    _userSub = null;
    if (user != null) {
      _userSub = _userService.watchUser(user.uid).listen(
        (model) {
          _userModel = model;
          if (model != null && model.username == null) {
            _generateMissingUsername(model);
          } else if (model != null && !_migrationRan) {
            _migrationRan = true;
            _userService.migrateUsersWithoutUsernames();
          }
          notifyListeners();
        },
        onError: (_) async {
          // Fallback to one-time fetch if stream fails
          _userModel = await _userService.getUser(user.uid);
          notifyListeners();
        },
      );
    } else {
      _userModel = null;
      notifyListeners();
    }
  }

  bool _generatingUsername = false;
  bool _migrationRan = false;

  Future<void> _generateMissingUsername(UserModel model) async {
    if (_generatingUsername) return;
    _generatingUsername = true;
    try {
      await _userService.generateAndClaimUsername(
        model.uid,
        model.firstName,
        model.lastName,
      );
      // After own username is set, migrate other users once
      if (!_migrationRan) {
        _migrationRan = true;
        _userService.migrateUsersWithoutUsernames();
      }
    } catch (_) {
      // Silently fail — will retry on next auth state change
    } finally {
      _generatingUsername = false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String firstName,
    String lastName,
    String phoneNumber, {
    required DateTime birthDate,
    required String username,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? cookingSkillLevel,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _authService.register(email, password);
      final uid = credential.user!.uid;
      final user = UserModel(
        uid: uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        birthDate: birthDate,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
        activityLevel: activityLevel,
        cookingSkillLevel: cookingSkillLevel,
        username: username,
      );
      await _userService.createUser(user);
      await _userService.claimUsername(username, uid);
      _userModel = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUser() async {
    if (_firebaseUser != null) {
      _userModel = await _userService.getUser(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
