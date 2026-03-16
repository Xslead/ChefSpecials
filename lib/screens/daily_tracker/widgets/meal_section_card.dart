import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/meal_entry.dart';

class MealSectionCard extends StatelessWidget {
  final MealType mealType;
  final List<MealEntry> entries;
  final VoidCallback onAddPressed;
  final Function(int) onRemoveEntry;

  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onAddPressed,
    required this.onRemoveEntry,
  });

  IconData _iconForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.coffee;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.eco;
    }
  }

  Color _colorForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return AppTheme.breakfastColor;
      case MealType.lunch:
        return AppTheme.lunchColor;
      case MealType.dinner:
        return AppTheme.dinnerColor;
      case MealType.snack:
        return AppTheme.snackColor;
    }
  }

  String _mealTypeName(AppLocalizations l10n, MealType type) {
    switch (type) {
      case MealType.breakfast:
        return l10n.breakfast;
      case MealType.lunch:
        return l10n.lunch;
      case MealType.dinner:
        return l10n.dinner;
      case MealType.snack:
        return l10n.snack;
    }
  }

  double _totalCalories() {
    return entries.fold(0, (sum, e) => sum + e.calories);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalCal = _totalCalories();
    final hasEntries = entries.isNotEmpty;
    final color = _colorForMealType(mealType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
          boxShadow: [AppTheme.shadowOf(context)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _iconForMealType(mealType),
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mealTypeName(l10n, mealType),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasEntries
                              ? '${totalCal.toInt()} ${l10n.kcal}'
                              : l10n.notAddedYet,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add button with gradient
                  GestureDetector(
                    onTap: onAddPressed,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Entries — always visible, no dropdown
            if (hasEntries)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Column(
                  children: List.generate(entries.length, (index) {
                    final entry = entries[index];
                    return Dismissible(
                      key: ValueKey(
                        '${mealType.name}_${entry.name}_$index',
                      ),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: AppTheme.errorColor,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onDismissed: (_) => onRemoveEntry(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${entry.name} (${entry.quantity.toInt()}${entry.unit})',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondaryOf(context),
                                ),
                              ),
                            ),
                            Text(
                              '${entry.calories.toInt()} ${AppLocalizations.of(context)!.kcal}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimaryOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
