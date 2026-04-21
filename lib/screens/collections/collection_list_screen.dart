import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../models/recipe_collection.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/styled_dialog.dart';

class CollectionListScreen extends StatefulWidget {
  const CollectionListScreen({super.key});

  @override
  State<CollectionListScreen> createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userModel?.uid;
      if (userId != null) {
        context.read<CollectionProvider>().init(userId);
      }
    });
  }

  Future<void> _createNewCollection() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        final nameController = TextEditingController();
        final descController = TextEditingController();
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.newCollection),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.collectionName,
                  prefixIcon: const Icon(Icons.folder_outlined, size: 20),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: l10n.collectionDescription,
                  prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, {
                'name': nameController.text.trim(),
                'description': descController.text.trim(),
              }),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    if (result != null && result['name']!.isNotEmpty && mounted) {
      final desc =
          result['description']!.isEmpty ? null : result['description'];
      try {
        await context.read<CollectionProvider>().createCollection(
              result['name']!,
              description: desc,
            );
        if (mounted) {
          await context.read<AchievementProvider>().triggerCheck(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.error)),
          );
        }
      }
    }
  }

  Future<void> _deleteCollection(RecipeCollection collection) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await StyledDialog.show<bool>(
      context: context,
      title: l10n.deleteCollection,
      content: Text(l10n.deleteCollectionConfirm),
      cancelText: l10n.cancel,
      confirmText: l10n.delete,
      isDestructive: true,
      onCancel: () => Navigator.pop(context, false),
      onConfirm: () => Navigator.pop(context, true),
    );
    if (confirmed == true && mounted) {
      await context
          .read<CollectionProvider>()
          .deleteCollection(collection.id!);
    }
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CollectionProvider>();

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.collections,
            icon: Icons.folder_outlined,
            subtitle: provider.collections.isNotEmpty
                ? l10n.itemCount(provider.collections.length)
                : null,
            trailing: [
              if (provider.collections.isNotEmpty)
                _buildCountBadge(provider.collections.length),
            ],
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.collections.isEmpty
                    ? EmptyState(
                        icon: Icons.folder_outlined,
                        title: l10n.noCollections,
                        subtitle: l10n.emptyCollectionSubtitle,
                      )
                    : _buildListView(provider, l10n),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'collection_fab',
        onPressed: _createNewCollection,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  Widget _buildListView(CollectionProvider provider, AppLocalizations l10n) {
    final allRecipes = context.watch<RecipeProvider>().allRecipes;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: provider.collections.length,
      itemBuilder: (context, index) {
        final collection = provider.collections[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildCollectionCard(
              context, collection, l10n, allRecipes, provider),
        );
      },
    );
  }

  Widget _buildCollectionCard(
    BuildContext context,
    RecipeCollection collection,
    AppLocalizations l10n,
    List<Recipe> allRecipes,
    CollectionProvider provider,
  ) {
    final recipeCount = collection.recipeIds.length;
    final coverRecipes = collection.recipeIds
        .take(3)
        .map((id) => allRecipes.where((r) => r.id == id).firstOrNull)
        .whereType<Recipe>()
        .toList();
    final updatedDate = DateFormat('MMM d').format(collection.updatedAt);

    return Dismissible(
      key: Key(collection.id!),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(l10n.delete,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        await _deleteCollection(collection);
        return false;
      },
      child: GestureDetector(
        onTap: () => context.push('/collection/${collection.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color:
                  AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
            ),
            boxShadow: [AppTheme.shadowOf(context)],
          ),
          child: Row(
            children: [
              // Cover image stack or folder icon
              _buildCoverThumbnail(context, coverRecipes),
              const SizedBox(width: 14),
              // Title + description + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (collection.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 3),
                      Text(
                        collection.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryOf(context),
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.menu_book,
                            size: 13,
                            color: AppTheme.textTertiaryOf(context)),
                        const SizedBox(width: 4),
                        Text(
                          l10n.recipeCountInCollection(recipeCount),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time,
                            size: 13,
                            color: AppTheme.textTertiaryOf(context)),
                        const SizedBox(width: 4),
                        Text(
                          updatedDate,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textTertiaryOf(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverThumbnail(
      BuildContext context, List<Recipe> coverRecipes) {
    if (coverRecipes.isNotEmpty && coverRecipes.first.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  coverRecipes.first.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      _buildFolderIcon(context),
                ),
              ),
              if (coverRecipes.length > 1)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      '+${coverRecipes.length - 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return _buildFolderIcon(context);
  }

  Widget _buildFolderIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.folder,
        color: AppTheme.primaryColor,
        size: 22,
      ),
    );
  }
}
