import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class AverageIntakeCard extends StatelessWidget {
  final Map<String, double> averages;

  const AverageIntakeCard({super.key, required this.averages});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                Icon(Icons.analytics_outlined,
                    size: 16, color: AppTheme.textTertiaryOf(context)),
                const SizedBox(width: 6),
                Text(
                  l10n.averageDailyIntake,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _statTile(
                  context,
                  l10n.calories,
                  averages['calories']?.toStringAsFixed(0) ?? '0',
                  'kcal',
                  AppTheme.primaryColor,
                ),
                _divider(context),
                _statTile(
                  context,
                  l10n.protein,
                  averages['protein']?.toStringAsFixed(0) ?? '0',
                  'g',
                  AppTheme.proteinBorderOf(context),
                ),
                _divider(context),
                _statTile(
                  context,
                  l10n.carbs,
                  averages['carbs']?.toStringAsFixed(0) ?? '0',
                  'g',
                  AppTheme.carbsBorderOf(context),
                ),
                _divider(context),
                _statTile(
                  context,
                  l10n.fat,
                  averages['fat']?.toStringAsFixed(0) ?? '0',
                  'g',
                  AppTheme.fatBorderOf(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
    );
  }

  Widget _statTile(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textTertiaryOf(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryOf(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
