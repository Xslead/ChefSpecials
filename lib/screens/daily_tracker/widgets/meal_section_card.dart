import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/meal_entry.dart';

class MealSectionCard extends StatefulWidget {
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

  @override
  State<MealSectionCard> createState() => _MealSectionCardState();
}

class _MealSectionCardState extends State<MealSectionCard> {
  bool _expanded = false;

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
        return Colors.orange;
      case MealType.lunch:
        return Colors.blue;
      case MealType.dinner:
        return Colors.indigo;
      case MealType.snack:
        return Colors.green;
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
    return widget.entries.fold(0, (sum, e) => sum + e.calories);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalCal = _totalCalories();
    final hasEntries = widget.entries.isNotEmpty;
    final color = _colorForMealType(widget.mealType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: hasEntries ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header row
              GestureDetector(
                onTap: hasEntries
                    ? () => setState(() => _expanded = !_expanded)
                    : null,
                behavior: HitTestBehavior.opaque,
                child: Padding(
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
                          _iconForMealType(widget.mealType),
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
                              _mealTypeName(l10n, widget.mealType),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasEntries
                                  ? l10n.itemsAdded(widget.entries.length)
                                  : l10n.notAddedYet,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Calories or Add button
                      if (hasEntries) ...[
                        Text(
                          '${totalCal.toInt()} ${l10n.kcal}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _expanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ] else
                        GestureDetector(
                          onTap: widget.onAddPressed,
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
              ),
              // Expanded entries
              if (_expanded && hasEntries)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade50),
                    ),
                  ),
                  child: Column(
                    children: [
                      ...List.generate(widget.entries.length, (index) {
                        final entry = widget.entries[index];
                        return Dismissible(
                          key: ValueKey(
                            '${widget.mealType.name}_${entry.name}_$index',
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
                          onDismissed: (_) => widget.onRemoveEntry(index),
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
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${entry.calories.toInt()} ${AppLocalizations.of(context)!.kcal}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      // Add more button
                      GestureDetector(
                        onTap: widget.onAddPressed,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.addFood,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
