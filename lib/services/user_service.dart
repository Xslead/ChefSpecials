import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _usernamesRef =>
      _firestore.collection('usernames');

  Future<void> createUser(UserModel user) async {
    final data = user.toMap();
    data['usernameLowercase'] = user.username?.toLowerCase();
    data['fullNameLowercase'] = user.fullName.toLowerCase();
    data['firstNameLowercase'] = user.firstName.toLowerCase();
    data['lastNameLowercase'] = user.lastName.toLowerCase();
    await _usersRef.doc(user.uid).set(data);
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).update(data);
  }

  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _usernamesRef.doc(username.toLowerCase()).get();
    return !doc.exists;
  }

  Future<void> claimUsername(String username, String uid) async {
    final lowerUsername = username.toLowerCase();
    await _firestore.runTransaction((txn) async {
      final doc = await txn.get(_usernamesRef.doc(lowerUsername));
      if (doc.exists) {
        throw Exception('Username is already taken');
      }
      txn.set(_usernamesRef.doc(lowerUsername), {
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      txn.update(_usersRef.doc(uid), {
        'username': username,
        'usernameLowercase': lowerUsername,
      });
    });
  }

  Future<String> generateAndClaimUsername(
      String uid, String firstName, String lastName) async {
    final base =
        '${firstName.toLowerCase()}${lastName.toLowerCase()}'.replaceAll(RegExp(r'[^a-z0-9]'), '');
    var candidate = base.length >= 3 ? base : '${base}user';

    for (var i = 0; i < 100; i++) {
      final tryName = i == 0 ? candidate : '$candidate$i';
      final available = await isUsernameAvailable(tryName);
      if (available) {
        await claimUsername(tryName, uid);
        return tryName;
      }
    }
    // Fallback with uid suffix
    final fallback = '${candidate}_${uid.substring(0, 5)}';
    await claimUsername(fallback, uid);
    return fallback;
  }

  Future<void> migrateUsersWithoutUsernames() async {
    try {
      final allUsers = await _usersRef.get();

      for (final doc in allUsers.docs) {
        final data = doc.data();
        final uid = data['uid'] as String;
        final firstName = data['firstName'] as String? ?? '';
        final lastName = data['lastName'] as String? ?? '';

        try {
          // Generate username if missing
          if (data['username'] == null || data['username'] == '') {
            await generateAndClaimUsername(uid, firstName, lastName);
          }

          // Backfill search fields for ALL users
          final updates = <String, dynamic>{};
          final fullName = '$firstName $lastName'.trim();
          if (data['fullNameLowercase'] == null) {
            updates['fullNameLowercase'] = fullName.toLowerCase();
          }
          if (data['firstNameLowercase'] == null) {
            updates['firstNameLowercase'] = firstName.toLowerCase();
          }
          if (data['lastNameLowercase'] == null) {
            updates['lastNameLowercase'] = lastName.toLowerCase();
          }
          if (updates.isNotEmpty) {
            await _usersRef.doc(uid).update(updates);
          }
        } catch (e) {
          debugPrint('Migration: skipped $uid — $e');
        }
      }
      debugPrint('Username migration complete: ${allUsers.docs.length} users processed');
    } catch (e) {
      debugPrint('Username migration error: $e');
    }
  }

  Future<List<UserModel>> searchUsers(String query, {int limit = 10}) async {
    final q = query.toLowerCase().replaceAll('@', '').trim();
    if (q.isEmpty) return [];

    final snapshot = await _usersRef.get();
    final users = <UserModel>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final username = (data['username'] as String? ?? '').toLowerCase();
      final firstName = (data['firstName'] as String? ?? '').toLowerCase();
      final lastName = (data['lastName'] as String? ?? '').toLowerCase();
      final fullName = (data['fullName'] as String? ?? '').toLowerCase();

      if (username.contains(q) ||
          firstName.contains(q) ||
          lastName.contains(q) ||
          fullName.contains(q)) {
        users.add(UserModel.fromMap(data));
      }

      if (users.length >= limit) break;
    }

    return users;
  }
}
