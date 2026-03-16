import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/shopping_list.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shopping_list_provider.dart';

class ShoppingListsScreen extends StatefulWidget {
  const ShoppingListsScreen({super.key});

  @override
  State<ShoppingListsScreen> createState() => _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends State<ShoppingListsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userModel?.uid;
      if (userId != null) {
        context.read<ShoppingListProvider>().init(userId);
      }
    });
  }

  Future<void> _createNewList() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
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
      await context.read<ShoppingListProvider>().createList(name);
    }
  }

  Future<void> _deleteList(ShoppingList list) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteList),
        content: Text(l10n.deleteListConfirm),
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
      await context.read<ShoppingListProvider>().deleteList(list.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ShoppingListProvider>();

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.lists.isEmpty
                    ? _buildEmptyState(l10n)
                    : _buildListView(provider, l10n),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shopping_list_fab',
        onPressed: _createNewList,
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
    ShoppingListProvider provider,
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
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
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
                  Icons.shopping_cart_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.shoppingLists,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (provider.lists.isNotEmpty)
                    Text(
                      l10n.itemCount(provider.lists.length),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiaryOf(context),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (provider.lists.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${provider.lists.length}',
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

  Widget _buildEmptyState(AppLocalizations l10n) {
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
              Icons.shopping_cart_outlined,
              size: 36,
              color: AppTheme.neutralLightOf(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noShoppingLists,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add ingredients from any recipe to get started',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textTertiaryOf(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(ShoppingListProvider provider, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: provider.lists.length,
      itemBuilder: (context, index) {
        final list = provider.lists[index];
        final totalCount = list.items.length;
        final checkedCount = list.items.where((i) => i.isChecked).length;
        final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: Key(list.id!),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              await _deleteList(list);
              return false;
            },
            child: GestureDetector(
              onTap: () => context.push('/shopping-list/${list.id}'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceOf(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
                  ),
                  boxShadow: [AppTheme.shadowOf(context)],
                ),
                child: Row(
                  children: [
                    // Progress circle
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                            backgroundColor: AppTheme.neutralLightOf(context),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
                          ),
                          Icon(
                            checkedCount == totalCount && totalCount > 0
                                ? Icons.check
                                : Icons.shopping_bag_outlined,
                            color: checkedCount == totalCount && totalCount > 0
                                ? AppTheme.primaryColor
                                : AppTheme.textTertiaryOf(context),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryOf(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalCount == 0
                                ? l10n.noItems
                                : '$checkedCount / $totalCount ${l10n.itemsChecked}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textTertiaryOf(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.textTertiaryOf(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
