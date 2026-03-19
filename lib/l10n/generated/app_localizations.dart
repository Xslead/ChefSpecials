import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ChefSpecials'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipe;

  /// No description provided for @recipeName.
  ///
  /// In en, this message translates to:
  /// **'Recipe Name'**
  String get recipeName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep Time'**
  String get prepTime;

  /// No description provided for @cookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook Time'**
  String get cookTime;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @startCooking.
  ///
  /// In en, this message translates to:
  /// **'Start Cooking'**
  String get startCooking;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @noRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipes;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchHint;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @myRecipes.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get myRecipes;

  /// No description provided for @dailyTracker.
  ///
  /// In en, this message translates to:
  /// **'Daily Tracker'**
  String get dailyTracker;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFood;

  /// No description provided for @addRecipeToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipeToMeal;

  /// No description provided for @nutritionGoals.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goals'**
  String get nutritionGoals;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummary;

  /// No description provided for @calorieTarget.
  ///
  /// In en, this message translates to:
  /// **'Calorie Target'**
  String get calorieTarget;

  /// No description provided for @proteinTarget.
  ///
  /// In en, this message translates to:
  /// **'Protein Target'**
  String get proteinTarget;

  /// No description provided for @carbsTarget.
  ///
  /// In en, this message translates to:
  /// **'Carbs Target'**
  String get carbsTarget;

  /// No description provided for @fatTarget.
  ///
  /// In en, this message translates to:
  /// **'Fat Target'**
  String get fatTarget;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @gram.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get gram;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'mL'**
  String get ml;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @selectFoodItem.
  ///
  /// In en, this message translates to:
  /// **'Select Food Item'**
  String get selectFoodItem;

  /// No description provided for @selectRecipe.
  ///
  /// In en, this message translates to:
  /// **'Select Recipe'**
  String get selectRecipe;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// No description provided for @noMealsYet.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet'**
  String get noMealsYet;

  /// No description provided for @addToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal'**
  String get addToMeal;

  /// No description provided for @goalsSaved.
  ///
  /// In en, this message translates to:
  /// **'Goals saved'**
  String get goalsSaved;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @exceeded.
  ///
  /// In en, this message translates to:
  /// **'Exceeded'**
  String get exceeded;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofLabel;

  /// No description provided for @dessert.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get dessert;

  /// No description provided for @drink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get drink;

  /// No description provided for @salad.
  ///
  /// In en, this message translates to:
  /// **'Salad'**
  String get salad;

  /// No description provided for @soup.
  ///
  /// In en, this message translates to:
  /// **'Soup'**
  String get soup;

  /// No description provided for @searchRecipeOrIngredient.
  ///
  /// In en, this message translates to:
  /// **'Search recipe or ingredient...'**
  String get searchRecipeOrIngredient;

  /// No description provided for @minuteShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minuteShort;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @consumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumed;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @remainingKcal.
  ///
  /// In en, this message translates to:
  /// **'Remaining kcal'**
  String get remainingKcal;

  /// No description provided for @todaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todaysMeals;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @itemsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} items added'**
  String itemsAdded(Object count);

  /// No description provided for @notAddedYet.
  ///
  /// In en, this message translates to:
  /// **'Not added yet'**
  String get notAddedYet;

  /// No description provided for @waterTracking.
  ///
  /// In en, this message translates to:
  /// **'Water Tracking'**
  String get waterTracking;

  /// No description provided for @carbsShort.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbsShort;

  /// No description provided for @waterTarget.
  ///
  /// In en, this message translates to:
  /// **'Water Target'**
  String get waterTarget;

  /// No description provided for @recipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String recipeCount(Object count);

  /// No description provided for @searchFoodItems.
  ///
  /// In en, this message translates to:
  /// **'Search food items...'**
  String get searchFoodItems;

  /// No description provided for @noFoodItems.
  ///
  /// In en, this message translates to:
  /// **'No food items yet'**
  String get noFoodItems;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @per100.
  ///
  /// In en, this message translates to:
  /// **'per 100g'**
  String get per100;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(Object count);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(Object date);

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @deleteRating.
  ///
  /// In en, this message translates to:
  /// **'Delete Rating'**
  String get deleteRating;

  /// No description provided for @ratingsAndComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get ratingsAndComments;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first!'**
  String get noComments;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get yourRating;

  /// No description provided for @tapToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap to rate'**
  String get tapToRate;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this comment?'**
  String get deleteCommentConfirm;

  /// No description provided for @ratingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ratings'**
  String ratingCount(int count);

  /// No description provided for @commentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} comments'**
  String commentCount(int count);

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @feedComingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See what the people you follow are cooking.'**
  String get feedComingSoonSubtitle;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @privateDescription.
  ///
  /// In en, this message translates to:
  /// **'Only you can see this recipe.'**
  String get privateDescription;

  /// No description provided for @publicDescription.
  ///
  /// In en, this message translates to:
  /// **'Everyone can see this recipe.'**
  String get publicDescription;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @noFollowing.
  ///
  /// In en, this message translates to:
  /// **'You\'re not following anyone yet'**
  String get noFollowing;

  /// No description provided for @noFollowingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore recipes and follow people to see their latest posts here.'**
  String get noFollowingSubtitle;

  /// No description provided for @noFeedRecipes.
  ///
  /// In en, this message translates to:
  /// **'No new recipes from people you follow.'**
  String get noFeedRecipes;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameTooShort;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken'**
  String get usernameTaken;

  /// No description provided for @usernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'Username is available'**
  String get usernameAvailable;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @searchFeedHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes or @username...'**
  String get searchFeedHint;

  /// No description provided for @dietaryTags.
  ///
  /// In en, this message translates to:
  /// **'Dietary Tags'**
  String get dietaryTags;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @glutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten Free'**
  String get glutenFree;

  /// No description provided for @dairyFree.
  ///
  /// In en, this message translates to:
  /// **'Dairy Free'**
  String get dairyFree;

  /// No description provided for @keto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get keto;

  /// No description provided for @lowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get lowCarb;

  /// No description provided for @halal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get halal;

  /// No description provided for @shoppingLists.
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get shoppingLists;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @addToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Add to Shopping List'**
  String get addToShoppingList;

  /// No description provided for @newList.
  ///
  /// In en, this message translates to:
  /// **'New List'**
  String get newList;

  /// No description provided for @listName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listName;

  /// No description provided for @clearChecked.
  ///
  /// In en, this message translates to:
  /// **'Clear Checked'**
  String get clearChecked;

  /// No description provided for @noShoppingLists.
  ///
  /// In en, this message translates to:
  /// **'No shopping lists yet'**
  String get noShoppingLists;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @itemsChecked.
  ///
  /// In en, this message translates to:
  /// **'checked'**
  String get itemsChecked;

  /// No description provided for @createNewList.
  ///
  /// In en, this message translates to:
  /// **'Create New List'**
  String get createNewList;

  /// No description provided for @addedToList.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedToList(String name);

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get deleteList;

  /// No description provided for @deleteListConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this list?'**
  String get deleteListConfirm;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @newCollection.
  ///
  /// In en, this message translates to:
  /// **'New Collection'**
  String get newCollection;

  /// No description provided for @collectionName.
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get collectionName;

  /// No description provided for @collectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get collectionDescription;

  /// No description provided for @noCollections.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get noCollections;

  /// No description provided for @deleteCollection.
  ///
  /// In en, this message translates to:
  /// **'Delete Collection'**
  String get deleteCollection;

  /// No description provided for @deleteCollectionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this collection?'**
  String get deleteCollectionConfirm;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to Collection'**
  String get addToCollection;

  /// No description provided for @removeFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Remove from Collection'**
  String get removeFromCollection;

  /// No description provided for @createNewCollection.
  ///
  /// In en, this message translates to:
  /// **'Create New Collection'**
  String get createNewCollection;

  /// No description provided for @addedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedToCollection(String name);

  /// No description provided for @removedFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Removed from {name}'**
  String removedFromCollection(String name);

  /// No description provided for @recipeCountInCollection.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String recipeCountInCollection(int count);

  /// No description provided for @emptyCollection.
  ///
  /// In en, this message translates to:
  /// **'No recipes in this collection'**
  String get emptyCollection;

  /// No description provided for @emptyCollectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add recipes from the recipe detail screen'**
  String get emptyCollectionSubtitle;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @applyFiltersCount.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters ({count})'**
  String applyFiltersCount(int count);

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on recipes to save them here'**
  String get favoritesEmptySubtitle;

  /// No description provided for @shoppingListEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients from any recipe to get started'**
  String get shoppingListEmptySubtitle;

  /// No description provided for @importRecipe.
  ///
  /// In en, this message translates to:
  /// **'Import Recipe'**
  String get importRecipe;

  /// No description provided for @importFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Import from URL'**
  String get importFromUrl;

  /// No description provided for @importUrlDescription.
  ///
  /// In en, this message translates to:
  /// **'Paste a link from any recipe website and we\'ll fill in the details for you.'**
  String get importUrlDescription;

  /// No description provided for @recipeUrl.
  ///
  /// In en, this message translates to:
  /// **'Recipe URL'**
  String get recipeUrl;

  /// No description provided for @importUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://www.example.com/recipe/...'**
  String get importUrlHint;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t import a recipe from this URL. Make sure it\'s a recipe website.'**
  String get importError;

  /// No description provided for @supportedSites.
  ///
  /// In en, this message translates to:
  /// **'Supported Sites'**
  String get supportedSites;

  /// No description provided for @shareRecipe.
  ///
  /// In en, this message translates to:
  /// **'Share Recipe'**
  String get shareRecipe;

  /// No description provided for @shareRecipeText.
  ///
  /// In en, this message translates to:
  /// **'Check out \"{title}\" by {author} on ChefSpecials!\n\n{ingredients}\n\nOpen in ChefSpecials:\n{link}'**
  String shareRecipeText(
    String title,
    String author,
    String ingredients,
    String link,
  );

  /// No description provided for @mealPlanner.
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get mealPlanner;

  /// No description provided for @weekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String weekOf(String date);

  /// No description provided for @copyFromLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Copy from Last Week'**
  String get copyFromLastWeek;

  /// No description provided for @generateShoppingListFromPlan.
  ///
  /// In en, this message translates to:
  /// **'Generate Shopping List'**
  String get generateShoppingListFromPlan;

  /// No description provided for @addMealToSlot.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMealToSlot;

  /// No description provided for @removeMeal.
  ///
  /// In en, this message translates to:
  /// **'Remove Meal'**
  String get removeMeal;

  /// No description provided for @weeklyNutritionSummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Nutrition'**
  String get weeklyNutritionSummary;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @noMealsPlanned.
  ///
  /// In en, this message translates to:
  /// **'No meals planned'**
  String get noMealsPlanned;

  /// No description provided for @mealPlanServings.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String mealPlanServings(int count);

  /// No description provided for @mealPlanSaved.
  ///
  /// In en, this message translates to:
  /// **'Meal plan saved'**
  String get mealPlanSaved;

  /// No description provided for @copiedFromLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Copied from last week'**
  String get copiedFromLastWeek;

  /// No description provided for @noMealPlanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'No meal plan found for last week'**
  String get noMealPlanLastWeek;

  /// No description provided for @copyWeek.
  ///
  /// In en, this message translates to:
  /// **'Copy this week'**
  String get copyWeek;

  /// No description provided for @pasteWeek.
  ///
  /// In en, this message translates to:
  /// **'Paste meals here'**
  String get pasteWeek;

  /// No description provided for @weekCopied.
  ///
  /// In en, this message translates to:
  /// **'Week meals copied'**
  String get weekCopied;

  /// No description provided for @weekPasted.
  ///
  /// In en, this message translates to:
  /// **'Meals pasted to this week'**
  String get weekPasted;

  /// No description provided for @noMealsToCopy.
  ///
  /// In en, this message translates to:
  /// **'No meals to copy this week'**
  String get noMealsToCopy;

  /// No description provided for @noCopiedMeals.
  ///
  /// In en, this message translates to:
  /// **'Copy a week first'**
  String get noCopiedMeals;

  /// No description provided for @shoppingListCreated.
  ///
  /// In en, this message translates to:
  /// **'Shopping list created'**
  String get shoppingListCreated;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @averageDailyIntake.
  ///
  /// In en, this message translates to:
  /// **'Average Daily Intake'**
  String get averageDailyIntake;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String currentStreak(int count);

  /// No description provided for @macroDistribution.
  ///
  /// In en, this message translates to:
  /// **'Macro Distribution'**
  String get macroDistribution;

  /// No description provided for @exportAsImage.
  ///
  /// In en, this message translates to:
  /// **'Export as Image'**
  String get exportAsImage;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noDataForPeriod;

  /// No description provided for @avgCalories.
  ///
  /// In en, this message translates to:
  /// **'Avg Calories'**
  String get avgCalories;

  /// No description provided for @avgProtein.
  ///
  /// In en, this message translates to:
  /// **'Avg Protein'**
  String get avgProtein;

  /// No description provided for @avgCarbs.
  ///
  /// In en, this message translates to:
  /// **'Avg Carbs'**
  String get avgCarbs;

  /// No description provided for @avgFat.
  ///
  /// In en, this message translates to:
  /// **'Avg Fat'**
  String get avgFat;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @mealReminders.
  ///
  /// In en, this message translates to:
  /// **'Meal Reminders'**
  String get mealReminders;

  /// No description provided for @socialAlerts.
  ///
  /// In en, this message translates to:
  /// **'Social Alerts'**
  String get socialAlerts;

  /// No description provided for @breakfastReminder.
  ///
  /// In en, this message translates to:
  /// **'Breakfast Reminder'**
  String get breakfastReminder;

  /// No description provided for @lunchReminder.
  ///
  /// In en, this message translates to:
  /// **'Lunch Reminder'**
  String get lunchReminder;

  /// No description provided for @dinnerReminder.
  ///
  /// In en, this message translates to:
  /// **'Dinner Reminder'**
  String get dinnerReminder;

  /// No description provided for @newRecipeAlerts.
  ///
  /// In en, this message translates to:
  /// **'New Recipes from Followed Users'**
  String get newRecipeAlerts;

  /// No description provided for @commentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Comments on My Recipes'**
  String get commentAlerts;

  /// No description provided for @followerAlerts.
  ///
  /// In en, this message translates to:
  /// **'New Followers'**
  String get followerAlerts;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled'**
  String get notificationsDisabled;

  /// No description provided for @notificationsDisabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in your phone settings to receive meal reminders and alerts.'**
  String get notificationsDisabledDescription;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get markAllRead;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get noAnnouncements;

  /// No description provided for @activityFollow.
  ///
  /// In en, this message translates to:
  /// **'{name} started following you'**
  String activityFollow(String name);

  /// No description provided for @activityComment.
  ///
  /// In en, this message translates to:
  /// **'{name} commented on {recipe}'**
  String activityComment(String name, String recipe);

  /// No description provided for @activityRating.
  ///
  /// In en, this message translates to:
  /// **'{name} rated {recipe}'**
  String activityRating(String name, String recipe);

  /// No description provided for @activityNewRecipe.
  ///
  /// In en, this message translates to:
  /// **'{name} posted {recipe}'**
  String activityNewRecipe(String name, String recipe);

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @timeForMeal.
  ///
  /// In en, this message translates to:
  /// **'Time for {meal}!'**
  String timeForMeal(String meal);

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @recipeModeration.
  ///
  /// In en, this message translates to:
  /// **'Recipe Moderation'**
  String get recipeModeration;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagement;

  /// No description provided for @adminAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get adminAnnouncements;

  /// No description provided for @banAppeals.
  ///
  /// In en, this message translates to:
  /// **'Ban Appeals'**
  String get banAppeals;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get auditLog;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @totalRecipes.
  ///
  /// In en, this message translates to:
  /// **'Total Recipes'**
  String get totalRecipes;

  /// No description provided for @totalComments.
  ///
  /// In en, this message translates to:
  /// **'Total Comments'**
  String get totalComments;

  /// No description provided for @activeToday.
  ///
  /// In en, this message translates to:
  /// **'Active Today'**
  String get activeToday;

  /// No description provided for @banUser.
  ///
  /// In en, this message translates to:
  /// **'Ban User'**
  String get banUser;

  /// No description provided for @unbanUser.
  ///
  /// In en, this message translates to:
  /// **'Unban User'**
  String get unbanUser;

  /// No description provided for @promoteToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Promote to Admin'**
  String get promoteToAdmin;

  /// No description provided for @demoteToUser.
  ///
  /// In en, this message translates to:
  /// **'Demote to User'**
  String get demoteToUser;

  /// No description provided for @banned.
  ///
  /// In en, this message translates to:
  /// **'Banned'**
  String get banned;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @banReason.
  ///
  /// In en, this message translates to:
  /// **'Ban Reason'**
  String get banReason;

  /// No description provided for @enterBanReason.
  ///
  /// In en, this message translates to:
  /// **'Enter the reason for banning this user'**
  String get enterBanReason;

  /// No description provided for @confirmBan.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to ban this user?'**
  String get confirmBan;

  /// No description provided for @confirmUnban.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unban this user?'**
  String get confirmUnban;

  /// No description provided for @confirmPromote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to promote this user to admin?'**
  String get confirmPromote;

  /// No description provided for @confirmDemote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to demote this user?'**
  String get confirmDemote;

  /// No description provided for @recipeCategories.
  ///
  /// In en, this message translates to:
  /// **'Recipe Categories'**
  String get recipeCategories;

  /// No description provided for @foodItemCategories.
  ///
  /// In en, this message translates to:
  /// **'Food Item Categories'**
  String get foodItemCategories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get enterCategoryName;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get confirmDeleteCategory;

  /// No description provided for @createAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Create Announcement'**
  String get createAnnouncement;

  /// No description provided for @announcementTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get announcementTitle;

  /// No description provided for @announcementBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get announcementBody;

  /// No description provided for @confirmDeleteAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this announcement?'**
  String get confirmDeleteAnnouncement;

  /// No description provided for @pendingAppeals.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingAppeals;

  /// No description provided for @allAppeals.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allAppeals;

  /// No description provided for @approveAppeal.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveAppeal;

  /// No description provided for @rejectAppeal.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectAppeal;

  /// No description provided for @reviewNote.
  ///
  /// In en, this message translates to:
  /// **'Review Note'**
  String get reviewNote;

  /// No description provided for @confirmApproveAppeal.
  ///
  /// In en, this message translates to:
  /// **'Approve this appeal and unban the user?'**
  String get confirmApproveAppeal;

  /// No description provided for @confirmRejectAppeal.
  ///
  /// In en, this message translates to:
  /// **'Reject this appeal?'**
  String get confirmRejectAppeal;

  /// No description provided for @appealSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your appeal has been submitted'**
  String get appealSubmitted;

  /// No description provided for @submitAppeal.
  ///
  /// In en, this message translates to:
  /// **'Submit Appeal'**
  String get submitAppeal;

  /// No description provided for @appealText.
  ///
  /// In en, this message translates to:
  /// **'Explain why your ban should be lifted...'**
  String get appealText;

  /// No description provided for @accountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Account Suspended'**
  String get accountSuspended;

  /// No description provided for @accountSuspendedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended for violating our community guidelines.'**
  String get accountSuspendedMessage;

  /// No description provided for @appealUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Appeal Under Review'**
  String get appealUnderReview;

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsers;

  /// No description provided for @noAppeals.
  ///
  /// In en, this message translates to:
  /// **'No appeals'**
  String get noAppeals;

  /// No description provided for @noAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'No audit logs'**
  String get noAuditLogs;

  /// No description provided for @deleteRecipeConfirmAdmin.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe? This action cannot be undone.'**
  String get deleteRecipeConfirmAdmin;

  /// No description provided for @viewRecipes.
  ///
  /// In en, this message translates to:
  /// **'View Recipes'**
  String get viewRecipes;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchRecipes;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String by(String name);

  /// No description provided for @activityAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'{title}'**
  String activityAnnouncement(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
