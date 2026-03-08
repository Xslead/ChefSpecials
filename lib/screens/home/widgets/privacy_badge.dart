import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/recipe.dart';

class PrivacyBadge extends StatelessWidget {
  final Recipe recipe;

  const PrivacyBadge({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPrivate = recipe.isPrivate;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPrivate ? Icons.lock_outline : Icons.public,
                size: 12,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                isPrivate ? l10n.private : l10n.public,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
