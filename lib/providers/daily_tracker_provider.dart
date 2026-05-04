import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_log.dart';
import '../models/meal_entry.dart';
import '../models/nutrition_goal.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/daily_tracker_service.dart';

class DailyTrackerProvider extends ChangeNotifier {
  final DailyTrackerService _service;
  final CacheService? _cacheService;
  final ConnectivityService? _connectivityService;

  DailyTrackerProvider({
    DailyTrackerService? dailyTrackerService,
    CacheService? cacheService,
    ConnectivityService? connectivityService,
  })  : _service = dailyTrackerService ?? DailyTrackerService(),
        _cacheService = cacheService,
        _connectivityService = connectivityService;

  DailyLog? _dailyLog;
  NutritionGoal? _nutritionGoal;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _userId;
  Map<String, double> _weeklyCalories = {};
  String? _loadedWeekKey;

  StreamSubscription? _logSubscription;
  StreamSubscription? _goalSubscription;

  DailyLog? get dailyLog => _dailyLog;
  NutritionGoal? get nutritionGoal => _nutritionGoal;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String get dateString => DateFormat('yyyy-MM-dd').format(_selectedDate);
  Map<String, double> get weeklyCalories => _weeklyCalories;

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _listenToGoal();
    _listenToLog();
    loadWeeklyCalories(_selectedDate);
  }

  void setDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _listenToLog();
    loadWeeklyCalories(_selectedDate);
    notifyListeners();
  }

  Future<void> loadWeeklyCalories(DateTime referenceDate) async {
    if (_userId == null) return;
    final weekStart =
        referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
    final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);
    if (_loadedWeekKey == weekKey) return;
    _loadedWeekKey = weekKey;

    final dates = List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      return DateFormat('yyyy-MM-dd').format(day);
    });
    _weeklyCalories = await _service.getWeeklyCalories(_userId!, dates);
    notifyListeners();
  }

  void refreshWeeklyCalories() {
    _loadedWeekKey = null;
    loadWeeklyCalories(_selectedDate);
  }

  void _listenToLog() {
    _logSubscription?.cancel();
    if (_userId == null) return;
    if (_dailyLog == null && !_isLoading) _isLoading = true;
    _dailyLog = null;

    // Immediately serve cached log so the UI isn't blank
    final cached = _cacheService?.getCachedDailyLog(dateString);
    if (cached != null) {
      _dailyLog = cached;
      _isLoading = false;
      notifyListeners();
    }

    _logSubscription = _service.getDailyLog(_userId!, dateString).listen(
      (log) {
        _dailyLog = log;
        _isLoading = false;
        _weeklyCalories[dateString] = log?.totalCalories ?? 0;
        notifyListeners();
        if (log != null) _cacheService?.cacheDailyLog(log);
      },
      onError: (_) {
        _isLoading = false;
        _dailyLog ??= _cacheService?.getCachedDailyLog(dateString);
        notifyListeners();
      },
    );
  }

  void _listenToGoal() {
    _goalSubscription?.cancel();
    if (_userId == null) return;
    _goalSubscription = _service.getNutritionGoal(_userId!).listen(
      (goal) {
        _nutritionGoal = goal;
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  Future<void> addMealEntry(MealEntry entry) async {
    if (_userId == null) return;

    final isOnline = await _connectivityService?.isOnline() ?? true;
    final currentMeals = List<MealEntry>.from(_dailyLog?.meals ?? [])
      ..add(entry);

    if (!isOnline) {
      // Optimistic local update
      _dailyLog = (_dailyLog ??
              DailyLog(userId: _userId!, date: dateString, meals: []))
          .copyWith(meals: currentMeals);
      notifyListeners();
      await _cacheService?.cacheDailyLog(_dailyLog!);
      await _cacheService?.queueOfflineAction({
        'type': 'add_meal_entry',
        'userId': _userId,
        'dateString': dateString,
        'entry': entry.toMap(),
      });
      return;
    }

    if (_dailyLog?.id?.isNotEmpty == true) {
      final updated = _dailyLog!.copyWith(meals: currentMeals);
      await _service.updateDailyLog(_dailyLog!.id!, updated);
    } else {
      final newLog =
          DailyLog(userId: _userId!, date: dateString, meals: currentMeals);
      await _service.createDailyLog(newLog);
    }
  }

  Future<void> removeMealEntry(int index) async {
    if (_dailyLog?.id?.isNotEmpty != true) return;
    final currentMeals = List<MealEntry>.from(_dailyLog!.meals);
    if (index < 0 || index >= currentMeals.length) return;
    currentMeals.removeAt(index);
    final updated = _dailyLog!.copyWith(meals: currentMeals);
    await _service.updateDailyLog(_dailyLog!.id!, updated);
  }

  Future<void> addWater(int ml) async {
    if (_userId == null) return;
    final currentWater = _dailyLog?.waterMl ?? 0;
    final newWater = currentWater + ml;

    if (_dailyLog?.id != null) {
      final updated = _dailyLog!.copyWith(waterMl: newWater);
      await _service.updateDailyLog(_dailyLog!.id!, updated);
    } else {
      final newLog = DailyLog(
          userId: _userId!, date: dateString, meals: [], waterMl: newWater);
      await _service.createDailyLog(newLog);
    }
  }

  Future<void> removeWater(int ml) async {
    if (_userId == null || _dailyLog?.id?.isNotEmpty != true) return;
    final currentWater = _dailyLog?.waterMl ?? 0;
    final newWater = (currentWater - ml).clamp(0, double.maxFinite).toInt();
    final updated = _dailyLog!.copyWith(waterMl: newWater);
    await _service.updateDailyLog(_dailyLog!.id!, updated);
  }

  Future<void> saveNutritionGoal(NutritionGoal goal) async {
    await _service.setNutritionGoal(goal);
  }

  List<MealEntry> mealsOfType(MealType type) =>
      _dailyLog?.mealsOfType(type) ?? [];

  double get totalCalories => _dailyLog?.totalCalories ?? 0;
  double get totalProtein => _dailyLog?.totalProtein ?? 0;
  double get totalCarbs => _dailyLog?.totalCarbs ?? 0;
  double get totalFat => _dailyLog?.totalFat ?? 0;

  double calorieProgress() {
    final target = _nutritionGoal?.calorieTarget ?? 2000;
    return (totalCalories / target).clamp(0, 1.5);
  }

  double proteinProgress() {
    final target = _nutritionGoal?.proteinTarget ?? 50;
    return (totalProtein / target).clamp(0, 1.5);
  }

  double carbsProgress() {
    final target = _nutritionGoal?.carbsTarget ?? 250;
    return (totalCarbs / target).clamp(0, 1.5);
  }

  double fatProgress() {
    final target = _nutritionGoal?.fatTarget ?? 65;
    return (totalFat / target).clamp(0, 1.5);
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _goalSubscription?.cancel();
    super.dispose();
  }
}
