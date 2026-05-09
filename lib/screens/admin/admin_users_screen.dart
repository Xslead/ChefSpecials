import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: const _UsersBody(),
    );
  }
}

class _UsersBody extends StatefulWidget {
  const _UsersBody();

  @override
  State<_UsersBody> createState() => _UsersBodyState();
}

class _UsersBodyState extends State<_UsersBody> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<AdminProvider>().loadUsers(searchQuery: query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.userManagement,
            icon: Icons.people,
            iconColor: AppTheme.secondaryColor,
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.users.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline,
                        title: l10n.noUsers,
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 40),
                        itemCount: provider.users.length,
                        itemBuilder: (context, index) =>
                            _buildUserCard(context, provider.users[index], l10n),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
      BuildContext context, UserModel user, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _showUserActions(context, user, l10n),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
            ),
            boxShadow: [AppTheme.shadowOf(context)],
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: user.photoUrl != null &&
                        user.photoUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryOf(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Role badge
                        if (user.isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.admin,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        // Ban badge
                        if (user.isBanned) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.banned,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiaryOf(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppTheme.textTertiaryOf(context)
                    .withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserActions(
      BuildContext context, UserModel user, AppLocalizations l10n) {
    final adminProvider = context.read<AdminProvider>();
    final authUser = context.read<AuthProvider>().userModel;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.neutralLightOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // User info header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Ban / Unban
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (user.isBanned
                            ? AppTheme.dinnerColor
                            : AppTheme.errorColor)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    user.isBanned ? Icons.check_circle : Icons.block,
                    color: user.isBanned
                        ? AppTheme.dinnerColor
                        : AppTheme.errorColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  user.isBanned ? l10n.unbanUser : l10n.banUser,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  if (user.isBanned) {
                    _confirmUnban(context, user, l10n, adminProvider,
                        authUser);
                  } else {
                    _showBanDialog(context, user, l10n, adminProvider,
                        authUser);
                  }
                },
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              // Promote / Demote
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    user.isAdmin
                        ? Icons.person_remove
                        : Icons.admin_panel_settings,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  user.isAdmin
                      ? l10n.demoteToUser
                      : l10n.promoteToAdmin,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmRoleChange(context, user, l10n, adminProvider,
                      authUser);
                },
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              // View recipes
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.starColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: AppTheme.starColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  l10n.recipes,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/my-recipes', extra: user.uid);
                },
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showBanDialog(
    BuildContext context,
    UserModel user,
    AppLocalizations l10n,
    AdminProvider provider,
    UserModel? authUser,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.banUser),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.confirmBan,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.enterBanReason,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(ctx);
              await provider.banUser(
                userId: user.uid,
                userName: user.fullName,
                reason: reason,
                adminId: authUser?.uid ?? '',
                adminName: authUser?.fullName ?? '',
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: Text(l10n.banUser),
          ),
        ],
      ),
    );
  }

  void _confirmUnban(
    BuildContext context,
    UserModel user,
    AppLocalizations l10n,
    AdminProvider provider,
    UserModel? authUser,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.unbanUser),
        content: Text(l10n.confirmUnban),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.unbanUser(
                userId: user.uid,
                userName: user.fullName,
                adminId: authUser?.uid ?? '',
                adminName: authUser?.fullName ?? '',
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.dinnerColor,
            ),
            child: Text(l10n.unbanUser),
          ),
        ],
      ),
    );
  }

  void _confirmRoleChange(
    BuildContext context,
    UserModel user,
    AppLocalizations l10n,
    AdminProvider provider,
    UserModel? authUser,
  ) {
    final isPromoting = !user.isAdmin;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isPromoting ? l10n.promoteToAdmin : l10n.demoteToUser,
        ),
        content: Text(
          isPromoting ? l10n.confirmPromote : l10n.confirmDemote,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.setUserRole(
                userId: user.uid,
                userName: user.fullName,
                role: isPromoting ? 'admin' : 'user',
                adminId: authUser?.uid ?? '',
                adminName: authUser?.fullName ?? '',
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
            child: Text(
              isPromoting ? l10n.promoteToAdmin : l10n.demoteToUser,
            ),
          ),
        ],
      ),
    );
  }
}
