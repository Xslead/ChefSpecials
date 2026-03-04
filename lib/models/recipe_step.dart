class RecipeStep {
  final int order;
  final String instruction;
  final String? imageUrl;
  final int? timerSeconds;

  RecipeStep({
    required this.order,
    required this.instruction,
    this.imageUrl,
    this.timerSeconds,
  });

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      order: map['order'] as int,
      instruction: map['instruction'] as String,
      imageUrl: map['imageUrl'] as String?,
      timerSeconds: map['timerSeconds'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'instruction': instruction,
      'imageUrl': imageUrl,
      'timerSeconds': timerSeconds,
    };
  }
}
