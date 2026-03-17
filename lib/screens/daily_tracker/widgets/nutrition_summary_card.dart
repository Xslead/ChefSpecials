import 'dart:math';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class NutritionSummaryCard extends StatelessWidget {
  final double currentCalories;
  final double targetCalories;
  final double currentProtein;
  final double targetProtein;
  final double currentCarbs;
  final double targetCarbs;
  final double currentFat;
  final double targetFat;
  final double calorieProgress;
  final double proteinProgress;
  final double carbsProgress;
  final double fatProgress;

  const NutritionSummaryCard({
    super.key,
    required this.currentCalories,
    required this.targetCalories,
    required this.currentProtein,
    required this.targetProtein,
    required this.currentCarbs,
    required this.targetCarbs,
    required this.currentFat,
    required this.targetFat,
    required this.calorieProgress,
    required this.proteinProgress,
    required this.carbsProgress,
    required this.fatProgress,
  });

  static const Color _fatColor = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remaining = (targetCalories - currentCalories).toInt();
    final isExceeded = remaining < 0;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Circular calorie ring
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _CalorieRingPainter(
                    progress: calorieProgress.clamp(0, 1.0),
                    isExceeded: isExceeded,
                    trackColor: AppTheme.neutralLightOf(context),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExceeded
                              ? '+${(-remaining).toString()}'
                              : remaining.toString(),
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: isExceeded
                                ? AppTheme.errorColor
                                : AppTheme.textPrimaryOf(context),
                          ),
                        ),
                        Text(
                          isExceeded
                              ? '${l10n.exceeded} ${l10n.kcal}'
                              : l10n.remainingKcal,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Consumed / Target row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCalorieStat(
                    context,
                    l10n.consumed,
                    '${currentCalories.toInt()} ${l10n.kcal}',
                    textTheme,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    color: AppTheme.neutralLightOf(context),
                  ),
                  _buildCalorieStat(
                    context,
                    l10n.target,
                    '${targetCalories.toInt()} ${l10n.kcal}',
                    textTheme,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Macro bars container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(
                color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
              ),
              boxShadow: [AppTheme.shadowOf(context)],
            ),
            child: Column(
              children: [
                _buildMacroRow(
                  context,
                  label: l10n.protein,
                  current: currentProtein,
                  target: targetProtein,
                  progress: proteinProgress,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 14),
                _buildMacroRow(
                  context,
                  label: l10n.carbsShort,
                  current: currentCarbs,
                  target: targetCarbs,
                  progress: carbsProgress,
                  color: AppTheme.starColor,
                ),
                const SizedBox(height: 14),
                _buildMacroRow(
                  context,
                  label: l10n.fat,
                  current: currentFat,
                  target: targetFat,
                  progress: fatProgress,
                  color: _fatColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieStat(
    BuildContext context,
    String label,
    String value,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppTheme.textTertiaryOf(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroRow(
    BuildContext context, {
    required String label,
    required double current,
    required double target,
    required double progress,
    required Color color,
  }) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final barColor = progress > 1.0 ? AppTheme.errorColor : color;

    return Row(
      children: [
        // Colored circle + label
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: barColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: clampedProgress,
                backgroundColor: AppTheme.neutralLightOf(context),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 8,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Value text
        Text(
          '${current.toInt()}g/${target.toInt()}g',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
      ],
    );
  }
}

class _CalorieRingPainter extends CustomPainter {
  final double progress;
  final bool isExceeded;
  final Color trackColor;

  _CalorieRingPainter({
    required this.progress,
    required this.isExceeded,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 6;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (isExceeded) {
      final progressPaint = Paint()
        ..color = AppTheme.errorColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
    } else {
      final gradient = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi,
        colors: const [
          AppTheme.primaryColor,
          AppTheme.primaryLight,
          AppTheme.primaryColor,
        ],
      );

      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(rect);

      canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CalorieRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isExceeded != isExceeded ||
        oldDelegate.trackColor != trackColor;
  }
}
