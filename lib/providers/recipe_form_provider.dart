import 'dart:io';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/recipe_step.dart';
import '../models/recipe.dart';
import '../models/food_item.dart';
import '../services/storage_service.dart';

class RecipeFormProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  String title = '';
  String description = '';
  String category = 'Breakfast';
  int servings = 1;
  int prepTimeMinutes = 10;
  int cookTimeMinutes = 0;
  File? imageFile;
  List<Ingredient> ingredients = [];
  List<RecipeStep> steps = [RecipeStep(order: 1, instruction: '')];
  int? caloriesPerServing;
  double? proteinGrams;
  double? carbsGrams;
  double? fatGrams;
  bool isSubmitting = false;

  void addIngredientFromFoodItem(FoodItem foodItem, String amount) {
    ingredients.add(Ingredient(
      name: foodItem.name,
      amount: amount,
      unit: foodItem.unit == '100g' ? 'g' : 'mL',
      foodItemId: foodItem.id,
      caloriesPer100: foodItem.calories,
      proteinPer100: foodItem.protein,
      carbsPer100: foodItem.carbs,
      fatPer100: foodItem.fat,
    ));
    _recalculateNutrition();
    notifyListeners();
  }

  void updateIngredientAmount(int index, String amount) {
    final old = ingredients[index];
    ingredients[index] = Ingredient(
      name: old.name,
      amount: amount,
      unit: old.unit,
      foodItemId: old.foodItemId,
      caloriesPer100: old.caloriesPer100,
      proteinPer100: old.proteinPer100,
      carbsPer100: old.carbsPer100,
      fatPer100: old.fatPer100,
    );
    _recalculateNutrition();
    notifyListeners();
  }

  void removeIngredient(int index) {
    ingredients.removeAt(index);
    _recalculateNutrition();
    notifyListeners();
  }

  void _recalculateNutrition() {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final ing in ingredients) {
      final grams = double.tryParse(ing.amount) ?? 0;
      final ratio = grams / 100.0;
      totalCalories += (ing.caloriesPer100 ?? 0) * ratio;
      totalProtein += (ing.proteinPer100 ?? 0) * ratio;
      totalCarbs += (ing.carbsPer100 ?? 0) * ratio;
      totalFat += (ing.fatPer100 ?? 0) * ratio;
    }

    final s = servings > 0 ? servings : 1;
    caloriesPerServing = (totalCalories / s).round();
    proteinGrams = double.parse((totalProtein / s).toStringAsFixed(1));
    carbsGrams = double.parse((totalCarbs / s).toStringAsFixed(1));
    fatGrams = double.parse((totalFat / s).toStringAsFixed(1));
  }

  void addStep() {
    steps.add(RecipeStep(order: steps.length + 1, instruction: ''));
    notifyListeners();
  }

  void removeStep(int index) {
    if (steps.length > 1) {
      steps.removeAt(index);
      for (int i = 0; i < steps.length; i++) {
        steps[i] = RecipeStep(
          order: i + 1,
          instruction: steps[i].instruction,
          imageUrl: steps[i].imageUrl,
          timerSeconds: steps[i].timerSeconds,
        );
      }
      _recalculatePrepTime();
      notifyListeners();
    }
  }

  void updateStep(int index, {String? instruction, int? timerSeconds}) {
    final old = steps[index];
    steps[index] = RecipeStep(
      order: old.order,
      instruction: instruction ?? old.instruction,
      imageUrl: old.imageUrl,
      timerSeconds: timerSeconds ?? old.timerSeconds,
    );
    _recalculatePrepTime();
    notifyListeners();
  }

  void _recalculatePrepTime() {
    int totalSeconds = 0;
    for (final step in steps) {
      totalSeconds += step.timerSeconds ?? 0;
    }
    prepTimeMinutes = (totalSeconds / 60).ceil();
  }

  void setImage(File file) {
    imageFile = file;
    notifyListeners();
  }

  Future<Recipe> buildRecipe(String authorId, String authorName) async {
    isSubmitting = true;
    notifyListeners();

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _storageService.uploadRecipeImage(imageFile!);
    }

    final validIngredients = ingredients
        .where((i) => i.name.isNotEmpty && i.amount.isNotEmpty)
        .toList();
    final validSteps = steps
        .where((s) => s.instruction.isNotEmpty)
        .toList();

    final recipe = Recipe(
      title: title,
      description: description,
      authorId: authorId,
      authorName: authorName,
      category: category,
      servings: servings,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      imageUrl: imageUrl,
      ingredients: validIngredients,
      steps: validSteps,
      caloriesPerServing: caloriesPerServing,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      createdAt: DateTime.now(),
    );

    isSubmitting = false;
    notifyListeners();
    return recipe;
  }

  void reset() {
    title = '';
    description = '';
    category = 'Breakfast';
    servings = 1;
    prepTimeMinutes = 10;
    cookTimeMinutes = 0;
    imageFile = null;
    ingredients = [];
    steps = [RecipeStep(order: 1, instruction: '')];
    caloriesPerServing = null;
    proteinGrams = null;
    carbsGrams = null;
    fatGrams = null;
    isSubmitting = false;
    notifyListeners();
  }
}
