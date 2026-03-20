import 'package:cached_network_image/cached_network_image.dart';
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

class CollectionDetailScreen extends StatefulWidget {
  final String collectionId;
  const CollectionDetailScreen({super.key, required this.collectionId});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  void _showAddRecipeSheet(
    RecipeCollection collection,
    List<Recipe> allRecipes,
    CollectionProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final currentIds = provider.collections
                .where((c) => c.id == widget.collectionId)
                .firstOrNull
                ?.recipeIds ?? [];

            final filtered = allRecipes.where((r) {
              if (query.isNotEmpty &&
                  !r.title.toLowerCase().contains(query.toLowerCase())) {
                return false;
              }
              return true;
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (_, scrollController) {
                return SafeArea(
                  child: Column(
                    children: [
                      // Handle bar
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 6),
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.neutralLightOf(ctx),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add,
                                  color: AppTheme.primaryColor, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.addToCollection,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    collection.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textTertiaryOf(ctx),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: TextField(
                          onChanged: (v) => setSheetState(() => query = v),
                          decoration: InputDecoration(
                            hintText: l10n.search,
                            prefixIcon:
                                const Icon(Icons.search, size: 20),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppTheme.neutralLightOf(ctx)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppTheme.neutralLightOf(ctx)),
                            ),
                          ),
                        ),
                      ),
                      // Recipe list
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  l10n.noRecipes,
                                  style: TextStyle(
                                    color: AppTheme.textTertiaryOf(ctx),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                itemCount: filtered.length,
                                itemBuilder: (_, i) {
                                  final recipe = filtered[i];
                                  final isAdded = currentIds
                                      .contains(recipe.id);
                                  return _buildRecipeTile(
                                    ctx,
                                    recipe,
                                    isAdded,
                                    provider,
                                    setSheetState,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRecipeTile(
    BuildContext context,
    Recipe recipe,
    bool isAdded,
    CollectionProvider provider,
    StateSetter setSheetState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () async {
          if (recipe.id == null) return;
          if (isAdded) {
            await provider.removeRecipe(widget.collectionId, recipe.id!);
          } else {
            await provider.addRecipe(widget.collectionId, recipe.id!);
          }
          setSheetState(() {});
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isAdded
                ? AppTheme.primaryColor.withValues(alpha: 0.06)
                : AppTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAdded
                  ? AppTheme.primaryColor.withValues(alpha: 0.3)
                  : AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Recipe thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: recipe.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: recipe.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: AppTheme.neutralSoftOf(context),
                            child: const Icon(Icons.restaurant,
                                size: 20, color: AppTheme.textTertiary),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: AppTheme.neutralSoftOf(context),
                            child: const Icon(Icons.restaurant,
                                size: 20, color: AppTheme.textTertiary),
                          ),
                        )
                      : Container(
                          color: AppTheme.neutralSoftOf(context),
                          child: const Icon(Icons.restaurant,
                              size: 20, color: AppTheme.textTertiary),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Title + category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recipe.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Check icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isAdded
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAdded
                        ? AppTheme.primaryColor
                        : AppTheme.neutralLightOf(context),
                    width: 2,
                  ),
                ),
                child: isAdded
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CollectionProvider>();
    final recipeProvider = context.watch<RecipeProvider>();
    final collection = provider.collections
        .where((c) => c.id == widget.collectionId)
        .firstOrNull;

    if (collection == null) {
      return Scaffold(
        body: Column(
          children: [
            _buildHeader(context, l10n, null, provider),
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
          _buildHeader(context, l10n, collection, provider),
          Expanded(
            child: recipes.isEmpty
                ? _buildEmptyState(context, l10n, collection,
                    recipeProvider.allRecipes, provider)
                : _buildRecipeList(
                    context, l10n, recipes, collection, provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'collection_detail_fab',
        onPressed: () => _showAddRecipeSheet(
            collection, recipeProvider.allRecipes, provider),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    RecipeCollection? collection,
    CollectionProvider provider,
  ) {
    final recipeCount = collection?.recipeIds.length ?? 0;

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
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (collection != null)
                      Text(
                        l10n.recipeCountInCollection(recipeCount),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                      ),
                  ],
                ),
              ),
              if (recipeCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$recipeCount',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeList(
    BuildContext context,
    AppLocalizations l10n,
    List<Recipe> recipes,
    RecipeCollection collection,
    CollectionProvider provider,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (collection.description?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 18,
                      color: AppTheme.primaryColor.withValues(alpha: 0.7)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      collection.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            '${l10n.recipes.toUpperCase()} (${recipes.length})',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textTertiaryOf(context),
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...recipes.map((recipe) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.remove_circle_outline,
                          color: Colors.white, size: 24),
                      const SizedBox(height: 4),
                      Text(l10n.remove,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                onDismissed: (_) {
                  provider.removeRecipe(widget.collectionId, recipe.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(l10n.removedFromCollection(collection.name)),
                      action: SnackBarAction(
                        label: l10n.undo,
                        onPressed: () {
                          provider.addRecipe(widget.collectionId, recipe.id!);
                        },
                      ),
                    ),
                  );
                },
                child: RecipeCard(recipe: recipe),
              ),
            )),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    RecipeCollection collection,
    List<Recipe> allRecipes,
    CollectionProvider provider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.neutralSoftOf(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 30,
                color: AppTheme.neutralLightOf(context),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.emptyCollection,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyCollectionSubtitle,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textTertiaryOf(context),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
