class AppConstants {
  static const String appName = 'ChefSpecials';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String recipesCollection = 'recipes';
  static const String favoritesCollection = 'favorites';
  static const String categoriesCollection = 'categories';

  static const String adminLogsCollection = 'admin_logs';
  static const String appealsCollection = 'appeals';
  static const String announcementsCollection = 'announcements';
  static const String activitiesCollection = 'activities';
  static const String commentsCollection = 'comments';
  static const String ratingsCollection = 'ratings';
  static const String foodItemsCollection = 'food_items';
  static const String substitutionsCollection = 'substitutions';

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

  // Dietary tags
  static const List<String> defaultDietaryTags = [
    'Vegan',
    'Vegetarian',
    'Gluten Free',
    'Dairy Free',
    'Keto',
    'Low Carb',
    'Halal',
  ];

  // Seasonal tags (stored alongside dietaryTags on a Recipe)
  static const List<String> defaultSeasonalTags = [
    'Spring',
    'Summer',
    'Autumn',
    'Winter',
  ];
}
