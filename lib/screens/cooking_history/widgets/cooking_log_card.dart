import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/cooking_log.dart';

class CookingLogCard extends StatelessWidget {
  final CookingLog log;

  const CookingLogCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
        ),
        boxShadow: [AppTheme.shadowOf(context)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: log.recipeImageUrl != null &&
                        log.recipeImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: log.recipeImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: AppTheme.neutralSoft,
                          child: const Icon(Icons.restaurant,
                              color: AppTheme.textTertiary, size: 24),
                        ),
                        errorWidget: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.recipeName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy • HH:mm').format(log.cookedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiaryOf(context),
                    ),
                  ),
                  if (log.personalRating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < log.personalRating!
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: AppTheme.starColor,
                        ),
                      ),
                    ),
                  ],
                  if (log.notes != null && log.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      log.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(context),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    l10n.cookedTimes(log.servings),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            // Result photo thumbnail
            if (log.photoUrl != null && log.photoUrl!.isNotEmpty) ...[
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CachedNetworkImage(
                    imageUrl: log.photoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.neutralSoft,
      child: const Icon(Icons.restaurant, color: AppTheme.textTertiary, size: 24),
    );
  }
}
