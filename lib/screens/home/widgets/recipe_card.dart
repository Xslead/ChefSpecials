import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final totalTime = recipe.prepTimeMinutes + recipe.cookTimeMinutes;
    final hasNutrition = recipe.caloriesPerServing != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/recipe/${recipe.id}', extra: recipe),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.authorName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTimeRow(totalTime),
                  if (hasNutrition) ...[
                    const SizedBox(height: 8),
                    _buildNutritionRow(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recipe.imageUrl!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.restaurant,
        size: 64,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        recipe.category,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildTimeRow(int totalTime) {
    return Row(
      children: [
        const Icon(
          Icons.timer_outlined,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          'Prep ${recipe.prepTimeMinutes}m',
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Cook ${recipe.cookTimeMinutes}m',
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '($totalTime min total)',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRow() {
    return Row(
      children: [
        if (recipe.caloriesPerServing != null)
          _buildNutritionItem(Icons.local_fire_department_outlined,
              '${recipe.caloriesPerServing} cal'),
        if (recipe.proteinGrams != null)
          _buildNutritionItem(
              Icons.fitness_center, '${recipe.proteinGrams!.toStringAsFixed(0)}g P'),
        if (recipe.carbsGrams != null)
          _buildNutritionItem(
              Icons.grain, '${recipe.carbsGrams!.toStringAsFixed(0)}g C'),
        if (recipe.fatGrams != null)
          _buildNutritionItem(
              Icons.opacity, '${recipe.fatGrams!.toStringAsFixed(0)}g F'),
      ],
    );
  }

  Widget _buildNutritionItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
