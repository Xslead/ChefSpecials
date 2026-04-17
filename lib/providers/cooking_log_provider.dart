import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/cooking_log.dart';
import '../models/recipe.dart';
import '../models/meal_entry.dart';
import '../services/cooking_log_service.dart';
import '../services/storage_service.dart';
import '../services/daily_tracker_service.dart';
import '../models/daily_log.dart';

class CookingLogProvider extends ChangeNotifier {
  final CookingLogService _service;
  final StorageService _storageService;
  final DailyTrackerService _dailyTrackerService;

  CookingLogProvider({
    CookingLogService? cookingLogService,
    StorageService? storageService,
    DailyTrackerService? dailyTrackerService,
  })  : _service = cookingLogService ?? CookingLogService(),
        _storageService = storageService ?? StorageService(),
        _dailyTrackerService = dailyTrackerService ?? DailyTrackerService();

  List<CookingLog> _cookingHistory = [];
  bool _isLoading = false;
  String? _userId;
  final Map<String, int> _cookCountCache = {};
  StreamSubscription? _subscription;

  List<CookingLog> get cookingHistory => _cookingHistory;
  bool get isLoading => _isLoading;

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _service.streamCookingHistory(userId).listen(
      (logs) {
        _cookingHistory = logs;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> logCook(
    Recipe recipe, {
    int? personalRating,
    String? notes,
    File? photo,
    int servings = 1,
    String? userId,
  }) async {
    final uid = userId ?? _userId;
    if (uid == null) return;

    String? photoUrl;
    if (photo != null) {
      try {
        final compressed = await _storageService.compressImage(photo);
        photoUrl = await _storageService.uploadRecipeImage(compressed, uid);
      } catch (_) {}
    }

    final now = DateTime.now();
    final log = CookingLog(
      recipeId: recipe.id!,
      recipeName: recipe.title,
      recipeImageUrl: recipe.imageUrl,
      userId: uid,
      cookedAt: now,
      personalRating: personalRating,
      notes: notes,
      photoUrl: photoUrl,
      servings: servings,
    );

    await _service.logCook(log);

    // Invalidate cook count cache for this recipe
    _cookCountCache.remove(recipe.id);

    // Auto-add to daily tracker
    if (recipe.caloriesPerServing != null) {
      await _addToDailyTracker(uid, recipe, servings, now);
    }
  }

  MealType _mealTypeFromHour(int hour) {
    if (hour < 11) return MealType.breakfast;
    if (hour < 15) return MealType.lunch;
    if (hour < 20) return MealType.dinner;
    return MealType.snack;
  }

  Future<void> _addToDailyTracker(
    String userId,
    Recipe recipe,
    int servings,
    DateTime now,
  ) async {
    try {
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final mealType = _mealTypeFromHour(now.hour);
      final factor = servings.toDouble();

      final entry = MealEntry(
        name: recipe.title,
        mealType: mealType,
        recipeId: recipe.id,
        quantity: servings.toDouble(),
        unit: 'serving',
        calories: (recipe.caloriesPerServing ?? 0) * factor,
        protein: (recipe.proteinGrams ?? 0) * factor,
        carbs: (recipe.carbsGrams ?? 0) * factor,
        fat: (recipe.fatGrams ?? 0) * factor,
      );

      final existing = await _dailyTrackerService
          .getDailyLog(userId, dateStr)
          .first
          .catchError((_) => null);

      if (existing?.id != null) {
        final updatedMeals = List<MealEntry>.from(existing!.meals)..add(entry);
        await _dailyTrackerService.updateDailyLog(
          existing.id!,
          existing.copyWith(meals: updatedMeals),
        );
      } else {
        await _dailyTrackerService.createDailyLog(
          DailyLog(userId: userId, date: dateStr, meals: [entry]),
        );
      }
    } catch (_) {}
  }

  Future<int> getCookCount(String recipeId) async {
    if (_cookCountCache.containsKey(recipeId)) {
      return _cookCountCache[recipeId]!;
    }
    if (_userId == null) return 0;
    try {
      final count =
          await _service.getCookCountForRecipe(_userId!, recipeId);
      _cookCountCache[recipeId] = count;
      return count;
    } catch (_) {
      return 0;
    }
  }

  int getCookCountFromCache(String recipeId) {
    // Count from local stream data (fast, no network call)
    return _cookingHistory.where((l) => l.recipeId == recipeId).length;
  }

  Future<void> deleteCookingLog(String logId) async {
    await _service.deleteCookingLog(logId);
    _cookingHistory.removeWhere((l) => l.id == logId);
    notifyListeners();
  }
}
