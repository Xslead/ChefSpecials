import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/premium_card.dart';

class MacroBarChart extends StatelessWidget {
  final double currentCalories;
  final double targetCalories;
  final double currentProtein;
  final double targetProtein;
  final double currentCarbs;
  final double targetCarbs;
  final double currentFat;
  final double targetFat;

  const MacroBarChart({
    super.key,
    required this.currentCalories,
    required this.targetCalories,
    required this.currentProtein,
    required this.targetProtein,
    required this.currentCarbs,
    required this.targetCarbs,
    required this.currentFat,
    required this.targetFat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final calPct = targetCalories > 0
        ? (currentCalories / targetCalories * 100).clamp(0, 150)
        : 0.0;
    final protPct = targetProtein > 0
        ? (currentProtein / targetProtein * 100).clamp(0, 150)
        : 0.0;
    final carbPct = targetCarbs > 0
        ? (currentCarbs / targetCarbs * 100).clamp(0, 150)
        : 0.0;
    final fatPct = targetFat > 0
        ? (currentFat / targetFat * 100).clamp(0, 150)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailySummary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryOf(context),
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  maxY: 150,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final labels = [
                          l10n.calories,
                          l10n.protein,
                          l10n.carbs,
                          l10n.fat,
                        ];
                        return BarTooltipItem(
                          '${labels[groupIndex]}\n${rod.toY.toInt()}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = [
                            l10n.calories,
                            l10n.protein,
                            l10n.carbs,
                            l10n.fat,
                          ];
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == 50 || value == 100) {
                            return Text(
                              '${value.toInt()}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 36,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppTheme.neutralLightOf(context),
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeBar(0, calPct.toDouble(), AppTheme.errorColor),
                    _makeBar(1, protPct.toDouble(), AppTheme.primaryColor),
                    _makeBar(2, carbPct.toDouble(), AppTheme.starColor),
                    _makeBar(3, fatPct.toDouble(), AppTheme.dinnerColor),
                  ],
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 100,
                        color: AppTheme.textTertiaryOf(context),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y > 100 ? AppTheme.errorColor : color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
