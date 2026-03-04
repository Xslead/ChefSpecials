import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';

class WaterTrackerSection extends StatelessWidget {
  final int currentMl;
  final int targetMl;
  final Function(int) onAdd;

  const WaterTrackerSection({
    super.key,
    required this.currentMl,
    required this.targetMl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final glassSize = 250;
    final totalGlasses = (targetMl / glassSize).ceil();
    final filledGlasses = (currentMl / glassSize).floor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
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
                  Icon(
                    Icons.water_drop,
                    color: Colors.blue.shade500,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.waterTracking,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '$currentMl / $targetMl ${l10n.ml}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Glass icons
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(totalGlasses, (index) {
              final isFilled = index < filledGlasses;
              return Icon(
                Icons.local_drink,
                size: 24,
                color: isFilled
                    ? Colors.blue.shade500
                    : Colors.grey.shade300,
              );
            }),
          ),
          const SizedBox(height: 16),
          // Add buttons
          Row(
            children: [
              Expanded(
                child: _WaterButton(
                  label: '+ 250${l10n.ml}',
                  onTap: () => onAdd(250),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WaterButton(
                  label: '+ 500${l10n.ml}',
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
  final VoidCallback onTap;

  const _WaterButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
