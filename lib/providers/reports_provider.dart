import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/daily_log.dart';
import '../models/daily_nutrition_summary.dart';
import '../services/daily_tracker_service.dart';

enum NutrientType { calories, protein, carbs, fat }

class ReportsProvider extends ChangeNotifier {
  final DailyTrackerService _service;

  ReportsProvider({DailyTrackerService? service})
      : _service = service ?? DailyTrackerService();

  List<DailyNutritionSummary> _dailySummaries = [];
  List<DailyNutritionSummary> get dailySummaries => _dailySummaries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NutrientType _selectedNutrient = NutrientType.calories;
  NutrientType get selectedNutrient => _selectedNutrient;

  int _streak = 0;
  int get streak => _streak;

  late DateTime _weekStart = _mondayOfWeek(DateTime.now());
  DateTime get weekStart => _weekStart;
  DateTime get weekEnd => _weekStart.add(const Duration(days: 6));

  late DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get selectedMonth => _selectedMonth;

  static DateTime _mondayOfWeek(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }

  void setSelectedNutrient(NutrientType type) {
    _selectedNutrient = type;
    notifyListeners();
  }

  // ── Weekly ──

  Future<void> loadWeeklyData(String userId) async {
    _isLoading = true;
    notifyListeners();

    final startStr = DateFormat('yyyy-MM-dd').format(_weekStart);
    final endStr = DateFormat('yyyy-MM-dd').format(weekEnd);

    try {
      final logs = await _service.getDailyLogsForRange(userId, startStr, endStr);
      _dailySummaries = _logsToSummaries(logs, _weekStart, 7);
      await _calculateStreak(userId);
    } catch (e) {
      debugPrint('Error loading weekly data: $e');
      _dailySummaries = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void previousWeek() {
    _weekStart = _weekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void nextWeek() {
    _weekStart = _weekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  // ── Monthly ──

  Future<void> loadMonthlyData(String userId) async {
    _isLoading = true;
    notifyListeners();

    final year = _selectedMonth.year;
    final month = _selectedMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startStr = DateFormat('yyyy-MM-dd').format(DateTime(year, month, 1));
    final endStr = DateFormat('yyyy-MM-dd').format(DateTime(year, month, daysInMonth));

    try {
      final logs = await _service.getDailyLogsForRange(userId, startStr, endStr);
      _dailySummaries = _logsToSummaries(logs, DateTime(year, month, 1), daysInMonth);
    } catch (e) {
      debugPrint('Error loading monthly data: $e');
      _dailySummaries = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  // ── Aggregation ──

  List<DailyNutritionSummary> _logsToSummaries(
      List<DailyLog> logs, DateTime start, int days) {
    final logMap = <String, DailyLog>{};
    for (final log in logs) {
      logMap[log.date] = log;
    }

    final summaries = <DailyNutritionSummary>[];
    for (int i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(day);
      final log = logMap[dateStr];
      summaries.add(DailyNutritionSummary(
        date: day,
        totalCalories: log?.totalCalories ?? 0,
        totalProtein: log?.totalProtein ?? 0,
        totalCarbs: log?.totalCarbs ?? 0,
        totalFat: log?.totalFat ?? 0,
      ));
    }
    return summaries;
  }

  Map<String, double> calculateAverages() {
    final withData = _dailySummaries.where((s) => s.totalCalories > 0).toList();
    if (withData.isEmpty) {
      return {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0};
    }
    final count = withData.length;
    return {
      'calories': withData.fold(0.0, (s, d) => s + d.totalCalories) / count,
      'protein': withData.fold(0.0, (s, d) => s + d.totalProtein) / count,
      'carbs': withData.fold(0.0, (s, d) => s + d.totalCarbs) / count,
      'fat': withData.fold(0.0, (s, d) => s + d.totalFat) / count,
    };
  }

  Map<String, double> calculateMacroDistribution() {
    final totalProtein = _dailySummaries.fold(0.0, (s, d) => s + d.totalProtein);
    final totalCarbs = _dailySummaries.fold(0.0, (s, d) => s + d.totalCarbs);
    final totalFat = _dailySummaries.fold(0.0, (s, d) => s + d.totalFat);
    final total = totalProtein + totalCarbs + totalFat;

    if (total == 0) {
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }
    return {
      'protein': (totalProtein / total) * 100,
      'carbs': (totalCarbs / total) * 100,
      'fat': (totalFat / total) * 100,
    };
  }

  Future<void> _calculateStreak(String userId) async {
    final today = DateTime.now();
    final lookbackStart = today.subtract(const Duration(days: 90));
    final startStr = DateFormat('yyyy-MM-dd').format(lookbackStart);
    final endStr = DateFormat('yyyy-MM-dd').format(today.subtract(const Duration(days: 1)));

    try {
      final logs = await _service.getDailyLogsForRange(userId, startStr, endStr);
      final loggedDates = <String>{};
      for (final log in logs) {
        if (log.meals.isNotEmpty) {
          loggedDates.add(log.date);
        }
      }

      int count = 0;
      var checkDate = today.subtract(const Duration(days: 1));
      while (true) {
        final dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
        if (!loggedDates.contains(dateStr)) break;
        count++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
      _streak = count;
    } catch (e) {
      _streak = 0;
    }
  }
}
