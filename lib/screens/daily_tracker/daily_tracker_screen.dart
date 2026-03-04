import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/meal_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/daily_tracker_provider.dart';
import 'widgets/meal_section_card.dart';
import 'widgets/nutrition_summary_card.dart';

class DailyTrackerScreen extends StatefulWidget {
  const DailyTrackerScreen({super.key});

  @override
  State<DailyTrackerScreen> createState() => _DailyTrackerScreenState();
}

class _DailyTrackerScreenState extends State<DailyTrackerScreen> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().userModel?.uid;
    if (userId != null) {
      context.read<DailyTrackerProvider>().init(userId);
    }
  }

  void _goToPreviousDay() {
    final provider = context.read<DailyTrackerProvider>();
    provider.setDate(provider.selectedDate.subtract(const Duration(days: 1)));
  }

  void _goToNextDay() {
    final provider = context.read<DailyTrackerProvider>();
    provider.setDate(provider.selectedDate.add(const Duration(days: 1)));
  }

  Future<void> _pickDate() async {
    final provider = context.read<DailyTrackerProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      provider.setDate(picked);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    if (_isToday(date)) return l10n.today;
    return DateFormat('MMM d, yyyy').format(date);
  }

  void _navigateToAddMeal(MealType mealType) {
    context.push('/add-meal-entry', extra: mealType);
  }

  void _removeMealEntry(MealType type, int localIndex) {
    final provider = context.read<DailyTrackerProvider>();
    final allMeals = provider.dailyLog?.meals ?? [];
    int globalIndex = -1;
    int count = 0;
    for (int i = 0; i < allMeals.length; i++) {
      if (allMeals[i].mealType == type) {
        if (count == localIndex) {
          globalIndex = i;
          break;
        }
        count++;
      }
    }
    if (globalIndex >= 0) {
      provider.removeMealEntry(globalIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<DailyTrackerProvider>();
    final goal = provider.nutritionGoal;

    final targetCal = goal?.calorieTarget ?? 2000;
    final targetProt = goal?.proteinTarget ?? 50;
    final targetCarbs = goal?.carbsTarget ?? 250;
    final targetFat = goal?.fatTarget ?? 65;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyTracker),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/nutrition-goals'),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildDatePicker(l10n, provider),
                NutritionSummaryCard(
                  currentCalories: provider.totalCalories,
                  targetCalories: targetCal,
                  currentProtein: provider.totalProtein,
                  targetProtein: targetProt,
                  currentCarbs: provider.totalCarbs,
                  targetCarbs: targetCarbs,
                  currentFat: provider.totalFat,
                  targetFat: targetFat,
                  calorieProgress: provider.calorieProgress(),
                  proteinProgress: provider.proteinProgress(),
                  carbsProgress: provider.carbsProgress(),
                  fatProgress: provider.fatProgress(),
                ),
                const SizedBox(height: 8),
                ...MealType.values.map(
                  (type) => MealSectionCard(
                    mealType: type,
                    entries: provider.mealsOfType(type),
                    onAddPressed: () => _navigateToAddMeal(type),
                    onRemoveEntry: (localIndex) =>
                        _removeMealEntry(type, localIndex),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildDatePicker(AppLocalizations l10n, DailyTrackerProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _goToPreviousDay,
            color: AppTheme.textPrimary,
          ),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(provider.selectedDate, l10n),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _isToday(provider.selectedDate) ? null : _goToNextDay,
            color: AppTheme.textPrimary,
            disabledColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
