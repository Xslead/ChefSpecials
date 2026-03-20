import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/food_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_item_form_provider.dart';
import '../../providers/food_item_provider.dart';
import '../../utils/category_helpers.dart';
import '../../utils/unit_converter.dart';
import '../../widgets/unit_converter_sheet.dart';

class AddFoodItemScreen extends StatelessWidget {
  final FoodItem? editItem;

  const AddFoodItemScreen({super.key, this.editItem});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = FoodItemFormProvider();
        if (editItem != null) {
          provider.loadFromFoodItem(editItem!);
        }
        return provider;
      },
      child: _AddFoodItemBody(editItem: editItem),
    );
  }
}

class _AddFoodItemBody extends StatefulWidget {
  final FoodItem? editItem;

  const _AddFoodItemBody({this.editItem});

  @override
  State<_AddFoodItemBody> createState() => _AddFoodItemBodyState();
}

class _AddFoodItemBodyState extends State<_AddFoodItemBody> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.editItem != null;

  String? _editVal(double v) => _isEditing ? v.toStringAsFixed(1) : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final formProvider = context.read<FoodItemFormProvider>();
    final authProvider = context.read<AuthProvider>();
    final foodItemProvider = context.read<FoodItemProvider>();
    final user = authProvider.userModel!;

    formProvider.setIsSubmitting(true);

    try {
      final foodItem = formProvider.buildFoodItem(
        userId: user.uid,
        existingItem: widget.editItem,
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
        formProvider.setIsSubmitting(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fp = context.watch<FoodItemFormProvider>();

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
                      _isEditing ? l10n.editFoodItem : l10n.addFoodItem,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
                      tooltip: l10n.unitConverter,
                      onPressed: () => UnitConverterSheet.show(context),
                    ),
                    TextButton(
                      onPressed: fp.isSubmitting ? null : _submit,
                      child: fp.isSubmitting
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
                    label: l10n.basicInfo,
                  ),
                  const SizedBox(height: 12),

                  // Name field
                  _buildSectionLabel('NAME'),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _isEditing ? fp.name : null,
                    decoration: _styledInputDecoration(
                      hintText: l10n.foodItemName,
                      prefixIcon: Icons.label_outlined,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l10n.requiredField : null,
                    onSaved: (v) => fp.setName(v ?? ''),
                  ),
                  const SizedBox(height: 12),

                  // Brand field
                  _buildSectionLabel('BRAND'),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _isEditing ? (fp.brand ?? '') : null,
                    decoration: _styledInputDecoration(
                      hintText: l10n.brandOptional,
                      prefixIcon: Icons.storefront_outlined,
                    ),
                    onSaved: (v) => fp.setBrand(v),
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
                              initialValue: fp.category,
                              isExpanded: true,
                              decoration: _styledInputDecoration(
                                prefixIcon: Icons.category_outlined,
                              ),
                              items: foodItemCategories
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(localizeFoodCategory(c, l10n))))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  fp.setCategory(v);
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
                            _buildSectionLabel(l10n.unit),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              key: ValueKey(fp.unit),
                              initialValue: fp.unit,
                              isExpanded: true,
                              decoration: _styledInputDecoration(
                                prefixIcon: Icons.straighten_outlined,
                              ),
                              items: foodItemUnits
                                  .map((u) => DropdownMenuItem(
                                      value: u, child: Text(u)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) fp.setUnit(v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Packet size & Barcode row
                  if (!fp.isBaseUnit)
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
                                l10n.nutritionAutoConvertInfo(fp.unit, UnitConverter.isVolumeUnit(fp.unit) ? 'mL' : 'g'),
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
                      if (fp.isBaseUnit)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel(l10n.packetSize),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: _isEditing ? fp.packetSize.toStringAsFixed(0) : null,
                                decoration: _styledInputDecoration(
                                  hintText: 'e.g. 330',
                                  prefixIcon: Icons.inventory_2_outlined,
                                  suffixText: UnitConverter.isVolumeUnit(fp.unit) ? 'mL' : 'g',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return l10n.requiredField;
                                  if (double.tryParse(v) == null) {
                                    return l10n.invalid;
                                  }
                                  return null;
                                },
                                onSaved: (v) =>
                                    fp.setPacketSize(
                                        double.tryParse(v ?? '') ?? 100),
                              ),
                            ],
                          ),
                        ),
                      if (fp.isBaseUnit) const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel(l10n.barcode),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _isEditing ? (fp.barcode ?? '') : null,
                              decoration: _styledInputDecoration(
                                hintText: l10n.optional,
                                prefixIcon: Icons.qr_code_2_outlined,
                              ),
                              keyboardType: TextInputType.number,
                              onSaved: (v) => fp.setBarcode(v),
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
                    label: fp.isBaseUnit
                        ? l10n.nutritionValuesPer(fp.unit)
                        : l10n.nutritionValuesPer('1 ${fp.unit}'),
                  ),
                  const SizedBox(height: 12),

                  // Calories - full width card
                  _buildNutritionCard(
                    icon: Icons.whatshot_outlined,
                    color: AppTheme.primaryColor,
                    label: l10n.calories,
                    suffix: l10n.kcal,
                    initialValue: _editVal(fp.calories),
                    onSaved: (v) =>
                        fp.setCalories(double.tryParse(v ?? '') ?? 0),
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
                          initialValue: _editVal(fp.protein),
                          onSaved: (v) =>
                              fp.setProtein(double.tryParse(v ?? '') ?? 0),
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
                          initialValue: _editVal(fp.carbs),
                          onSaved: (v) =>
                              fp.setCarbs(double.tryParse(v ?? '') ?? 0),
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
                          initialValue: _editVal(fp.fat),
                          onSaved: (v) =>
                              fp.setFat(double.tryParse(v ?? '') ?? 0),
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
                          label: l10n.fiber,
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(fp.fiber),
                          onSaved: (v) =>
                              fp.setFiber(double.tryParse(v ?? '') ?? 0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.cookie_outlined,
                          color: const Color(0xFFA855F7),
                          label: l10n.sugar,
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(fp.sugar),
                          onSaved: (v) =>
                              fp.setSugar(double.tryParse(v ?? '') ?? 0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.water_drop_outlined,
                          color: const Color(0xFF6366F1),
                          label: l10n.sodium,
                          suffix: 'mg',
                          compact: true,
                          initialValue: _editVal(fp.sodium),
                          onSaved: (v) =>
                              fp.setSodium(double.tryParse(v ?? '') ?? 0),
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
                          label: l10n.saturatedFat,
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(fp.saturatedFat),
                          onSaved: (v) =>
                              fp.setSaturatedFat(double.tryParse(v ?? '') ?? 0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.warning_amber_outlined,
                          color: const Color(0xFFF97316),
                          label: l10n.transFat,
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(fp.transFat),
                          onSaved: (v) =>
                              fp.setTransFat(double.tryParse(v ?? '') ?? 0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildNutritionCard(
                          icon: Icons.favorite_outline,
                          color: const Color(0xFFDC2626),
                          label: l10n.cholesterol,
                          suffix: 'mg',
                          compact: true,
                          initialValue: _editVal(fp.cholesterol),
                          onSaved: (v) =>
                              fp.setCholesterol(double.tryParse(v ?? '') ?? 0),
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
                          label: l10n.salt,
                          suffix: l10n.gram,
                          compact: true,
                          initialValue: _editVal(fp.salt),
                          onSaved: (v) =>
                              fp.setSalt(double.tryParse(v ?? '') ?? 0),
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
                    label: l10n.additionalInfo,
                  ),
                  const SizedBox(height: 12),

                  // Nutri-Score & NOVA Group row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel(l10n.nutriScore),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: fp.nutriScore,
                              isExpanded: true,
                              decoration: _styledInputDecoration(
                                prefixIcon: Icons.grade_outlined,
                                hintText: l10n.optional,
                              ),
                              items: ['A', 'B', 'C', 'D', 'E']
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) => fp.setNutriScore(v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel(l10n.novaGroup),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              initialValue: fp.novaGroup,
                              isExpanded: true,
                              decoration: _styledInputDecoration(
                                prefixIcon: Icons.science_outlined,
                                hintText: l10n.optional,
                              ),
                              items: [1, 2, 3, 4]
                                  .map((n) => DropdownMenuItem(
                                      value: n, child: Text('$n')))
                                  .toList(),
                              onChanged: (v) => fp.setNovaGroup(v),
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
                            _buildSectionLabel(l10n.servingSize),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _isEditing && fp.servingSize != null
                                  ? fp.servingSize!.toStringAsFixed(0)
                                  : null,
                              decoration: _styledInputDecoration(
                                hintText: l10n.optional,
                                prefixIcon: Icons.scale_outlined,
                                suffixText: UnitConverter.isVolumeUnit(fp.unit) ? 'mL' : 'g',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) {
                                if (v == null || v.isEmpty) return null;
                                if (double.tryParse(v) == null) {
                                  return l10n.invalid;
                                }
                                return null;
                              },
                              onSaved: (v) => fp.setServingSize(
                                  (v != null && v.isNotEmpty)
                                      ? double.tryParse(v)
                                      : null),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel(l10n.origin),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _isEditing ? (fp.origin ?? '') : null,
                              decoration: _styledInputDecoration(
                                hintText: l10n.optional,
                                prefixIcon: Icons.public_outlined,
                              ),
                              onSaved: (v) => fp.setOrigin(v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ingredients text field
                  _buildSectionLabel(l10n.ingredients),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _isEditing ? (fp.ingredientsText ?? '') : null,
                    decoration: _styledInputDecoration(
                      hintText: l10n.ingredientsListOptional,
                      prefixIcon: Icons.receipt_long_outlined,
                    ),
                    maxLines: 3,
                    onSaved: (v) => fp.setIngredientsText(v),
                  ),
                  const SizedBox(height: 16),

                  // Allergens
                  _buildSectionLabel(l10n.allergens),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: {
                      'Gluten': l10n.allergenGluten,
                      'Peanuts': l10n.allergenPeanuts,
                      'Tree Nuts': l10n.allergenTreeNuts,
                      'Milk': l10n.allergenMilk,
                      'Eggs': l10n.allergenEggs,
                      'Fish': l10n.allergenFish,
                      'Shellfish': l10n.allergenShellfish,
                      'Soy': l10n.allergenSoy,
                      'Sesame': l10n.allergenSesame,
                    }
                        .entries
                        .map(
                          (entry) {
                            final allergen = entry.key;
                            final label = entry.value;
                            return FilterChip(
                            label: Text(label),
                            selected: fp.allergens.contains(allergen),
                            onSelected: (_) => fp.toggleAllergen(allergen),
                            selectedColor:
                                AppTheme.primaryColor.withValues(alpha: 0.2),
                            checkmarkColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              color: fp.allergens.contains(allergen)
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondary,
                              fontWeight: fp.allergens.contains(allergen)
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                            backgroundColor: AppTheme.warmCream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                              side: BorderSide(
                                color: fp.allergens.contains(allergen)
                                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                    : AppTheme.warmBeige,
                              ),
                            ),
                          );
                          },
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
                        Expanded(
                          child: Text(
                            l10n.vegan,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: fp.isVegan,
                          onChanged: (v) => fp.setIsVegan(v),
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
                        Expanded(
                          child: Text(
                            l10n.vegetarian,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: fp.isVegetarian,
                          onChanged: (v) => fp.setIsVegetarian(v),
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
                        Expanded(
                          child: Text(
                            l10n.glutenFree,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: fp.isGlutenFree,
                          onChanged: (v) => fp.setIsGlutenFree(v),
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
