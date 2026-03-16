import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';
import '../home/widgets/recipe_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoriteProvider = context.watch<FavoriteProvider>();
    final recipeProvider = context.watch<RecipeProvider>();

    final favoriteIds = favoriteProvider.favoriteRecipeIds;
    final favoriteRecipes = recipeProvider.allRecipes
        .where((r) => r.id != null && favoriteIds.contains(r.id))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.favorites,
            icon: Icons.favorite,
            iconColor: AppTheme.errorColor,
            trailing: [
              if (favoriteRecipes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${favoriteRecipes.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ),
            ],
          ),

          // Body
          Expanded(
            child: favoriteRecipes.isEmpty
                ? EmptyState(
                    icon: Icons.favorite_border,
                    title: l10n.noFavorites,
                    subtitle: l10n.favoritesEmptySubtitle,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RecipeCard(recipe: favoriteRecipes[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
