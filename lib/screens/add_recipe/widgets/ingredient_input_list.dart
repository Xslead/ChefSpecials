import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/food_item.dart';
import '../../../providers/recipe_form_provider.dart';
import '../../../services/food_item_service.dart';

class IngredientInputList extends StatelessWidget {
  const IngredientInputList({super.key});

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<RecipeFormProvider>();
    final l10n = AppLocalizations.of(context)!;
    final ingredients = formProvider.ingredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.ingredients,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showFoodItemPicker(context),
            ),
          ],
        ),
        if (ingredients.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Tap + to add ingredients from the materials database',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ingredients.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final ingredient = ingredients[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ingredient.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (ingredient.caloriesPer100 != null)
                            Text(
                              '${ingredient.caloriesPer100!.toStringAsFixed(0)} kcal per 100${ingredient.unit ?? 'g'}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: ingredient.amount,
                        decoration: InputDecoration(
                          labelText: ingredient.unit ?? 'g',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            formProvider.updateIngredientAmount(index, value),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => formProvider.removeIngredient(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showFoodItemPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => _FoodItemPickerSheet(
          scrollController: scrollController,
          onSelected: (foodItem) {
            Navigator.pop(sheetContext);
            _showAmountDialog(context, foodItem);
          },
        ),
      ),
    );
  }

  void _showAmountDialog(BuildContext context, FoodItem foodItem) {
    final amountController = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(foodItem.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Per 100${foodItem.unit == "100g" ? "g" : "mL"}: '
              '${foodItem.calories.toStringAsFixed(0)} kcal, '
              '${foodItem.protein.toStringAsFixed(1)}g protein',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (${foodItem.unit == "100g" ? "g" : "mL"})',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = amountController.text.trim();
              if (amount.isNotEmpty) {
                context
                    .read<RecipeFormProvider>()
                    .addIngredientFromFoodItem(foodItem, amount);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _FoodItemPickerSheet extends StatefulWidget {
  final ScrollController scrollController;
  final ValueChanged<FoodItem> onSelected;

  const _FoodItemPickerSheet({
    required this.scrollController,
    required this.onSelected,
  });

  @override
  State<_FoodItemPickerSheet> createState() => _FoodItemPickerSheetState();
}

class _FoodItemPickerSheetState extends State<_FoodItemPickerSheet> {
  final FoodItemService _service = FoodItemService();
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _items = [];
  List<FoodItem> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    _service.getFoodItems().listen((items) {
      if (mounted) {
        setState(() {
          _items = items;
          _filtered = items;
          _isLoading = false;
        });
      }
    });
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _items;
      } else {
        final lower = query.toLowerCase();
        _filtered = _items
            .where((item) => item.name.toLowerCase().contains(lower))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search materials...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
            onChanged: _search,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                  ? const Center(child: Text('No materials found.\nAdd materials in the Materials screen first.'))
                  : ListView.builder(
                      controller: widget.scrollController,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.calories.toStringAsFixed(0)} kcal · '
                            '${item.protein.toStringAsFixed(1)}g P · '
                            '${item.carbs.toStringAsFixed(1)}g C · '
                            '${item.fat.toStringAsFixed(1)}g F '
                            'per ${item.unit}',
                          ),
                          trailing: Text(
                            item.category,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          onTap: () => widget.onSelected(item),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
