class Comment {
  final String? id;
  final String recipeId;
  final String userId;
  final String authorName;
  final String text;
  final int stars; // 0 means the user didn't rate when commenting
  final DateTime createdAt;

  Comment({
    this.id,
    required this.recipeId,
    required this.userId,
    required this.authorName,
    required this.text,
    this.stars = 0,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map, String docId) {
    return Comment(
      id: docId,
      recipeId: map['recipeId'] as String,
      userId: map['userId'] as String,
      authorName: map['authorName'] as String,
      text: map['text'] as String,
      stars: map['stars'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'authorName': authorName,
      'text': text,
      'stars': stars,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
