class Ingredient {
  final String name;
  final String amount;
  final String? unit;

  Ingredient({
    required this.name,
    required this.amount,
    this.unit,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] as String,
      amount: map['amount'] as String,
      unit: map['unit'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }
}
