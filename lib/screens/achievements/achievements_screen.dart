import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/achievement.dart';
import '../../models/user_achievement.dart';
import '../../providers/achievement_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AchievementProvider>().triggerCheck(context);
    });
  }

  String _localizedAchievementTitle(AppLocalizations l10n, Achievement a) {
    switch (a.id) {
      case 'first_recipe':
        return l10n.achievementFirstRecipe;
      case 'recipe_master':
        return l10n.achievementRecipeMaster;
      case 'streak_7':
        return l10n.achievementStreak7;
      case 'streak_30':
        return l10n.achievementStreak30;
      case 'top_rated':
        return l10n.achievementTopRated;
      case 'home_chef':
        return l10n.achievementHomeChef;
      case 'health_nut':
        return l10n.achievementHealthNut;
      case 'hydration_hero':
        return l10n.achievementHydrationHero;
      case 'social_butterfly':
        return l10n.achievementSocialButterfly;
      case 'smart_shopper':
        return l10n.achievementSmartShopper;
      case 'collector':
        return l10n.achievementCollector;
      case 'explorer':
        return l10n.achievementExplorer;
      default:
        return a.title;
    }
  }

  String _localizedAchievementDescription(
      AppLocalizations l10n, Achievement a) {
    switch (a.id) {
      case 'first_recipe':
        return l10n.achievementFirstRecipeDesc;
      case 'recipe_master':
        return l10n.achievementRecipeMasterDesc;
      case 'streak_7':
        return l10n.achievementStreak7Desc;
      case 'streak_30':
        return l10n.achievementStreak30Desc;
      case 'top_rated':
        return l10n.achievementTopRatedDesc;
      case 'home_chef':
        return l10n.achievementHomeChefDesc;
      case 'health_nut':
        return l10n.achievementHealthNutDesc;
      case 'hydration_hero':
        return l10n.achievementHydrationHeroDesc;
      case 'social_butterfly':
        return l10n.achievementSocialButterflyDesc;
      case 'smart_shopper':
        return l10n.achievementSmartShopperDesc;
      case 'collector':
        return l10n.achievementCollectorDesc;
      case 'explorer':
        return l10n.achievementExplorerDesc;
      default:
        return a.description;
    }
  }

  String _localizedCategory(AppLocalizations l10n, String category) {
    switch (category) {
      case 'cooking':
        return l10n.categoryCooking;
      case 'social':
        return l10n.categorySocial;
      case 'health':
        return l10n.categoryHealth;
      case 'exploration':
        return l10n.categoryExploration;
      default:
        return l10n.filterAll;
    }
  }

  List<Achievement> get _filteredAchievements {
    final all = Achievement.allAchievements;
    if (_selectedCategory == 'all') return all;
    return all.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AchievementProvider>();
    final unlocked = provider.unlockedCount;
    final total = provider.totalCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievements),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.achievementsUnlocked(unlocked, total),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : unlocked / total,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip(l10n.filterAll, 'all'),
                for (final c in Achievement.categories)
                  _buildCategoryChip(_localizedCategory(l10n, c), c),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: _filteredAchievements.length,
              itemBuilder: (context, index) {
                final achievement = _filteredAchievements[index];
                return _buildAchievementCard(context, l10n, provider, achievement);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final selected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = value),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    AppLocalizations l10n,
    AchievementProvider provider,
    Achievement achievement,
  ) {
    final unlocked = provider.isUnlocked(achievement.id);
    final progress = provider.getProgress(achievement.id);
    final unlockedEntry = provider.unlockedFor(achievement.id);
    final title = _localizedAchievementTitle(l10n, achievement);

    return GestureDetector(
      onTap: () => _showDetailSheet(
          context, l10n, achievement, unlocked, progress, unlockedEntry),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unlocked
                ? achievement.color
                : achievement.color.withValues(alpha: 0.25),
            width: unlocked ? 2 : 1,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: achievement.color.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: achievement.gradient,
                shape: BoxShape.circle,
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: achievement.color.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              foregroundDecoration: unlocked
                  ? null
                  : BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceOf(context)
                          .withValues(alpha: 0.55),
                    ),
              child: Icon(
                achievement.icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: unlocked
                    ? AppTheme.textPrimaryOf(context)
                    : AppTheme.textSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 6),
            if (unlocked && unlockedEntry != null)
              Text(
                l10n.unlockedOn(
                    DateFormat('dd MMM yyyy').format(unlockedEntry.unlockedAt)),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textTertiaryOf(context),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor:
                      AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation(achievement.color),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(
    BuildContext context,
    AppLocalizations l10n,
    Achievement achievement,
    bool unlocked,
    double progress,
    UserAchievement? unlockedEntry,
  ) {
    final title = _localizedAchievementTitle(l10n, achievement);
    final description = _localizedAchievementDescription(l10n, achievement);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: achievement.gradient,
                shape: BoxShape.circle,
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: achievement.color.withValues(alpha: 0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              foregroundDecoration: unlocked
                  ? null
                  : BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceOf(ctx).withValues(alpha: 0.5),
                    ),
              child: Icon(
                achievement.icon,
                size: 52,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryOf(ctx),
              ),
            ),
            const SizedBox(height: 16),
            if (unlocked && unlockedEntry != null)
              Text(
                l10n.unlockedOn(
                    DateFormat('dd MMM yyyy').format(unlockedEntry.unlockedAt)),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: achievement.color,
                ),
              )
            else ...[
              Text(
                '${l10n.progress}: ${(progress * 100).round()}%',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor:
                      AppTheme.neutralLightOf(ctx).withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation(achievement.color),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
