import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/announcement.dart';
import '../../models/user_model.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CreateAnnouncementSheet(
        parentContext: context,
        l10n: l10n,
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

class _CreateAnnouncementSheet extends StatefulWidget {
  final BuildContext parentContext;
  final AppLocalizations l10n;

  const _CreateAnnouncementSheet({
    required this.parentContext,
    required this.l10n,
  });

  @override
  State<_CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState
    extends State<_CreateAnnouncementSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _searchController = TextEditingController();
  bool _sendToAll = true;
  final List<UserModel> _selectedUsers = [];
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await widget.parentContext
        .read<AdminProvider>()
        .searchUsers(query);
    if (mounted) {
      setState(() {
        _searchResults = results
            .where((u) => !_selectedUsers.any((s) => s.uid == u.uid))
            .toList();
        _isSearching = false;
      });
    }
  }

  void _addUser(UserModel user) {
    setState(() {
      _selectedUsers.add(user);
      _searchResults.removeWhere((u) => u.uid == user.uid);
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _removeUser(String uid) {
    setState(() {
      _selectedUsers.removeWhere((u) => u.uid == uid);
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;
    if (!_sendToAll && _selectedUsers.isEmpty) return;

    Navigator.pop(context);
    final authUser =
        widget.parentContext.read<AuthProvider>().userModel;
    final provider =
        widget.parentContext.read<AdminProvider>();

    if (_sendToAll) {
      await provider.createAnnouncement(
        title: title,
        body: body,
        adminId: authUser?.uid ?? '',
        adminName: authUser?.fullName ?? '',
      );
    } else {
      await provider.createTargetedAnnouncement(
        title: title,
        body: body,
        adminId: authUser?.uid ?? '',
        adminName: authUser?.fullName ?? '',
        targetUserIds: _selectedUsers.map((u) => u.uid).toList(),
        targetUserNames:
            _selectedUsers.map((u) => u.fullName).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
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
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: l10n.announcementTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Body
            TextField(
              controller: _bodyController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.announcementBody,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Target toggle
            Container(
              decoration: BoxDecoration(
                color: AppTheme.neutralSoftOf(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _sendToAll = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _sendToAll
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            l10n.all,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _sendToAll
                                  ? Colors.white
                                  : AppTheme.textSecondaryOf(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _sendToAll = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_sendToAll
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_search,
                                size: 16,
                                color: !_sendToAll
                                    ? Colors.white
                                    : AppTheme.textSecondaryOf(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.searchUsers,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: !_sendToAll
                                      ? Colors.white
                                      : AppTheme.textSecondaryOf(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // User picker (only when specific users selected)
            if (!_sendToAll) ...[
              const SizedBox(height: 12),
              // Selected users chips
              if (_selectedUsers.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedUsers.map((user) {
                    return Chip(
                      avatar: CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      label: Text(
                        user.username != null
                            ? '${user.fullName} (@${user.username})'
                            : user.fullName,
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeUser(user.uid),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),
              // Search field
              TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: l10n.searchUsers,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
              // Search results
              if (_searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOf(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.neutralLightOf(context)
                          .withValues(alpha: 0.5),
                    ),
                    boxShadow: [AppTheme.shadowOf(context)],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 52,
                      color: AppTheme.neutralLightOf(context)
                          .withValues(alpha: 0.5),
                    ),
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryColor
                              .withValues(alpha: 0.1),
                          child: Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryOf(context),
                          ),
                        ),
                        subtitle: Text(
                          user.username != null
                              ? '@${user.username}'
                              : user.email,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                        trailing: Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                        onTap: () => _addUser(user),
                      );
                    },
                  ),
                ),
            ],
            const SizedBox(height: 16),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(
                  _sendToAll
                      ? l10n.createAnnouncement
                      : '${l10n.send} (${_selectedUsers.length})',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
