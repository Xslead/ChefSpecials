class RecipeCollection {
  final String? id;
  final String userId;
  final String name;
  final String? description;
  final List<String> recipeIds;
  final String? coverImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeCollection({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    this.recipeIds = const [],
    this.coverImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipeCollection.fromMap(Map<String, dynamic> map, String docId) {
    return RecipeCollection(
      id: docId,
      userId: map['userId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      recipeIds: List<String>.from(map['recipeIds'] ?? []),
      coverImageUrl: map['coverImageUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'recipeIds': recipeIds,
      'coverImageUrl': coverImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
