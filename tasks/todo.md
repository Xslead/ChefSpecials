# ChefSpecials — Build Progress

## Push 0: Project Foundation
- [x] CLAUDE.md (project-local, not committed)
- [x] README.md
- [x] .gitignore
- **Status:** PUSHED ✅

---

## Push 1: Project Scaffolding + Firebase + Auth
- [x] Flutter project creation
- [x] Dependencies in pubspec.yaml
- [x] Firebase setup (se380-food-tracker project, apps created, configs generated)
- [x] App theme, constants, routes (GoRouter)
- [x] Models: UserModel
- [x] Services: AuthService, UserService
- [x] Providers: AuthProvider, LocaleProvider
- [x] Screens: LoginScreen, RegisterScreen, HomeScreen (shell)
- [x] Config: main.dart, app.dart, theme.dart, constants.dart, routes.dart
- [x] i18n: app_en.arb, app_tr.arb + generated localizations
- [x] Firestore security rules deployed
- **Status:** PUSHED ✅

---

## Push 2: Recipe CRUD + Home Feed + Nutrition
- [x] Models: Recipe, RecipeStep, Ingredient
- [x] Services: RecipeService, StorageService
- [x] Providers: RecipeProvider, RecipeFormProvider
- [x] Screens: HomeScreen (feed), AddRecipeScreen, RecipeDetailScreen
- [x] Widgets: RecipeCard, CategoryFilterBar, IngredientInputList, StepInputList, ImagePickerTile, IngredientListView, StepOverviewList
- [x] Routes updated (add-recipe, recipe/:id)
- **Status:** PUSHED ✅

---

## Push 3: Cooking Mode (Step-by-Step Pages)
- [x] CookingModeScreen (PageView navigation)
- [x] StepPage widget, CountdownTimerWidget
- [x] Progress indicator (LinearProgressIndicator in AppBar)
- [x] Route: /cooking/:id added to GoRouter
- **Status:** PUSHED ✅

---

## Push 4: Search + Favorites
- [x] Models: Favorite
- [x] Services: FavoriteService
- [x] Providers: FavoriteProvider, SearchProvider
- [x] Screens: SearchScreen, FavoritesScreen
- [x] Heart icon on recipe cards
- **Status:** PUSHED ✅

---

## Push 5: Profile + i18n + Utilities + Polish
- [x] Screens: ProfileScreen, EditProfileScreen
- [x] Utils: validators, image_utils, date_utils
- **Status:** PUSHED ✅

---

## Push 6: Ingredient Database (Materials)
- [x] Model: FoodItem
- [x] Service: FoodItemService (CRUD + search)
- [x] Provider: FoodItemProvider
- [x] Screens: FoodItemListScreen, AddFoodItemScreen, FoodItemDetailScreen
- [x] Widgets: FoodItemCard, NutritionFactsTable
- [x] Seed Firestore with 28 real food items
- [x] Recipe ingredients link to materials database
- [x] Auto-calculate recipe nutrition from ingredient quantities
- **Status:** PUSHED ✅

---

## Push 7: Bottom Navigation + My Recipes
- [x] Bottom Navigation Bar (5 tabs): Home, Feed, Daily Tracker, Materials, Profile
- [x] ShellScreen with StatefulShellRoute.indexedStack
- [x] MyRecipesScreen
- **Status:** PUSHED ✅

---

## Push 8: Daily Tracker + Nutrition Goals
- [x] Models: DailyLog, MealEntry, NutritionGoal
- [x] Services: DailyTrackerService
- [x] Providers: DailyTrackerProvider
- [x] DailyTrackerScreen (redesigned with week navigation, wave water bar, accordion meals)
- [x] Nutrition Goals: set daily calorie/protein/carbs/fat targets
- **Status:** PUSHED ✅

---

## Push 9: Ratings & Comments
- [x] Models: Rating, Comment
- [x] Services: RatingService, CommentService
- [x] Providers: RatingProvider, CommentProvider
- **Status:** PUSHED ✅

---

## Push 10: Recipe Privacy + Social Feed + Follow System
- [x] Recipe Privacy: isPrivate field, visibility toggle
- [x] FollowService, FollowProvider
- [x] FeedScreen: recipes from followed users + user search
- [x] PublicProfileScreen, FollowListScreen
- [x] Username system: unique username field, search by username
- **Status:** PUSHED ✅

---

## Push 11: Dark Mode
- [x] ThemeProvider with light/dark/system modes
- [x] Persist theme preference (SharedPreferences)
- **Status:** PUSHED ✅

---

## Push 12: Dietary Tags
- [x] Dietary tags on Recipe model (Vegan, Gluten-Free, Keto, Halal, etc.)
- [x] Dietary tag picker on AddRecipeScreen
- [x] Filter recipes by dietary tags
- [x] Unified filter sheet (category + dietary tags + sort)
- **Status:** PUSHED ✅

---

## Push 13: Shopping List
- [x] Model: ShoppingList, ShoppingItem
- [x] Service: ShoppingListService
- [x] Provider: ShoppingListProvider
- [x] ShoppingListsScreen, ShoppingListDetailScreen
- [x] Auto-generate shopping list from recipe ingredients
- **Status:** PUSHED ✅

