import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
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
  bool _isVegetarian = false;
  bool _isGlutenFree = false;
  double _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fat = 0;
  double _saturatedFat = 0;
  double _transFat = 0;
  double _cholesterol = 0;
  double _fiber = 0;
  double _sugar = 0;
  double _sodium = 0;
  double _salt = 0;
  String? _nutriScore;
  int? _novaGroup;
  List<String> _allergens = [];
  String? _ingredientsText;
  String? _origin;
  double? _servingSize;

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
        isVegetarian: _isVegetarian,
        isGlutenFree: _isGlutenFree,
        calories: _calories,
        protein: _protein,
        carbs: _carbs,
        fat: _fat,
        saturatedFat: _saturatedFat,
        transFat: _transFat,
        cholesterol: _cholesterol,
        fiber: _fiber,
        sugar: _sugar,
        sodium: _sodium,
        salt: _salt,
        nutriScore: _nutriScore,
        novaGroup: _novaGroup,
        allergens: _allergens,
        ingredientsText: _ingredientsText,
        origin: _origin,
        servingSize: _servingSize,
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // Custom header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                      color: AppTheme.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.secondaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Add Food Item',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              l10n.save,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  // Basic Info Section
                  _buildSectionHeader(
                    icon: Icons.info_outline,
                    color: AppTheme.primaryColor,
                    label: 'BASIC INFO',
                  ),
                  const SizedBox(height: 12),

                  // Name field
                  _buildSectionLabel('NAME'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: _styledInputDecoration(
                      hintText: 'Food item name',
                      prefixIcon: Icons.restaurant,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                    onSaved: (v) => _name = v ?? '',
                  ),
                  const SizedBox(height: 12),

                  // Brand field
                  _buildSectionLabel('BRAND'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: _styledInputDecoration(
                      hintText: 'Brand (optional)',
                      prefixIcon: Icons.business,
                    ),
                    onSaved: (v) =>
                        _brand = (v != null && v.isNotEmpty) ? v : null,
                  ),
                  const SizedBox(height: 16),

                  // Category & Unit row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel(l10n.category),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _category,
                              decoration: _styledInputDecoration(
                                prefixIcon: Icons.category_outlined,
                              ),
                              items: _categories
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _category = v);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('UNIT'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _unit,
                              decoration: _styledInputDecoration(
                                prefixIcon: Icons.straighten,
                              ),
                              items: _units
                                  .map((u) => DropdownMenuItem(
                                      value: u, child: Text(u)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _unit = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Packet size & Barcode row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('PACKET SIZE'),
                            const SizedBox(height: 8),
                            TextFormField(
                              decoration: _styledInputDecoration(
                                hintText: 'e.g. 330',
                                prefixIcon: Icons.inventory_2_outlined,
                                suffixText: 'g/mL',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (double.tryParse(v) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                              onSaved: (v) =>
                                  _packetSize =
                                      double.tryParse(v ?? '') ?? 100,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('BARCODE'),
                            const SizedBox(height: 8),
                            TextFormField(
                              decoration: _styledInputDecoration(
                                hintText: 'Optional',
                                prefixIcon: Icons.qr_code,
                              ),
                              keyboardType: TextInputType.number,
                              onSaved: (v) => _barcode =
                                  (v != null && v.isNotEmpty) ? v : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nutrition Section
                  _buildSectionHeader(
                    icon: Icons.analytics_outlined,
                    color: AppTheme.secondaryColor,
                    label: 'NUTRITION VALUES',
                  ),
                  const SizedBox(height: 12),

                  // Calories - full width card
                  _buildNutritionCard(
                    icon: Icons.local_fire_department,
                    color: AppTheme.primaryColor,
                    label: l10n.calories,
                    suffix: l10n.kcal,
                    onSaved: (v) =>
                        _calories = double.tryParse(v ?? '') ?? 0,
                  ),
                  const SizedBox(height: 10),

                  // Protein, Carbs, Fat row
                  Row(
                    children: [
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.fitness_center,
                          color: AppTheme.secondaryColor,
                          label: l10n.protein,
                          suffix: l10n.gram,
                          compact: true,
                          onSaved: (v) =>
                              _protein = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.grain,
                          color: const Color(0xFFF59E0B),
                          label: l10n.carbs,
                          suffix: l10n.gram,
                          compact: true,
                          onSaved: (v) =>
                              _carbs = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.opacity,
                          color: const Color(0xFFEF4444),
                          label: l10n.fat,
                          suffix: l10n.gram,
                          compact: true,
                          onSaved: (v) =>
                              _fat = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Fiber, Sugar, Sodium row
                  Row(
                    children: [
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.grass,
                          color: const Color(0xFF22C55E),
                          label: 'Fiber',
                          suffix: l10n.gram,
                          compact: true,
                          onSaved: (v) =>
                              _fiber = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.cookie_outlined,
                          color: const Color(0xFFA855F7),
                          label: 'Sugar',
                          suffix: l10n.gram,
                          compact: true,
                          onSaved: (v) =>
                              _sugar = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.water_drop_outlined,
                          color: const Color(0xFF6366F1),
                          label: 'Sodium',
                          suffix: 'mg',
                          compact: true,
                          onSaved: (v) =>
                              _sodium = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Sat. Fat, Trans Fat, Cholesterol row
                  Row(
                    children: [
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.water_drop,
                          color: const Color(0xFFEC4899),
                          label: 'Sat. Fat',
                          suffix: l10n.gram,
                          compact: true,
                          onSaved: (v) =>
                              _saturatedFat = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.warning_amber,
                          color: const Color(0xFFF97316),
                          label: 'Trans Fat',
                          suffix: l10n.gram,
                          compact: true,
                          onSaved: (v) =>
                              _transFat = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.favorite_outline,
                          color: const Color(0xFFDC2626),
                          label: 'Cholesterol',
                          suffix: 'mg',
                          compact: true,
                          onSaved: (v) =>
                              _cholesterol = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Salt row
                  Row(
                    children: [
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.grain,
                          color: const Color(0xFF0EA5E9),
                          label: 'Salt',
                          suffix: l10n.gram,
                          compact: true,
                          onSaved: (v) =>
                              _salt = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Additional Info Section
                  _buildSectionHeader(
                    icon: Icons.tune,
                    color: const Color(0xFF8B5CF6),
                    label: 'ADDITIONAL INFO',
                  ),
                  const SizedBox(height: 12),

                  // Nutri-Score & NOVA Group row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('NUTRI-SCORE'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _nutriScore,
                              decoration: _styledInputDecoration(
                                prefixIcon: Icons.grade_outlined,
                                hintText: 'Optional',
                              ),
                              items: ['A', 'B', 'C', 'D', 'E']
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _nutriScore = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('NOVA GROUP'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              initialValue: _novaGroup,
                              decoration: _styledInputDecoration(
                                prefixIcon: Icons.science_outlined,
                                hintText: 'Optional',
                              ),
                              items: [1, 2, 3, 4]
                                  .map((n) => DropdownMenuItem(
                                      value: n, child: Text('$n')))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _novaGroup = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Serving Size & Origin row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('SERVING SIZE'),
                            const SizedBox(height: 8),
                            TextFormField(
                              decoration: _styledInputDecoration(
                                hintText: 'Optional',
                                prefixIcon: Icons.scale_outlined,
                                suffixText: 'g',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) {
                                if (v == null || v.isEmpty) return null;
                                if (double.tryParse(v) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                              onSaved: (v) => _servingSize =
                                  (v != null && v.isNotEmpty)
                                      ? double.tryParse(v)
                                      : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('ORIGIN'),
                            const SizedBox(height: 8),
                            TextFormField(
                              decoration: _styledInputDecoration(
                                hintText: 'Optional',
                                prefixIcon: Icons.public,
                              ),
                              onSaved: (v) => _origin =
                                  (v != null && v.isNotEmpty) ? v : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ingredients text field
                  _buildSectionLabel('INGREDIENTS'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: _styledInputDecoration(
                      hintText: 'List of ingredients (optional)',
                      prefixIcon: Icons.list_alt,
                    ),
                    maxLines: 3,
                    onSaved: (v) => _ingredientsText =
                        (v != null && v.isNotEmpty) ? v : null,
                  ),
                  const SizedBox(height: 16),

                  // Allergens
                  _buildSectionLabel('ALLERGENS'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Gluten',
                      'Peanuts',
                      'Tree Nuts',
                      'Milk',
                      'Eggs',
                      'Fish',
                      'Shellfish',
                      'Soy',
                      'Sesame',
                    ]
                        .map(
                          (allergen) => FilterChip(
                            label: Text(allergen),
                            selected: _allergens.contains(allergen),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _allergens = [..._allergens, allergen];
                                } else {
                                  _allergens = _allergens
                                      .where((a) => a != allergen)
                                      .toList();
                                }
                              });
                            },
                            selectedColor:
                                AppTheme.primaryColor.withValues(alpha: 0.2),
                            checkmarkColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              color: _allergens.contains(allergen)
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondary,
                              fontWeight: _allergens.contains(allergen)
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                            backgroundColor: AppTheme.warmCream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                              side: BorderSide(
                                color: _allergens.contains(allergen)
                                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                    : AppTheme.warmBeige,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Vegan toggle card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
                      boxShadow: [AppTheme.warmShadowLight()],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Vegan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isVegan,
                          onChanged: (v) => setState(() => _isVegan = v),
                          activeTrackColor:
                              const Color(0xFF22C55E).withValues(alpha: 0.5),
                          activeThumbColor: const Color(0xFF22C55E),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Vegetarian toggle card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
                      boxShadow: [AppTheme.warmShadowLight()],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.orange
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.spa,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Vegetarian',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isVegetarian,
                          onChanged: (v) => setState(() => _isVegetarian = v),
                          activeTrackColor:
                              Colors.orange.withValues(alpha: 0.5),
                          activeThumbColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Gluten Free toggle card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
                      boxShadow: [AppTheme.warmShadowLight()],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.blue
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.no_food,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Gluten Free',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isGlutenFree,
                          onChanged: (v) => setState(() => _isGlutenFree = v),
                          activeTrackColor:
                              Colors.blue.withValues(alpha: 0.5),
                          activeThumbColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textTertiary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  InputDecoration _styledInputDecoration({
    String? hintText,
    IconData? prefixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppTheme.textTertiary, size: 20)
          : null,
      suffixText: suffixText,
      suffixStyle: const TextStyle(
        fontSize: 12,
        color: AppTheme.textTertiary,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppTheme.warmCream,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppTheme.errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppTheme.errorColor, width: 1.5),
      ),
    );
  }

  Widget _buildNutritionCard({
    required IconData icon,
    required Color color,
    required String label,
    required String suffix,
    required FormFieldSetter<String> onSaved,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
        boxShadow: [AppTheme.warmShadowLight()],
      ),
      child: Column(
        children: [
          Container(
            width: compact ? 28 : 36,
            height: compact ? 28 : 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(compact ? 7 : 10),
            ),
            child: Icon(icon, color: color, size: compact ? 16 : 20),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            textAlign: TextAlign.center,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: compact ? 16 : 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: color.withValues(alpha: 0.3),
                fontSize: compact ? 16 : 20,
                fontWeight: FontWeight.w900,
              ),
              suffixText: suffix,
              suffixStyle: TextStyle(
                fontSize: compact ? 9 : 11,
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: AppTheme.warmCream,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: AppTheme.errorColor, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: AppTheme.errorColor, width: 1.5),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return '';
              if (double.tryParse(v) == null) return '';
              return null;
            },
            onSaved: onSaved,
          ),
        ],
      ),
    );
  }
}
