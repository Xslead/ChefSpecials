class AppConstants {
  static const String appName = 'ChefSpecials';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String recipesCollection = 'recipes';
  static const String favoritesCollection = 'favorites';
  static const String categoriesCollection = 'categories';

  // Storage paths
  static const String recipeImagesPath = 'recipe_images';
  static const String userAvatarsPath = 'user_avatars';

  // Recipe categories
  static const List<String> defaultCategories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Drink',
    'Salad',
    'Soup',
  ];
}
