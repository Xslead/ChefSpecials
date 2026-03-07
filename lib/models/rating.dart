class Rating {
  final String? id;
  final String recipeId;
  final String userId;
  final int stars;
  final DateTime createdAt;

  Rating({
    this.id,
    required this.recipeId,
    required this.userId,
    required this.stars,
    required this.createdAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map, String docId) {
    return Rating(
      id: docId,
      recipeId: map['recipeId'] as String,
      userId: map['userId'] as String,
      stars: map['stars'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'stars': stars,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
