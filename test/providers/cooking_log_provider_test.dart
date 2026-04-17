import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:chef_specials/providers/cooking_log_provider.dart';
import 'package:chef_specials/services/cooking_log_service.dart';
import 'package:chef_specials/services/daily_tracker_service.dart';
import 'package:chef_specials/services/storage_service.dart';
import 'package:chef_specials/models/cooking_log.dart';

import '../helpers/test_helpers.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CookingLogService service;
  late DailyTrackerService trackerService;
  late MockStorageService mockStorage;
  late CookingLogProvider provider;

  const userId = 'user1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = CookingLogService(firestore: fakeFirestore);
    trackerService = DailyTrackerService(firestore: fakeFirestore);
    mockStorage = MockStorageService();
    provider = CookingLogProvider(
      cookingLogService: service,
      storageService: mockStorage,
      dailyTrackerService: trackerService,
    );
  });

  tearDown(() => provider.dispose());

  group('CookingLogProvider', () {
    test('initial state is empty and not loading', () {
      expect(provider.cookingHistory, isEmpty);
      expect(provider.isLoading, false);
    });

    test('init subscribes to stream and sets loading', () async {
      provider.init(userId);
      expect(provider.isLoading, true);
      await Future.delayed(Duration.zero);
      expect(provider.isLoading, false);
    });

    test('init is idempotent for same user', () {
      provider.init(userId);
      provider.init(userId);
      // no crash, no duplicate subscription
    });

    test('getCookCountFromCache returns 0 when no history', () {
      final count = provider.getCookCountFromCache('recipe1');
      expect(count, 0);
    });

    test('getCookCountFromCache counts from loaded history', () async {
      final log = CookingLog(
        recipeId: 'recipe1',
        recipeName: 'Test',
        userId: userId,
        cookedAt: DateTime.now(),
        servings: 1,
      );
      await service.logCook(log);
      await service.logCook(log);

      provider.init(userId);
      await Future.delayed(Duration.zero);

      expect(provider.getCookCountFromCache('recipe1'), 2);
    });

    test('deleteCookingLog removes from local list', () async {
      final log = CookingLog(
        recipeId: 'recipe1',
        recipeName: 'Test',
        userId: userId,
        cookedAt: DateTime.now(),
        servings: 1,
      );
      await service.logCook(log);
      provider.init(userId);
      await Future.delayed(Duration.zero);

      expect(provider.cookingHistory.length, 1);
      final logId = provider.cookingHistory.first.id!;
      await provider.deleteCookingLog(logId);
      expect(provider.cookingHistory.isEmpty, true);
    });

    test('getCookCount fetches from service', () async {
      final log = CookingLog(
        recipeId: 'recipe1',
        recipeName: 'Test',
        userId: userId,
        cookedAt: DateTime.now(),
        servings: 1,
      );
      await service.logCook(log);
      provider.init(userId);
      await Future.delayed(Duration.zero);

      final count = await provider.getCookCount('recipe1');
      expect(count, 1);
    });

    test('logCook adds to daily tracker when recipe has nutrition', () async {
      final recipe = createTestRecipe(
        id: 'recipe1',
        caloriesPerServing: 300,
        proteinGrams: 25,
        carbsGrams: 30,
        fatGrams: 10,
      );
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.logCook(recipe, servings: 1, userId: userId);

      final snap = await fakeFirestore.collection('daily_logs').get();
      expect(snap.docs.isNotEmpty, true);
    });
  });
}
