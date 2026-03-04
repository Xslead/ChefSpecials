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
import 'widgets/water_tracker_section.dart';

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
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(l10n, provider),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children: [
                      // Calorie ring
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
                      // Today's Meals
                      _buildMealsHeader(l10n),
                      ...MealType.values.map(
                        (type) => MealSectionCard(
                          mealType: type,
                          entries: provider.mealsOfType(type),
                          onAddPressed: () => _navigateToAddMeal(type),
                          onRemoveEntry: (localIndex) =>
                              _removeMealEntry(type, localIndex),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Water tracker
                      WaterTrackerSection(
                        currentMl: provider.dailyLog?.totalWaterMl ?? 0,
                        targetMl: goal?.waterTargetMl ?? 2500,
                        onAdd: (ml) {
                          provider.addWater(ml);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          heroTag: 'tracker_fab',
          onPressed: () => _navigateToAddMeal(MealType.snack),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, DailyTrackerProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 4),
              // Date navigation
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  provider.setDate(
                    provider.selectedDate.subtract(const Duration(days: 1)),
                  );
                },
                color: AppTheme.textPrimary,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Text(
                    _formatDate(provider.selectedDate, l10n),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    _isToday(provider.selectedDate)
                        ? null
                        : () {
                            provider.setDate(
                              provider.selectedDate.add(const Duration(days: 1)),
                            );
                          },
                color: AppTheme.textPrimary,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/nutrition-goals'),
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealsHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.todaysMeals,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
