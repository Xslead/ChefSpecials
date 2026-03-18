// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ChefSpecials';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get logout => 'Logout';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get favorites => 'Favorites';

  @override
  String get profile => 'Profile';

  @override
  String get addRecipe => 'Add Recipe';

  @override
  String get recipeName => 'Recipe Name';

  @override
  String get description => 'Description';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get steps => 'Steps';

  @override
  String get category => 'Category';

  @override
  String get servings => 'Servings';

  @override
  String get prepTime => 'Prep Time';

  @override
  String get cookTime => 'Cook Time';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get startCooking => 'Start Cooking';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get noRecipes => 'No recipes yet';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get searchHint => 'Search recipes...';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Turkish';

  @override
  String get myRecipes => 'My Recipes';

  @override
  String get dailyTracker => 'Daily Tracker';

  @override
  String get materials => 'Materials';

  @override
  String get sortBy => 'Sort by';

  @override
  String get newest => 'Newest';

  @override
  String get oldest => 'Oldest';

  @override
  String get all => 'All';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get addFood => 'Add Food';

  @override
  String get addRecipeToMeal => 'Add Recipe';

  @override
  String get nutritionGoals => 'Nutrition Goals';

  @override
  String get dailySummary => 'Daily Summary';

  @override
  String get calorieTarget => 'Calorie Target';

  @override
  String get proteinTarget => 'Protein Target';

  @override
  String get carbsTarget => 'Carbs Target';

  @override
  String get fatTarget => 'Fat Target';

  @override
  String get kcal => 'kcal';

  @override
  String get gram => 'g';

  @override
  String get ml => 'mL';

  @override
  String get quantity => 'Quantity';

  @override
  String get selectFoodItem => 'Select Food Item';

  @override
  String get selectRecipe => 'Select Recipe';

  @override
  String get mealType => 'Meal Type';

  @override
  String get noMealsYet => 'No meals logged yet';

  @override
  String get addToMeal => 'Add to Meal';

  @override
  String get goalsSaved => 'Goals saved';

  @override
  String get today => 'Today';

  @override
  String get remaining => 'Remaining';

  @override
  String get exceeded => 'Exceeded';

  @override
  String get ofLabel => 'of';

  @override
  String get dessert => 'Dessert';

  @override
  String get drink => 'Drink';

  @override
  String get salad => 'Salad';

  @override
  String get soup => 'Soup';

  @override
  String get searchRecipeOrIngredient => 'Search recipe or ingredient...';

  @override
  String get minuteShort => 'min';

  @override
  String get popular => 'Popular';

  @override
  String get consumed => 'Consumed';

  @override
  String get target => 'Target';

  @override
  String get remainingKcal => 'Remaining kcal';

  @override
  String get todaysMeals => 'Today\'s Meals';

  @override
  String get viewAll => 'View All';

  @override
  String itemsAdded(Object count) {
    return '$count items added';
  }

  @override
  String get notAddedYet => 'Not added yet';

  @override
  String get waterTracking => 'Water Tracking';

  @override
  String get carbsShort => 'Carbs';

  @override
  String get waterTarget => 'Water Target';

  @override
  String recipeCount(Object count) {
    return '$count recipes';
  }

  @override
  String get searchFoodItems => 'Search food items...';

  @override
  String get noFoodItems => 'No food items yet';

  @override
  String get noResults => 'No results found';

  @override
  String get per100 => 'per 100g';

  @override
  String itemCount(Object count) {
    return '$count items';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get bio => 'Bio';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get recipes => 'Recipes';

  @override
  String memberSince(Object date) {
    return 'Member since $date';
  }

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get settings => 'Settings';

  @override
  String get deleteRating => 'Delete Rating';

  @override
  String get ratingsAndComments => 'Comments';

  @override
  String get writeComment => 'Write a comment...';

  @override
  String get send => 'Send';

  @override
  String get noComments => 'No comments yet. Be the first!';

  @override
  String get yourRating => 'Your Rating';

  @override
  String get tapToRate => 'Tap to rate';

  @override
  String get deleteComment => 'Delete Comment';

  @override
  String get deleteCommentConfirm => 'Delete this comment?';

  @override
  String ratingCount(int count) {
    return '$count ratings';
  }

  @override
  String commentCount(int count) {
    return '$count comments';
  }

  @override
  String get feed => 'Feed';

  @override
  String get feedComingSoonSubtitle =>
      'See what the people you follow are cooking.';

  @override
  String get private => 'Private';

  @override
  String get public => 'Public';

  @override
  String get privateDescription => 'Only you can see this recipe.';

  @override
  String get publicDescription => 'Everyone can see this recipe.';

  @override
  String get follow => 'Follow';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get noFollowing => 'You\'re not following anyone yet';

  @override
  String get noFollowingSubtitle =>
      'Explore recipes and follow people to see their latest posts here.';

  @override
  String get noFeedRecipes => 'No new recipes from people you follow.';

  @override
  String get username => 'Username';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get usernameTooShort => 'Username must be at least 3 characters';

  @override
  String get usernameTaken => 'Username is already taken';

  @override
  String get usernameAvailable => 'Username is available';

  @override
  String get people => 'People';

  @override
  String get searchFeedHint => 'Search recipes or @username...';

  @override
  String get dietaryTags => 'Dietary Tags';

  @override
  String get vegan => 'Vegan';

  @override
  String get vegetarian => 'Vegetarian';

  @override
  String get glutenFree => 'Gluten Free';

  @override
  String get dairyFree => 'Dairy Free';

  @override
  String get keto => 'Keto';

  @override
  String get lowCarb => 'Low Carb';

  @override
  String get halal => 'Halal';

  @override
  String get shoppingLists => 'Shopping Lists';

  @override
  String get shoppingList => 'Shopping List';

  @override
  String get addToShoppingList => 'Add to Shopping List';

  @override
  String get newList => 'New List';

  @override
  String get listName => 'List name';

  @override
  String get clearChecked => 'Clear Checked';

  @override
  String get noShoppingLists => 'No shopping lists yet';

  @override
  String get noItems => 'No items';

  @override
  String get itemsChecked => 'checked';

  @override
  String get createNewList => 'Create New List';

  @override
  String addedToList(String name) {
    return 'Added to $name';
  }

  @override
  String get deleteList => 'Delete List';

  @override
  String get deleteListConfirm => 'Are you sure you want to delete this list?';

  @override
  String get collections => 'Collections';

  @override
  String get collection => 'Collection';

  @override
  String get newCollection => 'New Collection';

  @override
  String get collectionName => 'Collection name';

  @override
  String get collectionDescription => 'Description (optional)';

  @override
  String get noCollections => 'No collections yet';

  @override
  String get deleteCollection => 'Delete Collection';

  @override
  String get deleteCollectionConfirm =>
      'Are you sure you want to delete this collection?';

  @override
  String get addToCollection => 'Add to Collection';

  @override
  String get removeFromCollection => 'Remove from Collection';

  @override
  String get createNewCollection => 'Create New Collection';

  @override
  String addedToCollection(String name) {
    return 'Added to $name';
  }

  @override
  String removedFromCollection(String name) {
    return 'Removed from $name';
  }

  @override
  String recipeCountInCollection(int count) {
    return '$count recipes';
  }

  @override
  String get emptyCollection => 'No recipes in this collection';

  @override
  String get emptyCollectionSubtitle =>
      'Add recipes from the recipe detail screen';

  @override
  String get filters => 'Filters';

  @override
  String get clearAll => 'Clear all';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String applyFiltersCount(int count) {
    return 'Apply Filters ($count)';
  }

  @override
  String get favoritesEmptySubtitle =>
      'Tap the heart icon on recipes to save them here';

  @override
  String get shoppingListEmptySubtitle =>
      'Add ingredients from any recipe to get started';

  @override
  String get importRecipe => 'Import Recipe';

  @override
  String get importFromUrl => 'Import from URL';

  @override
  String get importUrlDescription =>
      'Paste a link from any recipe website and we\'ll fill in the details for you.';

  @override
  String get recipeUrl => 'Recipe URL';

  @override
  String get importUrlHint => 'https://www.example.com/recipe/...';

  @override
  String get importButton => 'Import';

  @override
  String get importError =>
      'Couldn\'t import a recipe from this URL. Make sure it\'s a recipe website.';

  @override
  String get supportedSites => 'Supported Sites';

  @override
  String get shareRecipe => 'Share Recipe';

  @override
  String shareRecipeText(
    String title,
    String author,
    String ingredients,
    String link,
  ) {
    return 'Check out \"$title\" by $author on ChefSpecials!\n\n$ingredients\n\nOpen in ChefSpecials:\n$link';
  }
}
