import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/ingredient.dart';

class IngredientListView extends StatelessWidget {
  final List<Ingredient> ingredients;

  const IngredientListView({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(ingredients.length, (index) {
        final ingredient = ingredients[index];
        final subtitle = ingredient.unit != null
            ? '${ingredient.amount} ${ingredient.unit}'
            : ingredient.amount;

        return Container(
          color: index.isEven ? AppTheme.warmCream : Colors.transparent,
          child: ListTile(
            leading: const Icon(Icons.fiber_manual_record, size: 10, color: AppTheme.primaryColor),
            title: Text(
              ingredient.name,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            trailing: Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        );
      }),
    );
  }
}
