import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

/// Controllable fake for [FirebaseAuth] with callback-based behaviour.
/// Use [emitUser] to push auth state changes. Assign handler callbacks
/// (e.g. [onSignIn]) to control method responses.
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final _authStateController = StreamController<User?>.broadcast();
  User? _currentUser;

  // ----- configurable handlers -----
  Future<UserCredential> Function(String email, String password)? onSignIn;
  Future<UserCredential> Function(String email, String password)? onCreateUser;
  Future<void> Function(String email)? onSendPasswordReset;
  Future<void> Function()? onSignOut;

  // ----- call tracking -----
  int signInCallCount = 0;
  int createUserCallCount = 0;
  int sendPasswordResetCallCount = 0;
  int signOutCallCount = 0;

  // ----- overrides -----
  @override
  Stream<User?> authStateChanges() => _authStateController.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    signInCallCount++;
    if (onSignIn != null) return onSignIn!(email, password);
    throw UnimplementedError('onSignIn handler not set');
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    createUserCallCount++;
    if (onCreateUser != null) return onCreateUser!(email, password);
    throw UnimplementedError('onCreateUser handler not set');
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    sendPasswordResetCallCount++;
    if (onSendPasswordReset != null) return onSendPasswordReset!(email);
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    if (onSignOut != null) return onSignOut!();
  }

  /// Push a new auth state (sign-in / sign-out).
  void emitUser(User? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  void dispose() {
    _authStateController.close();
  }
}

/// Minimal mock [User] – only [uid] and [email] are needed by AuthProvider.
class MockUser extends Mock implements User {
  final String _uid;
  final String? _email;

  MockUser({String uid = 'test_uid', String? email = 'test@email.com'})
      : _uid = uid,
        _email = email;

  @override
  String get uid => _uid;

  @override
  String? get email => _email;
}

/// Mock [UserCredential] that wraps a [MockUser].
class MockUserCredential extends Mock implements UserCredential {
  final User? _user;

  MockUserCredential({User? user}) : _user = user;

  @override
  User? get user => _user;
}
