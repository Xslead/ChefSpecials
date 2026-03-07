import 'package:flutter/material.dart';
import '../config/theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final double borderRadius;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppTheme.warmBeige.withValues(alpha: 0.5),
        ),
        boxShadow: [AppTheme.warmShadowLight()],
      ),
      child: child,
    );
  }
}
