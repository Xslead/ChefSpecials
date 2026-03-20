import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nutrition_goal.dart';
import '../services/user_service.dart';
import '../services/daily_tracker_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;
  final List<String> _selectedDietaryPreferences = [];
  double _calorieTarget = 2000;
  double _proteinTarget = 50;
  double _carbsTarget = 250;
  double _fatTarget = 65;

  int get currentPage => _currentPage;
  List<String> get selectedDietaryPreferences =>
      List.unmodifiable(_selectedDietaryPreferences);
  double get calorieTarget => _calorieTarget;
  double get proteinTarget => _proteinTarget;
  double get carbsTarget => _carbsTarget;
  double get fatTarget => _fatTarget;
  bool get isLastPage => _currentPage == 3;

  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void toggleDietaryPreference(String preference) {
    if (_selectedDietaryPreferences.contains(preference)) {
      _selectedDietaryPreferences.remove(preference);
    } else {
      _selectedDietaryPreferences.add(preference);
    }
    notifyListeners();
  }

  void setCalorieTarget(double value) {
    _calorieTarget = value;
    notifyListeners();
  }

  void setProteinTarget(double value) {
    _proteinTarget = value;
    notifyListeners();
  }

  void setCarbsTarget(double value) {
    _carbsTarget = value;
    notifyListeners();
  }

  void setFatTarget(double value) {
    _fatTarget = value;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    _cachedCompleted = true;
    if (_selectedDietaryPreferences.isNotEmpty) {
      await prefs.setStringList(
          'pendingDietaryPreferences', _selectedDietaryPreferences);
    }
    final isNonDefault = _calorieTarget != 2000 ||
        _proteinTarget != 50 ||
        _carbsTarget != 250 ||
        _fatTarget != 65;
    if (isNonDefault) {
      await prefs.setDouble('pendingCalorieTarget', _calorieTarget);
      await prefs.setDouble('pendingProteinTarget', _proteinTarget);
      await prefs.setDouble('pendingCarbsTarget', _carbsTarget);
      await prefs.setDouble('pendingFatTarget', _fatTarget);
    }
  }

  static Future<void> savePendingOnboardingData(
    String userId,
    UserService userService,
    DailyTrackerService dailyTrackerService,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final dietaryPrefs = prefs.getStringList('pendingDietaryPreferences');
    if (dietaryPrefs != null && dietaryPrefs.isNotEmpty) {
      await userService.updateUser(userId, {
        'dietaryPreferences': dietaryPrefs,
      });
      await prefs.remove('pendingDietaryPreferences');
    }
    final pendingCalories = prefs.getDouble('pendingCalorieTarget');
    if (pendingCalories != null) {
      final goal = NutritionGoal(
        userId: userId,
        calorieTarget: pendingCalories,
        proteinTarget: prefs.getDouble('pendingProteinTarget') ?? 50,
        carbsTarget: prefs.getDouble('pendingCarbsTarget') ?? 250,
        fatTarget: prefs.getDouble('pendingFatTarget') ?? 65,
      );
      await dailyTrackerService.setNutritionGoal(goal);
      await prefs.remove('pendingCalorieTarget');
      await prefs.remove('pendingProteinTarget');
      await prefs.remove('pendingCarbsTarget');
      await prefs.remove('pendingFatTarget');
    }
  }

  static bool? _cachedCompleted;

  static void resetCache() {
    _cachedCompleted = null;
  }

  static Future<bool> hasCompletedOnboarding() async {
    if (_cachedCompleted != null) return _cachedCompleted!;
    final prefs = await SharedPreferences.getInstance();
    _cachedCompleted = prefs.getBool('hasCompletedOnboarding') ?? false;
    return _cachedCompleted!;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
