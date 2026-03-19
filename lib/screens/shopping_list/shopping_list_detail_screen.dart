import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/shopping_list.dart';
import '../../providers/shopping_list_provider.dart';

class ShoppingListDetailScreen extends StatelessWidget {
  final String listId;
  const ShoppingListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ShoppingListProvider>();
    final list = provider.lists.where((l) => l.id == listId).firstOrNull;

    if (list == null) {
      return Scaffold(
        body: Column(
          children: [
            _buildHeader(context, l10n, null, provider),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    final unchecked = <_IndexedItem>[];
    final checked = <_IndexedItem>[];
    for (var i = 0; i < list.items.length; i++) {
      if (list.items[i].isChecked) {
        checked.add(_IndexedItem(i, list.items[i]));
      } else {
        unchecked.add(_IndexedItem(i, list.items[i]));
      }
    }

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, list, provider),
          Expanded(
            child: list.items.isEmpty
                ? _buildEmptyState(context, l10n)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      if (unchecked.isNotEmpty) ...[
                        _buildSectionLabel(
                          context,
                          '${l10n.ingredients.toUpperCase()} (${unchecked.length})',
                        ),
                        const SizedBox(height: 8),
                        ...unchecked.map((indexed) => _buildItemTile(
                            context, provider, list, indexed, false)),
                      ],
                      if (checked.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSectionLabel(
                          context,
                          '${l10n.done.toUpperCase()} (${checked.length})',
                        ),
                        const SizedBox(height: 8),
                        ...checked.map((indexed) => _buildItemTile(
                            context, provider, list, indexed, true)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ShoppingList? list,
    ShoppingListProvider provider,
  ) {
    final checkedCount = list?.items.where((i) => i.isChecked).length ?? 0;

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
                  Icons.checklist_rounded,
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
                      list?.name ?? l10n.shoppingList,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (list != null && list.items.isNotEmpty)
                      Text(
                        '$checkedCount / ${list.items.length} ${l10n.itemsChecked}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                      ),
                  ],
                ),
              ),
              if (checkedCount > 0)
                TextButton.icon(
                  onPressed: () => provider.clearChecked(listId),
                  icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                  label: Text(
                    l10n.clearChecked,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    visualDensity: VisualDensity.compact,
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.neutralSoftOf(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.shopping_basket_outlined,
              size: 30,
              color: AppTheme.neutralLightOf(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noItems,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add ingredients from a recipe',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiaryOf(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textTertiaryOf(context),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    ShoppingListProvider provider,
    ShoppingList list,
    _IndexedItem indexed,
    bool isChecked,
  ) {
    final item = indexed.item;
    final subtitle =
        [item.amount, if (item.unit != null) item.unit].join(' ').trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Dismissible(
        key: Key('${list.id}_${indexed.index}_${item.name}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        onDismissed: (_) => provider.removeItem(list.id!, indexed.index),
        child: GestureDetector(
          onTap: () =>
              provider.toggleItem(list.id!, indexed.index, !isChecked),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isChecked
                  ? AppTheme.neutralSoftOf(context)
                  : AppTheme.surfaceOf(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isChecked
                    ? Colors.transparent
                    : AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
              ),
              boxShadow: isChecked ? null : [AppTheme.shadowOf(context)],
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isChecked
                          ? AppTheme.primaryColor
                          : AppTheme.neutralLightOf(context),
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isChecked
                              ? AppTheme.textTertiaryOf(context)
                              : AppTheme.textSecondaryOf(context),
                          decoration: isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiaryOf(context),
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndexedItem {
  final int index;
  final ShoppingItem item;
  const _IndexedItem(this.index, this.item);
}
