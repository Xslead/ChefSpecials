import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/report.dart';
import '../../providers/auth_provider.dart';
import '../../services/report_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = ReportService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      body: Column(
        children: [
          ScreenHeader(title: l10n.adminReports),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.pendingReports),
              Tab(text: l10n.allReports),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ReportList(service: _service, status: 'pending'),
                _ReportList(service: _service),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  final ReportService service;
  final String? status;

  const _ReportList({required this.service, this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<Report>>(
      stream: service.getReportsStream(status: status),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        final reports = snap.data ?? [];
        if (reports.isEmpty) {
          return EmptyState(
            icon: Icons.flag_outlined,
            title: l10n.pendingReports,
            subtitle: '',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, i) =>
              _ReportCard(report: reports[i], service: service),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final ReportService service;

  const _ReportCard({required this.report, required this.service});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final reviewerId =
        context.read<AuthProvider>().userModel?.uid ?? '';

    Color statusColor;
    switch (report.status) {
      case 'reviewed':
        statusColor = Colors.green;
        break;
      case 'dismissed':
        statusColor = AppTheme.textTertiary;
        break;
      default:
        statusColor = AppTheme.errorColor;
    }

    // Determine which userId to navigate to for "View Profile"
    final profileUserId = report.targetType == 'user'
        ? report.targetId
        : report.targetAuthorId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + type + date row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.targetType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy').format(report.createdAt),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppTheme.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Reporter
            if (report.reporterName != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 13, color: AppTheme.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Reported by: ${report.reporterName}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.textTertiary),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            // Target name + ID
            if (report.targetName != null) ...[
              Text(
                report.targetName!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
            ],
            Text(
              report.targetId,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppTheme.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Reason
            Text(
              'Reason: ${report.reason}',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            // Description (reporter's extra context)
            if (report.description != null && report.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.neutralSoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.neutralLight.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  report.description!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
              ),
            ],
            // Review note
            if (report.reviewNote != null) ...[
              const SizedBox(height: 6),
              Text(
                'Admin note: ${report.reviewNote}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
            const SizedBox(height: 10),
            // View Profile button
            if (profileUserId != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/user/$profileUserId'),
                  icon: const Icon(Icons.person_outline, size: 16),
                  label: Text(l10n.viewProfile),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            if (report.status == 'pending') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(
                          context, 'dismissed', reviewerId, l10n),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary),
                      child: Text(l10n.dismiss),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          _showReviewDialog(context, reviewerId, l10n),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.errorColor),
                      child: Text(l10n.approve),
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

  Future<void> _updateStatus(BuildContext context, String status,
      String reviewerId, AppLocalizations l10n,
      {String? note}) async {
    await service.updateReportStatus(
      reportId: report.id!,
      status: status,
      reviewedBy: reviewerId,
      reviewNote: note,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.reportReviewed)));
    }
  }

  Future<void> _showReviewDialog(BuildContext context, String reviewerId,
      AppLocalizations l10n) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.approve),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: 'Review note (optional)'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.approve),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _updateStatus(context, 'reviewed', reviewerId, l10n,
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim());
    }
  }
}
