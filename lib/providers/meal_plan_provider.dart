import 'dart:async';
import 'package:flutter/material.dart';
import '../models/meal_plan.dart';
import '../models/planned_meal.dart';
import '../models/recipe.dart';
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

  // Getters
  MealPlan? get currentPlan => _currentPlan;
  DateTime get selectedWeekStart => _selectedWeekStart;
  bool get isLoading => _isLoading;

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

  /// Aggregate ingredients across all planned meals into a shopping map.
  /// Returns a map of ingredient name to total servings count.
  Map<String, double> generateShoppingList() {
    if (_currentPlan == null) return {};
    final map = <String, double>{};
    for (final meal in _currentPlan!.meals) {
      final key = meal.recipeName;
      map[key] = (map[key] ?? 0) + meal.servings;
    }
    return map;
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
