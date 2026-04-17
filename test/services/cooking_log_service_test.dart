import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/cooking_log_service.dart';
import 'package:chef_specials/models/cooking_log.dart';

CookingLog _makeLog({
  String recipeId = 'recipe1',
  String userId = 'user1',
  int servings = 2,
  int? personalRating = 4,
}) {
  return CookingLog(
    recipeId: recipeId,
    recipeName: 'Test Recipe',
    recipeImageUrl: null,
    userId: userId,
    cookedAt: DateTime(2025, 6, 15),
    personalRating: personalRating,
    notes: 'Great!',
    servings: servings,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CookingLogService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = CookingLogService(firestore: fakeFirestore);
  });

  group('CookingLogService', () {
    test('logCook saves document to Firestore', () async {
      await service.logCook(_makeLog());
      final snap =
          await fakeFirestore.collection('cooking_logs').get();
      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['recipeName'], 'Test Recipe');
    });

    test('getCookingHistory returns logs for user ordered by cookedAt desc',
        () async {
      final log1 = _makeLog()
          .copyWith(cookedAt: DateTime(2025, 6, 10));
      final log2 = _makeLog()
          .copyWith(cookedAt: DateTime(2025, 6, 15));
      await service.logCook(log1);
      await service.logCook(log2);

      final history = await service.getCookingHistory('user1');
      expect(history.length, 2);
      // newest first
      expect(history.first.cookedAt.isAfter(history.last.cookedAt), true);
    });

    test('getCookingHistory respects limit', () async {
      for (int i = 0; i < 5; i++) {
        await service.logCook(_makeLog());
      }
      final history =
          await service.getCookingHistory('user1', limit: 3);
      expect(history.length, 3);
    });

    test('getCookingHistory filters by userId', () async {
      await service.logCook(_makeLog(userId: 'user1'));
      await service.logCook(_makeLog(userId: 'user2'));

      final history = await service.getCookingHistory('user1');
      expect(history.every((l) => l.userId == 'user1'), true);
    });

    test('getCookCountForRecipe returns correct count', () async {
      await service.logCook(_makeLog(recipeId: 'recipe1', userId: 'user1'));
      await service.logCook(_makeLog(recipeId: 'recipe1', userId: 'user1'));
      await service.logCook(_makeLog(recipeId: 'recipe2', userId: 'user1'));

      final count =
          await service.getCookCountForRecipe('user1', 'recipe1');
      expect(count, 2);
    });

    test('getCookCountForRecipe returns 0 when none', () async {
      final count =
          await service.getCookCountForRecipe('user1', 'unknownRecipe');
      expect(count, 0);
    });

    test('getTotalCooksForRecipe counts all users', () async {
      await service.logCook(_makeLog(recipeId: 'recipe1', userId: 'user1'));
      await service.logCook(_makeLog(recipeId: 'recipe1', userId: 'user2'));
      await service.logCook(_makeLog(recipeId: 'recipe2', userId: 'user1'));

      final total =
          await service.getTotalCooksForRecipe('recipe1');
      expect(total, 2);
    });

    test('deleteCookingLog removes document', () async {
      await service.logCook(_makeLog());
      final snap =
          await fakeFirestore.collection('cooking_logs').get();
      final docId = snap.docs.first.id;

      await service.deleteCookingLog(docId);
      final after =
          await fakeFirestore.collection('cooking_logs').get();
      expect(after.docs.isEmpty, true);
    });

    test('streamCookingHistory emits logs', () async {
      await service.logCook(_makeLog());
      final stream = service.streamCookingHistory('user1');
      final logs = await stream.first;
      expect(logs.length, 1);
      expect(logs.first.userId, 'user1');
    });
  });
}
