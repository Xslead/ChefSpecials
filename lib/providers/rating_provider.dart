import 'package:flutter/material.dart';
import '../models/rating.dart';
import '../services/rating_service.dart';

class RatingProvider extends ChangeNotifier {
  final RatingService _service;

  RatingProvider({RatingService? ratingService})
      : _service = ratingService ?? RatingService();

  Rating? _userRating; // existing saved rating (null = never rated)
  int _displayStars = 0; // local selection shown in the star widget

  Rating? get userRating => _userRating;
  int get displayStars => _displayStars;

  Future<void> loadUserRating(String recipeId, String userId) async {
    _userRating = await _service.getUserRating(recipeId, userId);
    _displayStars = _userRating?.stars ?? 0;
    notifyListeners();
  }

  /// Updates the local star selection without touching Firestore.
  void selectStars(int stars) {
    _displayStars = stars;
    notifyListeners();
  }

  /// Saves the current [_displayStars] to Firestore.
  /// Should only be called when [userRating] is null (first-time submit).
  Future<void> submitRating({
    required String recipeId,
    required String userId,
  }) async {
    if (_displayStars == 0) return;

    await _service.setRating(
      recipeId: recipeId,
      userId: userId,
      stars: _displayStars,
    );

    // Persist locally so UI knows the user has already rated
    _userRating = Rating(
      id: '${recipeId}_$userId',
      recipeId: recipeId,
      userId: userId,
      stars: _displayStars,
      createdAt: DateTime.now(),
    );
    // Keep displayStars at the saved value (shows read-only stars)
    notifyListeners();
  }

  Future<void> deleteRating({
    required String recipeId,
    required String userId,
  }) async {
    if (_userRating == null) return;
    final previous = _userRating!;

    // Optimistic
    _userRating = null;
    _displayStars = 0;
    notifyListeners();

    try {
      await _service.deleteRating(recipeId: recipeId, userId: userId);
    } catch (_) {
      _userRating = previous;
      _displayStars = previous.stars;
      notifyListeners();
      rethrow;
    }
  }
}
