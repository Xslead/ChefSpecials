import 'package:flutter/material.dart';
import '../../../models/ingredient.dart';

class IngredientListView extends StatelessWidget {
  final List<Ingredient> ingredients;

  const IngredientListView({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ingredients.map((ingredient) {
        final subtitle = ingredient.unit != null
            ? '${ingredient.amount} ${ingredient.unit}'
            : ingredient.amount;

        return ListTile(
          leading: const Icon(Icons.fiber_manual_record, size: 10),
          title: Text(ingredient.name),
          trailing: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          dense: true,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}
