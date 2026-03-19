import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/daily_nutrition_summary.dart';
import '../../../providers/reports_provider.dart';

class NutrientBarChart extends StatelessWidget {
  final List<DailyNutritionSummary> summaries;
  final NutrientType selectedNutrient;
  final ValueChanged<NutrientType> onNutrientChanged;

  const NutrientBarChart({
    super.key,
    required this.summaries,
    required this.selectedNutrient,
    required this.onNutrientChanged,
  });

  Color _barColor(BuildContext context) {
    switch (selectedNutrient) {
      case NutrientType.calories:
        return AppTheme.primaryColor;
      case NutrientType.protein:
        return AppTheme.proteinBorderOf(context);
      case NutrientType.carbs:
        return AppTheme.carbsBorderOf(context);
      case NutrientType.fat:
        return AppTheme.fatBorderOf(context);
    }
  }

  double _getValue(DailyNutritionSummary s) {
    switch (selectedNutrient) {
      case NutrientType.calories:
        return s.totalCalories;
      case NutrientType.protein:
        return s.totalProtein;
      case NutrientType.carbs:
        return s.totalCarbs;
      case NutrientType.fat:
        return s.totalFat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [l10n.calories, l10n.protein, l10n.carbs, l10n.fat];
    final types = NutrientType.values;
    final color = _barColor(context);
    final maxVal =
        summaries.fold(0.0, (m, s) => _getValue(s) > m ? _getValue(s) : m);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
          boxShadow: [AppTheme.shadowOf(context)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              children: [
                Icon(Icons.bar_chart_rounded,
                    size: 16, color: AppTheme.textTertiaryOf(context)),
                const SizedBox(width: 6),
                Text(
                  l10n.weekly,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Nutrient pills
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: types.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = selectedNutrient == types[i];
                  return GestureDetector(
                    onTap: () => onNutrientChanged(types[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryColor
                              : AppTheme.neutralLightOf(context),
                        ),
                      ),
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : AppTheme.textSecondaryOf(context),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Bar chart
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal > 0 ? maxVal * 1.2 : 100,
                  barGroups: List.generate(summaries.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: _getValue(summaries[i]),
                          color: color,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxVal > 0 ? maxVal * 1.2 : 100,
                            color: AppTheme.neutralLightOf(context)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= summaries.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              DateFormat('E')
                                  .format(summaries[idx].date)
                                  .substring(0, 2),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textTertiaryOf(context),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final unit = selectedNutrient == NutrientType.calories
                            ? 'kcal'
                            : 'g';
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(0)} $unit',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
