import 'dart:async';
import 'package:flutter/material.dart';
import '../services/follow_service.dart';

class FollowProvider extends ChangeNotifier {
  final FollowService _service = FollowService();

  Set<String> _followingIds = {};
  String? _currentUserId;
  StreamSubscription<List<String>>? _sub;

  Set<String> get followingIds => _followingIds;
  List<String> get followingList => _followingIds.toList();
  bool isFollowing(String uid) => _followingIds.contains(uid);

  void initialize(String currentUserId) {
    if (_currentUserId == currentUserId) return;
    _currentUserId = currentUserId;
    _sub?.cancel();
    _sub = _service.watchFollowingIds(currentUserId).listen((ids) {
      _followingIds = ids.toSet();
      notifyListeners();
    });
  }

  Future<void> follow(String targetId) async {
    if (_currentUserId == null) return;
    // Optimistic update — create a new set so reference changes
    _followingIds = {..._followingIds, targetId};
    notifyListeners();
    try {
      await _service.follow(_currentUserId!, targetId);
    } catch (_) {
      _followingIds = _followingIds.difference({targetId});
      notifyListeners();
    }
  }

  Future<void> unfollow(String targetId) async {
    if (_currentUserId == null) return;
    // Optimistic update — create a new set so reference changes
    _followingIds = _followingIds.difference({targetId});
    notifyListeners();
    try {
      await _service.unfollow(_currentUserId!, targetId);
    } catch (_) {
      _followingIds = {..._followingIds, targetId};
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
