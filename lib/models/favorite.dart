class Favorite {
  final String? id;
  final String userId;
  final String recipeId;
  final DateTime createdAt;

  Favorite({this.id, required this.userId, required this.recipeId, required this.createdAt});

  factory Favorite.fromMap(Map<String, dynamic> map, String docId) {
    return Favorite(
      id: docId,
      userId: map['userId'] as String,
      recipeId: map['recipeId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
