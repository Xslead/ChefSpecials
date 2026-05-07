import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/block_provider.dart';
import '../../widgets/screen_header.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  Future<List<UserModel>> _fetchBlockedUsers(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = FirebaseFirestore.instance;
    final futures = ids.map((id) => db.collection('users').doc(id).get());
    final docs = await Future.wait(futures);
    return docs
        .where((d) => d.exists)
        .map((d) => UserModel.fromMap(d.data()!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final blockedIds = context.watch<BlockProvider>().blockedUserIds;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.blockedUsers,
            icon: Icons.block_outlined,
          ),
          Expanded(
            child: blockedIds.isEmpty
                ? Center(
                    child: Text(
                      l10n.noBlockedUsers,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textTertiaryOf(context),
                      ),
                    ),
                  )
                : FutureBuilder<List<UserModel>>(
                    future: _fetchBlockedUsers(blockedIds),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryColor),
                        );
                      }
                      final users = snap.data ?? [];
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                        itemCount: users.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _BlockedUserTile(user: users[i]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BlockedUserTile extends StatelessWidget {
  final UserModel user;
  const _BlockedUserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          CircleAvatar(
            radius: 22,
            backgroundColor:
                AppTheme.primaryColor.withValues(alpha: 0.12),
            backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? CachedNetworkImageProvider(user.photoUrl!)
                : null,
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? Text(
                    user.firstName.isNotEmpty
                        ? user.firstName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (user.username != null && user.username!.isNotEmpty)
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiaryOf(context),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await context
                  .read<BlockProvider>()
                  .unblockUser(user.uid);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.userUnblocked)),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              l10n.unblockUser,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
