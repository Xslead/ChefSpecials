class FoodItem {
  final String? id;
  final String name;
  final String? brand;
  final String category;
  final String unit; // "100g" or "mL"
  final double packetSize; // grams or mL per packet
  final String? barcode;
  final bool isVegan;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final String? imageUrl;
  final String addedBy;
  final DateTime createdAt;
  final bool isVerified;

  FoodItem({
    this.id,
    required this.name,
    this.brand,
    required this.category,
    required this.unit,
    required this.packetSize,
    this.barcode,
    this.isVegan = false,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    this.imageUrl,
    required this.addedBy,
    required this.createdAt,
    this.isVerified = false,
  });

  // Nutrition per packet
  double get caloriesPerPacket => calories * packetSize / 100;
  double get proteinPerPacket => protein * packetSize / 100;
  double get carbsPerPacket => carbs * packetSize / 100;
  double get fatPerPacket => fat * packetSize / 100;
  double get fiberPerPacket => fiber * packetSize / 100;
  double get sugarPerPacket => sugar * packetSize / 100;
  double get sodiumPerPacket => sodium * packetSize / 100;

  factory FoodItem.fromMap(Map<String, dynamic> map, String docId) {
    return FoodItem(
      id: docId,
      name: map['name'] as String,
      brand: map['brand'] as String?,
      category: map['category'] as String,
      unit: map['unit'] as String,
      packetSize: (map['packetSize'] as num?)?.toDouble() ?? 100,
      barcode: map['barcode'] as String?,
      isVegan: map['isVegan'] as bool? ?? false,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      fiber: (map['fiber'] as num).toDouble(),
      sugar: (map['sugar'] as num).toDouble(),
      sodium: (map['sodium'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String?,
      addedBy: map['addedBy'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isVerified: map['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'category': category,
      'unit': unit,
      'packetSize': packetSize,
      'barcode': barcode,
      'isVegan': isVegan,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'imageUrl': imageUrl,
      'addedBy': addedBy,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}
