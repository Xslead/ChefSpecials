import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userModel?.uid;
      if (userId != null) {
        final provider = context.read<ActivityProvider>();
        provider.init(userId);
        provider.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ActivityProvider>();

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.announcements,
            icon: Icons.notifications_outlined,
            iconColor: AppTheme.snackColor,
            subtitle: provider.unreadCount > 0
                ? '${provider.unreadCount} unread'
                : null,
            trailing: [
              if (provider.unreadCount > 0)
                TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  child: Text(
                    l10n.markAllRead,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.activities.isEmpty
                    ? EmptyState(
                        icon: Icons.notifications_off_outlined,
                        title: l10n.noAnnouncements,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                        itemCount: provider.activities.length,
                        itemBuilder: (context, index) =>
                            _buildActivityCard(context, provider.activities[index], l10n),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    Activity activity,
    AppLocalizations l10n,
  ) {
    final color = _colorForType(activity.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(activity.id ?? activity.createdAt.toIso8601String()),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (activity.id == null) return false;
          if (direction == DismissDirection.endToStart && !activity.isRead) {
            context.read<ActivityProvider>().markAsRead(activity.id!);
          } else if (direction == DismissDirection.startToEnd && activity.isRead) {
            context.read<ActivityProvider>().markAsUnread(activity.id!);
          }
          return false;
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          decoration: BoxDecoration(
            color: AppTheme.starColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_unread_outlined, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Text(
                'Unread',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.done_all, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Text(
                'Read',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        child: GestureDetector(
          onTap: () => _onActivityTap(context, activity),
          child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: !activity.isRead
                ? color.withValues(alpha: 0.04)
                : AppTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: !activity.isRead
                  ? color.withValues(alpha: 0.3)
                  : AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
            ),
            boxShadow: [AppTheme.shadowOf(context)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar / type icon
              _buildAvatar(activity, color),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleText(context, activity, l10n),
                    if (activity.message != null &&
                        activity.type == ActivityType.comment) ...[
                      const SizedBox(height: 4),
                      ..._buildCommentContent(context, activity.message!),
                    ],
                    if (activity.message != null &&
                        activity.type == ActivityType.rating) ...[
                      const SizedBox(height: 4),
                      _buildStarRow(int.tryParse(activity.message!) ?? 0),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          _iconForType(activity.type),
                          size: 12,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(activity.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                        if (!activity.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Target image thumbnail
              if (activity.targetImageUrl != null) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: activity.targetImageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.neutralSoftOf(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        size: 20,
                        color: AppTheme.textTertiaryOf(context),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.neutralSoftOf(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        size: 20,
                        color: AppTheme.textTertiaryOf(context),
                      ),
                    ),
                  ),
                ),
              ],
              // Chevron
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppTheme.textTertiaryOf(context).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Activity activity, Color color) {
    if (activity.actorAvatar != null && activity.actorAvatar!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundImage: CachedNetworkImageProvider(activity.actorAvatar!),
          backgroundColor: AppTheme.neutralSoftOf(context),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Icon(
        _iconForType(activity.type),
        color: color,
        size: 22,
      ),
    );
  }

  Widget _buildTitleText(
    BuildContext context,
    Activity activity,
    AppLocalizations l10n,
  ) {
    final String text;
    switch (activity.type) {
      case ActivityType.follow:
        text = l10n.activityFollow(activity.actorName);
      case ActivityType.comment:
        text = l10n.activityComment(
            activity.actorName, activity.targetName ?? '');
      case ActivityType.rating:
        text = l10n.activityRating(
            activity.actorName, activity.targetName ?? '');
      case ActivityType.newRecipe:
        text = l10n.activityNewRecipe(
            activity.actorName, activity.targetName ?? '');
    }

    final actorStart = text.indexOf(activity.actorName);
    final primaryColor = AppTheme.textPrimaryOf(context);
    final secondaryColor = AppTheme.textSecondaryOf(context);

    if (actorStart == -1) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: secondaryColor,
          height: 1.3,
        ),
        children: [
          if (actorStart > 0) TextSpan(text: text.substring(0, actorStart)),
          TextSpan(
            text: activity.actorName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          if (actorStart + activity.actorName.length < text.length)
            TextSpan(
              text: text.substring(actorStart + activity.actorName.length),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCommentContent(BuildContext context, String message) {
    // Format: "stars|commentText" or just "commentText"
    final parts = message.split('|');
    final int? stars;
    final String commentText;
    if (parts.length >= 2 && int.tryParse(parts[0]) != null) {
      stars = int.parse(parts[0]);
      commentText = parts.sublist(1).join('|');
    } else {
      stars = null;
      commentText = message;
    }

    return [
      if (stars != null) ...[
        _buildStarRow(stars),
        const SizedBox(height: 4),
      ],
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.neutralSoftOf(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '"$commentText"',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppTheme.textSecondaryOf(context),
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
  }

  Widget _buildStarRow(int stars) {
    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          i < stars ? Icons.star : Icons.star_border,
          size: 16,
          color: AppTheme.starColor,
        ),
      ),
    );
  }

  void _onActivityTap(BuildContext context, Activity activity) {
    switch (activity.type) {
      case ActivityType.follow:
        context.push('/user/${activity.actorId}', extra: activity.actorName);
      case ActivityType.comment:
      case ActivityType.rating:
      case ActivityType.newRecipe:
        context.push('/recipe/${activity.targetId}');
    }
  }

  IconData _iconForType(ActivityType type) {
    return switch (type) {
      ActivityType.follow => Icons.person_add,
      ActivityType.comment => Icons.comment_outlined,
      ActivityType.rating => Icons.star_rounded,
      ActivityType.newRecipe => Icons.restaurant_menu,
    };
  }

  Color _colorForType(ActivityType type) {
    return switch (type) {
      ActivityType.follow => AppTheme.snackColor,
      ActivityType.comment => AppTheme.secondaryColor,
      ActivityType.rating => AppTheme.starColor,
      ActivityType.newRecipe => AppTheme.primaryColor,
    };
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(dateTime);
  }
}
