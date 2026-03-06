import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import 'widgets/ingredient_list_view.dart';
import 'widgets/step_overview_list.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Always use the latest version from the provider so edits are reflected immediately
    final liveRecipe = context
        .watch<RecipeProvider>()
        .allRecipes
        .firstWhere((r) => r.id == recipe.id, orElse: () => recipe);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, liveRecipe),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(context, l10n, theme, liveRecipe),
                  const SizedBox(height: 16),
                  _buildTimeRow(context, l10n, theme, liveRecipe),
                  if (_hasNutrition(liveRecipe)) ...[
                    const SizedBox(height: 16),
                    _buildNutritionCard(context, l10n, theme, liveRecipe),
                  ],
                  const SizedBox(height: 16),
                  _buildServingsInfo(context, l10n, theme, liveRecipe),
                  const SizedBox(height: 24),
                  Text(
                    l10n.ingredients,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IngredientListView(ingredients: liveRecipe.ingredients),
                  const SizedBox(height: 24),
                  Text(
                    l10n.steps,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StepOverviewList(steps: liveRecipe.steps),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/cooking/${liveRecipe.id}', extra: liveRecipe);
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

  bool _isOwner(BuildContext context, Recipe r) {
    final userId = context.read<AuthProvider>().userModel?.uid;
    return userId != null && userId == r.authorId;
  }

  Future<void> _deleteRecipe(BuildContext context, Recipe r) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('${l10n.delete} "${r.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<RecipeProvider>().deleteRecipe(r.id!);
      if (context.mounted) context.pop();
    }
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Recipe r) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      actions: [
        if (_isOwner(context, r)) ...[
          _buildCircleIconButton(
            icon: Icons.edit_outlined,
            color: Colors.blue.shade700,
            onPressed: () =>
                context.push('/edit-recipe/${r.id}', extra: r),
          ),
          _buildCircleIconButton(
            icon: Icons.delete_outline,
            color: Colors.red.shade600,
            onPressed: () => _deleteRecipe(context, r),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: r.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: r.imageUrl!,
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
    Recipe r,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              r.authorName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Chip(
              label: Text(r.category),
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
    Recipe r,
  ) {
    return Row(
      children: [
        _buildTimeItem(
          icon: Icons.hourglass_top,
          label: l10n.prepTime,
          value: '${r.prepTimeMinutes} min',
          theme: theme,
        ),
        const SizedBox(width: 24),
        _buildTimeItem(
          icon: Icons.local_fire_department,
          label: l10n.cookTime,
          value: '${r.cookTimeMinutes} min',
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

  bool _hasNutrition(Recipe r) =>
      r.caloriesPerServing != null ||
      r.proteinGrams != null ||
      r.carbsGrams != null ||
      r.fatGrams != null;

  Widget _buildNutritionCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Recipe r,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (r.caloriesPerServing != null)
              _buildNutritionItem(
                label: l10n.calories,
                value: '${r.caloriesPerServing}',
                unit: 'kcal',
                theme: theme,
              ),
            if (r.proteinGrams != null)
              _buildNutritionItem(
                label: l10n.protein,
                value: r.proteinGrams!.toStringAsFixed(1),
                unit: 'g',
                theme: theme,
              ),
            if (r.carbsGrams != null)
              _buildNutritionItem(
                label: l10n.carbs,
                value: r.carbsGrams!.toStringAsFixed(1),
                unit: 'g',
                theme: theme,
              ),
            if (r.fatGrams != null)
              _buildNutritionItem(
                label: l10n.fat,
                value: r.fatGrams!.toStringAsFixed(1),
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
    Recipe r,
  ) {
    return Row(
      children: [
        Icon(Icons.people_outline, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          '${l10n.servings}: ${r.servings}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
