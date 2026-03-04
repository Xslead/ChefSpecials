import 'dart:io';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/recipe_step.dart';
import '../models/recipe.dart';
import '../services/storage_service.dart';

class RecipeFormProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  String title = '';
  String description = '';
  String category = 'Breakfast';
  int servings = 1;
  int prepTimeMinutes = 10;
  int cookTimeMinutes = 15;
  File? imageFile;
  List<Ingredient> ingredients = [Ingredient(name: '', amount: '')];
  List<RecipeStep> steps = [RecipeStep(order: 1, instruction: '')];
  int? caloriesPerServing;
  double? proteinGrams;
  double? carbsGrams;
  double? fatGrams;
  bool isSubmitting = false;

  void addIngredient() {
    ingredients.add(Ingredient(name: '', amount: ''));
    notifyListeners();
  }

  void removeIngredient(int index) {
    if (ingredients.length > 1) {
      ingredients.removeAt(index);
      notifyListeners();
    }
  }

  void updateIngredient(int index, {String? name, String? amount, String? unit}) {
    final old = ingredients[index];
    ingredients[index] = Ingredient(
      name: name ?? old.name,
      amount: amount ?? old.amount,
      unit: unit ?? old.unit,
    );
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
    cookTimeMinutes = 15;
    imageFile = null;
    ingredients = [Ingredient(name: '', amount: '')];
    steps = [RecipeStep(order: 1, instruction: '')];
    caloriesPerServing = null;
    proteinGrams = null;
    carbsGrams = null;
    fatGrams = null;
    isSubmitting = false;
    notifyListeners();
  }
}
