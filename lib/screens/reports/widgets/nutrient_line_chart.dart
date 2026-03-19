import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/daily_nutrition_summary.dart';

class NutrientLineChart extends StatelessWidget {
  final List<DailyNutritionSummary> summaries;

  const NutrientLineChart({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proteinColor = AppTheme.proteinBorderOf(context);
    final carbsColor = AppTheme.carbsBorderOf(context);
    final fatColor = AppTheme.fatBorderOf(context);
    const caloriesColor = AppTheme.primaryColor;

    final maxCal =
        summaries.fold(0.0, (m, s) => s.totalCalories > m ? s.totalCalories : m);
    final maxMacro = summaries.fold(0.0, (m, s) {
      final v = [s.totalProtein, s.totalCarbs, s.totalFat]
          .reduce((a, b) => a > b ? a : b);
      return v > m ? v : m;
    });
    final maxY = (maxCal > maxMacro ? maxCal : maxMacro) * 1.2;

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
                Icon(Icons.show_chart_rounded,
                    size: 16, color: AppTheme.textTertiaryOf(context)),
                const SizedBox(width: 6),
                Text(
                  l10n.monthly,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _legendItem(l10n.calories, caloriesColor),
                _legendItem(l10n.protein, proteinColor),
                _legendItem(l10n.carbs, carbsColor),
                _legendItem(l10n.fat, fatColor),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  maxY: maxY > 0 ? maxY : 100,
                  minY: 0,
                  lineBarsData: [
                    _line(summaries.map((s) => s.totalCalories).toList(),
                        caloriesColor),
                    _line(summaries.map((s) => s.totalProtein).toList(),
                        proteinColor),
                    _line(
                        summaries.map((s) => s.totalCarbs).toList(), carbsColor),
                    _line(summaries.map((s) => s.totalFat).toList(), fatColor),
                  ],
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
                        interval: (summaries.length / 6)
                            .ceilToDouble()
                            .clamp(1, double.infinity),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= summaries.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${summaries[idx].date.day}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textTertiaryOf(context),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? maxY / 4 : 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color:
                          AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  lineTouchData: const LineTouchData(enabled: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _line(List<double> values, Color color) {
    return LineChartBarData(
      spots:
          List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.06),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
