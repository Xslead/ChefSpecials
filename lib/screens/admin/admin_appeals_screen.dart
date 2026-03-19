import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/ban_appeal.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';

class AdminAppealsScreen extends StatelessWidget {
  const AdminAppealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: const _AppealsBody(),
    );
  }
}

class _AppealsBody extends StatefulWidget {
  const _AppealsBody();

  @override
  State<_AppealsBody> createState() => _AppealsBodyState();
}

class _AppealsBodyState extends State<_AppealsBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAppeals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            title: l10n.banAppeals,
            icon: Icons.gavel,
            iconColor: AppTheme.errorColor,
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
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.pendingAppeals),
                      if (provider.pendingAppeals.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${provider.pendingAppeals.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(text: l10n.allAppeals),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending tab
                _buildAppealsList(
                  context,
                  provider,
                  provider.pendingAppeals,
                  l10n,
                  showActions: true,
                ),
                // All tab
                _buildAppealsList(
                  context,
                  provider,
                  provider.appeals,
                  l10n,
                  showActions: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppealsList(
    BuildContext context,
    AdminProvider provider,
    List<BanAppeal> appeals,
    AppLocalizations l10n, {
    required bool showActions,
  }) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appeals.isEmpty) {
      return EmptyState(
        icon: Icons.gavel_outlined,
        title: l10n.noAppeals,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: appeals.length,
      itemBuilder: (context, index) =>
          _buildAppealCard(context, appeals[index], l10n, showActions),
    );
  }

  Widget _buildAppealCard(BuildContext context, BanAppeal appeal,
      AppLocalizations l10n, bool showActions) {
    final statusColor = _statusColor(appeal.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.neutralLightOf(context)
                .withValues(alpha: 0.5),
          ),
          boxShadow: [AppTheme.shadowOf(context)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: user name + status badge
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      AppTheme.errorColor.withValues(alpha: 0.1),
                  child: Text(
                    appeal.userName.isNotEmpty
                        ? appeal.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.errorColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appeal.userName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                      Text(
                        appeal.userEmail,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appeal.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Appeal text
            Text(
              appeal.appealText,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryOf(context),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Date
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 13,
                  color: AppTheme.textTertiaryOf(context),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy HH:mm')
                      .format(appeal.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textTertiaryOf(context),
                  ),
                ),
              ],
            ),
            // Review note
            if (appeal.reviewNote != null &&
                appeal.reviewNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.neutralSoftOf(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  appeal.reviewNote!,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ),
            ],
            // Action buttons for pending
            if (showActions && appeal.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _confirmApprove(context, appeal, l10n),
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(l10n.approveAppeal),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.dinnerColor,
                        side: const BorderSide(
                          color: AppTheme.dinnerColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showRejectDialog(context, appeal, l10n),
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(l10n.rejectAppeal),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(
                          color: AppTheme.errorColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'pending' => AppTheme.starColor,
      'approved' => AppTheme.dinnerColor,
      'rejected' => AppTheme.errorColor,
      _ => AppTheme.textSecondary,
    };
  }

  void _confirmApprove(
      BuildContext context, BanAppeal appeal, AppLocalizations l10n) {
    final authUser = context.read<AuthProvider>().userModel;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.approveAppeal),
        content: Text(l10n.confirmApproveAppeal),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminProvider>().reviewAppeal(
                    appealId: appeal.id ?? '',
                    userName: appeal.userName,
                    status: 'approved',
                    adminId: authUser?.uid ?? '',
                    adminName: authUser?.fullName ?? '',
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.dinnerColor,
            ),
            child: Text(l10n.approveAppeal),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
      BuildContext context, BanAppeal appeal, AppLocalizations l10n) {
    final noteController = TextEditingController();
    final authUser = context.read<AuthProvider>().userModel;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.rejectAppeal),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.confirmRejectAppeal,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.reviewNote,
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
              Navigator.pop(ctx);
              await context.read<AdminProvider>().reviewAppeal(
                    appealId: appeal.id ?? '',
                    userName: appeal.userName,
                    status: 'rejected',
                    adminId: authUser?.uid ?? '',
                    adminName: authUser?.fullName ?? '',
                    note: noteController.text.trim().isNotEmpty
                        ? noteController.text.trim()
                        : null,
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: Text(l10n.rejectAppeal),
          ),
        ],
      ),
    );
  }
}
