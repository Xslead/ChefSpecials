import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement.dart';
import '../models/user_achievement.dart';

class AchievementService {
  final FirebaseFirestore _db;

  AchievementService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('user_achievements');

  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    final snap = await _ref.where('userId', isEqualTo: userId).get();
    return snap.docs
        .map((d) => UserAchievement.fromMap(d.data(), d.id))
        .toList()
      ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
  }

  Stream<List<UserAchievement>> streamUserAchievements(String userId) {
    return _ref.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => UserAchievement.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
      return list;
    });
  }

  Future<UserAchievement?> unlockAchievement(
    String userId,
    String achievementId,
  ) async {
    final existing = await _ref
        .where('userId', isEqualTo: userId)
        .where('achievementId', isEqualTo: achievementId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return null;

    final ua = UserAchievement(
      achievementId: achievementId,
      userId: userId,
      unlockedAt: DateTime.now(),
    );
    final docRef = await _ref.add(ua.toMap());
    return ua.copyWith(id: docRef.id);
  }

  Future<List<Achievement>> checkAndUnlockAchievements(
    String userId, {
    required Map<String, dynamic> context,
  }) async {
    final unlocked = <Achievement>[];
    final existingSnap = await _ref.where('userId', isEqualTo: userId).get();
    final existingIds = existingSnap.docs
        .map((d) => d.data()['achievementId'] as String)
        .toSet();

    for (final achievement in Achievement.allAchievements) {
      if (existingIds.contains(achievement.id)) continue;
      if (_meetsCriteria(achievement.criteria, context)) {
        final result = await unlockAchievement(userId, achievement.id);
        if (result != null) unlocked.add(achievement);
      }
    }
    return unlocked;
  }

  Future<double> getProgress(
    String userId,
    Achievement achievement, {
    Map<String, dynamic>? context,
  }) async {
    final ctx = context ?? {};
    final type = achievement.criteria['type'] as String?;
    final target = (achievement.criteria['target'] as num?)?.toDouble() ?? 1.0;
    if (type == null || target <= 0) return 0.0;
    final current = (ctx[type] as num?)?.toDouble() ?? 0.0;
    final ratio = current / target;
    if (ratio.isNaN || ratio.isInfinite) return 0.0;
    if (ratio < 0) return 0.0;
    if (ratio > 1) return 1.0;
    return ratio;
  }

  bool _meetsCriteria(
    Map<String, dynamic> criteria,
    Map<String, dynamic> context,
  ) {
    final type = criteria['type'] as String?;
    final target = criteria['target'];
    if (type == null || target == null) return false;
    final current = context[type];
    if (current == null) return false;
    if (target is num && current is num) {
      return current >= target;
    }
    return current == target;
  }
}