---

## Push 14: Recipe Collections
- [x] Model: RecipeCollection
- [x] Service: CollectionService
- [x] Provider: CollectionProvider
- [x] CollectionListScreen, CollectionDetailScreen
- **Status:** PUSHED ✅

---

## Push 15: Recipe Import
- [x] RecipeImportService (JSON-LD extraction from URLs)
- [x] ImportRecipeScreen with URL input
- **Status:** PUSHED ✅

---

## Push 16: iOS Keychain Fix
- [x] Added GoogleService-Info.plist to Xcode project references + Copy Bundle Resources
- [x] Added Runner.entitlements to Xcode project references
- [x] Fixed Debug.xcconfig missing Generated.xcconfig include
- [x] Fixed Podfile signing config + macOS 26 xattr codesign fix
- **Status:** PUSHED ✅

---

## Push 20: Testing
- [x] **765 tests passing** across all layers (70 files, 12,099 lines)
- [x] Models: 13/13 tested (233 tests)
- [x] Services: 12/13 tested (133 tests) — missing: recipe_import_service
- [x] Providers: 14/14 tested (195 tests)
- [x] Widgets: 10 shared widgets tested (136 tests)
- [x] Utils: 2/2 tested (66 tests)
- **Status:** PUSHED ✅

---

## App Statistics
- **Total Dart files:** 104
- **Lines of code (lib/):** 24,230
- **Lines of code (test/):** 13,527
- **Total lines:** 37,757
- **Screens implemented:** 28
- **Models:** 13
- **Services:** 13
- **Providers:** 14
- **Routes:** 24
- **l10n keys:** 229 (EN + TR)

---

# 🔴 BUGS TO FIX

### P0 — Critical
1. **Food item edit not implemented** — `food_item_detail_screen.dart:93` has `// TODO: Navigate to edit screen`
2. **Food item delete broken** — `food_item_detail_screen.dart:535` has `// TODO: Call provider.deleteFoodItem() and pop screen` — dialog dismisses but item is NOT deleted

### P1 — High
3. **Missing test:** `recipe_import_service_test.dart` — only service without a test file

---

# 🟡 FEATURES NOT YET IMPLEMENTED

### Push 17: Share Recipe
- [ ] Share recipe as link or image card via share_plus
- [ ] Generate shareable recipe card image
- [ ] Share button on RecipeDetailScreen

### Push 18: Weekly Meal Planner
- [ ] **Model:** MealPlan, PlannedMeal (day, mealType, recipeId)
- [ ] **Service:** MealPlanService (Firestore CRUD)
- [ ] **Provider:** MealPlanProvider
- [ ] **MealPlannerScreen** — weekly calendar view (Mon–Sun)
- [ ] Drag/assign recipes to days and meal slots
- [ ] Weekly nutrition totals summary
- [ ] Auto-generate shopping list from weekly plan

### Push 19: Weekly/Monthly Reports
- [ ] **ReportsScreen** — nutrition summary over time
- [ ] Weekly averages: calories, protein, carbs, fat
- [ ] Monthly trends with line/bar charts (fl_chart)
- [ ] Streak tracking (consecutive days logged)
- [ ] Export report as PDF or image

### Push 20: Push Notifications
- [ ] Firebase Cloud Messaging setup
- [ ] Meal reminders ("Time for lunch!")
- [ ] New recipe alerts from followed users
- [ ] Notification settings screen

### Push 21: Admin Panel
- [ ] AdminDashboard, AdminRecipes, AdminUsers, AdminCategories
- [ ] Admin route guard
- [ ] Firestore security rules for admin

### Push 22: Unit Converter + Recipe Scaling
- [ ] Measurement converter (g↔oz, mL↔cups, °C↔°F)
- [ ] Recipe scaling (multiply/divide ingredient quantities)
- [ ] Serving size selector on RecipeDetailScreen

### Push 23: Onboarding Flow
- [ ] First-launch walkthrough (3–4 pages)
- [ ] Dietary preference setup during onboarding
- [ ] SharedPreferences flag to show only once

### Push 24: Recipe Photo Gallery
- [ ] Multiple photos per recipe
- [ ] Photo carousel on RecipeDetailScreen
- [ ] Step-by-step photos in cooking mode

### Push 25: Cooking History ("Cooked It" Log)
- [ ] **Model:** CookingLog (recipeId, userId, cookedAt, rating, notes)
- [ ] "I Cooked This" button on RecipeDetailScreen
- [ ] Cooking history screen
- [ ] Integration with daily tracker

### Push 26: Seasonal & Trending Recipes
- [ ] Trending section on HomeScreen (most favorited/rated this week)
- [ ] Seasonal recipe suggestions
- [ ] "Popular Now" badge on recipe cards

### Push 27: Ingredient Substitution Suggestions
- [ ] Substitution database (e.g. butter → coconut oil)
- [ ] "Suggest Substitute" button on ingredients
- [ ] Filter by dietary tag

### Push 28: Achievement Badges & Gamification
- [ ] **Model:** UserAchievement (badgeId, unlockedAt)
- [ ] Badge definitions: First Recipe, 7-Day Streak, etc.
- [ ] Achievement unlock notifications
- [ ] Badges on profile screen
