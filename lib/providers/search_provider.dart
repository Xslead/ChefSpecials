import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class SearchProvider extends ChangeNotifier {
  final RecipeService _recipeService;

  SearchProvider({RecipeService? recipeService})
      : _recipeService = recipeService ?? RecipeService();

  String _query = '';
  List<Recipe> _allRecipes = [];
  List<Recipe> _results = [];
  bool _isLoading = false;

  String get query => _query;
  List<Recipe> get results => _results;
  bool get isLoading => _isLoading;

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();
    // Get recipes once from stream
    _allRecipes = await _recipeService.getRecipesStream().first;
    _results = _allRecipes;
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _query = query;
    if (query.isEmpty) {
      _results = _allRecipes;
    } else {
      final lower = query.toLowerCase();
      _results = _allRecipes.where((r) {
        return r.title.toLowerCase().contains(lower) ||
            r.category.toLowerCase().contains(lower) ||
            r.authorName.toLowerCase().contains(lower) ||
            r.description.toLowerCase().contains(lower) ||
            r.dietaryTags.any((tag) => tag.toLowerCase().contains(lower));
      }).toList();
    }
    notifyListeners();
  }

  void clear() {
    _query = '';
    _results = _allRecipes;
    notifyListeners();
  }
}
