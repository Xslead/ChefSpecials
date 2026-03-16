import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../models/recipe_collection.dart';
import '../../providers/collection_provider.dart';
import '../../providers/recipe_provider.dart';
import '../home/widgets/recipe_card.dart';

class CollectionDetailScreen extends StatelessWidget {
  final String collectionId;
  const CollectionDetailScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CollectionProvider>();
    final recipeProvider = context.watch<RecipeProvider>();
    final collection =
        provider.collections.where((c) => c.id == collectionId).firstOrNull;

    if (collection == null) {
      return Scaffold(
        body: Column(
          children: [
            _buildHeader(context, l10n, null),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    final recipes = collection.recipeIds
        .map((id) =>
            recipeProvider.allRecipes.where((r) => r.id == id).firstOrNull)
        .whereType<Recipe>()
        .toList();

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, collection),
          Expanded(
            child: recipes.isEmpty
                ? _buildEmptyState(context, l10n)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Dismissible(
                          key: Key(recipe.id!),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          onDismissed: (_) {
                            provider.removeRecipe(
                                collectionId, recipe.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.removedFromCollection(
                                      collection.name),
                                ),
                              ),
                            );
                          },
                          child: RecipeCard(recipe: recipe),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    RecipeCollection? collection,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
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
                color: AppTheme.textPrimaryOf(context),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.folder,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection?.name ?? l10n.collection,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (collection != null && collection.recipeIds.isNotEmpty)
                      Text(
                        l10n.recipeCountInCollection(
                            collection.recipeIds.length),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.neutralSoftOf(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 36,
              color: AppTheme.neutralLightOf(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyCollection,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.emptyCollectionSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textTertiaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
