class ShoppingItem {
  final String name;
  final String amount;
  final String? unit;
  final bool isChecked;

  ShoppingItem({
    required this.name,
    required this.amount,
    this.unit,
    this.isChecked = false,
  });

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      name: map['name'] as String,
      amount: map['amount'] as String,
      unit: map['unit'] as String?,
      isChecked: map['isChecked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'isChecked': isChecked,
    };
  }
}

class ShoppingList {
  final String? id;
  final String userId;
  final String name;
  final List<ShoppingItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? mealPlanWeekStart; // ISO8601 — set only for meal-planner-generated lists

  ShoppingList({
    this.id,
    required this.userId,
    required this.name,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.mealPlanWeekStart,
  });

  factory ShoppingList.fromMap(Map<String, dynamic> map, String docId) {
    return ShoppingList(
      id: docId,
      userId: map['userId'] as String,
      name: map['name'] as String,
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => ShoppingItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      mealPlanWeekStart: map['mealPlanWeekStart'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (mealPlanWeekStart != null) 'mealPlanWeekStart': mealPlanWeekStart,
    };
  }
}
