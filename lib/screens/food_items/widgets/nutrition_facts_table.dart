import 'package:flutter/material.dart';

import '../../../config/theme.dart';
import '../../../models/food_item.dart';
import '../../../utils/unit_converter.dart';

class NutritionFactsTable extends StatelessWidget {
  final FoodItem foodItem;

  const NutritionFactsTable({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unitSuffix = UnitConverter.isVolumeUnit(foodItem.unit) ? 'mL' : 'g';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Facts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Per ${foodItem.unit}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const Divider(thickness: 2, height: 20),
            // Column headers
            _buildColumnHeaders(context, unitSuffix),
            const Divider(height: 1),
            _buildRow(
              context,
              label: 'Calories',
              value: '${foodItem.calories.toStringAsFixed(1)} kcal',
              perPacketValue: '${foodItem.caloriesPerPacket.toStringAsFixed(1)} kcal',
              isBold: true,
            ),
            const Divider(height: 1),
            _buildRow(
              context,
              label: 'Protein',
              value: '${foodItem.protein.toStringAsFixed(1)} g',
              perPacketValue: '${foodItem.proteinPerPacket.toStringAsFixed(1)} g',
              barColor: const Color(0xFF0EA5E9),
              barRatio: _macroRatio(foodItem.protein),
            ),
            const Divider(height: 1),
            _buildRow(
              context,
              label: 'Carbohydrates',
              value: '${foodItem.carbs.toStringAsFixed(1)} g',
              perPacketValue: '${foodItem.carbsPerPacket.toStringAsFixed(1)} g',
              barColor: const Color(0xFFF59E0B),
              barRatio: _macroRatio(foodItem.carbs),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  _buildRow(
                    context,
                    label: 'Sugar',
                    value: '${foodItem.sugar.toStringAsFixed(1)} g',
                    perPacketValue: '${foodItem.sugarPerPacket.toStringAsFixed(1)} g',
                    isSubRow: true,
                  ),
                  const Divider(height: 1),
                  _buildRow(
                    context,
                    label: 'Fiber',
                    value: '${foodItem.fiber.toStringAsFixed(1)} g',
                    perPacketValue: '${foodItem.fiberPerPacket.toStringAsFixed(1)} g',
                    isSubRow: true,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildRow(
              context,
              label: 'Fat',
              value: '${foodItem.fat.toStringAsFixed(1)} g',
              perPacketValue: '${foodItem.fatPerPacket.toStringAsFixed(1)} g',
              barColor: const Color(0xFFEF4444),
              barRatio: _macroRatio(foodItem.fat),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  _buildRow(
                    context,
                    label: 'Saturated Fat',
                    value: '${foodItem.saturatedFat.toStringAsFixed(1)} g',
                    perPacketValue: '${foodItem.saturatedFatPerPacket.toStringAsFixed(1)} g',
                    isSubRow: true,
                  ),
                  const Divider(height: 1),
                  _buildRow(
                    context,
                    label: 'Trans Fat',
                    value: '${foodItem.transFat.toStringAsFixed(1)} g',
                    perPacketValue: '${foodItem.transFatPerPacket.toStringAsFixed(1)} g',
                    isSubRow: true,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildRow(
              context,
              label: 'Sodium',
              value: '${foodItem.sodium.toStringAsFixed(1)} mg',
              perPacketValue: '${foodItem.sodiumPerPacket.toStringAsFixed(1)} mg',
            ),
            const Divider(height: 1),
            _buildRow(
              context,
              label: 'Cholesterol',
              value: '${foodItem.cholesterol.toStringAsFixed(1)} mg',
              perPacketValue: '${foodItem.cholesterolPerPacket.toStringAsFixed(1)} mg',
            ),
            const Divider(height: 1),
            _buildRow(
              context,
              label: 'Salt',
              value: '${foodItem.salt.toStringAsFixed(1)} g',
              perPacketValue: '${foodItem.saltPerPacket.toStringAsFixed(1)} g',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnHeaders(BuildContext context, String unitSuffix) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '',
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Per ${foodItem.unit}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              'Per Packet (${foodItem.packetSize.toStringAsFixed(0)}$unitSuffix)',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  double _macroRatio(double value) {
    final total = foodItem.protein + foodItem.carbs + foodItem.fat;
    if (total == 0) return 0;
    return value / total;
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    String? perPacketValue,
    bool isBold = false,
    bool isSubRow = false,
    Color? barColor,
    double? barRatio,
  }) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
      fontSize: isSubRow ? 13 : 14,
      color: isSubRow ? AppTheme.textSecondary : AppTheme.textPrimary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label, style: textStyle),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: textStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              if (perPacketValue != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    perPacketValue,
                    style: textStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ],
          ),
          if (barColor != null && barRatio != null) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: barRatio,
                backgroundColor: AppTheme.warmBeige,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
