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
    };
  }
}
