import 'package:flutter/foundation.dart';
import '../models/daily_log.dart';
import '../models/meal_entry.dart';
import '../models/recipe.dart';
import 'cache_service.dart';
import 'daily_tracker_service.dart';
import 'food_item_service.dart';
import 'recipe_service.dart';

class SyncService {
  final RecipeService _recipeService;
  final FoodItemService _foodItemService;
  final DailyTrackerService _dailyTrackerService;
  final CacheService _cacheService;

  SyncService({
    RecipeService? recipeService,
    FoodItemService? foodItemService,
    DailyTrackerService? dailyTrackerService,
    CacheService? cacheService,
  })  : _recipeService = recipeService ?? RecipeService(),
        _foodItemService = foodItemService ?? FoodItemService(),
        _dailyTrackerService = dailyTrackerService ?? DailyTrackerService(),
        _cacheService = cacheService ?? CacheService();

  // Replays the offline queue against Firestore.
  // Successful actions are removed; failed actions are re-queued.
  Future<void> syncOfflineQueue(String userId) async {
    final queue = _cacheService.getOfflineQueue();
    if (queue.isEmpty) return;

    final failed = <Map<String, dynamic>>[];
    for (final action in queue) {
      try {
        await _processAction(userId, action);
      } catch (e) {
        debugPrint('SyncService: failed to replay action: $e');
        failed.add(action);
      }
    }

    await _cacheService.clearOfflineQueue();
    for (final action in failed) {
      await _cacheService.queueOfflineAction(action);
    }
  }

  Future<void> _processAction(
      String userId, Map<String, dynamic> action) async {
    final type = action['type'] as String?;
    switch (type) {
      case 'add_meal_entry':
        final dateString = action['dateString'] as String;
        final entryMap = action['entry'] as Map<String, dynamic>;
        final entry = MealEntry.fromMap(entryMap);
        final existingLog =
            await _dailyTrackerService.getDailyLog(userId, dateString).first;
        if (existingLog != null && existingLog.id != null) {
          final meals = List<MealEntry>.from(existingLog.meals)..add(entry);
          await _dailyTrackerService.updateDailyLog(
              existingLog.id!, existingLog.copyWith(meals: meals));
        } else {
          final newLog =
              DailyLog(userId: userId, date: dateString, meals: [entry]);
          await _dailyTrackerService.createDailyLog(newLog);
        }
      case 'create_recipe':
        final recipeMap = action['recipe'] as Map<String, dynamic>;
        final recipe =
            Recipe.fromMap(recipeMap, recipeMap['id'] as String? ?? '');
        await _recipeService.createRecipe(recipe);
    }
  }

  // Downloads all publicly visible data and stores it in the local cache.
  Future<void> fullSync(String userId) async {
    try {
      final recipes = await _recipeService.getRecipesStream().first;
      await _cacheService.cacheRecipes(recipes);
    } catch (e) {
      debugPrint('SyncService: recipe sync failed: $e');
    }

    try {
      final foodItems = await _foodItemService.getFoodItems().first;
      await _cacheService.cacheFoodItems(foodItems);
    } catch (e) {
      debugPrint('SyncService: food item sync failed: $e');
    }
  }
}
