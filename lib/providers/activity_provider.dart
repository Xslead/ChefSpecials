import 'dart:async';

import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../services/activity_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _service;
  ActivityProvider({ActivityService? service})
      : _service = service ?? ActivityService();

  List<Activity> _activities = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _userId;
  StreamSubscription? _activitiesSubscription;
  StreamSubscription? _unreadSubscription;

  List<Activity> get activities => _activities;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _listen();
    // Clean up old activities silently — don't block init
    _service.deleteOldActivities(userId).catchError((_) {});
  }

  void _listen() {
    _activitiesSubscription?.cancel();
    _unreadSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    _activitiesSubscription =
        _service.getActivitiesStream(_userId!).listen(
      (activities) {
        _activities = activities;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );

    _unreadSubscription =
        _service.getUnreadCount(_userId!).listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  void refresh() {
    if (_userId == null) return;
    _listen();
  }

  void markAsRead(String activityId) {
    _service.markAsRead(activityId);
  }

  void markAsUnread(String activityId) {
    _service.markAsUnread(activityId);
  }

  void markAllAsRead() {
    if (_userId == null) return;
    _service.markAllAsRead(_userId!);
  }

  Future<void> createCommentActivity({
    required String recipeAuthorId,
    required String actorId,
    required String actorName,
    String? actorAvatar,
    required String recipeId,
    required String recipeName,
    String? recipeImageUrl,
    required String commentText,
    int? stars,
  }) async {
    await _service.createCommentActivity(
      recipeAuthorId: recipeAuthorId,
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
      recipeId: recipeId,
      recipeName: recipeName,
      recipeImageUrl: recipeImageUrl,
      commentText: commentText,
      stars: stars,
    );
  }

  Future<void> createRatingActivity({
    required String recipeAuthorId,
    required String actorId,
    required String actorName,
    String? actorAvatar,
    required String recipeId,
    required String recipeName,
    String? recipeImageUrl,
    required int stars,
  }) async {
    await _service.createRatingActivity(
      recipeAuthorId: recipeAuthorId,
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
      recipeId: recipeId,
      recipeName: recipeName,
      recipeImageUrl: recipeImageUrl,
      stars: stars,
    );
  }

  Future<void> createNewRecipeActivity({
    required String recipeId,
    required String recipeName,
    String? recipeImageUrl,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required List<String> followerIds,
  }) async {
    await _service.createNewRecipeActivity(
      recipeId: recipeId,
      recipeName: recipeName,
      recipeImageUrl: recipeImageUrl,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      followerIds: followerIds,
    );
  }

  @override
  void dispose() {
    _activitiesSubscription?.cancel();
    _unreadSubscription?.cancel();
    super.dispose();
  }
}
