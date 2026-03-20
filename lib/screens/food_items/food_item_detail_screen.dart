import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../utils/unit_converter.dart';
import '../../models/food_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_item_provider.dart';
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
                  if (foodItem.allergens.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildAllergensCard(theme),
                  ],
                  if (foodItem.ingredientsText != null &&
                      foodItem.ingredientsText!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildIngredientsCard(theme),
                  ],
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
    final hasImage = foodItem.imageUrl != null && foodItem.imageUrl!.isNotEmpty;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      foregroundColor: hasImage ? Colors.white : AppTheme.textPrimaryOf(context),
      flexibleSpace: FlexibleSpaceBar(
        background: foodItem.imageUrl != null && foodItem.imageUrl!.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    foodItem.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildPlaceholderImage(context),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryDark.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _buildPlaceholderImage(context),
      ),
      actions: isOwner
          ? [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push('/edit-food-item', extra: foodItem);
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
                        Icon(Icons.delete_outline, size: 20, color: AppTheme.errorColor),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ]
          : null,
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      color: AppTheme.neutralSoftOf(context),
      child: Center(
        child: Icon(Icons.restaurant_outlined, size: 80, color: AppTheme.textTertiaryOf(context)),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final unitSuffix = UnitConverter.isVolumeUnit(foodItem.unit) ? 'mL' : 'g';

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
              _buildBadge(label: 'VEGAN', color: const Color(0xFF10B981))
            else
              _buildBadge(label: 'NON-VEGAN', color: AppTheme.textTertiary),
            if (foodItem.isVerified)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined, size: 14, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            if (foodItem.isVegetarian)
              _buildBadge(label: 'VEGETARIAN', color: const Color(0xFFF97316)),
            if (foodItem.isGlutenFree)
              _buildBadge(label: 'GLUTEN FREE', color: AppTheme.primaryColor),
            if (foodItem.nutriScore != null)
              _buildBadge(
                label: 'Nutri-Score: ${foodItem.nutriScore!.toUpperCase()}',
                color: _nutriScoreColor(foodItem.nutriScore!),
              ),
            if (foodItem.novaGroup != null)
              _buildBadge(
                label: 'NOVA ${foodItem.novaGroup}',
                color: _novaGroupColor(foodItem.novaGroup!),
              ),
            if (foodItem.origin != null)
              _buildBadge(
                label: foodItem.origin!,
                color: AppTheme.textSecondary,
              ),
            if (foodItem.servingSize != null)
              _buildBadge(
                label:
                    'Serving: ${foodItem.servingSize!.toStringAsFixed(0)}g',
                color: AppTheme.primaryColor,
              ),
          ],
        ),
        if (foodItem.barcode != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.qr_code_2_outlined, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                foodItem.barcode!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
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
                      child: Container(color: const Color(0xFF0EA5E9)),
                    ),
                    Expanded(
                      flex: (carbsRatio * 100).round().clamp(1, 100),
                      child: Container(color: const Color(0xFFF59E0B)),
                    ),
                    Expanded(
                      flex: (fatRatio * 100).round().clamp(1, 100),
                      child: Container(color: const Color(0xFFEF4444)),
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
                  color: const Color(0xFF0EA5E9),
                ),
                _buildMacroItem(
                  theme: theme,
                  label: 'Carbs',
                  value: '${foodItem.carbs.toStringAsFixed(1)}g',
                  percentage: '${(carbsRatio * 100).toStringAsFixed(0)}%',
                  color: const Color(0xFFF59E0B),
                ),
                _buildMacroItem(
                  theme: theme,
                  label: 'Fat',
                  value: '${foodItem.fat.toStringAsFixed(1)}g',
                  percentage: '${(fatRatio * 100).toStringAsFixed(0)}%',
                  color: const Color(0xFFEF4444),
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
        const Icon(Icons.person_outline, size: 16, color: AppTheme.textTertiary),
        const SizedBox(width: 4),
        Text(
          'Added by ${foodItem.addedBy}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textTertiary,
          ),
        ),
        const Spacer(),
        const Icon(Icons.calendar_today_outlined,
            size: 14, color: AppTheme.textTertiary),
        const SizedBox(width: 4),
        Text(
          '${foodItem.createdAt.day}/${foodItem.createdAt.month}/${foodItem.createdAt.year}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textTertiary,
          ),
        ),
      ],
    );
  }

  Color _nutriScoreColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return const Color(0xFF10B981);
      case 'B':
        return const Color(0xFF22C55E);
      case 'C':
        return const Color(0xFFF59E0B);
      case 'D':
        return const Color(0xFFF97316);
      case 'E':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _novaGroupColor(int group) {
    switch (group) {
      case 1:
        return const Color(0xFF10B981);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFFF97316);
      case 4:
        return const Color(0xFFEF4444);
      default:
        return AppTheme.textSecondary;
    }
  }

  Widget _buildAllergensCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allergens',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: foodItem.allergens
                  .map(
                    (allergen) => Chip(
                      label: Text(
                        allergen,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
                      side: BorderSide(
                        color: AppTheme.errorColor.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingredients',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              foodItem.ingredientsText!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await context.read<FoodItemProvider>().deleteFoodItem(foodItem.id!);
                if (context.mounted) context.pop();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete')),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
