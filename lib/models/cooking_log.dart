import 'package:cloud_firestore/cloud_firestore.dart';

class CookingLog {
  final String? id;
  final String recipeId;
  final String recipeName;
  final String? recipeImageUrl;
  final String userId;
  final DateTime cookedAt;
  final int? personalRating;
  final String? notes;
  final String? photoUrl;
  final int servings;

  CookingLog({
    this.id,
    required this.recipeId,
    required this.recipeName,
    this.recipeImageUrl,
    required this.userId,
    required this.cookedAt,
    this.personalRating,
    this.notes,
    this.photoUrl,
    required this.servings,
  });

  factory CookingLog.fromMap(Map<String, dynamic> map, String docId) {
    return CookingLog(
      id: docId,
      recipeId: map['recipeId'] as String,
      recipeName: map['recipeName'] as String,
      recipeImageUrl: map['recipeImageUrl'] as String?,
      userId: map['userId'] as String,
      cookedAt: (map['cookedAt'] as Timestamp).toDate(),
      personalRating: (map['personalRating'] as num?)?.toInt(),
      notes: map['notes'] as String?,
      photoUrl: map['photoUrl'] as String?,
      servings: (map['servings'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'recipeName': recipeName,
      'recipeImageUrl': recipeImageUrl,
      'userId': userId,
      'cookedAt': Timestamp.fromDate(cookedAt),
      'personalRating': personalRating,
      'notes': notes,
      'photoUrl': photoUrl,
      'servings': servings,
    };
  }

  CookingLog copyWith({
    String? id,
    String? recipeId,
    String? recipeName,
    String? recipeImageUrl,
    String? userId,
    DateTime? cookedAt,
    int? personalRating,
    String? notes,
    String? photoUrl,
    int? servings,
  }) {
    return CookingLog(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      recipeImageUrl: recipeImageUrl ?? this.recipeImageUrl,
      userId: userId ?? this.userId,
      cookedAt: cookedAt ?? this.cookedAt,
      personalRating: personalRating ?? this.personalRating,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      servings: servings ?? this.servings,
    );
  }
}
