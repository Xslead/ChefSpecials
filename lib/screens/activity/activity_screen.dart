import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/empty_state.dart';

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
      final userId = context.read<AuthProvider>().firebaseUser?.uid;
      if (userId != null) {
        context.read<ActivityProvider>().init(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          Consumer<ActivityProvider>(
            builder: (context, provider, _) {
              return ScreenHeader(
                title: l10n.announcements,
                icon: Icons.notifications_outlined,
                iconColor: AppTheme.snackColor,
                trailing: [
                  if (provider.unreadCount > 0)
                    TextButton(
                      onPressed: () => provider.markAllAsRead(),
                      child: Text(
                        l10n.markAllRead,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Expanded(
            child: Consumer<ActivityProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.activities.isEmpty) {
                  return EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: l10n.noAnnouncements,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: provider.activities.length,
                  itemBuilder: (context, index) {
                    return _buildActivityItem(
                      context,
                      provider.activities[index],
                      l10n,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    Activity activity,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () => _onActivityTap(context, activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
          boxShadow: [AppTheme.shadowOf(context)],
        ),
        child: Container(
          decoration: !activity.isRead
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border(
                    left: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 3,
                    ),
                  ),
                )
              : null,
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(activity),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleText(context, activity, l10n),
                    if (activity.message != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        activity.message!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiaryOf(context),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _formatTimeAgo(activity.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiaryOf(context),
                          ),
                    ),
                  ],
                ),
              ),
              if (activity.targetImageUrl != null) ...[
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    activity.targetImageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Activity activity) {
    if (activity.actorAvatar != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(activity.actorAvatar!),
      );
    }

    final iconData = _iconForType(activity.type);
    final iconColor = _colorForType(activity.type);

    return CircleAvatar(
      radius: 20,
      backgroundColor: iconColor.withValues(alpha: 0.1),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
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
        break;
      case ActivityType.comment:
        text = l10n.activityComment(
          activity.actorName,
          activity.targetName ?? '',
        );
        break;
      case ActivityType.rating:
        text = l10n.activityRating(
          activity.actorName,
          activity.targetName ?? '',
        );
        break;
      case ActivityType.newRecipe:
        text = l10n.activityNewRecipe(activity.actorName);
        break;
    }

    final actorNameLength = activity.actorName.length;
    final actorNameStart = text.indexOf(activity.actorName);

    if (actorNameStart == -1) {
      return Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
      );
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
        children: [
          if (actorNameStart > 0)
            TextSpan(text: text.substring(0, actorNameStart)),
          TextSpan(
            text: activity.actorName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (actorNameStart + actorNameLength < text.length)
            TextSpan(
              text: text.substring(actorNameStart + actorNameLength),
            ),
        ],
      ),
    );
  }

  void _onActivityTap(BuildContext context, Activity activity) {
    switch (activity.type) {
      case ActivityType.follow:
        context.push('/user/${activity.actorId}', extra: activity.actorName);
        break;
      case ActivityType.comment:
      case ActivityType.rating:
      case ActivityType.newRecipe:
        context.push('/recipe/${activity.targetId}');
        break;
    }
  }

  IconData _iconForType(ActivityType type) {
    switch (type) {
      case ActivityType.follow:
        return Icons.person_add;
      case ActivityType.comment:
        return Icons.comment;
      case ActivityType.rating:
        return Icons.star;
      case ActivityType.newRecipe:
        return Icons.restaurant_menu;
    }
  }

  Color _colorForType(ActivityType type) {
    switch (type) {
      case ActivityType.follow:
        return AppTheme.snackColor;
      case ActivityType.comment:
        return AppTheme.secondaryColor;
      case ActivityType.rating:
        return AppTheme.starColor;
      case ActivityType.newRecipe:
        return AppTheme.primaryColor;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
