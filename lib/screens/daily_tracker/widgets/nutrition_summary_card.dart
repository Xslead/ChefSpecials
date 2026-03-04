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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isExceeded = currentCalories > targetCalories;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              l10n.dailySummary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _CalorieRingPainter(
                  progress: calorieProgress.clamp(0, 1.0),
                  color: isExceeded ? AppTheme.errorColor : AppTheme.primaryColor,
                  backgroundColor: Colors.grey.shade200,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentCalories.toInt().toString(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isExceeded
                                  ? AppTheme.errorColor
                                  : AppTheme.primaryColor,
                            ),
                      ),
                      Text(
                        '${l10n.ofLabel} ${targetCalories.toInt()} ${l10n.kcal}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExceeded) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.exceeded} ${(currentCalories - targetCalories).toInt()} ${l10n.kcal}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                '${(targetCalories - currentCalories).toInt()} ${l10n.kcal} ${l10n.remaining}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
            const SizedBox(height: 20),
            _MacroProgressBar(
              label: l10n.protein,
              current: currentProtein,
              target: targetProtein,
              progress: proteinProgress,
              color: AppTheme.secondaryColor,
              unit: l10n.gram,
            ),
            const SizedBox(height: 12),
            _MacroProgressBar(
              label: l10n.carbs,
              current: currentCarbs,
              target: targetCarbs,
              progress: carbsProgress,
              color: const Color(0xFFF59E0B),
              unit: l10n.gram,
            ),
            const SizedBox(height: 12),
            _MacroProgressBar(
              label: l10n.fat,
              current: currentFat,
              target: targetFat,
              progress: fatProgress,
              color: const Color(0xFFEF4444),
              unit: l10n.gram,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final double progress;
  final Color color;
  final String unit;

  const _MacroProgressBar({
    required this.label,
    required this.current,
    required this.target,
    required this.progress,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clampedProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 1.0 ? AppTheme.errorColor : color,
              ),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(
            '${current.toInt()}/${target.toInt()}$unit',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: progress > 1.0
                      ? AppTheme.errorColor
                      : AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _CalorieRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CalorieRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
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

  @override
  bool shouldRepaint(covariant _CalorieRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
