import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../l10n/generated/app_localizations.dart';

class ServingSizeSelector extends StatelessWidget {
  final int currentServings;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const ServingSizeSelector({
    super.key,
    required this.currentServings,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.neutralSoftOf(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline,
              size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          _buildButton(
            icon: Icons.remove,
            onPressed:
                currentServings > min ? () => onChanged(currentServings - 1) : null,
            context: context,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              l10n.serves(currentServings),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            onPressed:
                currentServings < max ? () => onChanged(currentServings + 1) : null,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? theme.colorScheme.primary
              : AppTheme.neutralLightOf(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.white : AppTheme.textTertiaryOf(context),
        ),
      ),
    );
  }
}
