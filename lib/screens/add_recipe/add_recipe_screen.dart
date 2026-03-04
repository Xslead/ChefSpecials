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

            // Servings, Prep time, Cook time
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
                  child: TextFormField(
                    initialValue: formProvider.prepTimeMinutes.toString(),
                    decoration: InputDecoration(
                      labelText: l10n.prepTime,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) formProvider.prepTimeMinutes = n;
                    },
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
            const SizedBox(height: 20),

            // Ingredients
            const IngredientInputList(),
            const SizedBox(height: 20),

            // Steps
            const StepInputList(),
            const SizedBox(height: 20),

            // Nutrition section
            Text(
              'Nutrition',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.calories,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        formProvider.caloriesPerServing = int.tryParse(v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.protein,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) =>
                        formProvider.proteinGrams = double.tryParse(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.carbs,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) =>
                        formProvider.carbsGrams = double.tryParse(v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.fat,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) =>
                        formProvider.fatGrams = double.tryParse(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

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
