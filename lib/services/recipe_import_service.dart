import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_step.dart';

class RecipeImportService {
  final http.Client _client;

  RecipeImportService({http.Client? client}) : _client = client ?? http.Client();

  Future<Recipe> importFromUrl(String url) async {
    final uri = Uri.parse(url);
    final response = await _client.get(uri, headers: {
      'User-Agent':
          'Mozilla/5.0 (compatible; ChefSpecials/1.0; recipe importer)',
      'Accept': 'text/html,application/xhtml+xml',
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load page (HTTP ${response.statusCode})');
    }

    final html = response.body;
    final recipeJson = _extractRecipeJson(html);
    if (recipeJson == null) {
      throw Exception('No recipe schema found at this URL');
    }

    return _parseRecipeJson(recipeJson);
  }

  // ── JSON-LD extraction ──────────────────────────────────────────────────────

  Map<String, dynamic>? _extractRecipeJson(String html) {
    final regex = RegExp(
      r"""<script[^>]*type=["']application/ld\+json["'][^>]*>([\s\S]*?)</script>""",
      caseSensitive: false,
    );
    for (final match in regex.allMatches(html)) {
      final jsonStr = match.group(1)?.trim();
      if (jsonStr == null) continue;
      try {
        final decoded = json.decode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          final found = _findRecipe(decoded);
          if (found != null) return found;
        } else if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final found = _findRecipe(item);
              if (found != null) return found;
            }
          }
        }
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic>? _findRecipe(Map<String, dynamic> node) {
    final type = node['@type'];
    if (type == 'Recipe' || (type is List && type.contains('Recipe'))) {
      return node;
    }
    final graph = node['@graph'];
    if (graph is List) {
      for (final item in graph) {
        if (item is Map<String, dynamic>) {
          final found = _findRecipe(item);
          if (found != null) return found;
        }
      }
    }
    return null;
  }

  // ── Parsing ─────────────────────────────────────────────────────────────────

  Recipe _parseRecipeJson(Map<String, dynamic> j) {
    final title = j['name']?.toString() ?? '';
    final description = j['description']?.toString() ?? '';

    final cookMin = _parseDuration(j['cookTime']?.toString()) ?? 0;
    final prepMin = _parseDuration(j['prepTime']?.toString()) ?? 0;

    final servings = _parseServings(j['recipeYield']);
    final ingredients = _parseIngredients(j['recipeIngredient']);
    final steps = _parseSteps(j['recipeInstructions']);
    final category = _parseCategory(j['recipeCategory']) ?? 'Dinner';
    final imageUrl = _parseImage(j['image']);

    return Recipe(
      title: title,
      description: description,
      authorId: '',
      authorName: '',
      category: category,
      servings: servings,
      prepTimeMinutes: prepMin,
      cookTimeMinutes: cookMin,
      ingredients: ingredients,
      steps: steps,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
  }

  String? _parseImage(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.startsWith('http')) return raw;
    if (raw is Map) {
      final url = raw['url'];
      if (url is String && url.startsWith('http')) return url;
    }
    if (raw is List && raw.isNotEmpty) return _parseImage(raw.first);
    return null;
  }

  int? _parseDuration(String? s) {
    if (s == null || s.isEmpty) return null;
    final m = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?', caseSensitive: false)
        .firstMatch(s);
    if (m == null) return null;
    final h = int.tryParse(m.group(1) ?? '0') ?? 0;
    final min = int.tryParse(m.group(2) ?? '0') ?? 0;
    return h * 60 + min;
  }

  int _parseServings(dynamic raw) {
    if (raw == null) return 4;
    String s = raw is List ? (raw.isNotEmpty ? raw.first.toString() : '4') : raw.toString();
    final m = RegExp(r'\d+').firstMatch(s);
    return m != null ? int.parse(m.group(0)!) : 4;
  }

  List<Ingredient> _parseIngredients(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => _parseIngredientString(e.toString().trim())).toList();
  }

  Ingredient _parseIngredientString(String s) {
    // Try: "2 cups flour" | "1/2 tsp salt" | "200g chicken"
    final m = RegExp(r'^([\d/\.]+)\s*([a-zA-Z]+\.?)?\s+(.+)$').firstMatch(s);
    if (m != null) {
      final amount = m.group(1) ?? '';
      final unit = m.group(2);
      final name = m.group(3) ?? s;
      return Ingredient(name: name.trim(), amount: amount, unit: unit);
    }
    return Ingredient(name: s, amount: '');
  }

  List<RecipeStep> _parseSteps(dynamic raw) {
    final steps = <RecipeStep>[];
    int order = 1;

    void add(String text) {
      final t = text.trim();
      if (t.isNotEmpty) steps.add(RecipeStep(order: order++, instruction: t));
    }

    if (raw is List) {
      for (final item in raw) {
        if (item is String) {
          add(item);
        } else if (item is Map) {
          final type = item['@type'];
          if (type == 'HowToSection') {
            for (final sub in (item['itemListElement'] as List? ?? [])) {
              if (sub is Map) {
                add(sub['text']?.toString() ?? sub['name']?.toString() ?? '');
              } else if (sub is String) {
                add(sub);
              }
            }
          } else {
            add(item['text']?.toString() ?? item['name']?.toString() ?? '');
          }
        }
      }
    } else if (raw is String) {
      add(raw);
    }

    return steps.isEmpty ? [RecipeStep(order: 1, instruction: '')] : steps;
  }

  String? _parseCategory(dynamic raw) {
    final s = (raw is List ? raw.firstOrNull?.toString() : raw?.toString()) ?? '';
    final lower = s.toLowerCase();
    if (lower.contains('breakfast')) return 'Breakfast';
    if (lower.contains('lunch')) return 'Lunch';
    if (lower.contains('dinner') || lower.contains('main')) return 'Dinner';
    if (lower.contains('dessert') || lower.contains('sweet')) return 'Dessert';
    if (lower.contains('snack')) return 'Snack';
    if (lower.contains('drink') || lower.contains('beverage')) return 'Drink';
    if (lower.contains('salad')) return 'Salad';
    if (lower.contains('soup')) return 'Soup';
    return null;
  }
}
