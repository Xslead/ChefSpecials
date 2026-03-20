import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/ingredient.dart';
import '../../../utils/unit_converter.dart';

class IngredientListView extends StatelessWidget {
  final List<Ingredient> ingredients;
  final double? scaleFactor;
  final void Function(Ingredient)? onIngredientTap;

  const IngredientListView({
    super.key,
    required this.ingredients,
    this.scaleFactor,
    this.onIngredientTap,
  });

  String _formatAmount(Ingredient ingredient) {
    final rawAmount = ingredient.amount;
    final unit = ingredient.unit ?? '';

    if (scaleFactor != null && scaleFactor != 1.0) {
      final parsed = double.tryParse(rawAmount);
      if (parsed != null) {
        final scaled = parsed * scaleFactor!;
        return UnitConverter.smartFormat(scaled, unit);
      }
    }

    return unit.isNotEmpty ? '$rawAmount $unit' : rawAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(ingredients.length, (index) {
        final ingredient = ingredients[index];
        final subtitle = _formatAmount(ingredient);

        final tile = Container(
          color: index.isEven ? AppTheme.neutralSoft : Colors.transparent,
          child: ListTile(
            leading: const Icon(Icons.fiber_manual_record, size: 10, color: AppTheme.primaryColor),
            title: Text(
              ingredient.name,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (onIngredientTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.swap_horiz, size: 16, color: AppTheme.textTertiary),
                ],
              ],
            ),
            dense: true,
            visualDensity: VisualDensity.compact,
            onTap: onIngredientTap != null ? () => onIngredientTap!(ingredient) : null,
          ),
        );

        return tile;
      }),
    );
  }
}
