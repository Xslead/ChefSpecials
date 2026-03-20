import '../l10n/generated/app_localizations.dart';

String localizeCategory(String category, AppLocalizations l10n) {
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

String localizeDietaryTag(String tag, AppLocalizations l10n) {
  switch (tag) {
    case 'Vegan':
      return l10n.vegan;
    case 'Vegetarian':
      return l10n.vegetarian;
    case 'Gluten Free':
      return l10n.glutenFree;
    case 'Dairy Free':
      return l10n.dairyFree;
    case 'Keto':
      return l10n.keto;
    case 'Low Carb':
      return l10n.lowCarb;
    case 'Halal':
      return l10n.halal;
    default:
      return tag;
  }
}

String localizeFoodCategory(String category, AppLocalizations l10n) {
  switch (category) {
    case 'Protein':
      return l10n.protein;
    case 'Dairy':
      return l10n.foodCategoryDairy;
    case 'Grains':
      return l10n.foodCategoryGrains;
    case 'Vegetables':
      return l10n.foodCategoryVegetables;
    case 'Fruits':
      return l10n.foodCategoryFruits;
    case 'Oils & Fats':
      return l10n.foodCategoryOilsFats;
    case 'Beverages':
      return l10n.foodCategoryBeverages;
    case 'Other':
      return l10n.foodCategoryOther;
    default:
      return category;
  }
}
