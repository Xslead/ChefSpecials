import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/recipe_provider.dart';
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
      appBar: AppBar(
        title: Text(l10n.favorites),
      ),
      body: favoriteRecipes.isEmpty
          ? Center(
              child: Text(
                l10n.noFavorites,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            )
          : ListView.builder(
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(recipe: favoriteRecipes[index]);
              },
            ),
    );
  }
}
