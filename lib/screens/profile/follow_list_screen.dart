import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/follow_provider.dart';
import '../../services/follow_service.dart';
import '../../services/user_service.dart';

class FollowListScreen extends StatefulWidget {
  final String userId;
  final int initialTab; // 0 = followers, 1 = following

  const FollowListScreen({
    super.key,
    required this.userId,
    this.initialTab = 0,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FollowService _followService = FollowService();
  final UserService _userService = UserService();

  List<UserModel> _followers = [];
  List<UserModel> _following = [];
  bool _loadingFollowers = true;
  bool _loadingFollowing = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadFollowers();
    _loadFollowing();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowers() async {
    final ids = await _followService.getFollowerIds(widget.userId);
    final users = <UserModel>[];
    for (final id in ids) {
      final user = await _userService.getUser(id);
      if (user != null) users.add(user);
    }
    if (mounted) {
      setState(() {
        _followers = users;
        _loadingFollowers = false;
      });
    }
  }

  Future<void> _loadFollowing() async {
    final ids = await _followService.getFollowingIds(widget.userId);
    final users = <UserModel>[];
    for (final id in ids) {
      final user = await _userService.getUser(id);
      if (user != null) users.add(user);
    }
    if (mounted) {
      setState(() {
        _following = users;
        _loadingFollowing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(_followers, _loadingFollowers, l10n),
                _buildUserList(_following, _loadingFollowing, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                    color: AppTheme.textPrimaryOf(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.profile,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textTertiaryOf(context),
              indicatorColor: AppTheme.primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: l10n.followers),
                Tab(text: l10n.following),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(
    List<UserModel> users,
    bool loading,
    AppLocalizations l10n,
  ) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: 2,
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 56,
              color: AppTheme.neutralLightOf(context),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noFollowing,
              style: TextStyle(
                color: AppTheme.textTertiaryOf(context),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 72,
        color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
      ),
      itemBuilder: (context, index) => _buildUserTile(users[index]),
    );
  }

  Widget _buildUserTile(UserModel user) {
    final followProvider = context.watch<FollowProvider>();
    final isFollowing = followProvider.isFollowing(user.uid);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: user.photoUrl != null && user.photoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: user.photoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: AppTheme.neutralSoft,
                    child: const Icon(Icons.person,
                        size: 24, color: AppTheme.textTertiary),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppTheme.neutralSoft,
                    child: const Icon(Icons.person,
                        size: 24, color: AppTheme.textTertiary),
                  ),
                )
              : Container(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: const Icon(Icons.person,
                      size: 24, color: AppTheme.primaryColor),
                ),
        ),
      ),
      title: Text(
        user.fullName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        user.username != null
            ? '@${user.username}'
            : (user.bio ?? ''),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: user.username != null
              ? AppTheme.primaryColor
              : AppTheme.textTertiaryOf(context),
        ),
      ),
      trailing: _buildFollowButton(user.uid, isFollowing, followProvider),
      onTap: () => context.push('/user/${user.uid}', extra: user.fullName),
    );
  }

  Widget? _buildFollowButton(
    String uid,
    bool isFollowing,
    FollowProvider provider,
  ) {
    return SizedBox(
      height: 32,
      child: isFollowing
          ? OutlinedButton(
              onPressed: () => provider.unfollow(uid),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondaryOf(context),
                side: BorderSide(color: AppTheme.neutralLightOf(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              ),
              child: Text(
                AppLocalizations.of(context)!.unfollow,
                style: const TextStyle(fontSize: 12),
              ),
            )
          : FilledButton(
              onPressed: () => provider.follow(uid),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              ),
              child: Text(
                AppLocalizations.of(context)!.follow,
                style: const TextStyle(fontSize: 12),
              ),
            ),
    );
  }
}
