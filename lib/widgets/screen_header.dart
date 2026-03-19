import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final String? subtitle;
  final List<Widget>? trailing;
  final bool showBackButton;
  final VoidCallback? onBack;

  const ScreenHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppTheme.primaryColor;

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack ?? () => context.pop(),
                  color: AppTheme.textPrimaryOf(context),
                ),
              if (showBackButton) const SizedBox(width: 4),
              if (!showBackButton) const SizedBox(width: 12),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 20,
                  ),
                ),
              if (icon != null) const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiaryOf(context),
                            ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
