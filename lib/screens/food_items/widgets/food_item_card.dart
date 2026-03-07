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
    final color = _colorForCategory(foodItem.category, context);

    return GestureDetector(
      onTap: () => context.push(
        '/food-item/${foodItem.id}',
        extra: foodItem,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
          boxShadow: [AppTheme.shadowOf(context)],
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
                                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'V',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                            if (foodItem.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_outlined,
                                size: 14,
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          foodItem.brand != null
                              ? '${foodItem.brand} \u2022 ${foodItem.category}'
                              : foodItem.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiaryOf(context),
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textTertiaryOf(context),
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
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.neutralLightOf(context)),
                  ),
                ),
                child: Row(
                  children: [
                    _buildMiniNutrition(
                      context,
                      l10n.protein,
                      '${foodItem.protein.toStringAsFixed(1)}g',
                      AppTheme.primaryColor,
                    ),
                    _buildMiniNutrition(
                      context,
                      l10n.carbs,
                      '${foodItem.carbs.toStringAsFixed(1)}g',
                      const Color(0xFFF59E0B),
                    ),
                    _buildMiniNutrition(
                      context,
                      l10n.fat,
                      '${foodItem.fat.toStringAsFixed(1)}g',
                      const Color(0xFFEF4444),
                    ),
                    _buildMiniNutrition(
                      context,
                      l10n.per100,
                      '${foodItem.packetSize.toStringAsFixed(0)}${foodItem.unit == 'mL' ? 'mL' : 'g'}',
                      AppTheme.textSecondaryOf(context),
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

  Widget _buildMiniNutrition(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.textTertiaryOf(context),
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

  Color _colorForCategory(String category, BuildContext context) {
    switch (category) {
      case 'Protein':
        return const Color(0xFFEF4444);
      case 'Dairy':
        return const Color(0xFF0EA5E9);
      case 'Grains':
        return const Color(0xFFF59E0B);
      case 'Vegetables':
        return const Color(0xFF10B981);
      case 'Fruits':
        return const Color(0xFFF97316);
      case 'Oils & Fats':
        return const Color(0xFFEAB308);
      case 'Beverages':
        return const Color(0xFF06B6D4);
      default:
        return AppTheme.textTertiaryOf(context);
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Protein':
        return Icons.egg_outlined;
      case 'Dairy':
        return Icons.water_drop_outlined;
      case 'Grains':
        return Icons.bakery_dining_outlined;
      case 'Vegetables':
        return Icons.eco_outlined;
      case 'Fruits':
        return Icons.park_outlined;
      case 'Oils & Fats':
        return Icons.oil_barrel_outlined;
      case 'Beverages':
        return Icons.local_cafe_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }
}
