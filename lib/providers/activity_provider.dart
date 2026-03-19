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
    _service.deleteOldActivities(userId);
  }

  void _listen() {
    _activitiesSubscription?.cancel();
    _unreadSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    _activitiesSubscription =
        _service.getActivitiesStream(_userId!).listen((activities) {
      _activities = activities;
      _isLoading = false;
      notifyListeners();
    });

    _unreadSubscription =
        _service.getUnreadCount(_userId!).listen((count) {
      _unreadCount = count;
      notifyListeners();
    });
  }

  void markAllAsRead() {
    if (_userId == null) return;
    _service.markAllAsRead(_userId!);
  }

  @override
  void dispose() {
    _activitiesSubscription?.cancel();
    _unreadSubscription?.cancel();
    super.dispose();
  }
}
