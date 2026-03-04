import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/food_item.dart';
import '../../providers/auth_provider.dart';
import 'widgets/nutrition_facts_table.dart';

class FoodItemDetailScreen extends StatelessWidget {
  final FoodItem foodItem;

  const FoodItemDetailScreen({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final isOwner = authProvider.userModel?.uid == foodItem.addedBy;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isOwner),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  _buildMacroSummary(theme),
                  const SizedBox(height: 24),
                  NutritionFactsTable(foodItem: foodItem),
                  const SizedBox(height: 24),
                  _buildFooterInfo(theme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isOwner) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: foodItem.imageUrl != null && foodItem.imageUrl!.isNotEmpty
            ? Image.network(
                foodItem.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
      actions: isOwner
          ? [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    // TODO: Navigate to edit screen
                  } else if (value == 'delete') {
                    _showDeleteDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ]
          : null,
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.restaurant, size: 80, color: Colors.grey),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final unitSuffix = foodItem.unit == 'mL' ? 'mL' : 'g';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          foodItem.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (foodItem.brand != null) ...[
          const SizedBox(height: 2),
          Text(
            foodItem.brand!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _buildBadge(
              label: foodItem.category,
              color: AppTheme.secondaryColor,
            ),
            _buildBadge(
              label: 'Per ${foodItem.unit}',
              color: AppTheme.primaryColor,
            ),
            _buildBadge(
              label: 'Packet: ${foodItem.packetSize.toStringAsFixed(0)}$unitSuffix',
              color: AppTheme.primaryColor,
            ),
            if (foodItem.isVegan)
              _buildBadge(label: 'VEGAN', color: Colors.green)
            else
              _buildBadge(label: 'NON-VEGAN', color: Colors.grey),
            if (foodItem.isVerified)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (foodItem.barcode != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.qr_code, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                foodItem.barcode!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMacroSummary(ThemeData theme) {
    final totalMacros = foodItem.protein + foodItem.carbs + foodItem.fat;
    final proteinRatio = totalMacros > 0 ? foodItem.protein / totalMacros : 0.0;
    final carbsRatio = totalMacros > 0 ? foodItem.carbs / totalMacros : 0.0;
    final fatRatio = totalMacros > 0 ? foodItem.fat / totalMacros : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  foodItem.calories.toStringAsFixed(0),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'kcal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Macro ratio bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    Expanded(
                      flex: (proteinRatio * 100).round().clamp(1, 100),
                      child: Container(color: const Color(0xFF4A90D9)),
                    ),
                    Expanded(
                      flex: (carbsRatio * 100).round().clamp(1, 100),
                      child: Container(color: const Color(0xFFFF9F43)),
                    ),
                    Expanded(
                      flex: (fatRatio * 100).round().clamp(1, 100),
                      child: Container(color: const Color(0xFFEE5A5A)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem(
                  theme: theme,
                  label: 'Protein',
                  value: '${foodItem.protein.toStringAsFixed(1)}g',
                  percentage: '${(proteinRatio * 100).toStringAsFixed(0)}%',
                  color: const Color(0xFF4A90D9),
                ),
                _buildMacroItem(
                  theme: theme,
                  label: 'Carbs',
                  value: '${foodItem.carbs.toStringAsFixed(1)}g',
                  percentage: '${(carbsRatio * 100).toStringAsFixed(0)}%',
                  color: const Color(0xFFFF9F43),
                ),
                _buildMacroItem(
                  theme: theme,
                  label: 'Fat',
                  value: '${foodItem.fat.toStringAsFixed(1)}g',
                  percentage: '${(fatRatio * 100).toStringAsFixed(0)}%',
                  color: const Color(0xFFEE5A5A),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem({
    required ThemeData theme,
    required String label,
    required String value,
    required String percentage,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          percentage,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterInfo(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.person_outline, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          'Added by ${foodItem.addedBy}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
        const Spacer(),
        Icon(Icons.calendar_today_outlined,
            size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          '${foodItem.createdAt.day}/${foodItem.createdAt.month}/${foodItem.createdAt.year}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Food Item'),
        content:
            Text('Are you sure you want to delete "${foodItem.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: Call provider.deleteFoodItem() and pop screen
              Navigator.of(context).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
