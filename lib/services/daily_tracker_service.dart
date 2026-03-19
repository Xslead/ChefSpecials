import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/daily_log.dart';
import '../models/nutrition_goal.dart';

class DailyTrackerService {
  final FirebaseFirestore _firestore;

  DailyTrackerService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _logsRef =>
      _firestore.collection('daily_logs');

  CollectionReference<Map<String, dynamic>> get _goalsRef =>
      _firestore.collection('nutrition_goals');

  // ── Daily Logs ──

  Stream<DailyLog?> getDailyLog(String userId, String date) {
    return _logsRef
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: date)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return DailyLog.fromMap(doc.data(), doc.id);
    });
  }

  Future<String> createDailyLog(DailyLog log) async {
    final doc = await _logsRef.add(log.toMap());
    return doc.id;
  }

  Future<void> updateDailyLog(String id, DailyLog log) async {
    await _logsRef.doc(id).update(log.toMap());
  }

  Future<Map<String, double>> getWeeklyCalories(
      String userId, List<String> dates) async {
    final snapshot = await _logsRef
        .where('userId', isEqualTo: userId)
        .where('date', whereIn: dates)
        .get();

    final result = <String, double>{};
    for (final doc in snapshot.docs) {
      final log = DailyLog.fromMap(doc.data(), doc.id);
      result[log.date] = log.totalCalories;
    }
    return result;
  }

  Future<List<DailyLog>> getDailyLogsForRange(
      String userId, String startDate, String endDate) async {
    // Build list of all dates in range — avoids composite index requirement
    final dates = <String>[];
    var current = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    while (!current.isAfter(end)) {
      dates.add(DateFormat('yyyy-MM-dd').format(current));
      current = current.add(const Duration(days: 1));
    }

    // Firestore whereIn is limited to 30 items, so batch the queries
    final logs = <DailyLog>[];
    for (var i = 0; i < dates.length; i += 30) {
      final batch = dates.sublist(
          i, i + 30 > dates.length ? dates.length : i + 30);
      final snapshot = await _logsRef
          .where('userId', isEqualTo: userId)
          .where('date', whereIn: batch)
          .get();
      for (final doc in snapshot.docs) {
        logs.add(DailyLog.fromMap(doc.data(), doc.id));
      }
    }
    return logs;
  }

  // ── Nutrition Goals ──

  Stream<NutritionGoal?> getNutritionGoal(String userId) {
    return _goalsRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return NutritionGoal.fromMap(doc.data()!, userId);
    });
  }

  Future<void> setNutritionGoal(NutritionGoal goal) async {
    await _goalsRef.doc(goal.userId).set(goal.toMap());
  }
}
