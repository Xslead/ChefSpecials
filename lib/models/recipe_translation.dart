const Map<String, String> kSupportedLanguages = {
  'en': 'English',
  'tr': 'Türkçe',
  'de': 'Deutsch',
  'fr': 'Français',
  'es': 'Español',
  'it': 'Italiano',
  'ar': 'العربية',
  'zh': '中文',
  'ja': '日本語',
  'pt': 'Português',
  'ko': '한국어',
  'ru': 'Русский',
};

class RecipeTranslation {
  final String title;
  final String description;
  final List<String> stepInstructions;
  final List<String> ingredientNames;

  const RecipeTranslation({
    required this.title,
    required this.description,
    required this.stepInstructions,
    required this.ingredientNames,
  });

  factory RecipeTranslation.fromMap(Map<String, dynamic> map) {
    return RecipeTranslation(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      stepInstructions: List<String>.from(map['stepInstructions'] ?? []),
      ingredientNames: List<String>.from(map['ingredientNames'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'stepInstructions': stepInstructions,
        'ingredientNames': ingredientNames,
      };
}
