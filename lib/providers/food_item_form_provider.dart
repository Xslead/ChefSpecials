import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../utils/unit_converter.dart';

const List<String> foodItemCategories = [
  'Protein',
  'Dairy',
  'Grains',
  'Vegetables',
  'Fruits',
  'Oils & Fats',
  'Beverages',
  'Other',
];

const List<String> foodItemUnits = [
  '100g',
  '100mL',
  'oz',
  'lb',
  'kg',
  'cups',
  'tbsp',
  'tsp',
  'fl oz',
  'L',
];

class FoodItemFormProvider extends ChangeNotifier {
  FoodItemFormProvider();

  // Basic info
  String _name = '';
  String? _brand;
  String _category = foodItemCategories.first;
  String _unit = foodItemUnits.first;
  double _packetSize = 100;
  String? _barcode;

  // Dietary flags
  bool _isVegan = false;
  bool _isVegetarian = false;
  bool _isGlutenFree = false;

  // Nutrition per selected unit
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

  // Additional info
  String? _nutriScore;
  int? _novaGroup;
  List<String> _allergens = [];
  String? _ingredientsText;
  String? _origin;
  double? _servingSize;

  // Submission state
  bool _isSubmitting = false;
  String? _error;

  // --- Getters ---
  String get name => _name;
  String? get brand => _brand;
  String get category => _category;
  String get unit => _unit;
  double get packetSize => _packetSize;
  String? get barcode => _barcode;
  bool get isVegan => _isVegan;
  bool get isVegetarian => _isVegetarian;
  bool get isGlutenFree => _isGlutenFree;
  double get calories => _calories;
  double get protein => _protein;
  double get carbs => _carbs;
  double get fat => _fat;
  double get saturatedFat => _saturatedFat;
  double get transFat => _transFat;
  double get cholesterol => _cholesterol;
  double get fiber => _fiber;
  double get sugar => _sugar;
  double get sodium => _sodium;
  double get salt => _salt;
  String? get nutriScore => _nutriScore;
  int? get novaGroup => _novaGroup;
  List<String> get allergens => List.unmodifiable(_allergens);
  String? get ingredientsText => _ingredientsText;
  String? get origin => _origin;
  double? get servingSize => _servingSize;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  bool get isBaseUnit => _unit == '100g' || _unit == '100mL';

  // --- Setters ---
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setBrand(String? value) {
    _brand = (value != null && value.isNotEmpty) ? value : null;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    if (value == 'Beverages') {
      _unit = '100mL';
    }
    notifyListeners();
  }

  void setUnit(String value) {
    _unit = value;
    notifyListeners();
  }

  void setPacketSize(double value) {
    _packetSize = value;
    notifyListeners();
  }

  void setBarcode(String? value) {
    _barcode = (value != null && value.isNotEmpty) ? value : null;
    notifyListeners();
  }

  void setIsVegan(bool value) {
    _isVegan = value;
    notifyListeners();
  }

  void setIsVegetarian(bool value) {
    _isVegetarian = value;
    notifyListeners();
  }

  void setIsGlutenFree(bool value) {
    _isGlutenFree = value;
    notifyListeners();
  }

  void setCalories(double value) {
    _calories = value;
    notifyListeners();
  }

  void setProtein(double value) {
    _protein = value;
    notifyListeners();
  }

  void setCarbs(double value) {
    _carbs = value;
    notifyListeners();
  }

  void setFat(double value) {
    _fat = value;
    notifyListeners();
  }

  void setSaturatedFat(double value) {
    _saturatedFat = value;
    notifyListeners();
  }

  void setTransFat(double value) {
    _transFat = value;
    notifyListeners();
  }

  void setCholesterol(double value) {
    _cholesterol = value;
    notifyListeners();
  }

  void setFiber(double value) {
    _fiber = value;
    notifyListeners();
  }

  void setSugar(double value) {
    _sugar = value;
    notifyListeners();
  }

  void setSodium(double value) {
    _sodium = value;
    notifyListeners();
  }

  void setSalt(double value) {
    _salt = value;
    notifyListeners();
  }

  void setNutriScore(String? value) {
    _nutriScore = value;
    notifyListeners();
  }

  void setNovaGroup(int? value) {
    _novaGroup = value;
    notifyListeners();
  }

  void setIngredientsText(String? value) {
    _ingredientsText = (value != null && value.isNotEmpty) ? value : null;
    notifyListeners();
  }

  void setOrigin(String? value) {
    _origin = (value != null && value.isNotEmpty) ? value : null;
    notifyListeners();
  }

  void setServingSize(double? value) {
    _servingSize = value;
    notifyListeners();
  }

  void setIsSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // --- Allergen toggling ---
  void toggleAllergen(String allergen) {
    if (_allergens.contains(allergen)) {
      _allergens = _allergens.where((a) => a != allergen).toList();
    } else {
      _allergens = [..._allergens, allergen];
    }
    notifyListeners();
  }

  // --- Unit conversion ---
  double conversionFactor() {
    if (isBaseUnit) return 1.0;
    final isVolume = UnitConverter.isVolumeUnit(_unit);
    double unitInBase;
    if (isVolume) {
      switch (_unit) {
        case 'mL':
          unitInBase = 1;
          break;
        case 'L':
          unitInBase = 1000;
          break;
        case 'cups':
          unitInBase = 236.588;
          break;
        case 'tbsp':
          unitInBase = 14.787;
          break;
        case 'tsp':
          unitInBase = 4.929;
          break;
        case 'fl oz':
          unitInBase = 29.5735;
          break;
        default:
          unitInBase = 1;
          break;
      }
    } else {
      switch (_unit) {
        case 'g':
          unitInBase = 1;
          break;
        case 'kg':
          unitInBase = 1000;
          break;
        case 'oz':
          unitInBase = 28.3495;
          break;
        case 'lb':
          unitInBase = 453.592;
          break;
        default:
          unitInBase = 1;
          break;
      }
    }
    return 100.0 / unitInBase;
  }

  // --- Load from existing FoodItem (edit mode) ---
  void loadFromFoodItem(FoodItem item) {
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
    notifyListeners();
  }

  // --- Build FoodItem from form state ---
  FoodItem buildFoodItem({
    required String userId,
    FoodItem? existingItem,
  }) {
    final factor = conversionFactor();
    final storedUnit = isBaseUnit
        ? _unit
        : (UnitConverter.isVolumeUnit(_unit) ? '100mL' : '100g');

    return FoodItem(
      id: existingItem?.id,
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
      imageUrl: existingItem?.imageUrl,
      addedBy: existingItem?.addedBy ?? userId,
      createdAt: existingItem?.createdAt ?? DateTime.now(),
      isVerified: existingItem?.isVerified ?? false,
    );
  }

  void reset() {
    _name = '';
    _brand = null;
    _category = foodItemCategories.first;
    _unit = foodItemUnits.first;
    _packetSize = 100;
    _barcode = null;
    _isVegan = false;
    _isVegetarian = false;
    _isGlutenFree = false;
    _calories = 0;
    _protein = 0;
    _carbs = 0;
    _fat = 0;
    _saturatedFat = 0;
    _transFat = 0;
    _cholesterol = 0;
    _fiber = 0;
    _sugar = 0;
    _sodium = 0;
    _salt = 0;
    _nutriScore = null;
    _novaGroup = null;
    _allergens = [];
    _ingredientsText = null;
    _origin = null;
    _servingSize = null;
    _isSubmitting = false;
    _error = null;
    notifyListeners();
  }
}
