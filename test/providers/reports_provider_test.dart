import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/reports_provider.dart';
import 'package:chef_specials/services/daily_tracker_service.dart';

Future<void> _seedLog(
  FakeFirebaseFirestore firestore, {
  required String userId,
  required String date,
  double calories = 200,
  double protein = 20,
  double carbs = 30,
  double fat = 10,
}) async {
  await firestore.collection('daily_logs').add({
    'userId': userId,
    'date': date,
    'meals': [
      {
        'name': 'Test',
        'mealType': 'breakfast',
        'quantity': 100,
        'unit': 'g',
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      },
    ],
    'waterMl': 0,
  });
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DailyTrackerService service;
  late ReportsProvider provider;

  const userId = 'user1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = DailyTrackerService(firestore: fakeFirestore);
    provider = ReportsProvider(service: service);
  });

  group('ReportsProvider', () {
    test('initial state', () {
      expect(provider.isLoading, false);
      expect(provider.dailySummaries, isEmpty);
      expect(provider.streak, 0);
      expect(provider.selectedNutrient, NutrientType.calories);
    });

    test('setSelectedNutrient changes nutrient', () {
      provider.setSelectedNutrient(NutrientType.protein);
      expect(provider.selectedNutrient, NutrientType.protein);
    });

    test('loadWeeklyData returns 7 summaries', () async {
      await provider.loadWeeklyData(userId);
      expect(provider.dailySummaries.length, 7);
    });

    test('loadWeeklyData aggregates data correctly', () async {
      // Seed a log for the current week's Monday
      final monday = provider.weekStart;
      final dateStr =
          '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
      await _seedLog(fakeFirestore, userId: userId, date: dateStr);

      await provider.loadWeeklyData(userId);

      final mondaySummary = provider.dailySummaries.first;
      expect(mondaySummary.totalCalories, 200);
      expect(mondaySummary.totalProtein, 20);
      expect(mondaySummary.totalCarbs, 30);
      expect(mondaySummary.totalFat, 10);
    });

    test('loadMonthlyData returns correct number of days', () async {
      await provider.loadMonthlyData(userId);
      final daysInMonth = DateTime(
        provider.selectedMonth.year,
        provider.selectedMonth.month + 1,
        0,
      ).day;
      expect(provider.dailySummaries.length, daysInMonth);
    });

    test('calculateAverages returns zeros for empty data', () async {
      await provider.loadWeeklyData(userId);
      final avgs = provider.calculateAverages();
      expect(avgs['calories'], 0);
      expect(avgs['protein'], 0);
      expect(avgs['carbs'], 0);
      expect(avgs['fat'], 0);
    });

    test('calculateAverages computes correct averages', () async {
      final monday = provider.weekStart;
      final dateStr1 =
          '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
      final tuesday = monday.add(const Duration(days: 1));
      final dateStr2 =
          '${tuesday.year}-${tuesday.month.toString().padLeft(2, '0')}-${tuesday.day.toString().padLeft(2, '0')}';

      await _seedLog(fakeFirestore,
          userId: userId, date: dateStr1, calories: 100);
      await _seedLog(fakeFirestore,
          userId: userId, date: dateStr2, calories: 300);

      await provider.loadWeeklyData(userId);
      final avgs = provider.calculateAverages();
      expect(avgs['calories'], 200); // (100 + 300) / 2
    });

    test('calculateMacroDistribution sums to 100', () async {
      final monday = provider.weekStart;
      final dateStr =
          '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
      await _seedLog(fakeFirestore,
          userId: userId,
          date: dateStr,
          protein: 50,
          carbs: 100,
          fat: 50);

      await provider.loadWeeklyData(userId);
      final dist = provider.calculateMacroDistribution();
      final total = (dist['protein']! + dist['carbs']! + dist['fat']!);
      expect(total, closeTo(100, 0.01));
    });

    test('calculateMacroDistribution returns zeros for no data', () async {
      await provider.loadWeeklyData(userId);
      final dist = provider.calculateMacroDistribution();
      expect(dist['protein'], 0);
      expect(dist['carbs'], 0);
      expect(dist['fat'], 0);
    });

    test('previousWeek and nextWeek navigate correctly', () {
      final original = provider.weekStart;
      provider.previousWeek();
      expect(provider.weekStart, original.subtract(const Duration(days: 7)));
      provider.nextWeek();
      expect(provider.weekStart, original);
    });

    test('previousMonth and nextMonth navigate correctly', () {
      final original = provider.selectedMonth;
      provider.previousMonth();
      expect(provider.selectedMonth.month,
          DateTime(original.year, original.month - 1).month);
      provider.nextMonth();
      expect(provider.selectedMonth.month, original.month);
    });
  });
}
