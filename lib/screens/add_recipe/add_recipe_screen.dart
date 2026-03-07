import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
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
      body: Column(
        children: [
          // Custom header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                      color: AppTheme.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.addRecipe,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: formProvider.isSubmitting ? null : _submit,
                      child: formProvider.isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              l10n.save,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Body
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  // Image picker
                  const ImagePickerTile(),
                  const SizedBox(height: 20),

                  // Recipe name
                  _buildSectionLabel(l10n.recipeName),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: l10n.recipeName,
                      prefixIcon: const Icon(
                        Icons.edit_outlined,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                    onChanged: (v) => formProvider.title = v,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _buildSectionLabel(l10n.description),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: l10n.description,
                      prefixIcon: const Icon(
                        Icons.notes,
                        color: AppTheme.textTertiary,
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                    onChanged: (v) => formProvider.description = v,
                  ),
                  const SizedBox(height: 16),

                  // Category
                  _buildSectionLabel(l10n.category),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: formProvider.category,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.category_outlined,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    items: AppConstants.defaultCategories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) formProvider.category = v;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Servings, Prep, Cook time row
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactCard(
                          icon: Icons.people_outline,
                          color: AppTheme.primaryColor,
                          label: l10n.servings,
                          child: TextFormField(
                            initialValue: formProvider.servings.toString(),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryColor,
                            ),
                            decoration: _compactInputDecoration(),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) formProvider.servings = n;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCompactCard(
                          icon: Icons.timer_outlined,
                          color: const Color(0xFFF59E0B),
                          label: l10n.prepTime,
                          child: TextFormField(
                            initialValue:
                                formProvider.prepTimeMinutes.toString(),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF59E0B),
                            ),
                            decoration: _compactInputDecoration(),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) formProvider.prepTimeMinutes = n;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCompactCard(
                          icon: Icons.local_fire_department,
                          color: const Color(0xFFEF4444),
                          label: l10n.cookTime,
                          child: TextFormField(
                            initialValue:
                                formProvider.cookTimeMinutes.toString(),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFEF4444),
                            ),
                            decoration: _compactInputDecoration(),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) formProvider.cookTimeMinutes = n;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ingredients
                  const IngredientInputList(),
                  const SizedBox(height: 24),

                  // Steps
                  const StepInputList(),
                  const SizedBox(height: 24),

                  // Auto-calculated nutrition
                  if (formProvider.ingredients.isNotEmpty) ...[
                    _buildNutritionCard(l10n, formProvider),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildCompactCard({
    required IconData icon,
    required Color color,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
        boxShadow: [AppTheme.warmShadowLight()],
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _compactInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppTheme.warmCream,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildNutritionCard(
      AppLocalizations l10n, RecipeFormProvider formProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
        boxShadow: [AppTheme.warmShadowLight()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_outlined,
                    color: AppTheme.secondaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.calories.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildNutritionStat(
                l10n.calories,
                '${formProvider.caloriesPerServing ?? 0}',
                l10n.kcal,
                AppTheme.primaryColor,
              ),
              _buildNutritionStat(
                l10n.protein,
                '${formProvider.proteinGrams ?? 0}',
                l10n.gram,
                AppTheme.secondaryColor,
              ),
              _buildNutritionStat(
                l10n.carbs,
                '${formProvider.carbsGrams ?? 0}',
                l10n.gram,
                const Color(0xFFF59E0B),
              ),
              _buildNutritionStat(
                l10n.fat,
                '${formProvider.fatGrams ?? 0}',
                l10n.gram,
                const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStat(
      String label, String value, String unit, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
