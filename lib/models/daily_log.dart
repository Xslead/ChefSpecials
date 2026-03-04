import 'meal_entry.dart';

class DailyLog {
  final String? id;
  final String userId;
  final String date; // "yyyy-MM-dd" format
  final List<MealEntry> meals;
  final int waterMl;

  DailyLog({
    this.id,
    required this.userId,
    required this.date,
    required this.meals,
    this.waterMl = 0,
  });

  double get totalCalories => meals.fold(0, (sum, m) => sum + m.calories);
  double get totalProtein => meals.fold(0, (sum, m) => sum + m.protein);
  double get totalCarbs => meals.fold(0, (sum, m) => sum + m.carbs);
  double get totalFat => meals.fold(0, (sum, m) => sum + m.fat);
  int get totalWaterMl => waterMl;

  List<MealEntry> mealsOfType(MealType type) =>
      meals.where((m) => m.mealType == type).toList();

  double caloriesForMeal(MealType type) =>
      mealsOfType(type).fold(0, (sum, m) => sum + m.calories);

  factory DailyLog.fromMap(Map<String, dynamic> map, String docId) {
    return DailyLog(
      id: docId,
      userId: map['userId'] as String,
      date: map['date'] as String,
      meals: (map['meals'] as List<dynamic>?)
              ?.map((e) => MealEntry.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      waterMl: (map['waterMl'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'meals': meals.map((e) => e.toMap()).toList(),
      'waterMl': waterMl,
    };
  }

  DailyLog copyWith({List<MealEntry>? meals, int? waterMl}) {
    return DailyLog(
      id: id,
      userId: userId,
      date: date,
      meals: meals ?? this.meals,
      waterMl: waterMl ?? this.waterMl,
    );
  }
}
