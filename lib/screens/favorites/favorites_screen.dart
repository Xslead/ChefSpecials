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
      body: Column(
        children: [
          // Custom header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.favorites,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    if (favoriteRecipes.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${favoriteRecipes.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEF4444),
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
            child: favoriteRecipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            size: 36,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noFavorites,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap the heart icon on recipes to save them here',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
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
