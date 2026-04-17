import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/category_helpers.dart';
import '../../models/recipe.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/follow_provider.dart';
import '../../providers/recipe_form_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/screen_header.dart';
import 'widgets/multi_image_picker.dart';
import 'widgets/ingredient_input_list.dart';
import 'widgets/step_input_list.dart';

class AddRecipeScreen extends StatelessWidget {
  final Recipe? initialRecipe;

  const AddRecipeScreen({super.key, this.initialRecipe});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = RecipeFormProvider();
        if (initialRecipe != null) {
          provider.prefillFromRecipe(initialRecipe!);
        }
        return provider;
      },
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

    try {
      final user = authProvider.userModel;
      if (user == null) throw Exception('User not loaded yet. Please try again.');
      final followProvider = context.read<FollowProvider>();
      final activityProvider = context.read<ActivityProvider>();
      final recipe = await formProvider.buildRecipe(user.uid, user.fullName);
      final recipeId = await recipeProvider.createRecipe(recipe);
      // Notify followers about the new recipe (only public recipes)
      if (!recipe.isPrivate) {
        final followerIds =
            await followProvider.getFollowerIds(user.uid);
        if (followerIds.isNotEmpty) {
          activityProvider.createNewRecipeActivity(
            recipeId: recipeId,
            recipeName: recipe.title,
            recipeImageUrl: recipe.imageUrl,
            authorId: user.uid,
            authorName: user.fullName,
            authorAvatar: user.photoUrl,
            followerIds: followerIds,
          );
        }
      }
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 8),
          ),
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
          ScreenHeader(
            title: l10n.addRecipe,
            icon: Icons.restaurant_menu,
            trailing: [
              TextButton(
                onPressed: formProvider.isSubmitting ? null : _submit,
                child: formProvider.isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
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
          // Body
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  // Import from URL
                  OutlinedButton.icon(
                    onPressed: () => context.push('/import-recipe'),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(l10n.importFromUrl),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image picker
                  const MultiImagePicker(),
                  const SizedBox(height: 20),

                  // Recipe name
                  _buildSectionLabel(l10n.recipeName, context),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: formProvider.title,
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
                  _buildSectionLabel(l10n.description, context),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: formProvider.description,
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
                  _buildSectionLabel(l10n.category, context),
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
                            DropdownMenuItem(value: c, child: Text(localizeCategory(c, l10n))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) formProvider.category = v;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dietary Tags
                  _buildSectionLabel(l10n.dietaryTags, context),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.defaultDietaryTags.map((tag) {
                      final selected = formProvider.dietaryTags.contains(tag);
                      return FilterChip(
                        label: Text(localizeDietaryTag(tag, l10n)),
                        selected: selected,
                        onSelected: (_) => formProvider.toggleDietaryTag(tag),
                        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                        checkmarkColor: AppTheme.primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? AppTheme.primaryColor : AppTheme.textSecondaryOf(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selected
                                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                : AppTheme.neutralLightOf(context),
                          ),
                        ),
                        backgroundColor: AppTheme.surfaceOf(context),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Servings, Prep, Cook time row
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactCard(
                          context: context,
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
                            decoration: _compactInputDecoration(context),
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
                          context: context,
                          icon: Icons.timer_outlined,
                          color: AppTheme.starColor,
                          label: l10n.prepTime,
                          child: TextFormField(
                            initialValue:
                                formProvider.prepTimeMinutes.toString(),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.starColor,
                            ),
                            decoration: _compactInputDecoration(context),
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
                          context: context,
                          icon: Icons.local_fire_department,
                          color: AppTheme.errorColor,
                          label: l10n.cookTime,
                          child: TextFormField(
                            initialValue:
                                formProvider.cookTimeMinutes.toString(),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.errorColor,
                            ),
                            decoration: _compactInputDecoration(context),
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

                  // Visibility
                  _buildVisibilityToggle(context, l10n, formProvider),
                  const SizedBox(height: 24),

                  // Ingredients
                  const IngredientInputList(),
                  const SizedBox(height: 24),

                  // Steps
                  const StepInputList(),
                  const SizedBox(height: 24),

                  // Auto-calculated nutrition
                  if (formProvider.ingredients.isNotEmpty) ...[
                    _buildNutritionCard(l10n, formProvider, context),
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

  Widget _buildVisibilityToggle(
      BuildContext context, AppLocalizations l10n, RecipeFormProvider formProvider) {
    final isPrivate = formProvider.isPrivate;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPrivate
                  ? AppTheme.textTertiaryOf(context).withValues(alpha: 0.12)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPrivate ? Icons.lock_outline : Icons.public,
              color: isPrivate
                  ? AppTheme.textSecondaryOf(context)
                  : AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPrivate ? l10n.private : l10n.public,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isPrivate
                      ? l10n.privateDescription
                      : l10n.publicDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isPrivate,
            onChanged: formProvider.setIsPrivate,
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textTertiaryOf(context),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildCompactCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
        boxShadow: [AppTheme.shadowOf(context)],
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
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.textTertiaryOf(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _compactInputDecoration(BuildContext context) {
    return InputDecoration(
      filled: true,
      fillColor: AppTheme.neutralSoftOf(context),
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
      AppLocalizations l10n, RecipeFormProvider formProvider, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
        boxShadow: [AppTheme.shadowOf(context)],
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
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiaryOf(context),
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
                context,
              ),
              _buildNutritionStat(
                l10n.protein,
                '${formProvider.proteinGrams ?? 0}',
                l10n.gram,
                AppTheme.secondaryColor,
                context,
              ),
              _buildNutritionStat(
                l10n.carbs,
                '${formProvider.carbsGrams ?? 0}',
                l10n.gram,
                AppTheme.starColor,
                context,
              ),
              _buildNutritionStat(
                l10n.fat,
                '${formProvider.fatGrams ?? 0}',
                l10n.gram,
                AppTheme.errorColor,
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStat(
      String label, String value, String unit, Color color, BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.textTertiaryOf(context),
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
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textTertiaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
