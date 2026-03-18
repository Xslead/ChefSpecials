import 'dart:async';
import 'package:flutter/material.dart';
import '../models/meal_plan.dart';
import '../models/planned_meal.dart';
import '../models/recipe.dart';
import '../models/shopping_list.dart';
import '../services/meal_plan_service.dart';

class MealPlanProvider extends ChangeNotifier {
  final MealPlanService _service;

  MealPlanProvider({MealPlanService? service})
      : _service = service ?? MealPlanService();

  MealPlan? _currentPlan;
  DateTime _selectedWeekStart = _getMonday(DateTime.now());
  bool _isLoading = false;
  String? _userId;
  StreamSubscription? _planSubscription;
  List<PlannedMeal>? _copiedMeals;

  // Getters
  MealPlan? get currentPlan => _currentPlan;
  DateTime get selectedWeekStart => _selectedWeekStart;
  bool get isLoading => _isLoading;
  bool get hasCopiedMeals => _copiedMeals != null && _copiedMeals!.isNotEmpty;

  /// Get all meals for a specific day (0=Monday through 6=Sunday).
  List<PlannedMeal> getMealsForDay(int day) {
    return _currentPlan?.meals.where((m) => m.day == day).toList() ?? [];
  }

  /// Get meals for a specific day and meal type.
  List<PlannedMeal> getMealsForSlot(int day, String mealType) {
    return _currentPlan?.meals
            .where((m) => m.day == day && m.mealType == mealType)
            .toList() ??
        [];
  }

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _listenToPlan();
  }

  void _listenToPlan() {
    _planSubscription?.cancel();
    if (_userId == null) return;

    if (_currentPlan == null && !_isLoading) {
      _isLoading = true;
    }
    _currentPlan = null;

    _planSubscription =
        _service.getMealPlanStream(_userId!, _selectedWeekStart).listen(
      (plan) {
        _currentPlan = plan;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Navigate weeks: -1 for previous, +1 for next.
  void navigateWeek(int direction) {
    _selectedWeekStart =
        _selectedWeekStart.add(Duration(days: 7 * direction));
    _listenToPlan();
    notifyListeners();
  }

  /// Add a meal to the current week's plan. Creates the plan if it doesn't exist.
  Future<void> addMeal(String userId, PlannedMeal meal) async {
    if (_currentPlan?.id != null) {
      await _service.addMealToDay(_currentPlan!.id!, meal);
    } else {
      final now = DateTime.now();
      final newPlan = MealPlan(
        userId: userId,
        weekStartDate: _selectedWeekStart,
        meals: [meal],
        createdAt: now,
        updatedAt: now,
      );
      await _service.createMealPlan(newPlan);
    }
  }

  /// Remove a meal from the current week's plan.
  Future<void> removeMeal(String userId, PlannedMeal meal) async {
    if (_currentPlan?.id == null) return;
    await _service.removeMealFromDay(_currentPlan!.id!, meal);
  }

  /// Copy last week's meal plan to the current week.
  Future<void> copyFromLastWeek(String userId) async {
    await _service.copyFromPreviousWeek(userId, _selectedWeekStart);
  }

  /// Copy current week's meals to the in-memory clipboard.
  void copyCurrentWeek() {
    if (_currentPlan == null || _currentPlan!.meals.isEmpty) {
      throw Exception('No meals to copy');
    }
    _copiedMeals = List<PlannedMeal>.from(_currentPlan!.meals);
    notifyListeners();
  }

  /// Paste the previously copied meals into the currently viewed week.
  Future<void> pasteToCurrentWeek(String userId) async {
    if (_copiedMeals == null || _copiedMeals!.isEmpty) {
      throw Exception('No copied meals');
    }
    await _service.pasteMealsToWeek(userId, _selectedWeekStart, _copiedMeals!);
    // Re-subscribe to ensure the stream picks up the newly created/updated plan
    _listenToPlan();
  }

  /// Generate shopping items from planned meals by looking up recipe ingredients.
  /// Aggregates same-name+unit ingredients across all recipes, multiplied by servings.
  List<ShoppingItem> generateShoppingItems(List<Recipe> recipes) {
    if (_currentPlan == null || _currentPlan!.meals.isEmpty) return [];

    final recipeMap = <String, Recipe>{};
    for (final recipe in recipes) {
      if (recipe.id != null) recipeMap[recipe.id!] = recipe;
    }

    // key = "name|unit" for aggregation
    final aggregated = <String, _AggregatedIngredient>{};

    for (final meal in _currentPlan!.meals) {
      final recipe = recipeMap[meal.recipeId];
      if (recipe == null) continue;

      for (final ing in recipe.ingredients) {
        final key = '${ing.name.toLowerCase()}|${ing.unit ?? ''}';
        final parsedAmount = double.tryParse(ing.amount) ?? 0;
        final totalAmount = parsedAmount * meal.servings;

        if (aggregated.containsKey(key)) {
          aggregated[key]!.amount += totalAmount;
        } else {
          aggregated[key] = _AggregatedIngredient(
            name: ing.name,
            amount: totalAmount,
            unit: ing.unit,
          );
        }
      }
    }

    return aggregated.values
        .map((a) => ShoppingItem(
              name: a.name,
              amount: a.amount % 1 == 0
                  ? a.amount.toInt().toString()
                  : a.amount.toStringAsFixed(1),
              unit: a.unit,
            ))
        .toList();
  }

  /// Calculate weekly nutrition totals from planned meals using recipe data.
  /// Returns a map with keys: totalCalories, protein, carbs, fat.
  Map<String, double> getWeeklyNutrition(List<Recipe> recipes) {
    double totalCalories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    if (_currentPlan == null) {
      return {
        'totalCalories': totalCalories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
    }

    final recipeMap = <String, Recipe>{};
    for (final recipe in recipes) {
      if (recipe.id != null) {
        recipeMap[recipe.id!] = recipe;
      }
    }

    for (final meal in _currentPlan!.meals) {
      final recipe = recipeMap[meal.recipeId];
      if (recipe == null) continue;
      final multiplier = meal.servings.toDouble();
      totalCalories += (recipe.caloriesPerServing ?? 0) * multiplier;
      protein += (recipe.proteinGrams ?? 0) * multiplier;
      carbs += (recipe.carbsGrams ?? 0) * multiplier;
      fat += (recipe.fatGrams ?? 0) * multiplier;
    }

    return {
      'totalCalories': totalCalories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  /// Get the Monday of the week containing [date].
  static DateTime _getMonday(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  @override
  void dispose() {
    _planSubscription?.cancel();
    super.dispose();
  }
}

class _AggregatedIngredient {
  final String name;
  double amount;
  final String? unit;

  _AggregatedIngredient({
    required this.name,
    required this.amount,
    this.unit,
  });
}
