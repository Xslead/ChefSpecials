import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/food_item.dart';
import '../../models/meal_entry.dart';
import '../../models/recipe.dart';
import '../../providers/daily_tracker_provider.dart';
import '../../providers/food_item_provider.dart';
import '../../providers/recipe_provider.dart';

class AddMealEntryScreen extends StatefulWidget {
  final MealType mealType;

  const AddMealEntryScreen({super.key, required this.mealType});

  @override
  State<AddMealEntryScreen> createState() => _AddMealEntryScreenState();
}

class _AddMealEntryScreenState extends State<AddMealEntryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<FoodItemProvider>().ensureInitialized();
    context.read<RecipeProvider>().ensureInitialized();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _mealTypeName(AppLocalizations l10n) {
    switch (widget.mealType) {
      case MealType.breakfast:
        return l10n.breakfast;
      case MealType.lunch:
        return l10n.lunch;
      case MealType.dinner:
        return l10n.dinner;
      case MealType.snack:
        return l10n.snack;
    }
  }

  IconData _mealTypeIcon() {
    switch (widget.mealType) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.restaurant;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }

  Color _mealTypeColor() {
    switch (widget.mealType) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.blue;
      case MealType.dinner:
        return Colors.indigo;
      case MealType.snack:
        return Colors.green;
    }
  }

  void _showFoodItemBottomSheet(FoodItem item) {
    final l10n = AppLocalizations.of(context)!;
    final quantityController = TextEditingController(text: '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final qty = double.tryParse(quantityController.text) ?? 0;
            final calcCalories = item.calories * qty / 100;
            final calcProtein = item.protein * qty / 100;
            final calcCarbs = item.carbs * qty / 100;
            final calcFat = item.fat * qty / 100;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Item info
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: AppTheme.primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.brand != null && item.brand!.isNotEmpty)
                              Text(
                                item.brand!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Quantity input
                  Text(
                    '${l10n.quantity} (${l10n.gram})'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      suffixText: l10n.gram,
                      suffixStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryColor, width: 2),
                      ),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 16),
                  // Nutrition row
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        _buildSheetNutrition(
                          l10n.calories,
                          '${calcCalories.toInt()}',
                          l10n.kcal,
                          AppTheme.primaryColor,
                        ),
                        _buildSheetNutrition(
                          l10n.protein,
                          calcProtein.toStringAsFixed(1),
                          l10n.gram,
                          AppTheme.secondaryColor,
                        ),
                        _buildSheetNutrition(
                          l10n.carbs,
                          calcCarbs.toStringAsFixed(1),
                          l10n.gram,
                          const Color(0xFFF59E0B),
                        ),
                        _buildSheetNutrition(
                          l10n.fat,
                          calcFat.toStringAsFixed(1),
                          l10n.gram,
                          const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: qty > 0
                          ? () {
                              final entry = MealEntry(
                                name: item.name,
                                mealType: widget.mealType,
                                foodItemId: item.id,
                                quantity: qty,
                                unit: 'g',
                                calories: calcCalories,
                                protein: calcProtein,
                                carbs: calcCarbs,
                                fat: calcFat,
                              );
                              context
                                  .read<DailyTrackerProvider>()
                                  .addMealEntry(entry);
                              Navigator.pop(ctx);
                              context.pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.addToMeal,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetNutrition(
      String label, String value, String unit, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _addRecipeToMeal(Recipe recipe) {
    final cals = (recipe.caloriesPerServing ?? 0).toDouble();
    final prot = recipe.proteinGrams ?? 0;
    final carb = recipe.carbsGrams ?? 0;
    final f = recipe.fatGrams ?? 0;

    final entry = MealEntry(
      name: recipe.title,
      mealType: widget.mealType,
      recipeId: recipe.id,
      quantity: 1,
      unit: 'serving',
      calories: cals,
      protein: prot,
      carbs: carb,
      fat: f,
    );

    context.read<DailyTrackerProvider>().addMealEntry(entry);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mealColor = _mealTypeColor();

    return Scaffold(
      body: Column(
        children: [
          // Custom header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                          color: AppTheme.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: mealColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _mealTypeIcon(),
                            color: mealColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.addFood,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              _mealTypeName(l10n),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tab bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppTheme.textPrimary,
                      unselectedLabelColor: Colors.grey.shade500,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      dividerHeight: 0,
                      tabs: [
                        Tab(
                          height: 36,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.kitchen, size: 16),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  l10n.selectFoodItem,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          height: 36,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.menu_book, size: 16),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  l10n.selectRecipe,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFoodItemsTab(l10n),
                _buildRecipesTab(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemsTab(AppLocalizations l10n) {
    final foodProvider = context.watch<FoodItemProvider>();
    final hasSearchQuery = foodProvider.searchQuery.isNotEmpty;
    final items =
        hasSearchQuery ? foodProvider.searchResults : foodProvider.foodItems;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search, color: Colors.grey.shade400, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '${l10n.search}...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
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
                      setState(() {});
                      foodProvider.searchFoodItems(value);
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                      foodProvider.searchFoodItems('');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.clear,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // List
        Expanded(
          child: foodProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.kitchen,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noResults,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildFoodItemTile(item, l10n);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFoodItemTile(FoodItem item, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _showFoodItemBottomSheet(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.brand ?? item.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.calories.toInt()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  '${l10n.kcal}/100${l10n.gram}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesTab(AppLocalizations l10n) {
    final recipeProvider = context.watch<RecipeProvider>();
    final recipes = recipeProvider.allRecipes;

    if (recipeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.noRecipes,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final cals = recipe.caloriesPerServing ?? 0;

        return GestureDetector(
          onTap: () => _addRecipeToMeal(recipe),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: AppTheme.secondaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${recipe.servings} ${l10n.servings}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$cals',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '${l10n.kcal}/${l10n.servings}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
