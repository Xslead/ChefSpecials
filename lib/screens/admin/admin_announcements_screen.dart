import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/announcement.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';

class AdminAnnouncementsScreen extends StatelessWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: const _AnnouncementsBody(),
    );
  }
}

class _AnnouncementsBody extends StatefulWidget {
  const _AnnouncementsBody();

  @override
  State<_AnnouncementsBody> createState() => _AnnouncementsBodyState();
}

class _AnnouncementsBodyState extends State<_AnnouncementsBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAnnouncements();
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
            title: l10n.adminAnnouncements,
            icon: Icons.campaign,
            iconColor: AppTheme.snackColor,
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.announcements.isEmpty
                    ? EmptyState(
                        icon: Icons.campaign_outlined,
                        title: l10n.noAnnouncements,
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 80),
                        itemCount: provider.announcements.length,
                        itemBuilder: (context, index) =>
                            _buildAnnouncementCard(
                          context,
                          provider.announcements[index],
                          l10n,
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    Announcement announcement,
    AppLocalizations l10n,
  ) {
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    announcement.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppTheme.errorColor,
                  ),
                  onPressed: () => _confirmDelete(
                      context, announcement, l10n),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              announcement.body,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryOf(context),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 13,
                  color: AppTheme.textTertiaryOf(context),
                ),
                const SizedBox(width: 4),
                Text(
                  announcement.authorName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textTertiaryOf(context),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.schedule,
                  size: 13,
                  color: AppTheme.textTertiaryOf(context),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy HH:mm')
                      .format(announcement.createdAt),
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
    );
  }

  void _showCreateSheet(BuildContext context, AppLocalizations l10n) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.neutralLightOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.createAnnouncement,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryOf(context),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: l10n.announcementTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.announcementBody,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final body = bodyController.text.trim();
                  if (title.isEmpty || body.isEmpty) return;
                  Navigator.pop(ctx);
                  final authUser =
                      context.read<AuthProvider>().userModel;
                  await context
                      .read<AdminProvider>()
                      .createAnnouncement(
                        title: title,
                        body: body,
                        adminId: authUser?.uid ?? '',
                        adminName: authUser?.fullName ?? '',
                      );
                },
                child: Text(l10n.createAnnouncement),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Announcement announcement,
      AppLocalizations l10n) {
    final authUser = context.read<AuthProvider>().userModel;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.delete),
        content: Text(l10n.confirmDeleteAnnouncement),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminProvider>().deleteAnnouncement(
                    id: announcement.id ?? '',
                    title: announcement.title,
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
