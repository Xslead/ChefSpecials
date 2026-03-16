import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/shopping_list.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shopping_list_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/styled_dialog.dart';

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
    final name = await StyledDialog.showInput(
      context: context,
      title: l10n.newList,
      hintText: l10n.listName,
      cancelText: l10n.cancel,
      confirmText: l10n.save,
    );
    if (name != null && name.isNotEmpty && mounted) {
      await context.read<ShoppingListProvider>().createList(name);
    }
  }

  Future<void> _deleteList(ShoppingList list) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await StyledDialog.show<bool>(
      context: context,
      title: l10n.deleteList,
      content: Text(l10n.deleteListConfirm),
      cancelText: l10n.cancel,
      confirmText: l10n.delete,
      isDestructive: true,
      onCancel: () => Navigator.pop(context, false),
      onConfirm: () => Navigator.pop(context, true),
    );
    if (confirmed == true && mounted) {
      await context.read<ShoppingListProvider>().deleteList(list.id!);
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
    final provider = context.watch<ShoppingListProvider>();

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.shoppingLists,
            icon: Icons.shopping_cart_outlined,
            subtitle: provider.lists.isNotEmpty
                ? l10n.itemCount(provider.lists.length)
                : null,
            trailing: [
              if (provider.lists.isNotEmpty)
                _buildCountBadge(provider.lists.length),
            ],
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.lists.isEmpty
                    ? EmptyState(
                        icon: Icons.shopping_cart_outlined,
                        title: l10n.noShoppingLists,
                        subtitle: l10n.shoppingListEmptySubtitle,
                      )
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
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
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
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
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
