import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_log.dart';
import '../models/nutrition_goal.dart';

class DailyTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
