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

  static const int _pageSize = 10;

  List<Recipe> _streamRecipes = [];
  final List<Recipe> _extraRecipes = [];
  String? _selectedCategory;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  StreamSubscription? _subscription;

  final _authorNameController =
      StreamController<MapEntry<String, String>>.broadcast();
  Stream<MapEntry<String, String>> get authorNameChanges =>
      _authorNameController.stream;

  bool _initialized = false;

  List<Recipe> get allRecipes {
    final ids = _streamRecipes.map((r) => r.id).toSet();
    return [
      ..._streamRecipes,
      ..._extraRecipes.where((r) => !ids.contains(r.id)),
    ];
  }

  List<Recipe> get recipes {
    final pub = allRecipes.where((r) => !r.isPrivate);
    return _selectedCategory == null
        ? pub.toList()
        : pub.where((r) => r.category == _selectedCategory).toList();
  }

  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  void ensureInitialized() {
    if (!_initialized) {
      _initialized = true;
      _listenToRecipes();
    }
  }

  void _listenToRecipes() {
    _isLoading = true;

    if (_streamRecipes.isEmpty && _cacheService != null) {
      final cached = _cacheService.getCachedRecipes();
      if (cached.isNotEmpty) {
        _streamRecipes = cached;
        _isLoading = false;
        notifyListeners();
      }
    }

    _subscription?.cancel();
    _subscription =
        _recipeService.getRecipesStream(limit: _pageSize).listen(
      (recipes) {
        _streamRecipes = recipes;
        _hasMore = recipes.length >= _pageSize;
        _isLoading = false;
        notifyListeners();
        _cacheService?.cacheRecipes(allRecipes);
      },
      onError: (error) {
        debugPrint('RecipeProvider stream error: $error');
        _isLoading = false;
        if (_streamRecipes.isEmpty) {
          _streamRecipes = _cacheService?.getCachedRecipes() ?? [];
        }
        notifyListeners();
        Future.delayed(const Duration(seconds: 3), () {
          if (_initialized) _listenToRecipes();
        });
      },
    );
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    final all = allRecipes;
    if (all.isEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final oldest = all.last.createdAt;
      final more = await _recipeService.loadMoreRecipes(
        beforeCreatedAt: oldest,
        limit: _pageSize,
      );
      _extraRecipes.addAll(more);
      _hasMore = more.length >= _pageSize;
    } catch (e) {
      debugPrint('RecipeProvider loadMore error: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void refresh() {
    _extraRecipes.clear();
    _hasMore = true;
    _listenToRecipes();
  }

  void updateAuthorName(String authorId, String newName) {
    _streamRecipes = _streamRecipes.map((r) {
      if (r.authorId == authorId) return r.copyWith(authorName: newName);
      return r;
    }).toList();
    for (var i = 0; i < _extraRecipes.length; i++) {
      if (_extraRecipes[i].authorId == authorId) {
        _extraRecipes[i] = _extraRecipes[i].copyWith(authorName: newName);
      }
    }
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
      _streamRecipes = [offline, ..._streamRecipes];
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
