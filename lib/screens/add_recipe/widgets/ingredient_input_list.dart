import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/recipe_form_provider.dart';

class IngredientInputList extends StatelessWidget {
  const IngredientInputList({super.key});

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<RecipeFormProvider>();
    final l10n = AppLocalizations.of(context)!;
    final ingredients = formProvider.ingredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.ingredients,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: formProvider.addIngredient,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ingredients.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final ingredient = ingredients[index];
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: ingredient.name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) =>
                        formProvider.updateIngredient(index, name: value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: ingredient.amount,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) =>
                        formProvider.updateIngredient(index, amount: value),
                  ),
                ),
                const SizedBox(width: 4),
                if (ingredients.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 20,
                    onPressed: () => formProvider.removeIngredient(index),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
