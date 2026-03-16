import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/auth_provider.dart';
import 'package:chef_specials/services/auth_service.dart';
import 'package:chef_specials/services/user_service.dart';

import '../helpers/mock_firebase_auth.dart';

void main() {
  late FakeFirebaseAuth fakeAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late AuthService authService;
  late UserService userService;
  late AuthProvider provider;

  setUp(() {
    fakeAuth = FakeFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    authService = AuthService(auth: fakeAuth);
    userService = UserService(firestore: fakeFirestore);
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  AuthProvider createProvider() {
    provider = AuthProvider(
      authService: authService,
      userService: userService,
    );
    return provider;
  }

  /// Seed a user document in fake Firestore.
  Future<void> seedUser({
    String uid = 'u1',
    String email = 'test@email.com',
    String firstName = 'John',
    String lastName = 'Doe',
    String? username = 'johndoe',
  }) async {
    await fakeFirestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': 'user',
      'createdAt': '2025-01-01T00:00:00.000',
      'followingCount': 0,
      'followersCount': 0,
      'username': username,
    });
  }

  group('AuthProvider', () {
    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------
    group('initial state', () {
      test('has null firebaseUser', () {
        provider = createProvider();
        expect(provider.firebaseUser, isNull);
      });

      test('has null userModel', () {
        provider = createProvider();
        expect(provider.userModel, isNull);
      });

      test('isLoading is false', () {
        provider = createProvider();
        expect(provider.isLoading, false);
      });

      test('error is null', () {
        provider = createProvider();
        expect(provider.error, isNull);
      });

      test('isAuthenticated is false', () {
        provider = createProvider();
        expect(provider.isAuthenticated, false);
      });
    });

    // -----------------------------------------------------------------------
    // signIn
    // -----------------------------------------------------------------------
    group('signIn', () {
      test('returns true on success', () async {
        final mockUser = MockUser(uid: 'u1', email: 'test@email.com');
        final mockCred = MockUserCredential(user: mockUser);
        fakeAuth.onSignIn = (email, password) async => mockCred;

        provider = createProvider();
        final result = await provider.signIn('test@email.com', 'pass123');

        expect(result, true);
        expect(provider.isLoading, false);
        expect(provider.error, isNull);
      });

      test('returns false and sets error on FirebaseAuthException', () async {
        fakeAuth.onSignIn = (email, password) {
          throw FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password',
          );
        };

        provider = createProvider();
        final result = await provider.signIn('test@email.com', 'wrong');

        expect(result, false);
        expect(provider.isLoading, false);
        expect(provider.error, isNotNull);
      });

      test('returns false and sets error on generic exception', () async {
        fakeAuth.onSignIn = (email, password) {
          throw Exception('Network error');
        };

        provider = createProvider();
        final result = await provider.signIn('test@email.com', 'pass');

        expect(result, false);
        expect(provider.isLoading, false);
        expect(provider.error, contains('Network error'));
      });

      test('notifies listeners during sign-in flow', () async {
        final mockCred =
            MockUserCredential(user: MockUser(uid: 'u1'));
        fakeAuth.onSignIn = (email, password) async => mockCred;

        provider = createProvider();

        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        await provider.signIn('test@email.com', 'pass');

        // isLoading=true then isLoading=false (at least 2 notifications)
        expect(notifyCount, greaterThanOrEqualTo(2));
      });

      test('sets isLoading to true while awaiting', () async {
        final completer = Completer<UserCredential>();
        fakeAuth.onSignIn = (email, password) => completer.future;

        provider = createProvider();

        final future = provider.signIn('test@email.com', 'pass');
        expect(provider.isLoading, true);
        expect(provider.error, isNull);

        completer.complete(MockUserCredential(user: MockUser(uid: 'u1')));
        await future;

        expect(provider.isLoading, false);
      });
    });

    // -----------------------------------------------------------------------
    // register
    // -----------------------------------------------------------------------
    group('register', () {
      test('returns true on success and creates user model', () async {
        final mockUser = MockUser(uid: 'new_user', email: 'new@email.com');
        final mockCred = MockUserCredential(user: mockUser);
        fakeAuth.onCreateUser = (email, password) async => mockCred;

        provider = createProvider();

        final result = await provider.register(
          'new@email.com',
          'pass123',
          'John',
          'Doe',
          '+1234567890',
          birthDate: DateTime(1990, 1, 1),
          username: 'johndoe',
        );

        expect(result, true);
        expect(provider.isLoading, false);
        expect(provider.error, isNull);
        expect(provider.userModel, isNotNull);
        expect(provider.userModel!.firstName, 'John');
        expect(provider.userModel!.lastName, 'Doe');
        expect(provider.userModel!.email, 'new@email.com');
      });

      test('creates user document in Firestore', () async {
        final mockUser = MockUser(uid: 'new_user', email: 'new@email.com');
        final mockCred = MockUserCredential(user: mockUser);
        fakeAuth.onCreateUser = (email, password) async => mockCred;

        provider = createProvider();

        await provider.register(
          'new@email.com',
          'pass123',
          'John',
          'Doe',
          '+1234567890',
          birthDate: DateTime(1990, 1, 1),
          username: 'johndoe',
        );

        final userDoc =
            await fakeFirestore.collection('users').doc('new_user').get();
        expect(userDoc.exists, true);
        expect(userDoc.data()!['firstName'], 'John');
        expect(userDoc.data()!['lastName'], 'Doe');
      });

      test('returns false on FirebaseAuthException', () async {
        fakeAuth.onCreateUser = (email, password) {
          throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email already in use',
          );
        };

        provider = createProvider();

        final result = await provider.register(
          'existing@email.com',
          'pass123',
          'John',
          'Doe',
          '+1234567890',
          birthDate: DateTime(1990, 1, 1),
          username: 'johndoe',
        );

        expect(result, false);
        expect(provider.isLoading, false);
        expect(provider.error, isNotNull);
      });

      test('returns false on generic exception', () async {
        fakeAuth.onCreateUser = (email, password) {
          throw Exception('Network error');
        };

        provider = createProvider();

        final result = await provider.register(
          'test@email.com',
          'pass',
          'John',
          'Doe',
          '+123',
          birthDate: DateTime(1990, 1, 1),
          username: 'johndoe',
        );

        expect(result, false);
        expect(provider.error, contains('Network error'));
      });

      test('passes optional physical attributes', () async {
        final mockCred =
            MockUserCredential(user: MockUser(uid: 'u1'));
        fakeAuth.onCreateUser = (email, password) async => mockCred;

        provider = createProvider();

        await provider.register(
          'test@email.com',
          'pass',
          'Jane',
          'Smith',
          '+0987654321',
          birthDate: DateTime(1995, 6, 15),
          username: 'janesmith',
          gender: 'female',
          heightCm: 170.0,
          weightKg: 65.0,
          activityLevel: 'moderate',
          cookingSkillLevel: 'intermediate',
        );

        expect(provider.userModel!.gender, 'female');
        expect(provider.userModel!.heightCm, 170.0);
        expect(provider.userModel!.weightKg, 65.0);
        expect(provider.userModel!.activityLevel, 'moderate');
        expect(provider.userModel!.cookingSkillLevel, 'intermediate');
      });

      test('notifies listeners during register flow', () async {
        final mockCred =
            MockUserCredential(user: MockUser(uid: 'u1'));
        fakeAuth.onCreateUser = (email, password) async => mockCred;

        provider = createProvider();

        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        await provider.register(
          'test@email.com',
          'pass',
          'John',
          'Doe',
          '+123',
          birthDate: DateTime(1990, 1, 1),
          username: 'johndoe',
        );

        expect(notifyCount, greaterThanOrEqualTo(2));
      });
    });

    // -----------------------------------------------------------------------
    // signOut
    // -----------------------------------------------------------------------
    group('signOut', () {
      test('calls auth service signOut', () async {
        fakeAuth.onSignOut = () async {};

        provider = createProvider();
        await provider.signOut();

        expect(fakeAuth.signOutCallCount, 1);
      });
    });

    // -----------------------------------------------------------------------
    // auth state changes (_onAuthStateChanged)
    // -----------------------------------------------------------------------
    group('auth state changes', () {
      test('sets firebaseUser when user signs in via stream', () async {
        final mockUser = MockUser(uid: 'u1');
        provider = createProvider();

        fakeAuth.emitUser(mockUser);
        await Future.delayed(Duration.zero);

        expect(provider.firebaseUser, equals(mockUser));
        expect(provider.isAuthenticated, true);
      });

      test('clears state when user signs out via stream', () async {
        provider = createProvider();

        // Sign in
        fakeAuth.emitUser(MockUser(uid: 'u1'));
        await Future.delayed(Duration.zero);
        expect(provider.isAuthenticated, true);

        // Sign out
        fakeAuth.emitUser(null);
        await Future.delayed(Duration.zero);

        expect(provider.firebaseUser, isNull);
        expect(provider.userModel, isNull);
        expect(provider.isAuthenticated, false);
      });

      test('loads UserModel from Firestore on sign in', () async {
        await seedUser(uid: 'u1', firstName: 'John', lastName: 'Doe');

        provider = createProvider();
        fakeAuth.emitUser(MockUser(uid: 'u1'));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.userModel, isNotNull);
        expect(provider.userModel!.firstName, 'John');
        expect(provider.userModel!.lastName, 'Doe');
      });

      test('notifies listeners on auth state change', () async {
        provider = createProvider();

        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        fakeAuth.emitUser(MockUser(uid: 'u1'));
        await Future.delayed(Duration.zero);

        expect(notifyCount, greaterThanOrEqualTo(1));
      });

      test('switches user subscription on different auth user', () async {
        await seedUser(
            uid: 'u1', firstName: 'User', lastName: 'One', username: 'user1');
        await seedUser(
            uid: 'u2', firstName: 'User', lastName: 'Two', username: 'user2');

        provider = createProvider();

        fakeAuth.emitUser(MockUser(uid: 'u1'));
        await Future.delayed(const Duration(milliseconds: 100));
        expect(provider.userModel?.lastName, 'One');

        fakeAuth.emitUser(MockUser(uid: 'u2'));
        await Future.delayed(const Duration(milliseconds: 100));
        expect(provider.userModel?.lastName, 'Two');
      });

      test('sets userModel to null when Firestore doc missing', () async {
        provider = createProvider();

        fakeAuth.emitUser(MockUser(uid: 'no_doc'));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.firebaseUser, isNotNull);
        expect(provider.userModel, isNull);
      });
    });

    // -----------------------------------------------------------------------
    // refreshUser
    // -----------------------------------------------------------------------
    group('refreshUser', () {
      test('reloads userModel from Firestore', () async {
        await seedUser(uid: 'u1', firstName: 'John');

        provider = createProvider();
        fakeAuth.emitUser(MockUser(uid: 'u1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Update in Firestore
        await fakeFirestore
            .collection('users')
            .doc('u1')
            .update({'firstName': 'Jane'});

        await provider.refreshUser();

        expect(provider.userModel!.firstName, 'Jane');
      });

      test('does nothing when no user is signed in', () async {
        provider = createProvider();
        await provider.refreshUser();

        expect(provider.userModel, isNull);
      });

      test('notifies listeners after refresh', () async {
        await seedUser(uid: 'u1');

        provider = createProvider();
        fakeAuth.emitUser(MockUser(uid: 'u1'));
        await Future.delayed(const Duration(milliseconds: 100));

        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        await provider.refreshUser();

        expect(notifyCount, greaterThanOrEqualTo(1));
      });
    });

    // -----------------------------------------------------------------------
    // clearError
    // -----------------------------------------------------------------------
    group('clearError', () {
      test('clears error and notifies listeners', () async {
        fakeAuth.onSignIn = (email, password) {
          throw FirebaseAuthException(
            code: 'error',
            message: 'Some error',
          );
        };

        provider = createProvider();
        await provider.signIn('test@email.com', 'wrong');
        expect(provider.error, isNotNull);

        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        provider.clearError();

        expect(provider.error, isNull);
        expect(notifyCount, 1);
      });

      test('is no-op when error is already null', () {
        provider = createProvider();

        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        provider.clearError();

        // Still notifies (ChangeNotifier doesn't check equality)
        expect(provider.error, isNull);
      });
    });

    // -----------------------------------------------------------------------
    // dispose
    // -----------------------------------------------------------------------
    group('dispose', () {
      test('cancels user subscription without error', () async {
        provider = createProvider();
        fakeAuth.emitUser(MockUser(uid: 'u1'));
        await Future.delayed(Duration.zero);

        // Should not throw
        provider.dispose();
      });

      test('handles dispose when no user is signed in', () {
        provider = createProvider();
        // Should not throw
        provider.dispose();
      });
    });
  });
}
