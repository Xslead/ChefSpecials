import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;

  const FoodItemCard({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _colorForCategory(foodItem.category);

    return GestureDetector(
      onTap: () => context.push(
        '/food-item/${foodItem.id}',
        extra: foodItem,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
          boxShadow: [AppTheme.warmShadowLight()],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Main row
              Row(
                children: [
                  // Category icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _iconForCategory(foodItem.category),
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + brand + tags
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                foodItem.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (foodItem.isVegan) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'V',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                            if (foodItem.isVerified) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.blue.shade400,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          foodItem.brand != null
                              ? '${foodItem.brand} \u2022 ${foodItem.category}'
                              : foodItem.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Calories
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        foodItem.calories.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        l10n.kcal,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Nutrition mini bar
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.warmBeige),
                  ),
                ),
                child: Row(
                  children: [
                    _buildMiniNutrition(
                      l10n.protein,
                      '${foodItem.protein.toStringAsFixed(1)}g',
                      AppTheme.primaryColor,
                    ),
                    _buildMiniNutrition(
                      l10n.carbs,
                      '${foodItem.carbs.toStringAsFixed(1)}g',
                      const Color(0xFFF59E0B),
                    ),
                    _buildMiniNutrition(
                      l10n.fat,
                      '${foodItem.fat.toStringAsFixed(1)}g',
                      const Color(0xFFEF4444),
                    ),
                    _buildMiniNutrition(
                      l10n.per100,
                      '${foodItem.packetSize.toStringAsFixed(0)}${foodItem.unit == 'mL' ? 'mL' : 'g'}',
                      AppTheme.textSecondary,
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

  Widget _buildMiniNutrition(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'Protein':
        return Colors.red.shade400;
      case 'Dairy':
        return Colors.blue.shade400;
      case 'Grains':
        return Colors.amber.shade600;
      case 'Vegetables':
        return Colors.green.shade500;
      case 'Fruits':
        return Colors.orange.shade400;
      case 'Oils & Fats':
        return Colors.yellow.shade700;
      case 'Beverages':
        return Colors.cyan.shade500;
      default:
        return AppTheme.textTertiary;
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Protein':
        return Icons.egg_alt;
      case 'Dairy':
        return Icons.water_drop;
      case 'Grains':
        return Icons.grain;
      case 'Vegetables':
        return Icons.eco;
      case 'Fruits':
        return Icons.apple;
      case 'Oils & Fats':
        return Icons.opacity;
      case 'Beverages':
        return Icons.local_drink;
      default:
        return Icons.restaurant;
    }
  }
}
