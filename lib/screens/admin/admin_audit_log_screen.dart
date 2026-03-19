import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/admin_log.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';

class AdminAuditLogScreen extends StatelessWidget {
  const AdminAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: const _AuditLogBody(),
    );
  }
}

class _AuditLogBody extends StatefulWidget {
  const _AuditLogBody();

  @override
  State<_AuditLogBody> createState() => _AuditLogBodyState();
}

class _AuditLogBodyState extends State<_AuditLogBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAuditLogs();
    });
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
            title: l10n.auditLog,
            icon: Icons.history,
            iconColor: AppTheme.textSecondaryOf(context),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.auditLogs.isEmpty
                    ? EmptyState(
                        icon: Icons.history,
                        title: l10n.noAuditLogs,
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 40),
                        itemCount: provider.auditLogs.length,
                        itemBuilder: (context, index) =>
                            _buildLogEntry(
                          context,
                          provider.auditLogs[index],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(BuildContext context, AdminLog log) {
    final color = _colorForAction(log.action);
    final icon = _iconForAction(log.action);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action description
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryOf(context),
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: log.adminName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryOf(context),
                          ),
                        ),
                        TextSpan(text: ' ${_actionLabel(log.action)} '),
                        if (log.targetName != null)
                          TextSpan(
                            text: log.targetName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryOf(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Details
                  if (log.details != null &&
                      log.details!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neutralSoftOf(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        log.details!,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondaryOf(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Timestamp
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppTheme.textTertiaryOf(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy HH:mm')
                            .format(log.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForAction(String action) {
    final lower = action.toLowerCase();
    if (lower.contains('ban') && !lower.contains('unban')) {
      return Icons.block;
    }
    if (lower.contains('unban')) return Icons.check_circle;
    if (lower.contains('delete')) return Icons.delete_outline;
    if (lower.contains('promote')) return Icons.arrow_upward;
    if (lower.contains('demote')) return Icons.arrow_downward;
    if (lower.contains('category')) return Icons.category;
    if (lower.contains('announcement')) return Icons.campaign;
    if (lower.contains('appeal')) return Icons.gavel;
    return Icons.info_outline;
  }

  Color _colorForAction(String action) {
    final lower = action.toLowerCase();
    if (lower.contains('ban') && !lower.contains('unban')) {
      return AppTheme.errorColor;
    }
    if (lower.contains('unban')) return AppTheme.dinnerColor;
    if (lower.contains('delete')) return AppTheme.errorColor;
    if (lower.contains('promote') || lower.contains('demote')) {
      return AppTheme.primaryColor;
    }
    if (lower.contains('category')) return AppTheme.starColor;
    if (lower.contains('announcement')) return AppTheme.snackColor;
    if (lower.contains('appeal')) return AppTheme.secondaryColor;
    return AppTheme.textSecondary;
  }

  String _actionLabel(String action) {
    final lower = action.toLowerCase();
    if (lower.contains('ban') && !lower.contains('unban')) {
      return 'banned';
    }
    if (lower.contains('unban')) return 'unbanned';
    if (lower.contains('delete_recipe')) return 'deleted recipe';
    if (lower.contains('promote')) return 'promoted';
    if (lower.contains('demote')) return 'demoted';
    if (lower.contains('add_category')) return 'added category';
    if (lower.contains('update_category')) return 'updated category';
    if (lower.contains('delete_category')) return 'deleted category';
    if (lower.contains('create_announcement')) {
      return 'created announcement';
    }
    if (lower.contains('delete_announcement')) {
      return 'deleted announcement';
    }
    if (lower.contains('approve_appeal')) return 'approved appeal for';
    if (lower.contains('reject_appeal')) return 'rejected appeal for';
    return action;
  }
}
