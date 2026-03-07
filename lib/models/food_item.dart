class FoodItem {
  final String? id;
  final String name;
  final String? brand;
  final String category;
  final String unit; // "100g" or "mL"
  final double packetSize; // grams or mL per packet
  final String? barcode;
  final bool isVegan;
  final bool isVegetarian;
  final bool isGlutenFree;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double saturatedFat;
  final double transFat;
  final double cholesterol; // mg per 100g
  final double fiber;
  final double sugar;
  final double sodium; // mg per 100g
  final double salt; // g per 100g
  final String? nutriScore; // A, B, C, D, E
  final int? novaGroup; // 1-4
  final List<String> allergens;
  final String? ingredientsText;
  final String? origin;
  final double? servingSize; // grams per serving
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
    this.isVegetarian = false,
    this.isGlutenFree = false,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.saturatedFat = 0,
    this.transFat = 0,
    this.cholesterol = 0,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    this.salt = 0,
    this.nutriScore,
    this.novaGroup,
    this.allergens = const [],
    this.ingredientsText,
    this.origin,
    this.servingSize,
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
  double get saturatedFatPerPacket => saturatedFat * packetSize / 100;
  double get transFatPerPacket => transFat * packetSize / 100;
  double get cholesterolPerPacket => cholesterol * packetSize / 100;
  double get fiberPerPacket => fiber * packetSize / 100;
  double get sugarPerPacket => sugar * packetSize / 100;
  double get sodiumPerPacket => sodium * packetSize / 100;
  double get saltPerPacket => salt * packetSize / 100;

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
      isVegetarian: map['isVegetarian'] as bool? ?? false,
      isGlutenFree: map['isGlutenFree'] as bool? ?? false,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      saturatedFat: (map['saturatedFat'] as num?)?.toDouble() ?? 0,
      transFat: (map['transFat'] as num?)?.toDouble() ?? 0,
      cholesterol: (map['cholesterol'] as num?)?.toDouble() ?? 0,
      fiber: (map['fiber'] as num).toDouble(),
      sugar: (map['sugar'] as num).toDouble(),
      sodium: (map['sodium'] as num).toDouble(),
      salt: (map['salt'] as num?)?.toDouble() ?? 0,
      nutriScore: map['nutriScore'] as String?,
      novaGroup: map['novaGroup'] as int?,
      allergens: (map['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ingredientsText: map['ingredientsText'] as String?,
      origin: map['origin'] as String?,
      servingSize: (map['servingSize'] as num?)?.toDouble(),
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
      'isVegetarian': isVegetarian,
      'isGlutenFree': isGlutenFree,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'saturatedFat': saturatedFat,
      'transFat': transFat,
      'cholesterol': cholesterol,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'salt': salt,
      'nutriScore': nutriScore,
      'novaGroup': novaGroup,
      'allergens': allergens,
      'ingredientsText': ingredientsText,
      'origin': origin,
      'servingSize': servingSize,
      'imageUrl': imageUrl,
      'addedBy': addedBy,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}
