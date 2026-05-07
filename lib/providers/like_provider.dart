import 'package:flutter/material.dart';
import '../services/like_service.dart';

class LikeProvider extends ChangeNotifier {
  final LikeService _service;

  LikeProvider({LikeService? likeService})
      : _service = likeService ?? LikeService();

  Set<String> _likedRecipeIds = {};
  String? _userId;
  final Set<String> _inFlight = {};

  bool isLiked(String recipeId) => _likedRecipeIds.contains(recipeId);
  bool isInFlight(String recipeId) => _inFlight.contains(recipeId);

  Future<void> initialize(String userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _likedRecipeIds = {};
    try {
      final ids = await _service.getLikedRecipeIds(userId);
      _likedRecipeIds = Set.from(ids);
    } catch (_) {}
    notifyListeners();
  }

  void reset() {
    _userId = null;
    _likedRecipeIds = {};
    _inFlight.clear();
    notifyListeners();
  }

  Future<void> toggleLike(String recipeId, String userId) async {
    if (_inFlight.contains(recipeId)) return;
    final current = _likedRecipeIds.contains(recipeId);
    // Optimistic update
    if (current) {
      _likedRecipeIds.remove(recipeId);
    } else {
      _likedRecipeIds.add(recipeId);
    }
    _inFlight.add(recipeId);
    notifyListeners();
    try {
      await _service.toggleLike(recipeId, userId);
    } catch (_) {
      // Revert on error
      if (current) {
        _likedRecipeIds.add(recipeId);
      } else {
        _likedRecipeIds.remove(recipeId);
      }
    } finally {
      _inFlight.remove(recipeId);
      notifyListeners();
    }
  }
}
