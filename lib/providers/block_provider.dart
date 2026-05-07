import 'package:flutter/material.dart';
import '../services/block_service.dart';

class BlockProvider extends ChangeNotifier {
  final BlockService _service;

  BlockProvider({BlockService? blockService})
      : _service = blockService ?? BlockService();

  List<String> _blockedUserIds = [];
  String? _userId;

  List<String> get blockedUserIds => _blockedUserIds;

  bool isBlocked(String userId) => _blockedUserIds.contains(userId);

  Future<void> initialize(String userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _blockedUserIds = [];
    try {
      _blockedUserIds = await _service.getBlockedUserIds(userId);
    } catch (_) {}
    notifyListeners();
  }

  void reset() {
    _userId = null;
    _blockedUserIds = [];
    notifyListeners();
  }

  Future<void> blockUser(String targetUserId) async {
    if (_userId == null || _blockedUserIds.contains(targetUserId)) return;
    await _service.blockUser(_userId!, targetUserId);
    _blockedUserIds = [..._blockedUserIds, targetUserId];
    notifyListeners();
  }

  Future<void> unblockUser(String targetUserId) async {
    if (_userId == null) return;
    await _service.unblockUser(_userId!, targetUserId);
    _blockedUserIds =
        _blockedUserIds.where((id) => id != targetUserId).toList();
    notifyListeners();
  }
}
