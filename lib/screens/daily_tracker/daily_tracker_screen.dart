import 'dart:math';
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
      body: Column(
        children: [
          _buildHeader(l10n, provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
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
                        onRemove: (ml) {
                          provider.removeWater(ml);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  DateTime _weekStartOf(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _changeWeek(int direction) {
    final provider = context.read<DailyTrackerProvider>();
    final weekStart = _weekStartOf(provider.selectedDate);
    final newWeekStart = weekStart.add(Duration(days: 7 * direction));
    // Navigate to same weekday in new week, or today if in current week
    final newDate = newWeekStart.add(
        Duration(days: provider.selectedDate.weekday - 1));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (newDate.isAfter(today)) {
      provider.setDate(today);
    } else {
      provider.setDate(newDate);
    }
  }

  bool _isCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final thisWeekStart = _weekStartOf(DateTime(now.year, now.month, now.day));
    final dateWeekStart = _weekStartOf(date);
    return thisWeekStart == dateWeekStart;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildHeader(AppLocalizations l10n, DailyTrackerProvider provider) {
    final selectedDate = provider.selectedDate;
    final weekStart = _weekStartOf(selectedDate);
    final targetCal = provider.nutritionGoal?.calorieTarget ?? 2000;
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        boxShadow: [AppTheme.shadowOf(context)],
        border: Border(
          bottom: BorderSide(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Row 1: Icon badge + title + settings gear
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.dailyTracker,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push('/nutrition-goals'),
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Row 2: Week navigation with day circles
              Row(
                children: [
                  // Left arrow
                  GestureDetector(
                    onTap: () => _changeWeek(-1),
                    child: Icon(
                      Icons.chevron_left,
                      color: AppTheme.textSecondaryOf(context),
                      size: 28,
                    ),
                  ),
                  // 7 day circles
                  ...List.generate(7, (i) {
                    final day = weekStart.add(Duration(days: i));
                    final dateKey = DateFormat('yyyy-MM-dd').format(day);
                    final isSelected = _isSameDay(day, selectedDate);
                    final calories = provider.weeklyCalories[dateKey] ?? 0;
                    final progress = (calories / targetCal).clamp(0.0, 1.0);
                    final hasData = calories > 0;
                    final targetMet = progress >= 1.0;
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final isFuture = day.isAfter(today);

                    return Expanded(
                      child: GestureDetector(
                        onTap: isFuture ? null : () => provider.setDate(day),
                        child: Column(
                          children: [
                            // Day letter
                            Text(
                              dayLetters[i],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textTertiaryOf(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Circle with progress ring
                            SizedBox(
                              width: 38,
                              height: 38,
                              child: CustomPaint(
                                painter: _DayRingPainter(
                                  progress: progress,
                                  isSelected: isSelected,
                                  hasData: hasData,
                                  isFuture: isFuture,
                                  trackColor: AppTheme.neutralLightOf(context),
                                  fillColor: AppTheme.primaryColor,
                                  selectedBgColor: AppTheme.primaryColor,
                                ),
                                child: Center(
                                  child: targetMet && hasData
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: AppTheme.primaryColor,
                                        )
                                      : Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : isFuture
                                                    ? AppTheme.textTertiaryOf(
                                                        context)
                                                    : AppTheme.textPrimaryOf(
                                                        context),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  // Right arrow
                  GestureDetector(
                    onTap: _isCurrentWeek(selectedDate)
                        ? null
                        : () => _changeWeek(1),
                    child: Icon(
                      Icons.chevron_right,
                      color: _isCurrentWeek(selectedDate)
                          ? AppTheme.textTertiaryOf(context)
                          : AppTheme.textSecondaryOf(context),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Row 3: Full date text
              GestureDetector(
                onTap: _pickDate,
                child: Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryOf(context),
                      ),
                ),
              ),
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _DayRingPainter extends CustomPainter {
  final double progress;
  final bool isSelected;
  final bool hasData;
  final bool isFuture;
  final Color trackColor;
  final Color fillColor;
  final Color selectedBgColor;

  _DayRingPainter({
    required this.progress,
    required this.isSelected,
    required this.hasData,
    required this.isFuture,
    required this.trackColor,
    required this.fillColor,
    required this.selectedBgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Selected day: filled circle background
    if (isSelected) {
      final bgPaint = Paint()..color = selectedBgColor;
      canvas.drawCircle(center, radius, bgPaint);
      return;
    }

    // Track ring (always visible for non-future days)
    if (!isFuture) {
      final trackPaint = Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(center, radius, trackPaint);
    }

    // Progress arc
    if (hasData && !isSelected) {
      final progressPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DayRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.hasData != hasData ||
        oldDelegate.isFuture != isFuture;
  }
}
