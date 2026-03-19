import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  NotificationProvider({NotificationService? service})
      : _service = service ?? NotificationService();

  // Meal reminder notification IDs
  static const _breakfastId = 1001;
  static const _lunchId = 1002;
  static const _dinnerId = 1003;

  // SharedPreferences keys
  static const _keyBreakfastEnabled = 'notif_breakfast_enabled';
  static const _keyBreakfastHour = 'notif_breakfast_hour';
  static const _keyBreakfastMinute = 'notif_breakfast_minute';
  static const _keyLunchEnabled = 'notif_lunch_enabled';
  static const _keyLunchHour = 'notif_lunch_hour';
  static const _keyLunchMinute = 'notif_lunch_minute';
  static const _keyDinnerEnabled = 'notif_dinner_enabled';
  static const _keyDinnerHour = 'notif_dinner_hour';
  static const _keyDinnerMinute = 'notif_dinner_minute';
  static const _keyNewRecipeAlerts = 'notif_new_recipe_alerts';
  static const _keyCommentAlerts = 'notif_comment_alerts';
  static const _keyFollowerAlerts = 'notif_follower_alerts';

  // State
  bool _breakfastEnabled = false;
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 8, minute: 0);
  bool _lunchEnabled = false;
  TimeOfDay _lunchTime = const TimeOfDay(hour: 12, minute: 0);
  bool _dinnerEnabled = false;
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 19, minute: 0);
  bool _newRecipeAlerts = false;
  bool _commentAlerts = false;
  bool _followerAlerts = false;
  bool _isInitialized = false;
  bool _permissionDenied = false;

  // Getters
  bool get breakfastEnabled => _breakfastEnabled;
  TimeOfDay get breakfastTime => _breakfastTime;
  bool get lunchEnabled => _lunchEnabled;
  TimeOfDay get lunchTime => _lunchTime;
  bool get dinnerEnabled => _dinnerEnabled;
  TimeOfDay get dinnerTime => _dinnerTime;
  bool get newRecipeAlerts => _newRecipeAlerts;
  bool get commentAlerts => _commentAlerts;
  bool get followerAlerts => _followerAlerts;
  bool get permissionDenied => _permissionDenied;

  Future<void> init(String userId) async {
    if (_isInitialized) return;

    await _service.initialize();
    await _loadFromPrefs();

    final settings = await _service.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      _permissionDenied = true;
      _isInitialized = true;
      notifyListeners();
      return;
    }

    _permissionDenied = false;
    _isInitialized = true;

    // Save FCM token
    final token = await _service.getFcmToken();
    if (token != null) {
      await _service.saveFcmToken(userId, token);
    }

    notifyListeners();
  }

  Future<void> recheckPermission(String userId) async {
    _isInitialized = false;
    _permissionDenied = false;
    notifyListeners();
    await init(userId);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _breakfastEnabled = prefs.getBool(_keyBreakfastEnabled) ?? false;
    _breakfastTime = TimeOfDay(
      hour: prefs.getInt(_keyBreakfastHour) ?? 8,
      minute: prefs.getInt(_keyBreakfastMinute) ?? 0,
    );
    _lunchEnabled = prefs.getBool(_keyLunchEnabled) ?? false;
    _lunchTime = TimeOfDay(
      hour: prefs.getInt(_keyLunchHour) ?? 12,
      minute: prefs.getInt(_keyLunchMinute) ?? 0,
    );
    _dinnerEnabled = prefs.getBool(_keyDinnerEnabled) ?? false;
    _dinnerTime = TimeOfDay(
      hour: prefs.getInt(_keyDinnerHour) ?? 19,
      minute: prefs.getInt(_keyDinnerMinute) ?? 0,
    );
    _newRecipeAlerts = prefs.getBool(_keyNewRecipeAlerts) ?? false;
    _commentAlerts = prefs.getBool(_keyCommentAlerts) ?? false;
    _followerAlerts = prefs.getBool(_keyFollowerAlerts) ?? false;

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyBreakfastEnabled, _breakfastEnabled);
    await prefs.setInt(_keyBreakfastHour, _breakfastTime.hour);
    await prefs.setInt(_keyBreakfastMinute, _breakfastTime.minute);
    await prefs.setBool(_keyLunchEnabled, _lunchEnabled);
    await prefs.setInt(_keyLunchHour, _lunchTime.hour);
    await prefs.setInt(_keyLunchMinute, _lunchTime.minute);
    await prefs.setBool(_keyDinnerEnabled, _dinnerEnabled);
    await prefs.setInt(_keyDinnerHour, _dinnerTime.hour);
    await prefs.setInt(_keyDinnerMinute, _dinnerTime.minute);
    await prefs.setBool(_keyNewRecipeAlerts, _newRecipeAlerts);
    await prefs.setBool(_keyCommentAlerts, _commentAlerts);
    await prefs.setBool(_keyFollowerAlerts, _followerAlerts);
  }

  Future<void> toggleBreakfastReminder(bool enabled) async {
    _breakfastEnabled = enabled;
    notifyListeners();
    await _saveToPrefs();

    if (enabled) {
      await _service.scheduleMealReminder(
        id: _breakfastId,
        mealType: 'breakfast',
        title: 'Breakfast Reminder',
        body: 'Time for Breakfast!',
        hour: _breakfastTime.hour,
        minute: _breakfastTime.minute,
      );
    } else {
      await _service.cancelMealReminder(_breakfastId);
    }
  }

  Future<void> setBreakfastTime(TimeOfDay time) async {
    _breakfastTime = time;
    notifyListeners();
    await _saveToPrefs();

    if (_breakfastEnabled) {
      await _service.scheduleMealReminder(
        id: _breakfastId,
        mealType: 'breakfast',
        title: 'Breakfast Reminder',
        body: 'Time for Breakfast!',
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> toggleLunchReminder(bool enabled) async {
    _lunchEnabled = enabled;
    notifyListeners();
    await _saveToPrefs();

    if (enabled) {
      await _service.scheduleMealReminder(
        id: _lunchId,
        mealType: 'lunch',
        title: 'Lunch Reminder',
        body: 'Time for Lunch!',
        hour: _lunchTime.hour,
        minute: _lunchTime.minute,
      );
    } else {
      await _service.cancelMealReminder(_lunchId);
    }
  }

  Future<void> setLunchTime(TimeOfDay time) async {
    _lunchTime = time;
    notifyListeners();
    await _saveToPrefs();

    if (_lunchEnabled) {
      await _service.scheduleMealReminder(
        id: _lunchId,
        mealType: 'lunch',
        title: 'Lunch Reminder',
        body: 'Time for Lunch!',
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> toggleDinnerReminder(bool enabled) async {
    _dinnerEnabled = enabled;
    notifyListeners();
    await _saveToPrefs();

    if (enabled) {
      await _service.scheduleMealReminder(
        id: _dinnerId,
        mealType: 'dinner',
        title: 'Dinner Reminder',
        body: 'Time for Dinner!',
        hour: _dinnerTime.hour,
        minute: _dinnerTime.minute,
      );
    } else {
      await _service.cancelMealReminder(_dinnerId);
    }
  }

  Future<void> setDinnerTime(TimeOfDay time) async {
    _dinnerTime = time;
    notifyListeners();
    await _saveToPrefs();

    if (_dinnerEnabled) {
      await _service.scheduleMealReminder(
        id: _dinnerId,
        mealType: 'dinner',
        title: 'Dinner Reminder',
        body: 'Time for Dinner!',
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> toggleNewRecipeAlerts(bool enabled) async {
    _newRecipeAlerts = enabled;
    notifyListeners();
    await _saveToPrefs();

    if (enabled) {
      await _service.subscribeToTopic('new_recipes');
    } else {
      await _service.unsubscribeFromTopic('new_recipes');
    }
  }

  Future<void> toggleCommentAlerts(bool enabled) async {
    _commentAlerts = enabled;
    notifyListeners();
    await _saveToPrefs();

    if (enabled) {
      await _service.subscribeToTopic('comments');
    } else {
      await _service.unsubscribeFromTopic('comments');
    }
  }

  Future<void> toggleFollowerAlerts(bool enabled) async {
    _followerAlerts = enabled;
    notifyListeners();
    await _saveToPrefs();

    if (enabled) {
      await _service.subscribeToTopic('followers');
    } else {
      await _service.unsubscribeFromTopic('followers');
    }
  }
}
