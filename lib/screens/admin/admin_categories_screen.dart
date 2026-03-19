import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: const _CategoriesBody(),
    );
  }
}

class _CategoriesBody extends StatefulWidget {
  const _CategoriesBody();

  @override
  State<_CategoriesBody> createState() => _CategoriesBodyState();
}

class _CategoriesBodyState extends State<_CategoriesBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCategories(type: 'recipe');
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final type = _tabController.index == 0 ? 'recipe' : 'food_item';
    context.read<AdminProvider>().loadCategories(type: type);
  }

  String get _currentType =>
      _tabController.index == 0 ? 'recipe' : 'food_item';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.categoryManagement,
            icon: Icons.category,
            iconColor: AppTheme.starColor,
          ),
          // Tabs
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.neutralLightOf(context)
                      .withValues(alpha: 0.5),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textTertiaryOf(context),
              indicatorColor: AppTheme.primaryColor,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: l10n.recipeCategories),
                Tab(text: l10n.foodItemCategories),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(context, provider, l10n),
                _buildCategoryList(context, provider, l10n),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    AdminProvider provider,
    AppLocalizations l10n,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.categories.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        title: l10n.noResults,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: provider.categories.length,
      itemBuilder: (context, index) {
        final cat = provider.categories[index];
        final id = cat['id'] as String? ?? '';
        final name = cat['name'] as String? ?? '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.neutralLightOf(context)
                    .withValues(alpha: 0.5),
              ),
              boxShadow: [AppTheme.shadowOf(context)],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.starColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.category,
                    color: AppTheme.starColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                  onPressed: () =>
                      _showEditDialog(context, l10n, id, name),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppTheme.errorColor,
                  ),
                  onPressed: () =>
                      _confirmDelete(context, l10n, id, name),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, AppLocalizations l10n) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.addCategory),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.enterCategoryName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final authUser =
                  context.read<AuthProvider>().userModel;
              await context.read<AdminProvider>().addCategory(
                    name: name,
                    type: _currentType,
                    adminId: authUser?.uid ?? '',
                    adminName: authUser?.fullName ?? '',
                  );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppLocalizations l10n,
      String id, String currentName) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.editCategory),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.enterCategoryName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty || name == currentName) return;
              Navigator.pop(ctx);
              final authUser =
                  context.read<AuthProvider>().userModel;
              await context.read<AdminProvider>().updateCategory(
                    id: id,
                    name: name,
                    adminId: authUser?.uid ?? '',
                    adminName: authUser?.fullName ?? '',
                  );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n,
      String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.deleteCategory),
        content: Text(l10n.confirmDeleteCategory),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authUser =
                  context.read<AuthProvider>().userModel;
              await context.read<AdminProvider>().deleteCategory(
                    id: id,
                    name: name,
                    adminId: authUser?.uid ?? '',
                    adminName: authUser?.fullName ?? '',
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
