import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _recipes = [];
  String? _selectedCategory;
  bool _isLoading = false;
  StreamSubscription? _subscription;

  bool _initialized = false;

  List<Recipe> get recipes {
    final pub = _recipes.where((r) => !r.isPrivate);
    return _selectedCategory == null
        ? pub.toList()
        : pub.where((r) => r.category == _selectedCategory).toList();
  }
  List<Recipe> get allRecipes => _recipes;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  void ensureInitialized() {
    if (!_initialized) {
      _initialized = true;
      _listenToRecipes();
    }
  }

  void _listenToRecipes() {
    _isLoading = true;
    _subscription?.cancel();
    _subscription = _recipeService.getRecipesStream().listen(
      (recipes) {
        _recipes = recipes;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void refresh() {
    _listenToRecipes();
  }

  void updateAuthorName(String authorId, String newName) {
    _recipes = _recipes.map((r) {
      if (r.authorId == authorId) {
        return r.copyWith(authorName: newName);
      }
      return r;
    }).toList();
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<String> createRecipe(Recipe recipe) async {
    return await _recipeService.createRecipe(recipe);
  }

  Future<void> updateRecipe(String id, Map<String, dynamic> data) async {
    await _recipeService.updateRecipe(id, data);
  }

  Future<void> deleteRecipe(String id) async {
    await _recipeService.deleteRecipe(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
