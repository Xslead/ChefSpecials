import 'ingredient.dart';
import 'recipe_step.dart';

class Recipe {
  final String? id;
  final String title;
  final String description;
  final String authorId;
  final String authorName;
  final String category;
  final int servings;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String? imageUrl;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final int? caloriesPerServing;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatGrams;
  final DateTime createdAt;
  final double averageRating;
  final int ratingCount;
  final int commentCount;
  final bool isPrivate;

  Recipe({
    this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.category,
    required this.servings,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    this.caloriesPerServing,
    this.proteinGrams,
    this.carbsGrams,
    this.fatGrams,
    required this.createdAt,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.commentCount = 0,
    this.isPrivate = false,
  });

  factory Recipe.fromMap(Map<String, dynamic> map, String docId) {
    return Recipe(
      id: docId,
      title: map['title'] as String,
      description: map['description'] as String,
      authorId: map['authorId'] as String,
      authorName: map['authorName'] as String,
      category: map['category'] as String,
      servings: map['servings'] as int,
      prepTimeMinutes: map['prepTimeMinutes'] as int,
      cookTimeMinutes: map['cookTimeMinutes'] as int,
      imageUrl: map['imageUrl'] as String?,
      ingredients: (map['ingredients'] as List<dynamic>)
          .map((e) => Ingredient.fromMap(e as Map<String, dynamic>))
          .toList(),
      steps: (map['steps'] as List<dynamic>)
          .map((e) => RecipeStep.fromMap(e as Map<String, dynamic>))
          .toList(),
      caloriesPerServing: map['caloriesPerServing'] as int?,
      proteinGrams: (map['proteinGrams'] as num?)?.toDouble(),
      carbsGrams: (map['carbsGrams'] as num?)?.toDouble(),
      fatGrams: (map['fatGrams'] as num?)?.toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: map['ratingCount'] as int? ?? 0,
      commentCount: map['commentCount'] as int? ?? 0,
      isPrivate: map['isPrivate'] as bool? ?? false,
    );
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? authorId,
    String? authorName,
    String? category,
    int? servings,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String? imageUrl,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    int? caloriesPerServing,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    DateTime? createdAt,
    double? averageRating,
    int? ratingCount,
    int? commentCount,
    bool? isPrivate,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      category: category ?? this.category,
      servings: servings ?? this.servings,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      caloriesPerServing: caloriesPerServing ?? this.caloriesPerServing,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      createdAt: createdAt ?? this.createdAt,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      commentCount: commentCount ?? this.commentCount,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'category': category,
      'servings': servings,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'steps': steps.map((e) => e.toMap()).toList(),
      'caloriesPerServing': caloriesPerServing,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'createdAt': createdAt.toIso8601String(),
      'isPrivate': isPrivate,
    };
  }
}
