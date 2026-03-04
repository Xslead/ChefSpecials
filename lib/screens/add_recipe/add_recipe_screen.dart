import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_form_provider.dart';
import '../../providers/recipe_provider.dart';
import 'widgets/image_picker_tile.dart';
import 'widgets/ingredient_input_list.dart';
import 'widgets/step_input_list.dart';

class AddRecipeScreen extends StatelessWidget {
  const AddRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeFormProvider(),
      child: const _AddRecipeForm(),
    );
  }
}

class _AddRecipeForm extends StatefulWidget {
  const _AddRecipeForm();

  @override
  State<_AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<_AddRecipeForm> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final formProvider = context.read<RecipeFormProvider>();
    final recipeProvider = context.read<RecipeProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.userModel!;

    try {
      final recipe = await formProvider.buildRecipe(user.uid, user.fullName);
      await recipeProvider.createRecipe(recipe);
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formProvider = context.watch<RecipeFormProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addRecipe)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const ImagePickerTile(),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.recipeName,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              onChanged: (v) => formProvider.title = v,
            ),
            const SizedBox(height: 12),

            // Description
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.description,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              onChanged: (v) => formProvider.description = v,
            ),
            const SizedBox(height: 12),

            // Category dropdown
            DropdownButtonFormField<String>(
              initialValue: formProvider.category,
              decoration: InputDecoration(
                labelText: l10n.category,
                border: const OutlineInputBorder(),
              ),
              items: AppConstants.defaultCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) formProvider.category = v;
              },
            ),
            const SizedBox(height: 12),

            // Servings and Prep time
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: formProvider.servings.toString(),
                    decoration: InputDecoration(
                      labelText: l10n.servings,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) formProvider.servings = n;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.prepTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${formProvider.prepTimeMinutes} min',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: formProvider.cookTimeMinutes.toString(),
                    decoration: InputDecoration(
                      labelText: l10n.cookTime,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) formProvider.cookTimeMinutes = n;
                    },
                  ),
                ),
              ],
            ),
            if (formProvider.cookTimeMinutes > 0 || formProvider.prepTimeMinutes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Total: ${formProvider.prepTimeMinutes + formProvider.cookTimeMinutes} min',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Ingredients (from materials database)
            const IngredientInputList(),
            const SizedBox(height: 20),

            // Steps
            const StepInputList(),
            const SizedBox(height: 20),

            // Auto-calculated nutrition
            if (formProvider.ingredients.isNotEmpty) ...[
              Text(
                'Nutrition (auto-calculated per serving)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NutritionChip(
                        label: l10n.calories,
                        value: '${formProvider.caloriesPerServing ?? 0}',
                        unit: 'kcal',
                      ),
                      _NutritionChip(
                        label: l10n.protein,
                        value: '${formProvider.proteinGrams ?? 0}',
                        unit: 'g',
                      ),
                      _NutritionChip(
                        label: l10n.carbs,
                        value: '${formProvider.carbsGrams ?? 0}',
                        unit: 'g',
                      ),
                      _NutritionChip(
                        label: l10n.fat,
                        value: '${formProvider.fatGrams ?? 0}',
                        unit: 'g',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Submit button
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: formProvider.isSubmitting ? null : _submit,
                child: formProvider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _NutritionChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutritionChip({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(unit, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
