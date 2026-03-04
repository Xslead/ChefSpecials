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
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    item.name,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  if (item.brand != null && item.brand!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.brand!,
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  TextField(
                    controller: quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: '${l10n.quantity} (${l10n.gram})',
                      suffixText: l10n.gram,
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NutritionChip(
                          label: l10n.calories,
                          value: '${calcCalories.toInt()}',
                          unit: l10n.kcal,
                          color: AppTheme.primaryColor,
                        ),
                        _NutritionChip(
                          label: l10n.protein,
                          value: calcProtein.toStringAsFixed(1),
                          unit: l10n.gram,
                          color: AppTheme.secondaryColor,
                        ),
                        _NutritionChip(
                          label: l10n.carbs,
                          value: calcCarbs.toStringAsFixed(1),
                          unit: l10n.gram,
                          color: const Color(0xFFF59E0B),
                        ),
                        _NutritionChip(
                          label: l10n.fat,
                          value: calcFat.toStringAsFixed(1),
                          unit: l10n.gram,
                          color: const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
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
                      child: Text(l10n.addToMeal),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.addFood} - ${_mealTypeName(l10n)}'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(text: l10n.selectFoodItem),
            Tab(text: l10n.selectRecipe),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFoodItemsTab(l10n),
          _buildRecipesTab(l10n),
        ],
      ),
    );
  }

  Widget _buildFoodItemsTab(AppLocalizations l10n) {
    final foodProvider = context.watch<FoodItemProvider>();
    final hasSearchQuery =
        foodProvider.searchQuery.isNotEmpty;
    final items =
        hasSearchQuery ? foodProvider.searchResults : foodProvider.foodItems;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '${l10n.search}...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        foodProvider.searchFoodItems('');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
              foodProvider.searchFoodItems(value);
            },
          ),
        ),
        Expanded(
          child: foodProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noMealsYet,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            item.brand ?? item.category,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            '${item.calories.toInt()} ${l10n.kcal}/100${l10n.gram}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          onTap: () => _showFoodItemBottomSheet(item),
                        );
                      },
                    ),
        ),
      ],
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
        child: Text(
          l10n.noRecipes,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final cals = recipe.caloriesPerServing ?? 0;

        return ListTile(
          title: Text(
            recipe.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            '${recipe.servings} ${l10n.servings}',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: Text(
            '$cals ${l10n.kcal}/${l10n.servings}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          onTap: () => _addRecipeToMeal(recipe),
        );
      },
    );
  }
}

class _NutritionChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutritionChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
