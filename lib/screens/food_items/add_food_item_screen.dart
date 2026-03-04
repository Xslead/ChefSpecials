import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/food_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_item_provider.dart';

const List<String> _categories = [
  'Protein',
  'Dairy',
  'Grains',
  'Vegetables',
  'Fruits',
  'Oils & Fats',
  'Beverages',
  'Other',
];

const List<String> _units = ['100g', 'mL'];

class AddFoodItemScreen extends StatefulWidget {
  const AddFoodItemScreen({super.key});

  @override
  State<AddFoodItemScreen> createState() => _AddFoodItemScreenState();
}

class _AddFoodItemScreenState extends State<AddFoodItemScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  String _name = '';
  String? _brand;
  String _category = _categories.first;
  String _unit = _units.first;
  double _packetSize = 100;
  String? _barcode;
  bool _isVegan = false;
  double _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fat = 0;
  double _fiber = 0;
  double _sugar = 0;
  double _sodium = 0;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    final authProvider = context.read<AuthProvider>();
    final foodItemProvider = context.read<FoodItemProvider>();
    final user = authProvider.userModel!;

    try {
      final foodItem = FoodItem(
        name: _name,
        brand: _brand,
        category: _category,
        unit: _unit,
        packetSize: _packetSize,
        barcode: _barcode,
        isVegan: _isVegan,
        calories: _calories,
        protein: _protein,
        carbs: _carbs,
        fat: _fat,
        fiber: _fiber,
        sugar: _sugar,
        sodium: _sodium,
        addedBy: user.uid,
        createdAt: DateTime.now(),
      );

      await foodItemProvider.addFoodItem(foodItem);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              onSaved: (v) => _name = v ?? '',
            ),
            const SizedBox(height: 12),

            // Brand (optional)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Brand (optional)',
                border: OutlineInputBorder(),
              ),
              onSaved: (v) =>
                  _brand = (v != null && v.isNotEmpty) ? v : null,
            ),
            const SizedBox(height: 12),

            // Category dropdown
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 12),

            // Unit toggle
            DropdownButtonFormField<String>(
              initialValue: _unit,
              decoration: const InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
              items: _units
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _unit = v);
              },
            ),
            const SizedBox(height: 12),

            // Packet size (required)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Packet Size',
                suffixText: 'g / mL',
                hintText: 'e.g. 330 for a 330g packet',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                return null;
              },
              onSaved: (v) =>
                  _packetSize = double.tryParse(v ?? '') ?? 100,
            ),
            const SizedBox(height: 12),

            // Barcode (optional)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Barcode (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSaved: (v) =>
                  _barcode = (v != null && v.isNotEmpty) ? v : null,
            ),
            const SizedBox(height: 20),

            // Nutrition section header
            Text(
              'Nutrition Values',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Calories + Protein
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'Calories',
                    suffix: 'kcal',
                    onSaved: (v) => _calories = double.tryParse(v ?? '') ?? 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNumberField(
                    label: 'Protein',
                    suffix: 'g',
                    onSaved: (v) => _protein = double.tryParse(v ?? '') ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Carbs + Fat
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'Carbs',
                    suffix: 'g',
                    onSaved: (v) => _carbs = double.tryParse(v ?? '') ?? 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNumberField(
                    label: 'Fat',
                    suffix: 'g',
                    onSaved: (v) => _fat = double.tryParse(v ?? '') ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Fiber + Sugar
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'Fiber',
                    suffix: 'g',
                    onSaved: (v) => _fiber = double.tryParse(v ?? '') ?? 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNumberField(
                    label: 'Sugar',
                    suffix: 'g',
                    onSaved: (v) => _sugar = double.tryParse(v ?? '') ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sodium
            _buildNumberField(
              label: 'Sodium',
              suffix: 'mg',
              onSaved: (v) => _sodium = double.tryParse(v ?? '') ?? 0,
            ),
            const SizedBox(height: 16),

            // Vegan toggle
            SwitchListTile(
              title: const Text('Vegan'),
              value: _isVegan,
              onChanged: (v) => setState(() => _isVegan = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required String suffix,
    required FormFieldSetter<String> onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (double.tryParse(v) == null) return 'Invalid number';
        return null;
      },
      onSaved: onSaved,
    );
  }
}
