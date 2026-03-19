import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class MacroPieChart extends StatelessWidget {
  final Map<String, double> distribution;

  const MacroPieChart({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final protein = distribution['protein'] ?? 0;
    final carbs = distribution['carbs'] ?? 0;
    final fat = distribution['fat'] ?? 0;
    final hasData = protein > 0 || carbs > 0 || fat > 0;

    final proteinColor = AppTheme.proteinBorderOf(context);
    final carbsColor = AppTheme.carbsBorderOf(context);
    final fatColor = AppTheme.fatBorderOf(context);

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
            Row(
              children: [
                Icon(Icons.pie_chart_outline_rounded,
                    size: 16, color: AppTheme.textTertiaryOf(context)),
                const SizedBox(width: 6),
                Text(
                  l10n.macroDistribution,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasData)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.noDataForPeriod,
                    style: TextStyle(color: AppTheme.textTertiaryOf(context)),
                  ),
                ),
              )
            else
              Row(
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(
                            value: protein,
                            color: proteinColor,
                            title: '${protein.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            radius: 30,
                          ),
                          PieChartSectionData(
                            value: carbs,
                            color: carbsColor,
                            title: '${carbs.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            radius: 30,
                          ),
                          PieChartSectionData(
                            value: fat,
                            color: fatColor,
                            title: '${fat.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            radius: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _legendRow(context, l10n.protein,
                            '${protein.toStringAsFixed(1)}%', proteinColor),
                        const SizedBox(height: 10),
                        _legendRow(context, l10n.carbs,
                            '${carbs.toStringAsFixed(1)}%', carbsColor),
                        const SizedBox(height: 10),
                        _legendRow(context, l10n.fat,
                            '${fat.toStringAsFixed(1)}%', fatColor),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(
      BuildContext context, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
      ],
    );
  }
}
