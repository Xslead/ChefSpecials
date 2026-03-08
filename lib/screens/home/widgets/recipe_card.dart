import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/recipe.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorite_provider.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _isPressed = false;

  Recipe get recipe => widget.recipe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalTime = recipe.prepTimeMinutes + recipe.cookTimeMinutes;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.push('/recipe/${recipe.id}', extra: recipe);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
            ),
            boxShadow: [AppTheme.shadowOf(context)],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Stack(
                children: [
                  _buildImage(),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category badge (top-left, glass effect)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildCategoryBadge(l10n),
                  ),
                  // Favorite button (top-right, glass effect)
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
                    // Title
                    Text(
                      recipe.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryOf(context),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Author + Time row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _navigateToAuthor(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    AppTheme.primaryColor.withValues(alpha: 0.15),
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
                              Text(
                                recipe.authorName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryOf(context),
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      AppTheme.textSecondaryOf(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '\u2022',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiaryOf(context),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$totalTime ${l10n.minuteShort}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryOf(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Rating + comment row
                    _buildRatingRow(),
                    // Nutrition grid
                    if (recipe.caloriesPerServing != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.only(top: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppTheme.neutralLightOf(context)),
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
      ),
    );
  }

  void _navigateToAuthor(BuildContext context) {
    final currentUid =
        context.read<AuthProvider>().userModel?.uid;
    if (currentUid == recipe.authorId) {
      context.push('/profile');
    } else {
      context.push(
        '/user/${recipe.authorId}',
        extra: recipe.authorName,
      );
    }
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        Icon(
          recipe.averageRating > 0 ? Icons.star : Icons.star_border,
          size: 14,
          color: AppTheme.starColor,
        ),
        const SizedBox(width: 3),
        Text(
          recipe.averageRating > 0
              ? recipe.averageRating.toStringAsFixed(1)
              : '-',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        if (recipe.ratingCount > 0) ...[
          Text(
            ' (${recipe.ratingCount})',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiaryOf(context),
            ),
          ),
        ],
        const SizedBox(width: 10),
        Icon(
          Icons.chat_bubble_outline,
          size: 13,
          color: AppTheme.textTertiaryOf(context),
        ),
        const SizedBox(width: 3),
        Text(
          '${recipe.commentCount}',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryOf(context),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recipe.imageUrl!,
        height: 210,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 210,
          color: AppTheme.neutralLightOf(context),
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
      height: 210,
      width: double.infinity,
      color: AppTheme.neutralLightOf(context),
      child: Icon(
        Icons.restaurant,
        size: 56,
        color: AppTheme.textTertiaryOf(context),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();
    final isFav =
        recipe.id != null && favoriteProvider.isFavorite(recipe.id!);

    return GestureDetector(
      onTap: () {
        if (recipe.id != null) {
          favoriteProvider.toggleFavorite(recipe.id!);
        }
      },
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? AppTheme.errorColor : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(AppLocalizations l10n) {
    final label = _localizeCategory(recipe.category, l10n);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
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
              color: AppTheme.textTertiaryOf(context),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryOf(context),
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
