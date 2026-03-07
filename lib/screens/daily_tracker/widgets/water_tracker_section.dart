import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class WaterTrackerSection extends StatelessWidget {
  final int currentMl;
  final int targetMl;
  final Function(int) onAdd;
  final Function(int) onRemove;

  const WaterTrackerSection({
    super.key,
    required this.currentMl,
    required this.targetMl,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const glassSize = 250;
    final totalGlasses = (targetMl / glassSize).ceil();
    final filledGlasses = (currentMl / glassSize).floor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warmBeige.withValues(alpha: 0.5),
        ),
        boxShadow: [AppTheme.warmShadowLight()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop,
                      color: Color(0xFF0EA5E9), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    l10n.waterTracking,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              Text(
                '$currentMl / $targetMl ${l10n.ml}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Glass icons — tap a filled glass to remove it
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(totalGlasses, (index) {
              final isFilled = index < filledGlasses;
              return GestureDetector(
                onTap: isFilled
                    ? () => onRemove(glassSize)
                    : () => onAdd(glassSize),
                child: Icon(
                  Icons.local_drink,
                  size: 24,
                  color: isFilled
                      ? const Color(0xFF0EA5E9)
                      : AppTheme.warmBeige,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Add / remove buttons
          Row(
            children: [
              Expanded(
                child: _WaterButton(
                  label: '− 250 ${l10n.ml}',
                  color: const Color(0xFFEF4444),
                  borderColor: const Color(0xFFFECACA),
                  enabled: currentMl >= 250,
                  onTap: () => onRemove(250),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WaterButton(
                  label: '+ 250 ${l10n.ml}',
                  color: const Color(0xFF0EA5E9),
                  borderColor: const Color(0xFFBAE6FD),
                  enabled: true,
                  onTap: () => onAdd(250),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WaterButton(
                  label: '+ 500 ${l10n.ml}',
                  color: const Color(0xFF0EA5E9),
                  borderColor: const Color(0xFFBAE6FD),
                  enabled: true,
                  onTap: () => onAdd(500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color borderColor;
  final bool enabled;
  final VoidCallback onTap;

  const _WaterButton({
    required this.label,
    required this.color,
    required this.borderColor,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? borderColor : AppTheme.warmBeige,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: enabled ? color : AppTheme.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
