import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';

class AchievementCelebration extends StatelessWidget {
  final Widget child;

  const AchievementCelebration({super.key, required this.child});

  String _localizedTitle(AppLocalizations l10n, Achievement a) {
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

  String _localizedDescription(AppLocalizations l10n, Achievement a) {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AchievementProvider>();
    final l10n = AppLocalizations.of(context);
    final newly = provider.newlyUnlocked;

    return Stack(
      children: [
        child,
        if (newly.isNotEmpty && l10n != null)
          _CelebrationOverlay(
            achievement: newly.first,
            title: _localizedTitle(l10n, newly.first),
            description: _localizedDescription(l10n, newly.first),
            unlockedLabel: l10n.achievementUnlocked,
            awesomeLabel: l10n.awesome,
            onDismiss: provider.clearNewlyUnlocked,
          ),
      ],
    );
  }
}

class _CelebrationOverlay extends StatefulWidget {
  final Achievement achievement;
  final String title;
  final String description;
  final String unlockedLabel;
  final String awesomeLabel;
  final VoidCallback onDismiss;

  const _CelebrationOverlay({
    required this.achievement,
    required this.title,
    required this.description,
    required this.unlockedLabel,
    required this.awesomeLabel,
    required this.onDismiss,
  });

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.unlockedLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: widget.achievement.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _sparkleController,
                          builder: (_, _) => CustomPaint(
                            size: const Size(160, 160),
                            painter: _SparklePainter(
                              _sparkleController.value,
                              widget.achievement.color,
                            ),
                          ),
                        ),
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _iconController,
                            curve: Curves.elasticOut,
                          ),
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              gradient: widget.achievement.gradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.achievement.color
                                      .withValues(alpha: 0.55),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.achievement.icon,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.achievement.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.awesomeLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double t;
  final Color color;
  _SparklePainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    const count = 12;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi + t * 2 * math.pi;
      final radius = 55 + 20 * math.sin(t * 2 * math.pi + i);
      final offset = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final opacity = (0.3 + 0.7 * math.sin(t * 2 * math.pi + i).abs())
          .clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(offset, 3.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
