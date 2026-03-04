import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/recipe.dart';
import '../../../providers/favorite_provider.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalTime = recipe.prepTimeMinutes + recipe.cookTimeMinutes;

    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.id}', extra: recipe),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                _buildImage(),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildFavoriteButton(context),
                ),
              ],
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Badge row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryBadge(l10n),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Author + Time row
                  Row(
                    children: [
                      // Author avatar
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                        child: Text(
                          recipe.authorName.isNotEmpty
                              ? recipe.authorName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          recipe.authorName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '\u2022',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$totalTime ${l10n.minuteShort}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  // Nutrition grid
                  if (recipe.caloriesPerServing != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.only(top: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildNutritionColumn(
                            l10n.calories,
                            '${recipe.caloriesPerServing}',
                          ),
                          _buildNutritionColumn(
                            l10n.protein,
                            recipe.proteinGrams != null
                                ? '${recipe.proteinGrams!.toStringAsFixed(0)}g'
                                : '-',
                          ),
                          _buildNutritionColumn(
                            l10n.carbs,
                            recipe.carbsGrams != null
                                ? '${recipe.carbsGrams!.toStringAsFixed(0)}g'
                                : '-',
                          ),
                          _buildNutritionColumn(
                            l10n.fat,
                            recipe.fatGrams != null
                                ? '${recipe.fatGrams!.toStringAsFixed(0)}g'
                                : '-',
                          ),
                        ],
                      ),
                    ),
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
        height: 192,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 192,
          color: Colors.grey.shade100,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 2,
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
      height: 192,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.restaurant,
        size: 56,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();
    final isFav = recipe.id != null && favoriteProvider.isFavorite(recipe.id!);

    return GestureDetector(
      onTap: () {
        if (recipe.id != null) {
          favoriteProvider.toggleFavorite(recipe.id!);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.red.shade500 : Colors.grey.shade400,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(AppLocalizations l10n) {
    final color = _getCategoryColor();
    final label = _localizeCategory(recipe.category, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (recipe.category) {
      case 'Salad':
      case 'Soup':
        return const Color(0xFF059669); // emerald
      case 'Dessert':
      case 'Drink':
        return const Color(0xFF7C3AED); // violet
      case 'Snack':
        return const Color(0xFF0891B2); // cyan
      default:
        return AppTheme.primaryColor;
    }
  }

  Widget _buildNutritionColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _localizeCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Breakfast':
        return l10n.breakfast;
      case 'Lunch':
        return l10n.lunch;
      case 'Dinner':
        return l10n.dinner;
      case 'Dessert':
        return l10n.dessert;
      case 'Snack':
        return l10n.snack;
      case 'Drink':
        return l10n.drink;
      case 'Salad':
        return l10n.salad;
      case 'Soup':
        return l10n.soup;
      default:
        return category;
    }
  }
}
