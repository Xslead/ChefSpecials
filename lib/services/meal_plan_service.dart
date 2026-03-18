import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_plan.dart';
import '../models/planned_meal.dart';

class MealPlanService {
  final FirebaseFirestore _firestore;

  MealPlanService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _mealPlansRef =>
      _firestore.collection('meal_plans');

  /// Normalize a date to Monday at midnight UTC for consistent querying.
  DateTime _normalizeToMonday(DateTime date) {
    final monday = DateTime.utc(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
    return DateTime.utc(monday.year, monday.month, monday.day);
  }

  Future<MealPlan?> getMealPlan(String userId, DateTime weekStart) async {
    final normalized = _normalizeToMonday(weekStart);
    final snapshot = await _mealPlansRef
        .where('userId', isEqualTo: userId)
        .where('weekStartDate', isEqualTo: Timestamp.fromDate(normalized))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return MealPlan.fromMap(doc.data(), doc.id);
  }

  Stream<MealPlan?> getMealPlanStream(String userId, DateTime weekStart) {
    final normalized = _normalizeToMonday(weekStart);
    return _mealPlansRef
        .where('userId', isEqualTo: userId)
        .where('weekStartDate', isEqualTo: Timestamp.fromDate(normalized))
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return MealPlan.fromMap(doc.data(), doc.id);
    });
  }

  Future<String> createMealPlan(MealPlan plan) async {
    final data = plan.toMap();
    // Ensure weekStartDate is normalized
    data['weekStartDate'] =
        Timestamp.fromDate(_normalizeToMonday(plan.weekStartDate));
    final doc = await _mealPlansRef.add(data);
    return doc.id;
  }

  Future<void> updateMealPlan(MealPlan plan) async {
    if (plan.id == null) return;
    final data = plan.toMap();
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _mealPlansRef.doc(plan.id).update(data);
  }

  Future<void> addMealToDay(String planId, PlannedMeal meal) async {
    await _mealPlansRef.doc(planId).update({
      'meals': FieldValue.arrayUnion([meal.toMap()]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> removeMealFromDay(String planId, PlannedMeal meal) async {
    await _mealPlansRef.doc(planId).update({
      'meals': FieldValue.arrayRemove([meal.toMap()]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> copyFromPreviousWeek(
      String userId, DateTime currentWeekStart) async {
    final normalized = _normalizeToMonday(currentWeekStart);
    final previousWeek = normalized.subtract(const Duration(days: 7));

    final previousPlan = await getMealPlan(userId, previousWeek);
    if (previousPlan == null) return;

    final now = DateTime.now();
    final newPlan = MealPlan(
      userId: userId,
      weekStartDate: normalized,
      meals: List<PlannedMeal>.from(previousPlan.meals),
      createdAt: now,
      updatedAt: now,
    );

    await createMealPlan(newPlan);
  }
}
