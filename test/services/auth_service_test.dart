import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/auth_service.dart';

import '../helpers/mock_firebase_auth.dart';

void main() {
  late FakeFirebaseAuth fakeAuth;
  late AuthService service;

  setUp(() {
    fakeAuth = FakeFirebaseAuth();
    service = AuthService(auth: fakeAuth);
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  group('AuthService', () {
    // -----------------------------------------------------------------------
    // currentUser
    // -----------------------------------------------------------------------
    group('currentUser', () {
      test('returns null when no user is signed in', () {
        expect(service.currentUser, isNull);
      });

      test('returns user when signed in', () {
        final user = MockUser(uid: 'u1');
        fakeAuth.emitUser(user);
        expect(service.currentUser, equals(user));
        expect(service.currentUser!.uid, 'u1');
      });
    });

    // -----------------------------------------------------------------------
    // authStateChanges
    // -----------------------------------------------------------------------
    group('authStateChanges', () {
      test('emits user on auth state change', () {
        final user = MockUser(uid: 'u1');

        expectLater(
          service.authStateChanges,
          emitsInOrder([null, user]),
        );

        fakeAuth.emitUser(null);
        fakeAuth.emitUser(user);
      });

      test('emits null on sign out', () {
        expectLater(
          service.authStateChanges,
          emits(null),
        );

        fakeAuth.emitUser(null);
      });
    });

    // -----------------------------------------------------------------------
    // signIn
    // -----------------------------------------------------------------------
    group('signIn', () {
      test('returns credential on success', () async {
        final mockUser = MockUser(uid: 'u1');
        final mockCred = MockUserCredential(user: mockUser);

        fakeAuth.onSignIn = (email, password) async => mockCred;

        final result = await service.signIn('test@email.com', 'password123');
        expect(result.user!.uid, 'u1');
        expect(fakeAuth.signInCallCount, 1);
      });

      test('propagates FirebaseAuthException on wrong password', () {
        fakeAuth.onSignIn = (email, password) {
          throw FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password',
          );
        };

        expect(
          () => service.signIn('test@email.com', 'wrong'),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('propagates FirebaseAuthException for user not found', () {
        fakeAuth.onSignIn = (email, password) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          );
        };

        expect(
          () => service.signIn('missing@email.com', 'pass'),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    // -----------------------------------------------------------------------
    // register
    // -----------------------------------------------------------------------
    group('register', () {
      test('returns credential on success', () async {
        final mockUser = MockUser(uid: 'new_uid');
        final mockCred = MockUserCredential(user: mockUser);

        fakeAuth.onCreateUser = (email, password) async => mockCred;

        final result = await service.register('new@email.com', 'pass123');
        expect(result.user!.uid, 'new_uid');
        expect(fakeAuth.createUserCallCount, 1);
      });

      test('propagates FirebaseAuthException for duplicate email', () {
        fakeAuth.onCreateUser = (email, password) {
          throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email already in use',
          );
        };

        expect(
          () => service.register('existing@email.com', 'pass'),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('propagates FirebaseAuthException for weak password', () {
        fakeAuth.onCreateUser = (email, password) {
          throw FirebaseAuthException(
            code: 'weak-password',
            message: 'Password is too weak',
          );
        };

        expect(
          () => service.register('test@email.com', '123'),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    // -----------------------------------------------------------------------
    // sendPasswordResetEmail
    // -----------------------------------------------------------------------
    group('sendPasswordResetEmail', () {
      test('calls Firebase sendPasswordResetEmail', () async {
        fakeAuth.onSendPasswordReset = (email) async {};

        await service.sendPasswordResetEmail('test@email.com');
        expect(fakeAuth.sendPasswordResetCallCount, 1);
      });

      test('propagates exception for unknown email', () {
        fakeAuth.onSendPasswordReset = (email) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          );
        };

        expect(
          () => service.sendPasswordResetEmail('unknown@email.com'),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    // -----------------------------------------------------------------------
    // signOut
    // -----------------------------------------------------------------------
    group('signOut', () {
      test('calls Firebase signOut', () async {
        fakeAuth.onSignOut = () async {};

        await service.signOut();
        expect(fakeAuth.signOutCallCount, 1);
      });
    });
  });
}
