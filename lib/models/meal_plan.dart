import 'package:cloud_firestore/cloud_firestore.dart';
import 'planned_meal.dart';

class MealPlan {
  final String? id;
  final String userId;
  final DateTime weekStartDate; // always Monday of that week
  final List<PlannedMeal> meals;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealPlan({
    this.id,
    required this.userId,
    required this.weekStartDate,
    required this.meals,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealPlan.fromMap(Map<String, dynamic> map, String docId) {
    return MealPlan(
      id: docId,
      userId: map['userId'] as String,
      weekStartDate: (map['weekStartDate'] as Timestamp).toDate(),
      meals: (map['meals'] as List<dynamic>?)
              ?.map((e) => PlannedMeal.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'weekStartDate': Timestamp.fromDate(weekStartDate),
      'meals': meals.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MealPlan copyWith({
    String? id,
    String? userId,
    DateTime? weekStartDate,
    List<PlannedMeal>? meals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      meals: meals ?? this.meals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
