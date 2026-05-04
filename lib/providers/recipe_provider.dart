import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService;
  final CacheService? _cacheService;
  final ConnectivityService? _connectivityService;

  RecipeProvider({
    RecipeService? recipeService,
    CacheService? cacheService,
    ConnectivityService? connectivityService,
  })  : _recipeService = recipeService ?? RecipeService(),
        _cacheService = cacheService,
        _connectivityService = connectivityService;

  List<Recipe> _recipes = [];
  String? _selectedCategory;
  bool _isLoading = false;
  StreamSubscription? _subscription;

  final _authorNameController =
      StreamController<MapEntry<String, String>>.broadcast();
  Stream<MapEntry<String, String>> get authorNameChanges =>
      _authorNameController.stream;

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

    // Serve cached data immediately so UI isn't empty while stream loads
    if (_recipes.isEmpty && _cacheService != null) {
      final cached = _cacheService.getCachedRecipes();
      if (cached.isNotEmpty) {
        _recipes = cached;
        _isLoading = false;
        notifyListeners();
      }
    }

    _subscription?.cancel();
    _subscription = _recipeService.getRecipesStream().listen(
      (recipes) {
        _recipes = recipes;
        _isLoading = false;
        notifyListeners();
        _cacheService?.cacheRecipes(recipes);
      },
      onError: (error) {
        debugPrint('RecipeProvider stream error: $error');
        _isLoading = false;
        if (_recipes.isEmpty) {
          _recipes = _cacheService?.getCachedRecipes() ?? [];
        }
        notifyListeners();
        Future.delayed(const Duration(seconds: 3), () {
          if (_initialized) _listenToRecipes();
        });
      },
    );
  }

  void refresh() {
    _listenToRecipes();
  }

  void updateAuthorName(String authorId, String newName) {
    _recipes = _recipes.map((r) {
      if (r.authorId == authorId) return r.copyWith(authorName: newName);
      return r;
    }).toList();
    _authorNameController.add(MapEntry(authorId, newName));
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<String> createRecipe(Recipe recipe) async {
    final isOnline = await _connectivityService?.isOnline() ?? true;
    if (!isOnline) {
      final tempId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      final offline = recipe.copyWith(id: tempId);
      _recipes = [offline, ..._recipes];
      notifyListeners();
      await _cacheService?.queueOfflineAction({
        'type': 'create_recipe',
        'recipe': {...recipe.toMap(), 'id': tempId},
      });
      return tempId;
    }
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
    _authorNameController.close();
    super.dispose();
  }
}
