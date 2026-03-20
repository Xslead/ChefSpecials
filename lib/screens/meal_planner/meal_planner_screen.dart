import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/planned_meal.dart';
import '../../models/recipe.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/shopping_list_provider.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeProvider>().ensureInitialized();
    final userId = context.read<AuthProvider>().userModel?.uid;
    if (userId != null) {
      context.read<MealPlanProvider>().init(userId);
    }
  }

  String? get _userId => context.read<AuthProvider>().userModel?.uid;

  /// Auto-sync the shopping list for the current week (if one was already created).
  Future<void> _syncShoppingList() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      final mealProvider = context.read<MealPlanProvider>();
      final recipeProvider = context.read<RecipeProvider>();
      final shoppingProvider = context.read<ShoppingListProvider>();
      shoppingProvider.init(userId);

      final items = mealProvider.generateShoppingItems(recipeProvider.allRecipes);
      final weekStartIso = mealProvider.selectedWeekStart.toIso8601String();
      await shoppingProvider.syncMealPlanList(weekStartIso, items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.syncFailed)),
        );
      }
    }
  }

  static const _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  String _dayName(AppLocalizations l10n, int day) {
    switch (day) {
      case 0:
        return l10n.monday;
      case 1:
        return l10n.tuesday;
      case 2:
        return l10n.wednesday;
      case 3:
        return l10n.thursday;
      case 4:
        return l10n.friday;
      case 5:
        return l10n.saturday;
      case 6:
        return l10n.sunday;
      default:
        return '';
    }
  }

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  String _mealTypeName(AppLocalizations l10n, String type) {
    switch (type) {
      case 'breakfast':
        return l10n.breakfast;
      case 'lunch':
        return l10n.lunch;
      case 'dinner':
        return l10n.dinner;
      case 'snack':
        return l10n.snack;
      default:
        return type;
    }
  }

  Color _mealTypeColor(String type) {
    switch (type) {
      case 'breakfast':
        return AppTheme.breakfastColor;
      case 'lunch':
        return AppTheme.lunchColor;
      case 'dinner':
        return AppTheme.dinnerColor;
      case 'snack':
        return AppTheme.snackColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _mealTypeIcon(String type) {
    switch (type) {
      case 'breakfast':
        return Icons.coffee;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.eco;
      default:
        return Icons.restaurant;
    }
  }

  void _copyCurrentWeek() {
    try {
      context.read<MealPlanProvider>().copyCurrentWeek();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.weekCopied)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noMealsToCopy)),
        );
      }
    }
  }

  Future<void> _pasteToCurrentWeek() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await context.read<MealPlanProvider>().pasteToCurrentWeek(userId);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.weekPasted)),
        );
        _syncShoppingList();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noCopiedMeals)),
        );
      }
    }
  }

  Future<void> _generateShoppingList() async {
    final mealProvider = context.read<MealPlanProvider>();
    final recipeProvider = context.read<RecipeProvider>();
    final l10n = AppLocalizations.of(context)!;
    final userId = _userId;
    if (userId == null) return;

    final items = mealProvider.generateShoppingItems(recipeProvider.allRecipes);

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noMealsPlanned)),
      );
      return;
    }

    try {
      final weekStart = mealProvider.selectedWeekStart;
      final weekStartIso = weekStart.toIso8601String();
      final listName =
          '${l10n.mealPlanner} – ${DateFormat('MMM d').format(weekStart)}';
      final shoppingProvider = context.read<ShoppingListProvider>();
      shoppingProvider.init(userId);
      final listId = await shoppingProvider.upsertMealPlanList(
          listName, items, weekStartIso);
      if (mounted) {
        context.push('/shopping-list/$listId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error)),
        );
      }
    }
  }

  void _showRecipePicker(int day, String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
      ),
      builder: (ctx) => _RecipePickerSheet(
        day: day,
        mealType: mealType,
        onRecipeSelected: (recipe) async {
          final userId = _userId;
          if (userId == null) return;
          final meal = PlannedMeal(
            day: day,
            mealType: mealType,
            recipeId: recipe.id!,
            recipeName: recipe.title,
            recipeImageUrl: recipe.imageUrl,
            servings: 1,
          );
          Navigator.of(ctx).pop();
          try {
            await context.read<MealPlanProvider>().addMeal(userId, meal);
            if (mounted) _syncShoppingList();
          } catch (e) {
            if (mounted) {
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.error)),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _removeMeal(PlannedMeal meal) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await context.read<MealPlanProvider>().removeMeal(userId, meal);
      if (mounted) _syncShoppingList();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error)),
        );
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<MealPlanProvider>();

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(l10n, provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(l10n, provider),
          ),
        ],
      ),
    );
  }

  // ─── Header matching the app's standard header pattern ───
  Widget _buildHeader(AppLocalizations l10n, MealPlanProvider provider) {
    final weekStart = provider.selectedWeekStart;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        boxShadow: [AppTheme.shadowOf(context)],
        border: Border(
          bottom: BorderSide(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Row 1: Back + icon badge + title + actions
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppTheme.textPrimaryOf(context),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.mealPlanner,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 20),
                    onPressed: _copyCurrentWeek,
                    color: AppTheme.textSecondaryOf(context),
                    tooltip: l10n.copyWeek,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.paste_outlined,
                      size: 20,
                      color: provider.hasCopiedMeals
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondaryOf(context)
                              .withValues(alpha: 0.4),
                    ),
                    onPressed:
                        provider.hasCopiedMeals ? _pasteToCurrentWeek : null,
                    tooltip: l10n.pasteWeek,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                    onPressed: _generateShoppingList,
                    color: AppTheme.textSecondaryOf(context),
                    tooltip: l10n.generateShoppingListFromPlan,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Row 2: Week navigation with day circles
              Row(
                children: [
                  GestureDetector(
                    onTap: () => provider.navigateWeek(-1),
                    child: Icon(
                      Icons.chevron_left,
                      color: AppTheme.textSecondaryOf(context),
                      size: 22,
                    ),
                  ),
                  ...List.generate(7, (i) {
                    final day = weekStart.add(Duration(days: i));
                    final isToday = _isSameDay(day, DateTime.now());
                    final meals = provider.getMealsForDay(i);
                    final hasMeals = meals.isNotEmpty;

                    final isFilled = isToday || hasMeals;

                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            _dayLetters[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isFilled
                                  ? AppTheme.primaryColor
                                  : AppTheme.textTertiaryOf(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              border: !isFilled
                                  ? Border.all(
                                      color:
                                          AppTheme.neutralLightOf(context),
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isFilled
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isFilled
                                      ? Colors.white
                                      : AppTheme.textPrimaryOf(context),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Today indicator dot
                          if (isToday)
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(height: 5),
                        ],
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () => provider.navigateWeek(1),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondaryOf(context),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Row 3: Week date range text
              Text(
                '${DateFormat('MMM d').format(weekStart)} – ${DateFormat('MMM d, yyyy').format(weekStart.add(const Duration(days: 6)))}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryOf(context),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Body: day sections with meal cards ───
  Widget _buildBody(AppLocalizations l10n, MealPlanProvider provider) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: List.generate(7, (dayIndex) {
        final dayMeals = provider.getMealsForDay(dayIndex);
        final dayDate =
            provider.selectedWeekStart.add(Duration(days: dayIndex));
        final isToday = _isSameDay(dayDate, DateTime.now());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  if (isToday)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    _dayName(l10n, dayIndex),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: isToday
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d').format(dayDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textTertiaryOf(context),
                    ),
                  ),
                  const Spacer(),
                  if (dayMeals.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dayMeals.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Meal type cards for this day
            ..._mealTypes.map(
              (type) => _buildMealTypeCard(l10n, provider, dayIndex, type),
            ),
          ],
        );
      }),
    );
  }

  // ─── Meal type card (matches MealSectionCard pattern) ───
  Widget _buildMealTypeCard(
    AppLocalizations l10n,
    MealPlanProvider provider,
    int day,
    String mealType,
  ) {
    final meals = provider.getMealsForSlot(day, mealType);
    final color = _mealTypeColor(mealType);
    final icon = _mealTypeIcon(mealType);
    final hasMeals = meals.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
          boxShadow: [AppTheme.shadowOf(context)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Icon badge
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mealTypeName(l10n, mealType),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasMeals
                              ? l10n.mealPlanServings(meals.fold<int>(
                                  0, (sum, m) => sum + m.servings))
                              : l10n.noMealsPlanned,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiaryOf(context),
                            fontStyle: hasMeals
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add button
                  Material(
                    color: color,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => _showRecipePicker(day, mealType),
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Meal entries
            if (hasMeals)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.neutralLightOf(context)
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Column(
                  children: meals.map((meal) => _buildMealEntry(meal)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Individual meal entry row ───
  Widget _buildMealEntry(PlannedMeal meal) {
    return Dismissible(
      key: ValueKey(
          '${meal.day}_${meal.mealType}_${meal.recipeId}_${meal.servings}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              meal.servings > 1 ? '-1' : '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.remove_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 20),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        await _removeMeal(meal);
        return false; // Don't auto-remove; stream update handles UI
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            // Recipe thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 36,
                height: 36,
                child: meal.recipeImageUrl != null &&
                        meal.recipeImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: meal.recipeImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: AppTheme.neutralLightOf(context),
                          child: Icon(Icons.restaurant,
                              size: 16,
                              color: AppTheme.textTertiaryOf(context)),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: AppTheme.neutralLightOf(context),
                          child: Icon(Icons.restaurant,
                              size: 16,
                              color: AppTheme.textTertiaryOf(context)),
                        ),
                      )
                    : Container(
                        color: AppTheme.neutralLightOf(context),
                        child: Icon(Icons.restaurant,
                            size: 16,
                            color: AppTheme.textTertiaryOf(context)),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            // Name
            Expanded(
              child: Text(
                meal.recipeName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryOf(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Servings badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.neutralSoftOf(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'x${meal.servings}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondaryOf(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recipe Picker Bottom Sheet ───
class _RecipePickerSheet extends StatefulWidget {
  final int day;
  final String mealType;
  final ValueChanged<Recipe> onRecipeSelected;

  const _RecipePickerSheet({
    required this.day,
    required this.mealType,
    required this.onRecipeSelected,
  });

  @override
  State<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<_RecipePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipeProvider = context.watch<RecipeProvider>();
    final allRecipes = recipeProvider.allRecipes;

    final filtered = _query.isEmpty
        ? allRecipes
        : allRecipes
            .where(
              (r) =>
                  r.title.toLowerCase().contains(_query.toLowerCase()) ||
                  r.category.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.neutralLightOf(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title row with icon badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.selectRecipe,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.neutralSoftOf(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: AppTheme.textTertiaryOf(context),
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.neutralSoftOf(context),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.search_off,
                            size: 30,
                            color: AppTheme.neutralLightOf(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noResults,
                          style: TextStyle(
                            color: AppTheme.textSecondaryOf(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppTheme.neutralLightOf(context)
                          .withValues(alpha: 0.5),
                    ),
                    itemBuilder: (context, index) {
                      final recipe = filtered[index];
                      return _buildRecipeRow(recipe);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeRow(Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      onTap: () => widget.onRecipeSelected(recipe),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        child: SizedBox(
          width: 48,
          height: 48,
          child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: recipe.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: AppTheme.neutralLightOf(context),
                    child: Icon(Icons.restaurant,
                        size: 24, color: AppTheme.textTertiaryOf(context)),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppTheme.neutralLightOf(context),
                    child: Icon(Icons.restaurant,
                        size: 24, color: AppTheme.textTertiaryOf(context)),
                  ),
                )
              : Container(
                  color: AppTheme.neutralLightOf(context),
                  child: Icon(Icons.restaurant,
                      size: 24, color: AppTheme.textTertiaryOf(context)),
                ),
        ),
      ),
      title: Text(
        recipe.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Row(
        children: [
          Text(
            recipe.category,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
          if (recipe.caloriesPerServing != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.local_fire_department,
                size: 14, color: AppTheme.starColor),
            const SizedBox(width: 2),
            Text(
              '${recipe.caloriesPerServing} ${l10n.kcal}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
          ],
        ],
      ),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          color: AppTheme.primaryColor,
          size: 18,
        ),
      ),
    );
  }
}
