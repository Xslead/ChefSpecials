import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';

class CategoryFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onSelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(label: 'All', value: null),
          ...AppConstants.defaultCategories.map(
            (category) => _buildChip(label: category, value: category),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, required String? value}) {
    final isSelected = selectedCategory == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
