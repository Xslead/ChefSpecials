import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../home/widgets/recipe_card.dart';
import '../home/widgets/privacy_badge.dart';

enum _SortOption { newest, oldest, category }

class MyRecipesScreen extends StatefulWidget {
  final String? userId;

  const MyRecipesScreen({super.key, this.userId});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  String? _selectedCategory;
  _SortOption _sortOption = _SortOption.newest;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchBarKey = GlobalKey();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _isSearching) {
        setState(() {
          _isSearching = false;
          _searchQuery = '';
          _searchController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
  }

  List<Recipe> _filterAndSort(List<Recipe> recipes) {
    var filtered = recipes;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((r) => r.category == _selectedCategory).toList();
    }

    switch (_sortOption) {
      case _SortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOption.category:
        filtered.sort((a, b) => a.category.compareTo(b.category));
    }

    return filtered;
  }

  String _localizeCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Breakfast':
        return l10n.breakfast;
      case 'Lunch':
        return l10n.lunch;
      case 'Dinner':
        return l10n.dinner;
      case 'Dessert':
        return l10n.dessert;
      case 'Snack':
        return l10n.snack;
      case 'Drink':
        return l10n.drink;
      case 'Salad':
        return l10n.salad;
      case 'Soup':
        return l10n.soup;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final recipeProvider = context.watch<RecipeProvider>();
    final currentUser = authProvider.userModel;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isOwnProfile = widget.userId == null || widget.userId == currentUser.uid;
    final targetUid = widget.userId ?? currentUser.uid;

    final userRecipes = recipeProvider.allRecipes
        .where((r) =>
            r.authorId == targetUid && (isOwnProfile || !r.isPrivate))
        .toList();
    final displayedRecipes = _filterAndSort(userRecipes);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, userRecipes.length, isOwnProfile),
          Expanded(
            child: displayedRecipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 64,
                          color: AppTheme.neutralLightOf(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noRecipes,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: displayedRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = displayedRecipes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: isOwnProfile
                            ? Stack(
                                children: [
                                  RecipeCard(recipe: recipe),
                                  Positioned(
                                    top: 12,
                                    right: 52,
                                    child: PrivacyBadge(recipe: recipe),
                                  ),
                                ],
                              )
                            : RecipeCard(recipe: recipe),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isOwnProfile
          ? FloatingActionButton(
              heroTag: 'my_recipes_fab',
              onPressed: () => context.push('/add-recipe'),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, int totalCount, bool isOwnProfile) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                    color: AppTheme.textPrimaryOf(context),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOwnProfile ? l10n.myRecipes : l10n.recipes,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        l10n.recipeCount(totalCount),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PopupMenuButton<_SortOption>(
                    icon: Icon(
                      Icons.sort,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                    tooltip: l10n.sortBy,
                    onSelected: (option) => setState(() => _sortOption = option),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _SortOption.newest,
                        child: Text(l10n.newest),
                      ),
                      PopupMenuItem(
                        value: _SortOption.oldest,
                        child: Text(l10n.oldest),
                      ),
                      PopupMenuItem(
                        value: _SortOption.category,
                        child: Text(l10n.category),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Search bar
              GestureDetector(
                onTap: () {
                  if (!_isSearching) {
                    setState(() => _isSearching = true);
                  }
                },
                child: Container(
                  key: _searchBarKey,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.neutralLightOf(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _isSearching
                      ? Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search,
                              color: AppTheme.textTertiaryOf(context),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: l10n.searchRecipeOrIngredient,
                                  hintStyle: TextStyle(
                                    color: AppTheme.textTertiaryOf(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                onChanged: (value) {
                                  setState(() => _searchQuery = value);
                                },
                                onTapOutside: (event) {
                                  final box = _searchBarKey.currentContext
                                      ?.findRenderObject() as RenderBox?;
                                  if (box != null) {
                                    final localPos =
                                        box.globalToLocal(event.position);
                                    if (box.paintBounds.contains(localPos)) {
                                      return;
                                    }
                                  }
                                  _closeSearch();
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_searchController.text.isEmpty) {
                                  _closeSearch();
                                } else {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.clear,
                                  size: 18,
                                  color: AppTheme.textTertiaryOf(context),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search,
                              color: AppTheme.textTertiaryOf(context),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.searchRecipeOrIngredient,
                              style: TextStyle(
                                color: AppTheme.textTertiaryOf(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 14),
              // Category filter pills
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPill(
                      label: l10n.all,
                      isSelected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    ...AppConstants.defaultCategories.map(
                      (category) => _buildPill(
                        label: _localizeCategory(category, l10n),
                        isSelected: _selectedCategory == category,
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.neutralLightOf(context),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
            ),
          ),
        ),
      ),
    );
  }
}
