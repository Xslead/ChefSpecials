import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../utils/category_helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/empty_state.dart';
import '../home/widgets/recipe_card.dart';
import '../home/widgets/privacy_badge.dart';

class MyRecipesScreen extends StatefulWidget {
  final String? userId;

  const MyRecipesScreen({super.key, this.userId});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  String? _selectedCategory;
  final Set<String> _selectedDietaryTags = {};
  String _sortBy = 'newest';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchBarKey = GlobalKey();
  String _searchQuery = '';

  int get _activeFilterCount =>
      (_selectedCategory != null ? 1 : 0) +
      _selectedDietaryTags.length +
      (_sortBy != 'newest' ? 1 : 0);

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

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_selectedCategory != null) {
      filtered = filtered.where((r) => r.category == _selectedCategory).toList();
    }
    if (_selectedDietaryTags.isNotEmpty) {
      filtered = filtered
          .where((r) => _selectedDietaryTags.every((t) => r.dietaryTags.contains(t)))
          .toList();
    }
    switch (_sortBy) {
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case 'popular':
        filtered.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
                ? EmptyState(
                    icon: Icons.menu_book,
                    title: l10n.noRecipes,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                ],
              ),
              const SizedBox(height: 14),
              // Search bar + filter button
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!_isSearching) setState(() => _isSearching = true);
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
                                  Icon(Icons.search,
                                      color: AppTheme.textTertiaryOf(context),
                                      size: 22),
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
                                        filled: false,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                      onChanged: (value) =>
                                          setState(() => _searchQuery = value),
                                      onTapOutside: (event) {
                                        final box = _searchBarKey.currentContext
                                            ?.findRenderObject() as RenderBox?;
                                        if (box != null) {
                                          final localPos = box
                                              .globalToLocal(event.position);
                                          if (box.paintBounds
                                              .contains(localPos)) { return; }
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
                                      child: Icon(Icons.clear,
                                          size: 18,
                                          color:
                                              AppTheme.textTertiaryOf(context)),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  const SizedBox(width: 14),
                                  Icon(Icons.search,
                                      color: AppTheme.textTertiaryOf(context),
                                      size: 22),
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
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context, l10n),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _activeFilterCount > 0
                            ? AppTheme.primaryColor
                            : AppTheme.neutralLightOf(context),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Badge(
                        isLabelVisible: _activeFilterCount > 0,
                        label: Text('$_activeFilterCount',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700)),
                        backgroundColor: Colors.white,
                        textColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.tune_rounded,
                          size: 22,
                          color: _activeFilterCount > 0
                              ? Colors.white
                              : AppTheme.textTertiaryOf(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.neutralLightOf(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: AppTheme.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.filters,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (_activeFilterCount > 0)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                              _selectedDietaryTags.clear();
                              _sortBy = 'newest';
                            });
                            setSheetState(() {});
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text(l10n.clearAll,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: AppTheme.neutralLightOf(context), height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context,
                            icon: Icons.category_rounded, title: l10n.category),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.defaultCategories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return _buildChip(
                              context: context,
                              label: _localizeCategory(cat, l10n),
                              selected: isSelected,
                              onTap: () {
                                setState(() => _selectedCategory =
                                    isSelected ? null : cat);
                                setSheetState(() {});
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(context,
                            icon: Icons.eco_rounded, title: l10n.dietaryTags),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.defaultDietaryTags.map((tag) {
                            final isSelected =
                                _selectedDietaryTags.contains(tag);
                            return _buildChip(
                              context: context,
                              label: localizeDietaryTag(tag, l10n),
                              selected: isSelected,
                              outlined: true,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedDietaryTags.remove(tag);
                                  } else {
                                    _selectedDietaryTags.add(tag);
                                  }
                                });
                                setSheetState(() {});
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(context,
                            icon: Icons.sort_rounded, title: l10n.sortBy),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildSortOption(
                                context, setSheetState, 'newest', l10n.newest),
                            _buildSortOption(
                                context, setSheetState, 'oldest', l10n.oldest),
                            _buildSortOption(context, setSheetState, 'popular',
                                l10n.popular),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _activeFilterCount > 0
                            ? l10n.applyFiltersCount(_activeFilterCount)
                            : l10n.applyFilters,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context,
      {required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryOf(context),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? (outlined
                  ? AppTheme.primaryColor.withValues(alpha: 0.12)
                  : AppTheme.primaryColor)
              : AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(50),
          border: selected && outlined
              ? Border.all(color: AppTheme.primaryColor, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? (outlined ? AppTheme.primaryColor : Colors.white)
                : AppTheme.textSecondaryOf(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, StateSetter setSheetState,
      String value, String label) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = value);
        setSheetState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppTheme.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
