import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class SearchProvider extends ChangeNotifier {
  static const String _historyKey = 'search_history';
  static const int _maxHistory = 10;

  final RecipeService _recipeService;

  SearchProvider({RecipeService? recipeService})
      : _recipeService = recipeService ?? RecipeService();

  // ── Text search ──
  String _query = '';
  List<Recipe> _allRecipes = [];
  List<Recipe> _results = [];
  bool _isLoading = false;
  List<String> _suggestions = [];
  List<String> _searchHistory = [];

  // ── Filters ──
  RangeValues? _cookTimeRange;
  RangeValues? _calorieRange;
  String? _difficultyLevel;
  int? _maxIngredientCount;
  String _sortBy = 'newest';

  // ── Ingredient mode ──
  bool _isIngredientMode = false;
  final List<String> _ingredientFilters = [];

  // ── Getters ──
  String get query => _query;
  List<Recipe> get results => _results;
  bool get isLoading => _isLoading;
  List<String> get suggestions => List.unmodifiable(_suggestions);
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  RangeValues? get cookTimeRange => _cookTimeRange;
  RangeValues? get calorieRange => _calorieRange;
  String? get difficultyLevel => _difficultyLevel;
  int? get maxIngredientCount => _maxIngredientCount;
  String get sortBy => _sortBy;
  bool get isIngredientMode => _isIngredientMode;
  List<String> get ingredientFilters => List.unmodifiable(_ingredientFilters);

  int get activeFilterCount {
    int n = 0;
    if (_cookTimeRange != null) n++;
    if (_calorieRange != null) n++;
    if (_difficultyLevel != null) n++;
    if (_maxIngredientCount != null) n++;
    if (_sortBy != 'newest') n++;
    return n;
  }

  // ── Load ──
  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();
    _allRecipes = await _recipeService.getRecipesStream().first;
    _results = _applyAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList(_historyKey) ?? [];
    notifyListeners();
  }

  // ── Text search ──
  void search(String query) {
    _query = query;
    _updateSuggestions(query);
    _results = _applyAll();
    notifyListeners();
  }

  Future<void> commitSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    _searchHistory.remove(q);
    _searchHistory.insert(0, q);
    if (_searchHistory.length > _maxHistory) {
      _searchHistory = _searchHistory.sublist(0, _maxHistory);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _searchHistory);
    notifyListeners();
  }

  Future<void> removeFromHistory(String query) async {
    _searchHistory.remove(query);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _searchHistory);
    notifyListeners();
  }

  void clear() {
    _query = '';
    _suggestions = [];
    _results = _applyAll();
    notifyListeners();
  }

  // ── Filters ──
  void applyFilters({
    required RangeValues? cookTimeRange,
    required RangeValues? calorieRange,
    required String? difficultyLevel,
    required int? maxIngredientCount,
    required String sortBy,
  }) {
    _cookTimeRange = cookTimeRange;
    _calorieRange = calorieRange;
    _difficultyLevel = difficultyLevel;
    _maxIngredientCount = maxIngredientCount;
    _sortBy = sortBy;
    _results = _applyAll();
    notifyListeners();
  }

  void clearFilters() {
    _cookTimeRange = null;
    _calorieRange = null;
    _difficultyLevel = null;
    _maxIngredientCount = null;
    _sortBy = 'newest';
    _results = _applyAll();
    notifyListeners();
  }

  // ── Ingredient mode ──
  void setIngredientMode(bool value) {
    _isIngredientMode = value;
    if (!value) _ingredientFilters.clear();
    _results = _applyAll();
    notifyListeners();
  }

  void addIngredient(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isEmpty || _ingredientFilters.contains(trimmed)) return;
    _ingredientFilters.add(trimmed);
    _results = _applyAll();
    notifyListeners();
  }

  void removeIngredient(String ingredient) {
    _ingredientFilters.remove(ingredient);
    _results = _applyAll();
    notifyListeners();
  }

  // ── Private helpers ──
  void _updateSuggestions(String query) {
    if (query.length < 2) {
      _suggestions = [];
      return;
    }
    final lower = query.toLowerCase();
    final titleMatches = _allRecipes
        .where((r) => r.title.toLowerCase().contains(lower))
        .map((r) => r.title)
        .toSet()
        .take(5)
        .toList();
    final historyMatches = _searchHistory
        .where((h) => h.toLowerCase().contains(lower) && !titleMatches.contains(h))
        .take(3)
        .toList();
    _suggestions = [...titleMatches, ...historyMatches];
  }

  List<Recipe> _applyAll() {
    if (_isIngredientMode) return _applyIngredientSearch();

    final filtered = _allRecipes.where((r) {
      if (_query.isNotEmpty) {
        final lower = _query.toLowerCase();
        final textMatch = r.title.toLowerCase().contains(lower) ||
            r.category.toLowerCase().contains(lower) ||
            r.authorName.toLowerCase().contains(lower) ||
            r.description.toLowerCase().contains(lower) ||
            r.dietaryTags.any((t) => t.toLowerCase().contains(lower));
        if (!textMatch) return false;
      }

      if (_cookTimeRange != null) {
        final totalTime = (r.prepTimeMinutes + r.cookTimeMinutes).toDouble();
        final maxTime =
            _cookTimeRange!.end >= 120 ? double.infinity : _cookTimeRange!.end;
        if (totalTime < _cookTimeRange!.start || totalTime > maxTime) {
          return false;
        }
      }

      if (_calorieRange != null) {
        final cal = (r.caloriesPerServing ?? 0).toDouble();
        final maxCal =
            _calorieRange!.end >= 1000 ? double.infinity : _calorieRange!.end;
        if (cal < _calorieRange!.start || cal > maxCal) return false;
      }

      if (_difficultyLevel != null && r.difficultyLevel != _difficultyLevel) {
        return false;
      }

      if (_maxIngredientCount != null &&
          r.ingredients.length > _maxIngredientCount!) { return false; }

      return true;
    }).toList();

    _sortList(filtered);
    return filtered;
  }

  List<Recipe> _applyIngredientSearch() {
    if (_ingredientFilters.isEmpty) return _allRecipes;

    final pairs = <_Scored>[];
    for (final r in _allRecipes) {
      final names = r.ingredients.map((i) => i.name.toLowerCase()).toList();
      var matched = 0;
      for (final f in _ingredientFilters) {
        final fl = f.toLowerCase();
        if (names.any((n) => n.contains(fl))) matched++;
      }
      if (matched == _ingredientFilters.length) pairs.add(_Scored(r, matched));
    }
    pairs.sort((a, b) => b.score.compareTo(a.score));
    return pairs.map((p) => p.recipe).toList();
  }

  void _sortList(List<Recipe> list) {
    switch (_sortBy) {
      case 'popular':
        list.sort((a, b) => (b.ratingCount + b.commentCount)
            .compareTo(a.ratingCount + a.commentCount));
        break;
      case 'rating':
        list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case 'cookTime':
        list.sort((a, b) => a.cookTimeMinutes.compareTo(b.cookTimeMinutes));
        break;
      case 'calories':
        list.sort((a, b) =>
            (a.caloriesPerServing ?? 0).compareTo(b.caloriesPerServing ?? 0));
        break;
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }
}

class _Scored {
  final Recipe recipe;
  final int score;
  _Scored(this.recipe, this.score);
}
