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
    final remaining = (targetCalories - currentCalories).toInt();
    final isExceeded = remaining < 0;

    return Column(
      children: [
        // Circular calorie ring
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            children: [
              SizedBox(
                width: 192,
                height: 192,
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
                          isExceeded
                              ? '+${(-remaining).toString()}'
                              : remaining.toString(),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: isExceeded
                                ? AppTheme.errorColor
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          isExceeded
                              ? '${l10n.exceeded} ${l10n.kcal}'
                              : l10n.remainingKcal,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
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
                    l10n.consumed,
                    '${currentCalories.toInt()} ${l10n.kcal}',
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.grey.shade200,
                  ),
                  _buildCalorieStat(
                    l10n.target,
                    '${targetCalories.toInt()} ${l10n.kcal}',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Macro cards row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _MacroCard(
                  label: l10n.protein,
                  current: currentProtein,
                  target: targetProtein,
                  progress: proteinProgress,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroCard(
                  label: l10n.carbsShort,
                  current: currentCarbs,
                  target: targetCarbs,
                  progress: carbsProgress,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroCard(
                  label: l10n.fat,
                  current: currentFat,
                  target: targetFat,
                  progress: fatProgress,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final double progress;

  const _MacroCard({
    required this.label,
    required this.current,
    required this.target,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              children: [
                TextSpan(text: '${current.toInt()}g '),
                TextSpan(
                  text: '/ ${target.toInt()}g',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clampedProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 1.0 ? AppTheme.errorColor : AppTheme.primaryColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
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
    const strokeWidth = 12.0;

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
