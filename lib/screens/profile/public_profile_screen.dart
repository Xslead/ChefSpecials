import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/follow_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../services/user_service.dart';
import '../home/widgets/recipe_card.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  final String initialName;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    required this.initialName,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final UserService _userService = UserService();
  UserModel? _user;
  bool _loadingUser = true;
  StreamSubscription<UserModel?>? _userSub;

  @override
  void initState() {
    super.initState();
    _userSub = _userService.watchUser(widget.userId).listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
          _loadingUser = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = context.read<AuthProvider>().userModel;
    final followProvider = context.watch<FollowProvider>();
    final recipeProvider = context.watch<RecipeProvider>();

    if (currentUser != null) {
      context.read<FollowProvider>().initialize(currentUser.uid);
    }

    final isOwnProfile = currentUser?.uid == widget.userId;
    final isFollowing = followProvider.isFollowing(widget.userId);

    final userRecipes = recipeProvider.allRecipes
        .where((r) => r.authorId == widget.userId && !r.isPrivate)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, isOwnProfile, isFollowing, followProvider),
          Expanded(
            child: _loadingUser
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: 2,
                    ),
                  )
                : _buildBody(context, l10n, userRecipes),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isOwnProfile,
    bool isFollowing,
    FollowProvider followProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        border: Border(
          bottom: BorderSide(
              color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
                color: AppTheme.textPrimaryOf(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _user?.fullName ?? widget.initialName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isOwnProfile && !_loadingUser)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isFollowing
                      ? OutlinedButton(
                          key: const ValueKey('unfollow'),
                          onPressed: () =>
                              followProvider.unfollow(widget.userId),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textSecondaryOf(context),
                            side: BorderSide(
                                color: AppTheme.neutralLightOf(context)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: Text(l10n.unfollow,
                              style: const TextStyle(fontSize: 13)),
                        )
                      : FilledButton(
                          key: const ValueKey('follow'),
                          onPressed: () =>
                              followProvider.follow(widget.userId),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: Text(l10n.follow,
                              style: const TextStyle(fontSize: 13)),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AppLocalizations l10n, List<Recipe> recipes) {
    final user = _user;
    if (user == null) {
      return Center(
        child: Text(l10n.error,
            style: TextStyle(color: AppTheme.textTertiaryOf(context))),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        // Profile card
        _buildProfileCard(context, l10n, user),
        const SizedBox(height: 16),
        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(
                    '/my-recipes',
                    extra: widget.userId,
                  ),
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.menu_book,
                    color: AppTheme.primaryColor,
                    count: recipes.length,
                    label: l10n.recipes,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(
                    '/follow-list/${widget.userId}',
                    extra: 0,
                  ),
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.people_outline,
                    color: AppTheme.secondaryColor,
                    count: user.followersCount,
                    label: l10n.followers,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(
                    '/follow-list/${widget.userId}',
                    extra: 1,
                  ),
                  child: _buildStatCard(
                    context: context,
                    icon: Icons.person_add_outlined,
                    color: const Color(0xFFF59E0B),
                    count: user.followingCount,
                    label: l10n.following,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Recipes header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Text(
                l10n.recipes,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${recipes.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              if (recipes.length > 3)
                GestureDetector(
                  onTap: () => context.push(
                    '/my-recipes',
                    extra: widget.userId,
                  ),
                  child: Row(
                    children: [
                      Text(
                        l10n.viewAll,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (recipes.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Column(
                children: [
                  Icon(Icons.menu_book,
                      size: 56, color: AppTheme.neutralLightOf(context)),
                  const SizedBox(height: 12),
                  Text(l10n.noRecipes,
                      style: TextStyle(
                          color: AppTheme.textTertiaryOf(context),
                          fontSize: 15)),
                ],
              ),
            ),
          )
        else
          ...recipes.take(3).map(
            (recipe) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: RecipeCard(recipe: recipe),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileCard(
      BuildContext context, AppLocalizations l10n, UserModel user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
          boxShadow: [AppTheme.shadowOf(context)],
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceOf(context),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: AppTheme.neutralSoft,
                            child: const Icon(Icons.person,
                                size: 40, color: AppTheme.textTertiary),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: AppTheme.neutralSoft,
                            child: const Icon(Icons.person,
                                size: 40, color: AppTheme.textTertiary),
                          ),
                        )
                      : Container(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: const Icon(Icons.person,
                              size: 40, color: AppTheme.primaryColor),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            if (user.username != null) ...[
              const SizedBox(height: 4),
              Text(
                '@${user.username}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                user.bio!,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neutralSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: AppTheme.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.memberSince(
                        DateFormat('MMM yyyy').format(user.createdAt)),
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: AppTheme.textTertiaryOf(context).withValues(alpha: 0.4),
            ),
          ),
          Center(
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textTertiaryOf(context),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
