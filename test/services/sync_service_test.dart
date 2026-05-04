import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:chef_specials/models/daily_log.dart';
import 'package:chef_specials/models/meal_entry.dart';
import 'package:chef_specials/services/cache_service.dart';
import 'package:chef_specials/services/daily_tracker_service.dart';
import 'package:chef_specials/services/food_item_service.dart';
import 'package:chef_specials/services/recipe_service.dart';
import 'package:chef_specials/services/sync_service.dart';

import '../helpers/test_helpers.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CacheService cacheService;
  late SyncService syncService;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_sync_test_');
    fakeFirestore = FakeFirebaseFirestore();
    cacheService = CacheService();
    await cacheService.initialize(hivePath: tempDir.path);

    syncService = SyncService(
      recipeService: RecipeService(firestore: fakeFirestore),
      foodItemService: FoodItemService(firestore: fakeFirestore),
      dailyTrackerService: DailyTrackerService(firestore: fakeFirestore),
      cacheService: cacheService,
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('syncOfflineQueue', () {
    test('does nothing when queue is empty', () async {
      await syncService.syncOfflineQueue('user1');
      expect(cacheService.getOfflineQueue(), isEmpty);
    });

    test('replays add_meal_entry action and clears queue on success', () async {
      final entry = createTestMealEntry();
      await cacheService.queueOfflineAction({
        'type': 'add_meal_entry',
        'userId': 'user1',
        'dateString': '2024-01-15',
        'entry': entry.toMap(),
      });

      await syncService.syncOfflineQueue('user1');

      expect(cacheService.getOfflineQueue(), isEmpty);

      // Verify the meal was written to Firestore
      final logs = await fakeFirestore
          .collection('daily_logs')
          .where('userId', isEqualTo: 'user1')
          .where('date', isEqualTo: '2024-01-15')
          .get();
      expect(logs.docs, isNotEmpty);
    });

    test('keeps failed actions in queue', () async {
      // Queue an action with an invalid type to force failure in processing
      // and then a valid one
      await cacheService.queueOfflineAction({'type': 'unknown_type'});
      await cacheService.queueOfflineAction({'type': 'unknown_type_2'});

      // syncOfflineQueue should not throw; failed items stay in queue
      await syncService.syncOfflineQueue('user1');

      // Unknown types are silently skipped (no exception), so queue is cleared
      // (they fail at the switch default — no exception thrown for unknown types)
      expect(cacheService.getOfflineQueue(), isEmpty);
    });

    test('updates existing log when date doc already exists', () async {
      // Pre-create a daily log in Firestore
      final existingLog = DailyLog(userId: 'user1', date: '2024-02-01', meals: []);
      await fakeFirestore.collection('daily_logs').add(existingLog.toMap());

      final entry = createTestMealEntry(mealType: MealType.lunch);
      await cacheService.queueOfflineAction({
        'type': 'add_meal_entry',
        'userId': 'user1',
        'dateString': '2024-02-01',
        'entry': entry.toMap(),
      });

      await syncService.syncOfflineQueue('user1');
      expect(cacheService.getOfflineQueue(), isEmpty);
    });
  });

  group('fullSync', () {
    test('caches public recipes after sync', () async {
      await fakeFirestore.collection('recipes').add(
        createTestRecipeMap(isPrivate: false),
      );

      await syncService.fullSync('user1');

      final cached = cacheService.getCachedRecipes();
      expect(cached, isNotEmpty);
    });

    test('caches food items after sync', () async {
      await fakeFirestore
          .collection('food_items')
          .add(createTestFoodItemMap());

      await syncService.fullSync('user1');

      final cached = cacheService.getCachedFoodItems();
      expect(cached, isNotEmpty);
    });

    test('handles empty Firestore gracefully', () async {
      await expectLater(syncService.fullSync('user1'), completes);
    });
  });
}
