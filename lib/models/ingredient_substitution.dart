class IngredientSubstitution {
  final String? id;
  final String originalIngredient;
  final String substituteName;
  final String ratio;
  final String? notes;
  final List<String> dietaryTags;
  final String? submittedBy;
  final bool isVerified;

  IngredientSubstitution({
    this.id,
    required this.originalIngredient,
    required this.substituteName,
    required this.ratio,
    this.notes,
    this.dietaryTags = const [],
    this.submittedBy,
    this.isVerified = false,
  });

  static String normalize(String name) => name.toLowerCase().trim();

  factory IngredientSubstitution.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return IngredientSubstitution(
      id: docId,
      originalIngredient: map['originalIngredient'] as String,
      substituteName: map['substituteName'] as String,
      ratio: map['ratio'] as String? ?? '1:1',
      notes: map['notes'] as String?,
      dietaryTags: (map['dietaryTags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      submittedBy: map['submittedBy'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'originalIngredient': normalize(originalIngredient),
      'substituteName': substituteName,
      'ratio': ratio,
      'notes': notes,
      'dietaryTags': dietaryTags,
      'submittedBy': submittedBy,
      'isVerified': isVerified,
    };
  }

  IngredientSubstitution copyWith({
    String? id,
    String? originalIngredient,
    String? substituteName,
    String? ratio,
    String? notes,
    List<String>? dietaryTags,
    String? submittedBy,
    bool? isVerified,
  }) {
    return IngredientSubstitution(
      id: id ?? this.id,
      originalIngredient: originalIngredient ?? this.originalIngredient,
      substituteName: substituteName ?? this.substituteName,
      ratio: ratio ?? this.ratio,
      notes: notes ?? this.notes,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      submittedBy: submittedBy ?? this.submittedBy,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
