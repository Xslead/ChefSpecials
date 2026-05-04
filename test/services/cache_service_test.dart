import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:chef_specials/models/daily_log.dart';
import 'package:chef_specials/models/food_item.dart';
import 'package:chef_specials/models/ingredient.dart';
import 'package:chef_specials/models/meal_entry.dart';
import 'package:chef_specials/models/recipe.dart';
import 'package:chef_specials/models/recipe_step.dart';
import 'package:chef_specials/services/cache_service.dart';

void main() {
  late CacheService cacheService;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    cacheService = CacheService();
    await cacheService.initialize(hivePath: tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Recipe _makeRecipe(String id) => Recipe(
        id: id,
        title: 'Test Recipe $id',
        description: 'desc',
        authorId: 'user1',
        authorName: 'Chef',
        category: 'Dinner',
        servings: 2,
        prepTimeMinutes: 10,
        cookTimeMinutes: 20,
        ingredients: [
          Ingredient(name: 'Salt', amount: '1', unit: 'g'),
        ],
        steps: [
          RecipeStep(order: 1, instruction: 'Cook'),
        ],
        createdAt: DateTime(2024, 1, 1),
      );

  FoodItem _makeFoodItem(String id) => FoodItem(
        id: id,
        name: 'Test Food $id',
        category: 'Grains',
        unit: '100g',
        packetSize: 100,
        calories: 300,
        protein: 10,
        carbs: 50,
        fat: 5,
        fiber: 3,
        sugar: 5,
        sodium: 100,
        addedBy: 'user1',
        createdAt: DateTime(2024, 1, 1),
      );

  DailyLog _makeDailyLog(String date) => DailyLog(
        id: 'log_$date',
        userId: 'user1',
        date: date,
        meals: [
          MealEntry(
            name: 'Oats',
            mealType: MealType.breakfast,
            quantity: 100,
            unit: 'g',
            calories: 300,
            protein: 10,
            carbs: 50,
            fat: 5,
          ),
        ],
      );

  group('cacheRecipes / getCachedRecipes', () {
    test('stores and retrieves recipes', () async {
      final recipes = [_makeRecipe('r1'), _makeRecipe('r2')];
      await cacheService.cacheRecipes(recipes);

      final cached = cacheService.getCachedRecipes();
      expect(cached, hasLength(2));
      expect(cached.map((r) => r.id), containsAll(['r1', 'r2']));
    });

    test('clears previous cache on re-cache', () async {
      await cacheService.cacheRecipes([_makeRecipe('old')]);
      await cacheService.cacheRecipes([_makeRecipe('new1'), _makeRecipe('new2')]);

      final cached = cacheService.getCachedRecipes();
      expect(cached.map((r) => r.id), isNot(contains('old')));
      expect(cached, hasLength(2));
    });

    test('returns empty list when nothing cached', () {
      expect(cacheService.getCachedRecipes(), isEmpty);
    });
  });

  group('cacheFoodItems / getCachedFoodItems', () {
    test('stores and retrieves food items', () async {
      final items = [_makeFoodItem('f1'), _makeFoodItem('f2')];
      await cacheService.cacheFoodItems(items);

      final cached = cacheService.getCachedFoodItems();
      expect(cached, hasLength(2));
      expect(cached.map((f) => f.id), containsAll(['f1', 'f2']));
    });

    test('returns empty list when nothing cached', () {
      expect(cacheService.getCachedFoodItems(), isEmpty);
    });
  });

  group('cacheDailyLog / getCachedDailyLog', () {
    test('stores and retrieves a daily log', () async {
      final log = _makeDailyLog('2024-01-15');
      await cacheService.cacheDailyLog(log);

      final cached = cacheService.getCachedDailyLog('2024-01-15');
      expect(cached, isNotNull);
      expect(cached!.date, '2024-01-15');
      expect(cached.meals, hasLength(1));
    });

    test('returns null for an uncached date', () {
      expect(cacheService.getCachedDailyLog('2024-12-31'), isNull);
    });

    test('overwrites existing log for same date', () async {
      await cacheService.cacheDailyLog(_makeDailyLog('2024-01-15'));
      final updated = DailyLog(id: 'log2', userId: 'user1', date: '2024-01-15', meals: []);
      await cacheService.cacheDailyLog(updated);

      final cached = cacheService.getCachedDailyLog('2024-01-15');
      expect(cached!.meals, isEmpty);
    });
  });

  group('queueOfflineAction / getOfflineQueue / clearOfflineQueue', () {
    test('queues and retrieves actions', () async {
      await cacheService.queueOfflineAction({'type': 'add_meal_entry', 'date': '2024-01-15'});
      await cacheService.queueOfflineAction({'type': 'create_recipe', 'id': 'r1'});

      final queue = cacheService.getOfflineQueue();
      expect(queue, hasLength(2));
      expect(queue.first['type'], 'add_meal_entry');
    });

    test('clearOfflineQueue removes all actions', () async {
      await cacheService.queueOfflineAction({'type': 'test'});
      await cacheService.clearOfflineQueue();

      expect(cacheService.getOfflineQueue(), isEmpty);
    });

    test('returns empty list when queue is empty', () {
      expect(cacheService.getOfflineQueue(), isEmpty);
    });
  });

  group('getCacheSize', () {
    test('returns 0 when caches are empty', () {
      expect(cacheService.getCacheSize(), 0);
    });

    test('returns positive value after caching data', () async {
      await cacheService.cacheRecipes([_makeRecipe('r1')]);
      expect(cacheService.getCacheSize(), greaterThan(0));
    });
  });

  group('clearAllCaches', () {
    test('clears all cached data', () async {
      await cacheService.cacheRecipes([_makeRecipe('r1')]);
      await cacheService.cacheFoodItems([_makeFoodItem('f1')]);
      await cacheService.cacheDailyLog(_makeDailyLog('2024-01-15'));

      await cacheService.clearAllCaches();

      expect(cacheService.getCachedRecipes(), isEmpty);
      expect(cacheService.getCachedFoodItems(), isEmpty);
      expect(cacheService.getCachedDailyLog('2024-01-15'), isNull);
      expect(cacheService.getCacheSize(), 0);
    });
  });
}
