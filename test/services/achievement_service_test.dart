import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/achievement.dart';
import 'package:chef_specials/services/achievement_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AchievementService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = AchievementService(firestore: fakeFirestore);
  });

  group('AchievementService.unlockAchievement', () {
    test('creates unlock document', () async {
      final unlocked =
          await service.unlockAchievement('user1', 'first_recipe');
      expect(unlocked, isNotNull);
      expect(unlocked!.achievementId, 'first_recipe');
      expect(unlocked.userId, 'user1');

      final snap =
          await fakeFirestore.collection('user_achievements').get();
      expect(snap.docs.length, 1);
    });

    test('does not create duplicate', () async {
      await service.unlockAchievement('user1', 'first_recipe');
      final second =
          await service.unlockAchievement('user1', 'first_recipe');
      expect(second, isNull);

      final snap =
          await fakeFirestore.collection('user_achievements').get();
      expect(snap.docs.length, 1);
    });

    test('different users can unlock the same achievement', () async {
      await service.unlockAchievement('user1', 'first_recipe');
      await service.unlockAchievement('user2', 'first_recipe');

      final snap =
          await fakeFirestore.collection('user_achievements').get();
      expect(snap.docs.length, 2);
    });
  });

  group('AchievementService.getUserAchievements', () {
    test('returns user achievements sorted by unlockedAt desc', () async {
      await service.unlockAchievement('user1', 'first_recipe');
      await Future.delayed(const Duration(milliseconds: 5));
      await service.unlockAchievement('user1', 'recipe_master');

      final list = await service.getUserAchievements('user1');
      expect(list.length, 2);
      expect(list.first.unlockedAt.isAfter(list.last.unlockedAt) ||
              list.first.unlockedAt.isAtSameMomentAs(list.last.unlockedAt),
          isTrue);
    });

    test('returns empty when no unlocks', () async {
      final list = await service.getUserAchievements('user1');
      expect(list, isEmpty);
    });

    test('only returns achievements for the requested user', () async {
      await service.unlockAchievement('user1', 'first_recipe');
      await service.unlockAchievement('user2', 'home_chef');
      final list = await service.getUserAchievements('user1');
      expect(list.length, 1);
      expect(list.first.achievementId, 'first_recipe');
    });
  });

  group('AchievementService.streamUserAchievements', () {
    test('stream emits user achievements', () async {
      await service.unlockAchievement('user1', 'first_recipe');
      final list = await service.streamUserAchievements('user1').first;
      expect(list.length, 1);
      expect(list.first.achievementId, 'first_recipe');
    });
  });

  group('AchievementService.checkAndUnlockAchievements', () {
    test('unlocks achievement when criteria met', () async {
      final newly = await service.checkAndUnlockAchievements(
        'user1',
        context: {'recipesPublished': 1},
      );
      expect(newly.any((a) => a.id == 'first_recipe'), isTrue);
    });

    test('does not unlock when criteria not met', () async {
      final newly = await service.checkAndUnlockAchievements(
        'user1',
        context: {'recipesPublished': 0},
      );
      expect(newly.any((a) => a.id == 'first_recipe'), isFalse);
    });

    test('does not double-unlock already-unlocked achievements', () async {
      await service.unlockAchievement('user1', 'first_recipe');
      final newly = await service.checkAndUnlockAchievements(
        'user1',
        context: {'recipesPublished': 5},
      );
      expect(newly.any((a) => a.id == 'first_recipe'), isFalse);
    });

    test('unlocks multiple achievements in one call', () async {
      final newly = await service.checkAndUnlockAchievements(
        'user1',
        context: {
          'recipesPublished': 10,
          'mealStreak': 7,
          'followers': 10,
        },
      );
      final ids = newly.map((a) => a.id).toSet();
      expect(ids.contains('first_recipe'), isTrue);
      expect(ids.contains('recipe_master'), isTrue);
      expect(ids.contains('streak_7'), isTrue);
      expect(ids.contains('social_butterfly'), isTrue);
    });
  });

  group('AchievementService.getProgress', () {
    test('returns 0.0 when current value is missing', () async {
      final achievement = Achievement.byId('first_recipe')!;
      final progress =
          await service.getProgress('user1', achievement, context: {});
      expect(progress, 0.0);
    });

    test('returns ratio between 0 and 1', () async {
      final achievement = Achievement.byId('recipe_master')!;
      final progress = await service.getProgress(
        'user1',
        achievement,
        context: {'recipesPublished': 5},
      );
      expect(progress, closeTo(0.5, 1e-9));
    });

    test('caps at 1.0 when current >= target', () async {
      final achievement = Achievement.byId('recipe_master')!;
      final progress = await service.getProgress(
        'user1',
        achievement,
        context: {'recipesPublished': 100},
      );
      expect(progress, 1.0);
    });
  });
}
