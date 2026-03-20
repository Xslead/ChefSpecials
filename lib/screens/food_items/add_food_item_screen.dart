import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/food_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_item_provider.dart';
import '../../utils/unit_converter.dart';
import '../../widgets/unit_converter_sheet.dart';

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

const List<String> _units = ['100g', '100mL', 'oz', 'lb', 'kg', 'cups', 'tbsp', 'tsp', 'fl oz', 'L'];

class AddFoodItemScreen extends StatefulWidget {
  final FoodItem? editItem;

  const AddFoodItemScreen({super.key, this.editItem});

  @override
  State<AddFoodItemScreen> createState() => _AddFoodItemScreenState();
}

class _AddFoodItemScreenState extends State<AddFoodItemScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  bool get _isEditing => widget.editItem != null;
  bool get _isBaseUnit => _unit == '100g' || _unit == '100mL';

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

  @override
  void initState() {
    super.initState();
    final item = widget.editItem;
    if (item != null) {
      _name = item.name;
      _brand = item.brand;
      _category = item.category;
      _unit = item.unit;
      _packetSize = item.packetSize;
      _barcode = item.barcode;
      _isVegan = item.isVegan;
      _isVegetarian = item.isVegetarian;
      _isGlutenFree = item.isGlutenFree;
      _calories = item.calories;
      _protein = item.protein;
      _carbs = item.carbs;
      _fat = item.fat;
      _saturatedFat = item.saturatedFat;
      _transFat = item.transFat;
      _cholesterol = item.cholesterol;
      _fiber = item.fiber;
      _sugar = item.sugar;
      _sodium = item.sodium;
      _salt = item.salt;
      _nutriScore = item.nutriScore;
      _novaGroup = item.novaGroup;
      _allergens = List<String>.from(item.allergens);
      _ingredientsText = item.ingredientsText;
      _origin = item.origin;
      _servingSize = item.servingSize;
    }
  }

  String? _editVal(double v) => _isEditing ? v.toStringAsFixed(1) : null;

  double _conversionFactor() {
    if (_isBaseUnit) return 1.0;
    final isVolume = UnitConverter.isVolumeUnit(_unit);
    // How many g or mL does 1 of the selected unit equal?
    double unitInBase;
    if (isVolume) {
      switch (_unit) {
        case 'mL': unitInBase = 1; break;
        case 'L': unitInBase = 1000; break;
        case 'cups': unitInBase = 236.588; break;
        case 'tbsp': unitInBase = 14.787; break;
        case 'tsp': unitInBase = 4.929; break;
        case 'fl oz': unitInBase = 29.5735; break;
        default: unitInBase = 1; break;
      }
    } else {
      switch (_unit) {
        case 'g': unitInBase = 1; break;
        case 'kg': unitInBase = 1000; break;
        case 'oz': unitInBase = 28.3495; break;
        case 'lb': unitInBase = 453.592; break;
        default: unitInBase = 1; break;
      }
    }
    // per 1 unit → per 100 base: multiply by (100 / unitInBase)
    return 100.0 / unitInBase;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    final authProvider = context.read<AuthProvider>();
    final foodItemProvider = context.read<FoodItemProvider>();
    final user = authProvider.userModel!;

    // Auto-convert nutrition from "per 1 [unit]" to "per 100g/100mL"
    final factor = _conversionFactor();
    final storedUnit = _isBaseUnit
        ? _unit
        : (UnitConverter.isVolumeUnit(_unit) ? '100mL' : '100g');

    try {
      final foodItem = FoodItem(
        id: _isEditing ? widget.editItem!.id : null,
        name: _name,
        brand: _brand,
        category: _category,
        unit: storedUnit,
        packetSize: _packetSize,
        barcode: _barcode,
        isVegan: _isVegan,
        isVegetarian: _isVegetarian,
        isGlutenFree: _isGlutenFree,
        calories: _calories * factor,
        protein: _protein * factor,
        carbs: _carbs * factor,
        fat: _fat * factor,
        saturatedFat: _saturatedFat * factor,
        transFat: _transFat * factor,
        cholesterol: _cholesterol * factor,
        fiber: _fiber * factor,
        sugar: _sugar * factor,
        sodium: _sodium * factor,
        salt: _salt * factor,
        nutriScore: _nutriScore,
        novaGroup: _novaGroup,
        allergens: _allergens,
        ingredientsText: _ingredientsText,
        origin: _origin,
        servingSize: _servingSize,
        imageUrl: _isEditing ? widget.editItem!.imageUrl : null,
        addedBy: _isEditing ? widget.editItem!.addedBy : user.uid,
        createdAt: _isEditing ? widget.editItem!.createdAt : DateTime.now(),
        isVerified: _isEditing ? widget.editItem!.isVerified : false,
      );

      if (_isEditing) {
        await foodItemProvider.updateFoodItem(foodItem);
      } else {
        await foodItemProvider.addFoodItem(foodItem);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)),
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
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
                      child: Icon(
                        _isEditing ? Icons.edit_outlined : Icons.add_box_outlined,
                        color: AppTheme.secondaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isEditing ? 'Edit Food Item' : 'Add Food Item',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
                      tooltip: 'Unit Converter',
                      onPressed: () => UnitConverterSheet.show(context),
                    ),
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
                    icon: Icons.info_outlined,
                    color: AppTheme.primaryColor,
                    label: 'BASIC INFO',
                  ),
                  const SizedBox(height: 12),

                  // Name field
                  _buildSectionLabel('NAME'),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _isEditing ? _name : null,
                    decoration: _styledInputDecoration(
                      hintText: 'Food item name',
                      prefixIcon: Icons.label_outlined,
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
                    initialValue: _isEditing ? (_brand ?? '') : null,
                    decoration: _styledInputDecoration(
                      hintText: 'Brand (optional)',
                      prefixIcon: Icons.storefront_outlined,
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
                              isExpanded: true,
                              decoration: _styledInputDecoration(
                                prefixIcon: Icons.category_outlined,
                              ),
                              items: _categories
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _category = v;
                                    if (v == 'Beverages') {
                                      _unit = '100mL';
                                    }
                                  });
                                }
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
                              key: ValueKey(_unit),
                              initialValue: _unit,
                              isExpanded: true,
                              decoration: _styledInputDecoration(
                                prefixIcon: Icons.straighten_outlined,
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
                  if (!_isBaseUnit)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Enter nutrition per 1 $_unit — values will be auto-converted to per 100${UnitConverter.isVolumeUnit(_unit) ? 'mL' : 'g'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      if (_isBaseUnit)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('PACKET SIZE'),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: _isEditing ? _packetSize.toStringAsFixed(0) : null,
                                decoration: _styledInputDecoration(
                                  hintText: 'e.g. 330',
                                  prefixIcon: Icons.inventory_2_outlined,
                                  suffixText: UnitConverter.isVolumeUnit(_unit) ? 'mL' : 'g',
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
                      if (_isBaseUnit) const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('BARCODE'),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _isEditing ? (_barcode ?? '') : null,
                              decoration: _styledInputDecoration(
                                hintText: 'Optional',
                                prefixIcon: Icons.qr_code_2_outlined,
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
                    label: _isBaseUnit
                        ? 'NUTRITION VALUES (per $_unit)'
                        : 'NUTRITION VALUES (per 1 $_unit)',
                  ),
                  const SizedBox(height: 12),

                  // Calories - full width card
                  _buildNutritionCard(
                    icon: Icons.whatshot_outlined,
                    color: AppTheme.primaryColor,
                    label: l10n.calories,
                    suffix: l10n.kcal,
                    initialValue: _editVal(_calories),
                    onSaved: (v) =>
                        _calories = double.tryParse(v ?? '') ?? 0,
                  ),
                  const SizedBox(height: 10),

                  // Protein, Carbs, Fat row
                  Row(
                    children: [
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.fitness_center_outlined,
                          color: AppTheme.secondaryColor,
                          label: l10n.protein,
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(_protein),
                          onSaved: (v) =>
                              _protein = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.bakery_dining_outlined,
                          color: const Color(0xFFF59E0B),
                          label: l10n.carbs,
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(_carbs),
                          onSaved: (v) =>
                              _carbs = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.water_drop_outlined,
                          color: const Color(0xFFEF4444),
                          label: l10n.fat,
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(_fat),
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
                          icon: Icons.grass_outlined,
                          color: const Color(0xFF22C55E),
                          label: 'Fiber',
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(_fiber),
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
                          initialValue: _editVal(_sugar),
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
                          initialValue: _editVal(_sodium),
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
                          icon: Icons.opacity_outlined,
                          color: const Color(0xFFEC4899),
                          label: 'Sat. Fat',
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(_saturatedFat),
                          onSaved: (v) =>
                              _saturatedFat = double.tryParse(v ?? '') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.warning_amber_outlined,
                          color: const Color(0xFFF97316),
                          label: 'Trans Fat',
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(_transFat),
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
                          initialValue: _editVal(_cholesterol),
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
                          icon: Icons.scatter_plot_outlined,
                          color: const Color(0xFF0EA5E9),
                          label: 'Salt',
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(_salt),
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
                    icon: Icons.tune_outlined,
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
                              isExpanded: true,
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
                              isExpanded: true,
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
                              initialValue: _isEditing && _servingSize != null
                                  ? _servingSize!.toStringAsFixed(0)
                                  : null,
                              decoration: _styledInputDecoration(
                                hintText: 'Optional',
                                prefixIcon: Icons.scale_outlined,
                                suffixText: UnitConverter.isVolumeUnit(_unit) ? 'mL' : 'g',
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
                              initialValue: _isEditing ? (_origin ?? '') : null,
                              decoration: _styledInputDecoration(
                                hintText: 'Optional',
                                prefixIcon: Icons.public_outlined,
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
                    initialValue: _isEditing ? (_ingredientsText ?? '') : null,
                    decoration: _styledInputDecoration(
                      hintText: 'List of ingredients (optional)',
                      prefixIcon: Icons.receipt_long_outlined,
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
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
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
                            Icons.eco_outlined,
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
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
                      boxShadow: [AppTheme.warmShadowLight()],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.spa_outlined,
                            color: Color(0xFFF97316),
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
                              const Color(0xFFF97316).withValues(alpha: 0.5),
                          activeThumbColor: const Color(0xFFF97316),
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
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
                      boxShadow: [AppTheme.warmShadowLight()],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.no_food_outlined,
                            color: AppTheme.primaryColor,
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
                              AppTheme.primaryColor.withValues(alpha: 0.5),
                          activeThumbColor: AppTheme.primaryColor,
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
      prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
    String? initialValue,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
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
            initialValue: initialValue,
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
