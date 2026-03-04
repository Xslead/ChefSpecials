class NutritionGoal {
  final String userId;
  final double calorieTarget;
  final double proteinTarget;
  final double carbsTarget;
  final double fatTarget;
  final int waterTargetMl;

  NutritionGoal({
    required this.userId,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    this.waterTargetMl = 2500,
  });

  factory NutritionGoal.defaultGoal(String userId) {
    return NutritionGoal(
      userId: userId,
      calorieTarget: 2000,
      proteinTarget: 50,
      carbsTarget: 250,
      fatTarget: 65,
      waterTargetMl: 2500,
    );
  }

  factory NutritionGoal.fromMap(Map<String, dynamic> map, String userId) {
    return NutritionGoal(
      userId: userId,
      calorieTarget: (map['calorieTarget'] as num?)?.toDouble() ?? 2000,
      proteinTarget: (map['proteinTarget'] as num?)?.toDouble() ?? 50,
      carbsTarget: (map['carbsTarget'] as num?)?.toDouble() ?? 250,
      fatTarget: (map['fatTarget'] as num?)?.toDouble() ?? 65,
      waterTargetMl: (map['waterTargetMl'] as num?)?.toInt() ?? 2500,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calorieTarget': calorieTarget,
      'proteinTarget': proteinTarget,
      'carbsTarget': carbsTarget,
      'fatTarget': fatTarget,
      'waterTargetMl': waterTargetMl,
    };
  }
}
