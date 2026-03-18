class PlannedMeal {
  final int day; // 0=Monday through 6=Sunday
  final String mealType; // "breakfast"/"lunch"/"dinner"/"snack"
  final String recipeId;
  final String recipeName; // denormalized
  final String? recipeImageUrl;
  final int servings;

  PlannedMeal({
    required this.day,
    required this.mealType,
    required this.recipeId,
    required this.recipeName,
    this.recipeImageUrl,
    this.servings = 1,
  });

  factory PlannedMeal.fromMap(Map<String, dynamic> map) {
    return PlannedMeal(
      day: map['day'] as int,
      mealType: map['mealType'] as String,
      recipeId: map['recipeId'] as String,
      recipeName: map['recipeName'] as String,
      recipeImageUrl: map['recipeImageUrl'] as String?,
      servings: map['servings'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'mealType': mealType,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'recipeImageUrl': recipeImageUrl,
      'servings': servings,
    };
  }

  PlannedMeal copyWith({int? servings}) {
    return PlannedMeal(
      day: day,
      mealType: mealType,
      recipeId: recipeId,
      recipeName: recipeName,
      recipeImageUrl: recipeImageUrl,
      servings: servings ?? this.servings,
    );
  }

  /// Same slot = same day + mealType + recipeId.
  bool isSameSlotAndRecipe(PlannedMeal other) {
    return day == other.day &&
        mealType == other.mealType &&
        recipeId == other.recipeId;
  }
}
