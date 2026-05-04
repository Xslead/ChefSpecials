import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_log.dart';
import '../models/food_item.dart';
import '../models/recipe.dart';

class CacheService {
  static const _recipesBox = 'recipes';
  static const _foodItemsBox = 'food_items';
  static const _dailyLogsBox = 'daily_logs';
  static const _offlineQueueBox = 'offline_queue';

  bool _initialized = false;

  Future<void> initialize({String? hivePath}) async {
    if (_initialized) return;
    if (hivePath != null) {
      Hive.init(hivePath);
    } else {
      await Hive.initFlutter();
    }
    await Future.wait([
      Hive.openBox<String>(_recipesBox),
      Hive.openBox<String>(_foodItemsBox),
      Hive.openBox<String>(_dailyLogsBox),
      Hive.openBox<String>(_offlineQueueBox),
    ]);
    _initialized = true;
  }

  // Recipes
  Future<void> cacheRecipes(List<Recipe> recipes) async {
    if (!_initialized) return;
    final box = Hive.box<String>(_recipesBox);
    await box.clear();
    final encoded = <String, String>{
      for (final r in recipes)
        if (r.id != null) r.id!: jsonEncode({...r.toMap(), 'id': r.id})
    };
    await box.putAll(encoded);
  }

  List<Recipe> getCachedRecipes() {
    if (!_initialized) return [];
    final box = Hive.box<String>(_recipesBox);
    return box.values.map((json) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final id = map['id'] as String? ?? '';
        return Recipe.fromMap(map, id);
      } catch (e) {
        debugPrint('CacheService: failed to decode recipe: $e');
        return null;
      }
    }).whereType<Recipe>().toList();
  }

  // Food Items
  Future<void> cacheFoodItems(List<FoodItem> items) async {
    if (!_initialized) return;
    final box = Hive.box<String>(_foodItemsBox);
    await box.clear();
    final encoded = <String, String>{
      for (final f in items)
        if (f.id != null) f.id!: jsonEncode({...f.toMap(), 'id': f.id})
    };
    await box.putAll(encoded);
  }

  List<FoodItem> getCachedFoodItems() {
    if (!_initialized) return [];
    final box = Hive.box<String>(_foodItemsBox);
    return box.values.map((json) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final id = map['id'] as String? ?? '';
        return FoodItem.fromMap(map, id);
      } catch (e) {
        debugPrint('CacheService: failed to decode food item: $e');
        return null;
      }
    }).whereType<FoodItem>().toList();
  }

  // Daily Logs — keyed by date string "yyyy-MM-dd"
  Future<void> cacheDailyLog(DailyLog log) async {
    if (!_initialized) return;
    final box = Hive.box<String>(_dailyLogsBox);
    await box.put(log.date, jsonEncode({...log.toMap(), 'id': log.id ?? ''}));
  }

  DailyLog? getCachedDailyLog(String dateString) {
    if (!_initialized) return null;
    final box = Hive.box<String>(_dailyLogsBox);
    final json = box.get(dateString);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final id = map['id'] as String? ?? '';
      return DailyLog.fromMap(map, id);
    } catch (e) {
      debugPrint('CacheService: failed to decode daily log: $e');
      return null;
    }
  }

  // Offline Queue
  Future<void> queueOfflineAction(Map<String, dynamic> action) async {
    if (!_initialized) return;
    final box = Hive.box<String>(_offlineQueueBox);
    await box.add(jsonEncode(action));
  }

  List<Map<String, dynamic>> getOfflineQueue() {
    if (!_initialized) return [];
    final box = Hive.box<String>(_offlineQueueBox);
    return box.values.map((json) {
      try {
        return jsonDecode(json) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }).whereType<Map<String, dynamic>>().toList();
  }

  Future<void> clearOfflineQueue() async {
    if (!_initialized) return;
    await Hive.box<String>(_offlineQueueBox).clear();
  }

  // Returns approximate cache size in bytes (JSON string lengths)
  int getCacheSize() {
    if (!_initialized) return 0;
    int bytes = 0;
    for (final name in [_recipesBox, _foodItemsBox, _dailyLogsBox]) {
      final box = Hive.box<String>(name);
      for (final v in box.values) {
        bytes += v.length;
      }
    }
    return bytes;
  }

  Future<void> clearAllCaches() async {
    if (!_initialized) return;
    await Hive.box<String>(_recipesBox).clear();
    await Hive.box<String>(_foodItemsBox).clear();
    await Hive.box<String>(_dailyLogsBox).clear();
    await Hive.box<String>(_offlineQueueBox).clear();
  }
}
