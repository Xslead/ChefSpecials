import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cooking_log.dart';

class CookingLogService {
  final FirebaseFirestore _firestore;

  CookingLogService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _logsRef =>
      _firestore.collection('cooking_logs');

  Future<void> logCook(CookingLog log) async {
    await _logsRef.add(log.toMap());
  }

  Future<List<CookingLog>> getCookingHistory(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _logsRef
        .where('userId', isEqualTo: userId)
        .orderBy('cookedAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CookingLog.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<CookingLog>> streamCookingHistory(String userId) {
    return _logsRef
        .where('userId', isEqualTo: userId)
        .orderBy('cookedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CookingLog.fromMap(d.data(), d.id)).toList());
  }

  Future<int> getCookCountForRecipe(String userId, String recipeId) async {
    final snap = await _logsRef
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: recipeId)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<int> getTotalCooksForRecipe(String recipeId) async {
    final snap = await _logsRef
        .where('recipeId', isEqualTo: recipeId)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<void> deleteCookingLog(String logId) async {
    await _logsRef.doc(logId).delete();
  }

  Future<void> updateCookingLog(CookingLog log) async {
    if (log.id == null) return;
    await _logsRef.doc(log.id).update(log.toMap());
  }
}
