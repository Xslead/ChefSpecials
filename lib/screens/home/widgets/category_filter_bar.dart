import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPill(
            context: context,
            label: l10n.all,
            value: null,
          ),
          ...AppConstants.defaultCategories.map(
            (category) => _buildPill(
              context: context,
              label: _localizeCategory(category, l10n),
              value: category,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({required BuildContext context, required String label, required String? value}) {
    final isSelected = selectedCategory == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelected(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.neutralLightOf(context),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
            ),
          ),
        ),
      ),
    );
  }

  String _localizeCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Breakfast':
        return l10n.breakfast;
      case 'Lunch':
        return l10n.lunch;
      case 'Dinner':
        return l10n.dinner;
      case 'Dessert':
        return l10n.dessert;
      case 'Snack':
        return l10n.snack;
      case 'Drink':
        return l10n.drink;
      case 'Salad':
        return l10n.salad;
      case 'Soup':
        return l10n.soup;
      default:
        return category;
    }
  }
}
