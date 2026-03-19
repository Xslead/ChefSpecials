import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/comment.dart';
import '../../models/recipe.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/shopping_list_provider.dart';
import '../../providers/collection_provider.dart';
import '../../models/shopping_list.dart';
import '../../services/shopping_list_service.dart';
import '../../services/activity_service.dart';
import '../../widgets/gradient_button.dart';
import 'widgets/ingredient_list_view.dart';
import 'widgets/step_overview_list.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
      ],
      child: _RecipeDetailBody(recipe: recipe),
    );
  }
}

class _RecipeDetailBody extends StatefulWidget {
  final Recipe recipe;
  const _RecipeDetailBody({required this.recipe});

  @override
  State<_RecipeDetailBody> createState() => _RecipeDetailBodyState();
}

class _RecipeDetailBodyState extends State<_RecipeDetailBody> {
  final TextEditingController _commentController = TextEditingController();
  bool _submittingComment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeId = widget.recipe.id;
      if (recipeId == null) return;
      final userId = context.read<AuthProvider>().userModel?.uid;
      if (userId != null) {
        context.read<RatingProvider>().loadUserRating(recipeId, userId);
      }
      context.read<CommentProvider>().listenToComments(recipeId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool _isOwner(Recipe r) {
    final userId = context.read<AuthProvider>().userModel?.uid;
    return userId != null && userId == r.authorId;
  }

  Future<void> _deleteRecipe(BuildContext context, Recipe r) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.delete),
        content: Text('${l10n.delete} "${r.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onSendPressed(Recipe r) async {
    final ratingProvider = context.read<RatingProvider>();
    final commentProvider = context.read<CommentProvider>();
    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;

    if (_isOwner(r)) {
      _showSnackBar('You cannot rate or comment on your own recipe.');
      return;
    }

    final pendingStars = ratingProvider.displayStars;
    final hasExistingRating = ratingProvider.userRating != null;
    final commentText = _commentController.text.trim();

    final myEntry = commentProvider.comments
        .where((c) => c.userId == user.uid)
        .firstOrNull;
    final hasTextComment = myEntry != null && myEntry.text.isNotEmpty;

    if (pendingStars == 0 && commentText.isEmpty) {
      _showSnackBar('Please select stars or write a comment.');
      return;
    }

    if (pendingStars > 0 && hasExistingRating) {
      _showSnackBar('Delete your existing rating first to submit a new one.');
      return;
    }

    if (commentText.isNotEmpty && hasTextComment) {
      _showSnackBar('Delete your existing comment first to submit a new one.');
      return;
    }

    setState(() => _submittingComment = true);
    try {
      if (pendingStars > 0 && !hasExistingRating) {
        await ratingProvider.submitRating(
          recipeId: r.id!,
          userId: user.uid,
        );
      }

      final commentStars = ratingProvider.userRating?.stars ?? pendingStars;

      if (myEntry == null) {
        await commentProvider.addComment(Comment(
          recipeId: r.id!,
          userId: user.uid,
          authorName: user.fullName,
          text: commentText,
          stars: commentStars,
          createdAt: DateTime.now(),
        ));
      } else if (commentText.isNotEmpty && myEntry.text.isEmpty) {
        await commentProvider.updateCommentText(
          commentId: myEntry.id!,
          recipeId: r.id!,
          newText: commentText,
          newStars: commentStars,
        );
      }
      _commentController.clear();

      // Create a single activity notification for comment+rating
      final activityService = ActivityService();
      final hasNewRating = pendingStars > 0 && !hasExistingRating;
      if (commentText.isNotEmpty && hasNewRating) {
        // Combined: comment + rating → single comment activity with stars in message
        activityService.createCommentActivity(
          recipeAuthorId: r.authorId,
          actorId: user.uid,
          actorName: user.fullName,
          actorAvatar: user.photoUrl,
          recipeId: r.id!,
          recipeName: r.title,
          recipeImageUrl: r.imageUrl,
          commentText: commentText,
          stars: pendingStars,
        );
      } else if (commentText.isNotEmpty) {
        activityService.createCommentActivity(
          recipeAuthorId: r.authorId,
          actorId: user.uid,
          actorName: user.fullName,
          actorAvatar: user.photoUrl,
          recipeId: r.id!,
          recipeName: r.title,
          recipeImageUrl: r.imageUrl,
          commentText: commentText,
        );
      } else if (hasNewRating) {
        activityService.createRatingActivity(
          recipeAuthorId: r.authorId,
          actorId: user.uid,
          actorName: user.fullName,
          actorAvatar: user.photoUrl,
          recipeId: r.id!,
          recipeName: r.title,
          recipeImageUrl: r.imageUrl,
          stars: pendingStars,
        );
      }
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  Future<void> _deleteReview(String commentId, String recipeId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteComment),
        content: const Text('Your rating and comment will both be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final userId = context.read<AuthProvider>().userModel?.uid;
      final commentProvider = context.read<CommentProvider>();
      final ratingProvider = context.read<RatingProvider>();
      await commentProvider.deleteComment(
        commentId: commentId,
        recipeId: recipeId,
      );
      if (userId != null && mounted) {
        await ratingProvider.deleteRating(
          recipeId: recipeId,
          userId: userId,
        );
      }
    }
  }

  Future<void> _shareRecipe(Recipe r) async {
    final l10n = AppLocalizations.of(context)!;
    final ingredientsList = r.ingredients
        .map((ing) => '- ${ing.amount} ${ing.unit} ${ing.name}')
        .join('\n');
    final link = 'chefspecials://recipe/${r.id}';
    final text = l10n.shareRecipeText(
      r.title,
      r.authorName,
      ingredientsList,
      link,
    );
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (_) {}
  }

  void _showAddToShoppingListSheet(BuildContext context, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ShoppingListProvider>();
    final userId = context.read<AuthProvider>().userModel?.uid;
    if (userId != null) provider.init(userId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final lists = context.read<ShoppingListProvider>().lists;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.addToShoppingList,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  title: Text(l10n.createNewList),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _createAndAddToList(context, recipe);
                  },
                ),
                if (lists.isNotEmpty) const Divider(),
                ...lists.map((list) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: const Icon(Icons.list_alt,
                            color: AppTheme.primaryColor),
                      ),
                      title: Text(list.name),
                      subtitle: Text(
                        '${list.items.length} ${l10n.ingredients.toLowerCase()}',
                      ),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await _addIngredientsToList(
                            context, list.id!, list.name, recipe);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddToCollectionSheet(BuildContext context, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final collectionProvider = context.read<CollectionProvider>();
    final userId = context.read<AuthProvider>().userModel?.uid;
    if (userId != null) collectionProvider.init(userId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final collections = context.read<CollectionProvider>().collections;
        final recipeId = recipe.id;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.addToCollection,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  title: Text(l10n.createNewCollection),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _createCollectionAndAddRecipe(context, recipe);
                  },
                ),
                if (collections.isNotEmpty) const Divider(),
                ...collections.map((collection) {
                  final contains = recipeId != null &&
                      collection.recipeIds.contains(recipeId);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        contains ? Icons.folder : Icons.folder_outlined,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(collection.name),
                    subtitle: Text(
                      l10n.recipeCountInCollection(
                          collection.recipeIds.length),
                    ),
                    trailing: contains
                        ? const Icon(Icons.check_circle,
                            color: AppTheme.primaryColor)
                        : null,
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (recipeId == null) return;
                      final messenger = ScaffoldMessenger.of(context);
                      if (contains) {
                        await collectionProvider.removeRecipe(
                            collection.id!, recipeId);
                        if (context.mounted) {
                          messenger.showSnackBar(SnackBar(
                            content: Text(
                                l10n.removedFromCollection(collection.name)),
                          ));
                        }
                      } else {
                        await collectionProvider.addRecipe(
                            collection.id!, recipeId);
                        if (context.mounted) {
                          messenger.showSnackBar(SnackBar(
                            content: Text(
                                l10n.addedToCollection(collection.name)),
                          ));
                        }
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createCollectionAndAddRecipe(
      BuildContext context, Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final collectionProvider = context.read<CollectionProvider>();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.newCollection),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.collectionName),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    if (name != null && name.isNotEmpty && mounted) {
      try {
        final collectionId = await collectionProvider.createCollection(name);
        if (recipe.id != null && collectionId.isNotEmpty) {
          await collectionProvider.addRecipe(collectionId, recipe.id!);
        }
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.addedToCollection(name))),
          );
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.error)));
        }
      }
    }
  }

  Future<void> _createAndAddToList(BuildContext context, Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = context.read<AuthProvider>().userModel?.uid;
    final messenger = ScaffoldMessenger.of(context);
    if (userId == null) return;
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.newList),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.listName),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    if (name != null && name.isNotEmpty && mounted) {
      try {
        final items = recipe.ingredients
            .map((ing) => ShoppingItem(
                  name: ing.name,
                  amount: ing.amount,
                  unit: ing.unit,
                ))
            .toList();
        final now = DateTime.now();
        final newList = ShoppingList(
          userId: userId,
          name: name,
          items: items,
          createdAt: now,
          updatedAt: now,
        );
        await ShoppingListService().createShoppingList(newList);
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.addedToList(name))),
          );
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.error)),
          );
        }
      }
    }
  }

  Future<void> _addIngredientsToList(
    BuildContext context,
    String listId,
    String listName,
    Recipe recipe,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ShoppingListProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final items = recipe.ingredients
          .map((ing) => ShoppingItem(
                name: ing.name,
                amount: ing.amount,
                unit: ing.unit,
              ))
          .toList();
      await provider.addIngredientsToList(listId, items);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.addedToList(listName))),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final liveRecipe = context
        .watch<RecipeProvider>()
        .allRecipes
        .firstWhere((r) => r.id == widget.recipe.id, orElse: () => widget.recipe);

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
                  GradientButton(
                    text: l10n.startCooking,
                    icon: Icons.restaurant,
                    onPressed: () {
                      context.push('/cooking/${liveRecipe.id}', extra: liveRecipe);
                    },
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: l10n.addToShoppingList,
                    icon: Icons.shopping_cart_outlined,
                    onPressed: () => _showAddToShoppingListSheet(context, liveRecipe),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: l10n.addToCollection,
                    icon: Icons.folder_outlined,
                    onPressed: () => _showAddToCollectionSheet(context, liveRecipe),
                  ),
                  const SizedBox(height: 32),
                  _buildRatingsSection(context, l10n, theme, liveRecipe),
                  const SizedBox(height: 24),
                  _buildCommentsSection(context, l10n, theme, liveRecipe),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCircleButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onPressed,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.glassWhite.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Recipe r) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      actions: [
        _buildGlassCircleButton(
          icon: Icons.share_outlined,
          iconColor: Colors.white,
          onPressed: () => _shareRecipe(r),
        ),
        if (_isOwner(r)) ...[
          _buildGlassCircleButton(
            icon: Icons.edit_outlined,
            iconColor: Colors.white,
            onPressed: () =>
                context.push('/edit-recipe/${r.id}', extra: r),
          ),
          _buildGlassCircleButton(
            icon: Icons.delete_outline,
            iconColor: Colors.white,
            onPressed: () => _deleteRecipe(context, r),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            r.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: r.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.neutralLight,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.neutralLight,
      child: const Center(
        child: Icon(Icons.restaurant_menu, size: 80, color: AppTheme.textTertiary),
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
            GestureDetector(
              onTap: () {
                final currentUserId =
                    context.read<AuthProvider>().userModel?.uid;
                if (r.authorId == currentUserId) {
                  context.go('/profile');
                } else {
                  context.push('/user/${r.authorId}', extra: r.authorName);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        AppTheme.primaryColor.withValues(alpha: 0.15),
                    child: Text(
                      r.authorName.isNotEmpty
                          ? r.authorName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    r.authorName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
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
                color: AppTheme.textSecondary,
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
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppTheme.textSecondary,
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

  Widget _buildRatingsSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Recipe r,
  ) {
    final ratingProvider = context.watch<RatingProvider>();
    final userId = context.read<AuthProvider>().userModel?.uid;
    final isOwner = _isOwner(r);
    final hasExistingRating = ratingProvider.userRating != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.ratingsAndComments,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (r.ratingCount > 0) ...[
              const Icon(Icons.star, size: 18, color: AppTheme.starColor),
              const SizedBox(width: 4),
              Text(
                r.averageRating.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.ratingCount(r.ratingCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
        if (userId != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.yourRating,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          _StarRatingWidget(
            currentStars: ratingProvider.displayStars,
            onRate: (stars) async {
              if (isOwner) {
                _showSnackBar('You cannot rate your own recipe.');
                return;
              }
              if (hasExistingRating) {
                _showSnackBar(
                    'Delete your review (via the comment card) to re-rate.');
                return;
              }
              context.read<RatingProvider>().selectStars(stars);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCommentsSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Recipe r,
  ) {
    final comments = context.watch<CommentProvider>().comments;
    final userId = context.read<AuthProvider>().userModel?.uid;
    final hasMyTextComment = userId != null &&
        comments.any((c) => c.userId == userId && c.text.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userId != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: hasMyTextComment
                        ? 'Delete your comment to write a new one'
                        : l10n.writeComment,
                    hintStyle: TextStyle(
                      color: hasMyTextComment
                          ? AppTheme.starColor
                          : AppTheme.textTertiary,
                      fontSize: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              _submittingComment
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton.filled(
                      onPressed: () => _onSendPressed(r),
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ],
          ),
        const SizedBox(height: 16),
        if (comments.isEmpty)
          Center(
            child: Text(
              l10n.noComments,
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 14,
              ),
            ),
          )
        else
          ...comments.map((c) {
            final isMyComment = c.userId == userId;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neutralSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.neutralLight.withValues(alpha: 0.5),
                ),
                boxShadow: [AppTheme.warmShadowLight()],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                        child: Text(
                          c.authorName.isNotEmpty
                              ? c.authorName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.authorName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (c.stars > 0)
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  i < c.stars ? Icons.star : Icons.star_border,
                                  size: 13,
                                  color: AppTheme.starColor,
                                )),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(c.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      if (isMyComment) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _deleteReview(c.id!, r.id!),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (c.text.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(c.text, style: const TextStyle(fontSize: 14)),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StarRatingWidget extends StatelessWidget {
  final int currentStars;
  final Future<void> Function(int stars) onRate;

  const _StarRatingWidget({required this.currentStars, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => onRate(star),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              star <= currentStars ? Icons.star : Icons.star_border,
              color: AppTheme.starColor,
              size: 32,
            ),
          ),
        );
      }),
    );
  }
}
