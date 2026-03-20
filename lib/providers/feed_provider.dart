import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/user_model.dart';
import '../services/recipe_service.dart';
import '../services/user_service.dart';

class FeedProvider extends ChangeNotifier {
  final RecipeService _recipeService;
  final UserService _userService;

  FeedProvider({RecipeService? recipeService, UserService? userService})
      : _recipeService = recipeService ?? RecipeService(),
        _userService = userService ?? UserService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DateTime? _oldestLoaded;
  String _searchQuery = '';
  List<String> _followingIds = [];
  String? _selectedCategory;
  final Set<String> _selectedDietaryTags = {};
  String _sortBy = 'newest';
  List<UserModel> _searchedUsers = [];
  bool _isSearchingUsers = false;
  String? _error;

  Timer? _userSearchDebounce;

  // Getters
  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  List<String> get followingIds => _followingIds;
  String? get selectedCategory => _selectedCategory;
  Set<String> get selectedDietaryTags => _selectedDietaryTags;
  String get sortBy => _sortBy;
  List<UserModel> get searchedUsers => _searchedUsers;
  bool get isSearchingUsers => _isSearchingUsers;
  String? get error => _error;

  int get activeFilterCount =>
      (_selectedCategory != null ? 1 : 0) +
      _selectedDietaryTags.length +
      (_sortBy != 'newest' ? 1 : 0);

  List<Recipe> get displayedRecipes {
    var result = _recipes.toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result =
          result.where((r) => r.title.toLowerCase().contains(q)).toList();
    }
    if (_selectedCategory != null) {
      result =
          result.where((r) => r.category == _selectedCategory).toList();
    }
    if (_selectedDietaryTags.isNotEmpty) {
      result = result
          .where(
              (r) => _selectedDietaryTags.every((t) => r.dietaryTags.contains(t)))
          .toList();
    }
    switch (_sortBy) {
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case 'popular':
        result.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  Future<void> loadFeed(List<String> followingIds) async {
    _followingIds = followingIds;
    _isLoading = true;
    _recipes = [];
    _oldestLoaded = null;
    _hasMore = true;
    _error = null;
    notifyListeners();

    if (followingIds.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final fetched = await _recipeService.getFeedRecipes(followingIds);
      _recipes = fetched;
      _hasMore = fetched.length == 20;
      _oldestLoaded = fetched.isNotEmpty ? fetched.last.createdAt : null;
    } catch (e) {
      debugPrint('FeedProvider load error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _oldestLoaded == null) return;
    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _recipeService.getFeedRecipes(
        _followingIds,
        before: _oldestLoaded,
      );
      _recipes.addAll(fetched);
      _hasMore = fetched.length == 20;
      if (fetched.isNotEmpty) _oldestLoaded = fetched.last.createdAt;
    } catch (e) {
      debugPrint('FeedProvider loadMore error: $e');
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String value) {
    final trimmed = value.trim();
    _searchQuery = trimmed;
    _error = null;
    notifyListeners();

    _userSearchDebounce?.cancel();
    if (trimmed.isEmpty) {
      _searchedUsers = [];
      _isSearchingUsers = false;
      notifyListeners();
      return;
    }

    _isSearchingUsers = true;
    notifyListeners();

    _userSearchDebounce =
        Timer(const Duration(milliseconds: 400), () async {
      try {
        final users = await _userService.searchUsers(trimmed, limit: 10);
        if (_searchQuery == trimmed) {
          _searchedUsers = users;
          _isSearchingUsers = false;
          notifyListeners();
        }
      } catch (e) {
        _isSearchingUsers = false;
        _error = e.toString();
        notifyListeners();
      }
    });
  }

  void clearSearch() {
    _searchQuery = '';
    _searchedUsers = [];
    _isSearchingUsers = false;
    _userSearchDebounce?.cancel();
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleDietaryTag(String tag) {
    if (_selectedDietaryTags.contains(tag)) {
      _selectedDietaryTags.remove(tag);
    } else {
      _selectedDietaryTags.add(tag);
    }
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedDietaryTags.clear();
    _sortBy = 'newest';
    notifyListeners();
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

  @override
  void dispose() {
    _userSearchDebounce?.cancel();
    super.dispose();
  }
}
