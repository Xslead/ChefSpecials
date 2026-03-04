import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import 'widgets/ingredient_list_view.dart';
import 'widgets/step_overview_list.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(context, l10n, theme),
                  const SizedBox(height: 16),
                  _buildTimeRow(context, l10n, theme),
                  if (_hasNutrition) ...[
                    const SizedBox(height: 16),
                    _buildNutritionCard(context, l10n, theme),
                  ],
                  const SizedBox(height: 16),
                  _buildServingsInfo(context, l10n, theme),
                  const SizedBox(height: 24),
                  Text(
                    l10n.ingredients,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IngredientListView(ingredients: recipe.ingredients),
                  const SizedBox(height: 24),
                  Text(
                    l10n.steps,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StepOverviewList(steps: recipe.steps),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/cooking/${recipe.id}', extra: recipe);
                      },
                      icon: const Icon(Icons.restaurant),
                      label: Text(l10n.startCooking),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: recipe.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: recipe.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
      ),
    );
  }

  Widget _buildTitleSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              recipe.authorName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Chip(
              label: Text(recipe.category),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeRow(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Row(
      children: [
        _buildTimeItem(
          icon: Icons.hourglass_top,
          label: l10n.prepTime,
          value: '${recipe.prepTimeMinutes} min',
          theme: theme,
        ),
        const SizedBox(width: 24),
        _buildTimeItem(
          icon: Icons.local_fire_department,
          label: l10n.cookTime,
          value: '${recipe.cookTimeMinutes} min',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildTimeItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool get _hasNutrition =>
      recipe.caloriesPerServing != null ||
      recipe.proteinGrams != null ||
      recipe.carbsGrams != null ||
      recipe.fatGrams != null;

  Widget _buildNutritionCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (recipe.caloriesPerServing != null)
              _buildNutritionItem(
                label: l10n.calories,
                value: '${recipe.caloriesPerServing}',
                unit: 'kcal',
                theme: theme,
              ),
            if (recipe.proteinGrams != null)
              _buildNutritionItem(
                label: l10n.protein,
                value: recipe.proteinGrams!.toStringAsFixed(1),
                unit: 'g',
                theme: theme,
              ),
            if (recipe.carbsGrams != null)
              _buildNutritionItem(
                label: l10n.carbs,
                value: recipe.carbsGrams!.toStringAsFixed(1),
                unit: 'g',
                theme: theme,
              ),
            if (recipe.fatGrams != null)
              _buildNutritionItem(
                label: l10n.fat,
                value: recipe.fatGrams!.toStringAsFixed(1),
                unit: 'g',
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem({
    required String label,
    required String value,
    required String unit,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildServingsInfo(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(Icons.people_outline, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          '${l10n.servings}: ${recipe.servings}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
