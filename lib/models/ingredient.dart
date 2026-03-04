class Ingredient {
  final String name;
  final String amount;
  final String? unit;
  final String? foodItemId;
  final double? caloriesPer100;
  final double? proteinPer100;
  final double? carbsPer100;
  final double? fatPer100;

  Ingredient({
    required this.name,
    required this.amount,
    this.unit,
    this.foodItemId,
    this.caloriesPer100,
    this.proteinPer100,
    this.carbsPer100,
    this.fatPer100,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] as String,
      amount: map['amount'] as String,
      unit: map['unit'] as String?,
      foodItemId: map['foodItemId'] as String?,
      caloriesPer100: (map['caloriesPer100'] as num?)?.toDouble(),
      proteinPer100: (map['proteinPer100'] as num?)?.toDouble(),
      carbsPer100: (map['carbsPer100'] as num?)?.toDouble(),
      fatPer100: (map['fatPer100'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'foodItemId': foodItemId,
      'caloriesPer100': caloriesPer100,
      'proteinPer100': proteinPer100,
      'carbsPer100': carbsPer100,
      'fatPer100': fatPer100,
    };
  }
}
