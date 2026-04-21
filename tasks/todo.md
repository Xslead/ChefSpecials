# ChefSpecials — Progress Tracker

---

## Completed Pushes

Push 0: Project Foundation

 [x] CLAUDE.md (project-local, not committed)
 [x] README.md
 [x] .gitignore
Status: PUSHED

Push 1: Project Scaffolding + Firebase + Auth

 [x] Flutter project creation
 [x] Dependencies in pubspec.yaml
 [x] Firebase setup (se380-food-tracker project, apps created, configs generated)
 [x] App theme, constants, routes (GoRouter)
 [x] Models: UserModel
 [x] Services: AuthService, UserService
 [x] Providers: AuthProvider, LocaleProvider
 [x] Screens: LoginScreen, RegisterScreen, HomeScreen (shell)
 [x] Config: main.dart, app.dart, theme.dart, constants.dart, routes.dart
 [x] i18n: app_en.arb, app_tr.arb + generated localizations
 [x] Firestore security rules deployed
 [x] Self-test: flutter analyze — 0 issues
 [x] Self-test: flutter build ios + apk — SUCCESS
Status: PUSHED

Push 2: Recipe CRUD + Home Feed + Nutrition

 [x] Models: Recipe, RecipeStep, Ingredient
 [x] Services: RecipeService, StorageService
 [x] Providers: RecipeProvider, RecipeFormProvider
 [x] Screens: HomeScreen (feed), AddRecipeScreen, RecipeDetailScreen
 [x] Widgets: RecipeCard, CategoryFilterBar, IngredientInputList, StepInputList, ImagePickerTile, IngredientListView, StepOverviewList
 [x] Routes updated (add-recipe, recipe/:id)
 [x] RecipeProvider added to MultiProvider
 [x] Self-test: flutter analyze — 0 issues
Status: PUSHED

Push 3: Cooking Mode (Step-by-Step Pages)

 [x] CookingModeScreen (PageView navigation)
 [x] StepPage widget
 [x] CountdownTimerWidget
 [x] Progress indicator (LinearProgressIndicator in AppBar)
 [x] Route: /cooking/:id added to GoRouter
 [x] RecipeDetailScreen "Start Cooking" button wired with extra
 [x] Self-test: flutter analyze — 0 issues
 [x] Self-test: running on Android emulator
Status: PUSHED

Push 4: Search + Favorites

 [x] Models: Favorite
 [x] Services: FavoriteService
 [x] Providers: FavoriteProvider, SearchProvider
 [x] Screens: SearchScreen, FavoritesScreen
 [x] Widgets: SearchResultTile
 [x] Heart icon on recipe cards
 [x] Routes: /search, /favorites added
 [x] FavoriteProvider added to MultiProvider
 [x] Home AppBar: search + favorites icons
 [x] Self-test: flutter analyze — 0 issues
Status: PUSHED

Push 5: Profile + i18n + Utilities + Polish

 [x] Screens: ProfileScreen, EditProfileScreen
 [x] AuthProvider: refreshUser() method added
 [x] StorageService: uploadUserAvatar() method added
 [x] Utils: validators, image_utils, date_utils
 [x] Routes: /profile, /edit-profile added
 [x] Home AppBar: profile icon replaces logout
 [x] Self-test: flutter analyze — 0 issues
Status: PUSHED

Push 6: Ingredient Database (Materials)

 [x] Model: FoodItem (name, brand, packetSize, barcode, isVegan, unit: "100g" or "mL", calories, protein, carbs, fat, fiber, sugar, sodium)
 [x] Firestore collection: food_items — shared database all users can browse
 [x] Service: FoodItemService (CRUD + search)
 [x] Provider: FoodItemProvider
 [x] Screens:
 [x] FoodItemListScreen — browse/search all materials with category filter
 [x] AddFoodItemScreen — any user can add a new material with nutrition per 100g or mL
 [x] FoodItemDetailScreen — view full nutrition breakdown (per 100g + per packet)
 [x] Widgets: FoodItemCard, NutritionFactsTable
 [x] Seed Firestore with 28 real food items (real brands, nutrition data from Open Food Facts/USDA)
 [x] Firestore security rules for food_items collection deployed
 [x] Recipe ingredients now link to materials database (food item picker instead of free-text)
 [x] Auto-calculate recipe nutrition from ingredient quantities
 [x] Cook time auto-calculated from step timers (sum of all step timerSeconds)
 [x] Materials accessible from Home screen AppBar (kitchen icon)
 [x] Self-test: flutter analyze — 0 issues
Status: PUSHED

Push 7: Bottom Navigation + My Recipes

 [x] Bottom Navigation Bar (5 tabs): Home, Feed, Daily Tracker, Materials, Profile
 [x] ShellScreen with NavigationBar + StatefulShellRoute.indexedStack
 [x] GoRouter updated to StatefulShellRoute with 5 branches
 [x] My Recipes Tab:
 [x] MyRecipesScreen — only logged-in user's recipes
 [x] Filter/sort options (by date, category)
 [x] FAB to add new recipe
 [x] Profile tab — existing ProfileScreen moved into bottom nav
 [x] Materials tab — FoodItemListScreen in bottom nav
 [x] FoodItemProvider moved to global MultiProvider
 [x] HomeScreen AppBar cleaned (removed Materials + Profile icons, kept Search + Favorites)
 [x] DailyTrackerScreen placeholder created
 [x] l10n updated (EN + TR): myRecipes, dailyTracker, materials, sortBy, newest, oldest, all, comingSoon
 [x] Sub-screens (add-recipe, recipe detail, cooking mode, etc.) push on top of shell via parentNavigatorKey
 [x] Self-test: flutter analyze — 0 issues
Status: PUSHED

Push 8: Daily Tracker + Nutrition Goals

 [x] Models: DailyLog, MealEntry (breakfast, lunch, dinner, snack), NutritionGoal
 [x] Services: DailyTrackerService (Firestore CRUD)
 [x] Providers: DailyTrackerProvider
 [x] DailyTrackerScreen — date picker + meal sections
 [x] Meal sections: Breakfast, Lunch, Dinner, Snack
 [x] Add food items (from materials DB) or full recipes to a meal slot
 [x] Specify quantity (e.g. 150g chicken, 200mL milk)
 [x] Auto-calculate nutrition based on quantity × per-100g values
 [x] Daily nutrition summary: total calories, protein, carbs, fat
 [x] Per-meal nutrition breakdown
 [x] Circular/bar charts for macro visualization (fl_chart BarChart + custom CalorieRingPainter)
 [x] Nutrition Goals: set daily calorie/protein/carbs/fat targets
 [x] Progress rings showing current vs target on Daily Tracker
 [x] DailyTrackerProvider added to MultiProvider
 [x] Firestore security rules deployed (daily_logs, nutrition_goals)
 [x] l10n updated (EN + TR): breakfast, lunch, dinner, snack, nutritionGoals, dailySummary, etc.
 [x] Routes: /add-meal-entry, /nutrition-goals added
 [x] Self-test: flutter analyze — 0 issues
Status: PUSHED

Push 9: Ratings & Comments

 [x] Models: Rating, Comment
 [x] Services: RatingService, CommentService
 [x] Providers: RatingProvider, CommentProvider
 [x] Star rating widget (1–5 stars) on RecipeDetailScreen
 [x] Average rating displayed on RecipeCard
 [x] Comments section on RecipeDetailScreen (add/view/delete)
Status: PUSHED

Push 10: Recipe Privacy + Social Feed + Follow System

 [x] Recipe Privacy: isPrivate field on Recipe model, visibility toggle on AddRecipeScreen
 [x] FollowService: follow/unfollow, getFollowerIds, getFollowingIds
 [x] FollowProvider: real-time follow state, follower/following counts
 [x] FeedScreen: recipes from followed users + user search by username
 [x] Feed tab added to bottom nav (Tab 2)
 [x] PublicProfileScreen: view other users' public recipes
 [x] FollowListScreen: followers/following tabs with follow/unfollow buttons
 [x] Follow/unfollow button on public profiles
 [x] Follower/following counts on ProfileScreen (tappable stat cards)
 [x] Username system: unique username field on UserModel, search by username
 [x] Navigation icons on follow list tabs + chevron on stat cards
Status: PUSHED

Push 11: Dark Mode

 [x] ThemeProvider with light/dark/system modes
 [x] Persist theme preference (SharedPreferences)
 [x] Dark mode toggle on ProfileScreen (sun/moon icon)
 [x] All screens support dark theme colors via AppTheme helper methods
Status: PUSHED

Push 12: Dietary Tags

 [x] Add dietary tags to Recipe model (Vegan, Gluten-Free, Keto, Halal, etc.)
 [x] Dietary tag picker on AddRecipeScreen
 [x] Filter recipes by dietary tags on HomeScreen/SearchScreen
 [x] Unified filter sheet (category + dietary tags + sort) on Home and Materials screens
 [x] Fix: filter icon alignment when badge is visible
Status: PUSHED

Push 13: Shopping List

 [x] Model: ShoppingList, ShoppingItem (name, amount, unit, isChecked)
 [x] Service: ShoppingListService (Firestore CRUD, toggle, clear checked, add items)
 [x] Provider: ShoppingListProvider (stream subscription, all CRUD methods)
 [x] ShoppingListsScreen — view all user's lists with progress circles, swipe-to-delete
 [x] ShoppingListDetailScreen — check/uncheck items, strikethrough, clear checked, swipe-to-delete
 [x] Auto-generate shopping list from recipe ingredients (button on RecipeDetailScreen)
 [x] Bottom sheet: pick existing list or create new list from recipe detail
 [x] Shopping cart icon on Home screen header for quick access
 [x] Firestore security rules deployed (owner-only read/write)
 [x] Firestore composite index deployed (userId + updatedAt)
 [x] l10n: 13 new keys in EN + TR
 [x] UI redesigned to match app design patterns (custom headers, shadows, adaptive colors)
Status: PUSHED

Push 14: Recipe Collections

 [x] Model: RecipeCollection (name, description, recipeIds, coverImage)
 [x] Service: CollectionService (Firestore CRUD)
 [x] Provider: CollectionProvider
 [x] CollectionListScreen — view all user's collections
 [x] CollectionDetailScreen — view recipes in a collection
 [x] Create/edit/delete custom folders (e.g. "Quick Meals", "Keto", "Weekend")
 [x] Add/remove recipes to collections from RecipeDetailScreen
Status: PUSHED

Push 15: Recipe Import from URL

 [x] RecipeImportService (JSON-LD extraction from URLs)
 [x] ImportRecipeScreen with URL input
 [x] Auto-parse ingredients/steps from recipe link
Status: PUSHED

Push 16: iOS Keychain Fix

 [x] Added GoogleService-Info.plist to Xcode project references + Copy Bundle Resources
 [x] Added Runner.entitlements to Xcode project references
 [x] Fixed Debug.xcconfig missing Generated.xcconfig include
 [x] Fixed Podfile signing config + macOS 26 xattr codesign fix
Status: PUSHED

Push 17: Share Recipe + Deep Links

 [x] Added share_plus dependency to pubspec.yaml
 [x] Added l10n keys: shareRecipe, shareRecipeText (EN + TR)
 [x] Share glass circle button in RecipeDetailScreen AppBar
 [x] _shareRecipe() method formats title, author, ingredients list
 [x] Deep link support: chefspecials:// URL scheme (Android + iOS)
 [x] _RecipeLoaderScreen — loads recipe by ID from Firestore for deep link access
 [x] Route /recipe/:id now works without extra data (deep link compatible)
Status: PUSHED

Push 18: Bug Fixes + Analyze Cleanup

 [x] Bug #1: Food item edit — AddFoodItemScreen now supports editing (editItem param, pre-fill, updateFoodItem)
 [x] Bug #1: Route /edit-food-item added to GoRouter
 [x] Bug #2: Food item delete — FoodItemProvider.deleteFoodItem() wired in detail screen dialog
 [x] Bug #3: RecipeImportService test — 58 tests (DI via http.Client, JSON-LD extraction, parsing)
 [x] FoodItemProvider: added deleteFoodItem() and updateFoodItem() methods
 [x] Fix: empty_catches in main.dart → debugPrint
 [x] Fix: use_build_context_synchronously in login_screen, recipe_detail_screen (3 locations)
 [x] Fix: deprecated value → initialValue on DropdownButtonFormField (register_screen, 3 locations)
 [x] Fix: deprecated activeColor → activeTrackColor on Switch (edit_recipe_screen)
 [x] Fix: unused_local_variable favoriteCount/favoriteProvider in profile_screen
 [x] Fix: unnecessary_import mockito in storage_service_test
 [x] flutter analyze — 0 issues
 [x] flutter test — 919 tests passing (55 files, 14,586 lines)
Status: PUSHED

Push 20: Testing

 [x] 919 tests passing across all layers (55 files, 14,586 lines)
 [x] DI constructors added to all 12 services and 11 providers
 [x] Dev dependencies: fake_cloud_firestore, mockito, build_runner, http (MockClient)
 [x] Test helpers: 26 factory functions for all 13 models
Unit Tests (test/)
 [x] Models (233 tests): Recipe, Ingredient, ShoppingList, ShoppingItem, FoodItem, DailyLog, MealEntry, NutritionGoal, UserModel, Rating, Comment, Favorite, RecipeStep
 [x] fromMap() / toMap() round-trip correctness
 [x] Default values, null handling, edge cases, computed properties, copyWith, enums
 [x] Services (191 tests, fake_cloud_firestore + MockClient):
 [x] RecipeService — CRUD, streams, category filter, feed pagination, author name batch update
 [x] FavoriteService — toggle, isFavorite, streams
 [x] ShoppingListService — CRUD, toggle, clear checked, remove, add items
 [x] FoodItemService — CRUD, search, category filter
 [x] DailyTrackerService — CRUD, date queries, nutrition goals
 [x] RatingService — set/delete with transaction, average calculation
 [x] CommentService — subcollection CRUD, transaction counters
 [x] FollowService — follow/unfollow batch writes, streams
 [x] UserService — CRUD, username claim transaction, search, migration
 [x] RecipeImportService — importFromUrl, JSON-LD extraction, parsing, duration, servings, ingredients, steps, category, image
 [x] Providers (195 tests, fake_cloud_firestore + real services):
 [x] LocaleProvider, ThemeProvider — simple state tests
 [x] RecipeProvider — stream, filter, CRUD, author name update
 [x] FavoriteProvider — stream, toggle, isFavorite
 [x] ShoppingListProvider — init, CRUD, toggle, clear
 [x] DailyTrackerProvider — meals, water, progress, goals
 [x] FoodItemProvider — filters, sort, search, category
 [x] RatingProvider / CommentProvider — optimistic updates, transactions
 [x] SearchProvider — multi-field query filtering
 [x] FollowProvider — optimistic follow/unfollow
 [x] RecipeFormProvider — nutrition calc, step management, form state
 [x] Utils (66 tests):
 [x] Validators (email, password, required, confirmPassword)
 [x] Date utils (timeAgo, formatDate)
Widget Tests (test/widgets/)
 [x] Shared Widgets (136 tests):
 [x] RecipeCard — title, author, category, rating, comments, nutrition, dietary tags
 [x] FoodItemCard — name, brand, calories, vegan badge, verified icon, nutrition bar
 [x] NutritionFactsTable — per-unit, per-packet, macros, micros, progress bars
 [x] GradientButton — label, onPressed, disabled state, icon, height
 [x] PremiumCard — child, padding, gradient, borderRadius, shadow
 [x] CountdownTimerWidget — start, pause, reset, Done!, MM:SS format
 [x] CategoryFilterBar — all chips, selection callback, l10n
 [x] SearchResultTile — title, category, time, calorie badge
 [x] IngredientListView — names, amounts, alternating rows
 [x] StepOverviewList — numbers, instructions, timer formatting
Test Infrastructure
 [x] Add flutter_test, mockito, fake_cloud_firestore to dev_dependencies
 [x] Test helpers: 26 factory functions (test/helpers/test_helpers.dart)
 [x] CI-ready: flutter test runs 919 tests in ~12 seconds
Status: PUSHED

---

Push 23: Screen Logic Refactoring

**Phase 0: Shared Infrastructure (L10n Keys)**
- [x] Added 9 new l10n keys to `app_en.arb` and `app_tr.arb`: phoneNumberRequired, invalidPhoneNumber, passwordsDoNotMatch, personalInformation, helpsPersonalizeExperience, editRecipe, syncFailed, commentSubmitted, ratingSubmitted

**Phase 1: Critical & High Severity**
- [x] **Feed Screen** — Created `FeedProvider` (screen-scoped), refactored `feed_screen.dart` to remove direct `RecipeService`/`UserService`, replaced 12+ setState calls with provider methods, added SnackBar error feedback (35 new tests)
- [x] **Register Screen** — Localized 14 hardcoded strings, removed direct `UserService`, routed username check through `AuthProvider.isUsernameAvailable()`, localized dropdown display text
- [x] **Home Screen** — Removed duplicate `listenToFavorites()` call from `build()` (was running every frame)
- [x] **Recipe Detail** — Added 3 passthrough methods to `ActivityProvider`, removed direct `ActivityService`/`ShoppingListService` instantiation, added success SnackBars for comment/rating submission

**Phase 2: Medium Severity**
- [x] **Add Food Item Screen** — Created `FoodItemFormProvider` (26 state fields, nutrition unit conversion), refactored screen to use provider (36 new tests)
- [x] **Add Meal Entry Screen** — Added try-catch + SnackBar around `addMealEntry` calls
- [x] **Meal Planner Screen** — Added try-catch + SnackBar to `_syncShoppingList()`

**Phase 3: Low Severity**
- [x] **Search Screen** — Removed 3 redundant `setState(() {})` calls, switched clear icon to `searchProvider.query.isNotEmpty`
- [x] **Forgot Password Screen** — Removed direct `AuthService`, routed through `AuthProvider.sendPasswordResetEmail()`
- [x] **Add Recipe Screen** — Added `getFollowerIds()` to `FollowProvider`, removed direct `FollowService`/`ActivityService`
- [x] **Edit Recipe Screen** — Replaced 3 hardcoded strings with l10n keys (`editRecipe`, `requiredField` x2)

**New Files (4)**
- `lib/providers/feed_provider.dart`
- `lib/providers/food_item_form_provider.dart`
- `test/providers/feed_provider_test.dart` (35 tests)
- `test/providers/food_item_form_provider_test.dart` (36 tests)

**Modified Files (19)**: app_en.arb, app_tr.arb, auth_provider, activity_provider, follow_provider, feed_screen, register_screen, home_screen, recipe_detail_screen, add_food_item_screen, add_meal_entry_screen, meal_planner_screen, search_screen, forgot_password_screen, add_recipe_screen, edit_recipe_screen + 3 test files

**Quality**
- [x] flutter analyze — 0 issues
- [x] flutter test — 1269 tests passing (80 new tests)
- [x] Emulator smoke test — all 11 refactored screens working
Status: PUSHED

---

## App Statistics

 Total Dart files: 152 (lib) + 77 (test) = 229
 Tests: 1285 (0 failures)
 Screens implemented: 42
 Models: 20
 Services: 17
 Providers: 22
 Routes: 38
 l10n keys: 382 (EN + TR)
 Widgets: 3 (ServingSizeSelector, UnitConverterSheet, unit_converter utility)

---

## Bugs

All bugs resolved as of Push 18.

| # | Bug | Status | Resolution |
|---|-----|--------|------------|
| 1 | Food item edit not implemented | FIXED | AddFoodItemScreen supports editing via editItem param + /edit-food-item route |
| 2 | Food item delete broken | FIXED | FoodItemProvider.deleteFoodItem() wired in detail screen dialog |
| 3 | Missing test for recipe_import_service | FIXED | 58 tests added (DI via http.Client, full parsing coverage) |

---

## Remaining Features

---

### Task 1: Weekly Meal Planner (Push 19)

**Model: MealPlan**
- [x] Create `lib/models/meal_plan.dart`
- [x] Fields: `id`, `userId`, `weekStartDate`, `meals`, `createdAt`, `updatedAt`
- [x] `fromMap()` factory — reads Firestore Timestamps, converts to DateTime
- [x] `toMap()` — converts DateTime back to Timestamps
- [x] `copyWith()` for immutable updates
- [x] Firestore collection: `meal_plans`, document ID: auto-generated

**Model: PlannedMeal**
- [x] Separate file `lib/models/planned_meal.dart`
- [x] Fields: `day`, `mealType`, `recipeId`, `recipeName`, `recipeImageUrl`, `servings`
- [x] `fromMap()` and `toMap()`

**Service: MealPlanService**
- [x] Create `lib/services/meal_plan_service.dart`
- [x] Stateless class, Firestore `meal_plans` collection, optional FirebaseFirestore DI
- [x] `getMealPlan()`, `getMealPlanStream()`, `createMealPlan()`, `updateMealPlan()`
- [x] `addMealToDay()` (arrayUnion), `removeMealFromDay()` (arrayRemove)
- [x] `copyFromPreviousWeek()` — clone previous week

**Provider: MealPlanProvider**
- [x] Create `lib/providers/meal_plan_provider.dart`
- [x] Extends ChangeNotifier, stream subscription, init/dispose
- [x] `init()`, `navigateWeek()`, `addMeal()`, `removeMeal()`
- [x] `getMealsForDay()`, `getMealsForSlot()`, `copyFromLastWeek()`
- [x] `generateShoppingList()`, `getWeeklyNutrition()`
- [x] Registered in `main.dart` MultiProvider

**Screen: MealPlannerScreen**
- [x] Create `lib/screens/meal_planner/meal_planner_screen.dart`
- [x] Week navigation (prev/next arrows + "Week of {date}")
- [x] Action buttons: Copy from Last Week, Generate Shopping List
- [x] 7 day cards with 4 meal slots each (breakfast, lunch, dinner, snack)
- [x] Empty slots with "Add Meal" → recipe picker bottom sheet (searchable)
- [x] Filled slots with recipe image, name, servings, delete button
- [x] Today's card highlighted with primary color border

**Route & Access**
- [x] GoRoute `/meal-planner` in routes.dart under parentNavigatorKey
- [x] "Meal Planner" ListTile on ProfileScreen (calendar icon)

**l10n**
- [x] 17 new keys in `app_en.arb` and `app_tr.arb` (day names, meal actions, feedback messages)
- [x] `flutter gen-l10n` regenerated

**Tests (110 new tests)**
- [x] `test/models/meal_plan_test.dart` — 42 tests (fromMap/toMap, copyWith, edge cases)
- [x] `test/services/meal_plan_service_test.dart` — 37 tests (CRUD, streams, copy, isolation)
- [x] `test/providers/meal_plan_provider_test.dart` — 38 tests (week nav, meals, nutrition, shopping list)

**Note:** Firestore security rules need updating for `meal_plans` collection (PERMISSION_DENIED on device)
Status: PUSHED (Push 19)

Push 19b: Meal Planner Improvements

**Copy/Paste Overhaul**
- [x] Copy button now copies CURRENT week (not last week)
- [x] Paste button added next to copy in header
- [x] Paste icon highlighted (primary color) when clipboard has meals, dimmed when empty
- [x] Paste REPLACES entire target week (not merge)
- [x] Re-subscribes stream after paste for reliable UI update

**Servings System**
- [x] Adding same recipe to same slot increments servings (x1 → x2 → x3) instead of duplicates
- [x] Swipe delete removes 1 serving at a time; fully removes entry at x0
- [x] `PlannedMeal.copyWith()` and `isSameSlotAndRecipe()` helpers added
- [x] Service uses full array read-modify-write instead of arrayUnion/arrayRemove

**Day Circle Redesign**
- [x] Day circles ALWAYS show date number (no more meal count replacing dates)
- [x] Days with meals get filled primary-color background
- [x] Today gets a small dot indicator below the circle to distinguish from "has meals"

**Shopping List Integration**
- [x] Generate shopping list from actual recipe INGREDIENTS (not recipe names)
- [x] Ingredients aggregated by name+unit across all recipes, multiplied by servings
- [x] `ShoppingList.mealPlanWeekStart` field added — links list to a specific week
- [x] Max 1 shopping list per week from meal planner (upsert, not create)
- [x] Auto-sync: adding/removing/pasting meals auto-updates the week's shopping list
- [x] Shopping cart button silently opens the list (no repeated snackbar)
- [x] `ShoppingListService.getMealPlanShoppingList()` query method
- [x] `ShoppingListProvider.upsertMealPlanList()` and `syncMealPlanList()` methods

**l10n**
- [x] 7 new keys in EN + TR ARBs (copyWeek, pasteWeek, weekCopied, weekPasted, etc.)

**Tests**
- [x] Updated `meal_plan_provider_test.dart` — generateShoppingList tests adapted to new generateShoppingItems API

Status: PUSHED

---

### Task 2: Weekly/Monthly Reports (Push 20)

**Model: DailyNutritionSummary**
- [x] Create `lib/models/daily_nutrition_summary.dart`
- [x] Lightweight immutable data class: date, totalCalories, totalProtein, totalCarbs, totalFat

**Provider: ReportsProvider**
- [x] Create `lib/providers/reports_provider.dart`
- [x] Extends `ChangeNotifier`, reads existing `daily_logs` via DailyTrackerService
- [x] Holds: selectedTab (weekly/monthly), dailySummaries, loading state, selectedNutrient, weekStart/weekEnd, selectedMonth, streak
- [x] `loadWeeklyData(String userId)` — query daily_logs for 7 days, aggregate into List\<DailyNutritionSummary\> with zero-fill for unlogged days
- [x] `loadMonthlyData(String userId)` — query daily_logs for entire month (1st to last day), aggregate daily summaries
- [x] `calculateMacroDistribution()` → {protein: %, carbs: %, fat: %} — for pie chart, sums to 100
- [x] `_calculateStreak(String userId)` — count consecutive days with at least one meal entry (90-day lookback)
- [x] `calculateAverages()` → {avgCalories, avgProtein, avgCarbs, avgFat} — arithmetic mean over loaded period
- [x] `previousWeek()`, `nextWeek()`, `previousMonth()`, `nextMonth()` — navigation
- [x] `setSelectedNutrient(NutrientType)` — toggles nutrient in bar chart
- [x] Register in `main.dart` MultiProvider

**DailyTrackerService Enhancement**
- [x] `getDailyLogsForRange(userId, startDate, endDate)` — batched queries for date range

**Screen: ReportsScreen**
- [x] Create `lib/screens/reports/reports_screen.dart`
- [x] Full-screen page, header with title, back button, export icon
- [x] TabBarView with 2 tabs — "Weekly" and "Monthly"
- [x] **Weekly tab:**
  - Week navigation row with 7 day circles (M-S) showing logged/today status + chevrons
  - NutrientBarChart: nutrient pills (Calories, Protein, Carbs, Fat), bar chart with tooltips
  - AverageIntakeCard: 4-column grid with dividers
  - StreakCard: fire icon + streak count + motivational message
- [x] **Monthly tab:**
  - Month navigation row with progress bar (days tracked / total) + chevrons
  - NutrientLineChart: 4 colored lines with area fill, legend, auto-scaled Y-axis
  - MacroPieChart: donut chart with percentages + legend
  - AverageIntakeCard for monthly averages
- [x] Export as PNG via RepaintBoundary + share_plus
- [x] Uses `Consumer<ReportsProvider>`

**Widgets (7 chart/card widgets)**
- [x] `nutrient_bar_chart.dart` — weekly bar chart with nutrient selector pills
- [x] `nutrient_line_chart.dart` — monthly multi-line chart with area fill
- [x] `macro_pie_chart.dart` — donut pie chart with legend
- [x] `average_intake_card.dart` — 4-column summary metrics
- [x] `streak_card.dart` — fire icon badge + streak count
- [x] `week_selector.dart` — reusable week navigation
- [x] `month_selector.dart` — reusable month navigation

**Route**
- [x] Add GoRoute path `/reports` in `lib/config/routes.dart` under parentNavigatorKey
- [x] Access point: "Reports" ListTile on ProfileScreen (bar chart icon)

**l10n**
- [x] 10 new keys in `app_en.arb` and `app_tr.arb`: reports, weekly, monthly, averageDailyIntake, currentStreak, macroDistribution, exportAsImage, noDataForPeriod, avgCalories/Protein/Carbs/Fat

**Tests (22 new tests)**
- [x] `test/providers/reports_provider_test.dart` — 12 tests: initial state, nutrient selection, weekly/monthly loading, aggregation, averages, macro distribution sums to 100, week/month navigation
- [x] `test/screens/reports/reports_screen_test.dart` — 8 tests: header, tabs, export button, charts with/without data, day circles, monthly tab, back button

**Quality**
- [x] flutter analyze — 0 issues
- [x] flutter test — 1048 tests passing (0 failures)
Status: PUSHED (Push 20)

---

### Task 3: Push Notifications (Push 20b)

**Dependencies**
- [x] `firebase_messaging` added via `flutter pub add`
- [x] `flutter_local_notifications` added
- [x] `timezone` added (required for `zonedSchedule`)

**Platform Configuration**
- [x] Android: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM` permissions
- [x] Android: FCM default channel metadata, notification icon, boot receiver
- [x] iOS: `aps-environment` entitlement for push notifications
- [x] iOS: `UIBackgroundModes` with `remote-notification` and `fetch`

**Service: NotificationService**
- [x] Create `lib/services/notification_service.dart`
- [x] `initialize()` — local notifications plugin, Android channel, FCM foreground listener
- [x] `requestPermission()`, `getFcmToken()`, `saveFcmToken()`
- [x] `subscribeToTopic()` / `unsubscribeFromTopic()`
- [x] `scheduleMealReminder()` — zonedSchedule daily repeating
- [x] `cancelMealReminder()` / `cancelAllReminders()`
- [x] DI: optional FirebaseFirestore, FirebaseMessaging, FlutterLocalNotificationsPlugin

**Provider: NotificationProvider**
- [x] Create `lib/providers/notification_provider.dart`
- [x] Extends `ChangeNotifier`, 3 meal reminders + 3 social alert toggles
- [x] SharedPreferences persistence (12 keys)
- [x] `init()` — initialize service, request permission, save FCM token
- [x] Toggle methods: breakfast/lunch/dinner reminders with time pickers
- [x] Toggle methods: newRecipeAlerts, commentAlerts, followerAlerts (FCM topics)
- [x] Registered in `main.dart` MultiProvider

**Screen: NotificationSettingsScreen**
- [x] Create `lib/screens/profile/notification_settings_screen.dart`
- [x] Custom header with back button matching app design
- [x] Meal Reminders section: 3 cards with toggle + time picker
- [x] Social Alerts section: 3 SwitchListTile items
- [x] `Consumer<NotificationProvider>` for reactive UI

**Integration**
- [x] `main.dart`: FCM background handler + NotificationProvider in MultiProvider
- [x] `routes.dart`: `/notification-settings` route under parentNavigatorKey
- [x] `profile_screen.dart`: "Notification Settings" ListTile with bell icon (first in features card)

**l10n**
- [x] 11 new keys in `app_en.arb` and `app_tr.arb` (notificationSettings, mealReminders, socialAlerts, breakfastReminder, lunchReminder, dinnerReminder, newRecipeAlerts, commentAlerts, followerAlerts, timeForMeal)

**Tests (9 new tests)**
- [x] `test/services/notification_service_test.dart` — 3 tests: instantiation, saveFcmToken write, token update
- [x] `test/providers/notification_provider_test.dart` — 6 tests: defaults, prefs loading, instantiation, default times, round-trip

**Quality**
- [x] flutter analyze — 0 issues
- [x] flutter test — 1057 tests passing (0 failures)
Status: PUSHED (Push 20b)

---

### Task 3b: Announcements / Activity Feed (Push 20c)

**Model: Activity**
- [x] Create `lib/models/activity.dart`
- [x] ActivityType enum: follow, comment, rating, newRecipe
- [x] Fields: userId, actorId, actorName, actorAvatar, type, targetId, targetName, targetImageUrl, message, isRead, createdAt
- [x] fromMap/toMap with type serialization

**Service: ActivityService**
- [x] Create `lib/services/activity_service.dart`
- [x] Firestore collection `activities`, DI with optional FirebaseFirestore
- [x] createActivity, getActivitiesStream (limit 100), getUnreadCount stream
- [x] markAllAsRead (batch), markAsRead, markAsUnread
- [x] deleteOldActivities (30 days, client-side filter)
- [x] Helper methods: createFollowActivity, createCommentActivity (with optional stars), createRatingActivity, createNewRecipeActivity (batch write to all followers)

**Provider: ActivityProvider**
- [x] Create `lib/providers/activity_provider.dart`
- [x] Dual stream subscriptions (activities + unread count)
- [x] Error handlers to prevent infinite loading
- [x] refresh() method to recover from stream errors
- [x] markAsRead, markAsUnread, markAllAsRead
- [x] Registered in main.dart MultiProvider

**Screen: ActivityScreen**
- [x] Create `lib/screens/activity/activity_screen.dart`
- [x] ScreenHeader with unread count subtitle + "Mark All Read" button
- [x] Card-based list matching app design (surface, border, shadow, rounded 14)
- [x] Unread items: tinted background + colored border + dot indicator
- [x] Avatar with type-colored ring (network image or fallback icon)
- [x] RichText: bold actor name (16px) + action text (12px, secondary)
- [x] Comment activities: star row + italic quote bubble
- [x] Rating activities: star row
- [x] New recipe activities: show recipe name in text
- [x] Swipe left → mark as read (blue), swipe right → mark as unread (amber)
- [x] Tap navigates: follow→profile, comment/rating/newRecipe→recipe
- [x] Relative time formatting (just now, Nm, Nh, Nd, MMM d)

**Integration**
- [x] Bell icon with red unread badge on Home screen header (left of Collections)
- [x] ActivityProvider initialized on HomeScreen
- [x] FollowProvider: creates follow activity on follow action
- [x] RecipeDetailScreen: combined comment+rating into single activity
- [x] AddRecipeScreen: notifies all followers on new public recipe

**Firestore**
- [x] Security rules deployed for activities collection
- [x] Composite indexes: userId+createdAt DESC, userId+isRead

**l10n**
- [x] 12 new keys (EN + TR): announcements, markAllRead, noAnnouncements, activityFollow, activityComment, activityRating, activityNewRecipe, notificationsDisabled, notificationsDisabledDescription, enableNotifications

**Tests (25 new)**
- [x] test/models/activity_test.dart — 7 tests (fromMap, toMap, round-trip, defaults, enum)
- [x] test/services/activity_service_test.dart — 10 tests (CRUD, helpers, self-skip, batch, markAllAsRead, deleteOld)
- [x] test/providers/activity_provider_test.dart — 5 tests (defaults, init, markAllAsRead)
- [x] Updated test/providers/follow_provider_test.dart — ActivityService DI

**Quality**
- [x] flutter analyze — 0 issues
- [x] flutter test — 1078 tests passing (0 failures)
Status: PUSHED (Push 20c)

---

### Task 4: Admin Panel (Push 21)

**Models**
- [x] UserModel: added `isBanned`, `banReason`, `bannedAt`, `bannedBy` fields + `isAdmin` getter
- [x] Activity: added `announcement` to ActivityType enum
- [x] Created `AdminLog` model (id, adminId, adminName, action, targetId, targetName, details, createdAt)
- [x] Created `BanAppeal` model (id, userId, userName, userEmail, appealText, status, reviewedBy, reviewNote, createdAt, reviewedAt)
- [x] Created `Announcement` model (id, title, body, authorId, authorName, createdAt)

**Service: AdminService**
- [x] Create `lib/services/admin_service.dart` with DI (optional FirebaseFirestore)
- [x] `getDashboardStats()` — counts users, recipes, comments (from recipe commentCount), active today
- [x] `getAllUsers({searchQuery, limit})` / `banUser()` / `unbanUser()` / `setUserRole()`
- [x] `getAllRecipes({searchQuery, limit})` / `deleteRecipeAsAdmin()` — cascade cleanup (ratings, favorites, comments)
- [x] `getCategories({type})` / `addCategory()` / `updateCategory()` / `deleteCategory()` / `seedDefaultCategories()`
- [x] `createAnnouncement()` — saves to announcements + fan-out Activity to all users
- [x] `getAnnouncements()` / `deleteAnnouncement()`
- [x] `logAction(AdminLog)` / `getAuditLogs({limit})`
- [x] `submitAppeal()` / `getPendingAppeals()` / `getAllAppeals()` / `reviewAppeal()` / `getUserAppeal()`
- [x] `_notifyUser()` helper — sends activity announcement to affected user on every admin action

**Provider: AdminProvider**
- [x] Create `lib/providers/admin_provider.dart` — wraps AdminService, manages loading/error state
- [x] All mutations auto-log to audit trail via `logAction()`
- [x] Registered in `main.dart` MultiProvider

**Screens (8 new + 1 modified)**
- [x] `AdminDashboardScreen` — 2x2 stat cards, 6 navigation tiles, pull-to-refresh, seeds categories on init
- [x] `AdminUsersScreen` — search, user cards with role/ban badges, bottom sheet actions (ban/unban/promote/demote)
- [x] `AdminRecipesScreen` — search, recipe cards, swipe-to-delete with required description dialog
- [x] `AdminCategoriesScreen` — two tabs (recipe/food item), edit/delete per item, FAB to add
- [x] `AdminAnnouncementsScreen` — list + FAB to create (title + body bottom sheet)
- [x] `AdminAppealsScreen` — pending/all tabs, approve (unbans automatically) / reject with optional note
- [x] `AdminAuditLogScreen` — chronological, color-coded by action type, read-only
- [x] `BannedScreen` — ban reason, appeal form or "under review" status, sign out button

**Integration**
- [x] Routes: `/admin`, `/admin/users`, `/admin/recipes`, `/admin/categories`, `/admin/announcements`, `/admin/appeals`, `/admin/audit-log`, `/banned`
- [x] ProfileScreen: conditional "Admin Panel" ListTile (visible only when `user.isAdmin`)
- [x] LoginScreen: ban check after login → redirect to `/banned`
- [x] AuthProvider: `isBanned` getter
- [x] ActivityScreen: handles `ActivityType.announcement` (megaphone icon, message display)
- [x] Constants: `adminLogsCollection`, `appealsCollection`, `announcementsCollection`

**User Notifications on Admin Actions**
- [x] Ban → user gets "Account Suspended" announcement with reason
- [x] Unban → user gets "Your account has been restored" announcement
- [x] Delete recipe → recipe author gets notification with admin's description (required field)
- [x] Promote/Demote → user gets role change announcement
- [x] Appeal approved → user gets unban notification automatically

**Firestore Rules**
- [x] `isAdmin()` helper function (reads user doc role)
- [x] Admin overrides on: users, recipes, comments, food_items, categories
- [x] New rules: admin_logs (admin read/create), appeals (user create, admin read/update), announcements (admin CRUD, user read)
- [x] Deployed with `firebase deploy --only firestore:rules`

**l10n**
- [x] ~65 new keys in `app_en.arb` and `app_tr.arb`

**Tests**
- [x] `test/models/admin_log_test.dart` — 4 tests
- [x] `test/models/ban_appeal_test.dart` — 6 tests
- [x] `test/models/announcement_test.dart` — 3 tests
- [x] `test/models/user_model_test.dart` — updated for ban fields + isAdmin
- [x] `test/models/activity_test.dart` — updated for announcement enum
- [x] `test/services/admin_service_test.dart` — 28 tests
- [x] `test/providers/admin_provider_test.dart` — 24 tests
- [x] `test/helpers/test_helpers.dart` — factories for new models + ban fields

**Quality**
- [x] flutter analyze — 0 issues
- [x] flutter test — 1148 tests passing (0 failures)
Status: PUSHED (Push 21)

---

### Task 5: Unit Converter + Recipe Scaling (Push 22)

**Utility: UnitConverter**
- [x] Create `lib/utils/unit_converter.dart` — pure static class
- [x] `convertWeight(double value, WeightUnit from, WeightUnit to)` — Enums: g, kg, oz, lb
- [x] `convertVolume(double value, VolumeUnit from, VolumeUnit to)` — Enums: mL, L, cups, tbsp, tsp, flOz
- [x] `convertTemperature(double value, TempUnit from, TempUnit to)` — celsius/fahrenheit
- [x] `scaleIngredient(double originalAmount, int originalServings, int newServings)` → double
- [x] `smartFormat(double value, String unit)` → String — auto-simplify (1000g→kg, 1000mL→L)
- [x] `isVolumeUnit(String unit)` — shared helper for weight vs volume detection

**Widget: UnitConverterSheet**
- [x] Create `lib/widgets/unit_converter_sheet.dart` — showModalBottomSheet
- [x] SegmentedButton (Weight | Volume | Temperature), TextField, two DropdownButtons (From/To), Result + Copy
- [x] Pre-fill from ingredient tap, auto-detect category from unit

**Widget: ServingSizeSelector**
- [x] Create `lib/widgets/serving_size_selector.dart`
- [x] Row: minus button, "Serves X" text, plus button (min 1, max 20)

**RecipeDetailScreen Modifications**
- [x] Replace static servings with ServingSizeSelector
- [x] Ingredients auto-scale with scaleFactor
- [x] Nutrition card scales with serving count
- [x] Ingredient tap opens UnitConverterSheet pre-filled
- [x] Shopping list uses scaled ingredient amounts
- [x] Favorite button added to AppBar (heart icon, before share)
- [x] Shopping list & collection sheets use ListenableBuilder (fix empty on first open)

**CookingModeScreen Modification**
- [x] Unit converter icon button in AppBar → opens empty UnitConverterSheet

**Add Recipe — Ingredient Input**
- [x] Unit selector dropdown in amount dialog (g/kg/oz/lb for weight, mL/L/cups/tbsp/tsp/fl oz for volume)
- [x] Auto-converts to base unit (g or mL) on save
- [x] Converter icon (↔) on each ingredient row for quick reference

**Add Food Item (Materials)**
- [x] Unit dropdown expanded: 100g, 100mL, oz, lb, kg, cups, tbsp, tsp, fl oz, L
- [x] Non-base units: nutrition entered "per 1 [unit]", auto-converted to per 100g/100mL on save
- [x] Info banner explains conversion, packet size hidden for non-base units
- [x] Auto-select mL for Beverages category
- [x] Unit converter button in header
- [x] Dynamic suffixes (packet size, serving size, nutrition header) based on selected unit

**Downstream Fixes**
- [x] All food item display (card, detail, nutrition table) uses `UnitConverter.isVolumeUnit()` for correct g/mL display
- [x] `RecipeFormProvider.addIngredientFromFoodItem()` uses `isVolumeUnit()` for unit detection

**l10n**
- [x] 10 new keys (EN + TR): unitConverter, serves, fromUnit, toUnit, weight, volume, temperature, tapToConvert, copied, result

**Tests (41 new)**
- [x] `test/utils/unit_converter_test.dart` — 32 tests: all weight/volume/temp conversions, scaling, smartFormat
- [x] `test/widgets/unit_converter_sheet_test.dart` — 4 tests: rendering, category switching, conversion, pre-fill
- [x] `test/widgets/serving_size_selector_test.dart` — 5 tests: rendering, callbacks, min/max bounds

**Quality**
- [x] flutter analyze — 0 issues
- [x] flutter test — 1189 tests passing (0 failures)
Status: PUSHED (Push 22)

---

### Task 6: Onboarding Flow (Push 24)

**Provider: OnboardingProvider**
- [x] Create `lib/providers/onboarding_provider.dart` — screen-scoped ChangeNotifier
- [x] State: currentPage, pageController, selectedDietaryPreferences, calorieTarget, proteinTarget, carbsTarget, fatTarget
- [x] Methods: nextPage(), previousPage(), goToPage(), toggleDietaryPreference(), nutrition setters
- [x] completeOnboarding() → save to SharedPreferences + set hasCompletedOnboarding flag
- [x] Static savePendingOnboardingData() → read from SharedPreferences → save to Firestore after login/register
- [x] Static hasCompletedOnboarding() with cached result for router performance
- [x] resetCache() for test isolation

**Screen: OnboardingScreen**
- [x] Create `lib/screens/onboarding/onboarding_screen.dart` — full-screen, no AppBar, no bottom nav
- [x] PageView with 4 pages, ClampingScrollPhysics (swipeable), animated dot indicators
- [x] Back button (pages 2-4), Skip button (pages 3-4), Next/Get Started button
- [x] **Page 1 — Welcome:** Lottie food animation + title + subtitle
- [x] **Page 2 — Features Overview:** 3 feature rows with icons (nutrition, meals, sharing)
- [x] **Page 3 — Dietary Preferences:** 8 FilterChips (Vegan, Vegetarian, Gluten-Free, Keto, Halal, Dairy-Free, Nut-Free, Low Carb)
- [x] **Page 4 — Nutrition Goals:** 4 sliders (calories 1000-4000, protein 30-300g, carbs 50-500g, fat 20-200g)
- [x] Fade-in animation on each page transition

**Model: UserModel**
- [x] Added `dietaryPreferences` field (List<String>, default [])
- [x] Updated fromMap(), toMap(), copyWith()

**Route & Auth Integration**
- [x] `/onboarding` route in routes.dart under _rootNavigatorKey
- [x] Async redirect: /login or /register → /onboarding if not completed
- [x] login_screen.dart: save pending onboarding data after login (normal + quick login)
- [x] register_screen.dart: save pending onboarding data after register

**Locale Detection**
- [x] LocaleProvider.init() now reads device system locale on first launch
- [x] If phone is Turkish → app starts in Turkish; falls back to English for unsupported locales

**l10n**
- [x] 15 new keys (EN + TR): welcomeToChefSpecials, discoverCookShare, trackYourNutrition, logMealsMonitor, planYourMeals, organizeWeeklyMealPlan, shareRecipes, connectWithFoodLovers, selectDietaryPreferences, setDailyGoals, nutFree, skip, getStarted

**Tests**
- [x] `test/providers/onboarding_provider_test.dart` — 16 tests: initial state, page nav, dietary toggle, nutrition setters, SharedPreferences persistence, cache behavior, unmodifiable list
- [x] Updated test/helpers/test_helpers.dart — dietaryPreferences param on createTestUser/createTestUserMap

**Assets**
- [x] `assets/animations/cooking.json` — real Lottie food animation from LottieFiles
- [x] `lottie` dependency added to pubspec.yaml

**New Files (4):** onboarding_provider.dart, onboarding_screen.dart, onboarding_provider_test.dart, cooking.json
**Modified Files (12):** pubspec.yaml, user_model.dart, routes.dart, login_screen.dart, register_screen.dart, locale_provider.dart, app_en.arb, app_tr.arb, 3 generated l10n files, test_helpers.dart

**Quality**
- [x] flutter analyze — 0 issues
- [x] flutter test — 1285 tests passing (16 new)
Status: PUSHED (Push 24)

---

### Task 7: Recipe Photo Gallery (Push 24b)

**Model Updates**
- [x] Update `lib/models/recipe.dart`: add `photos` (List\<String\>, default []) — additional gallery images alongside existing `imageUrl`
- [x] Update `fromMap()`: read `'photos' as List<String> ?? []`
- [x] Update `toMap()`: write `'photos'`
- [x] Update RecipeStep model: add `imageUrl` (String?, default null) — optional photo per step
- [x] Update RecipeStep `fromMap()` and `toMap()`

**Widget: PhotoCarousel**
- [x] Create `lib/widgets/photo_carousel.dart`
- [x] PageView.builder, dot indicators, image count badge "1/5" in top-right
- [x] Tap image → opens PhotoViewer (full-screen)
- [x] Single image: show without dots/pagination

**Widget: PhotoViewer**
- [x] Create `lib/widgets/photo_viewer.dart`
- [x] Full-screen overlay, black background, InteractiveViewer (pinch-to-zoom, pan)
- [x] Close button (X), swipe left/right for multiple images, counter "2 of 5"

**Widget: PhotoGrid**
- [x] Create `lib/widgets/photo_grid.dart`
- [x] 1 image → full-width; 2 → side-by-side; 3 → one large + two small; 4+ → 2x2 grid, last cell "+N more" overlay
- [x] Tap any image → PhotoViewer at that index

**AddRecipeScreen Modifications**
- [x] Replace single ImagePickerTile with multi-image picker section
- [x] Horizontal scrollable list + "Add Photo" button at end
- [x] ReorderableListView / LongPressDraggable for drag-to-reorder
- [x] First image = cover image (imageUrl field)
- [x] Use `ImagePicker().pickMultiImage()`

**RecipeDetailScreen Modifications**
- [x] Replace single cover image with PhotoCarousel if `recipe.photos` is not empty
- [x] Fallback to single `imageUrl` display (backward compatible)

**CookingModeScreen Modifications**
- [x] If RecipeStep has imageUrl, show it above step instruction text (height ~150, rounded corners)

**StorageService Modifications**
- [x] `uploadRecipePhotos(String recipeId, List<File> files, {onProgress})` → Future\<List\<String\>\> — upload to `recipes/{recipeId}/photos/{index}`
- [x] `deleteRecipePhotos(String recipeId)` → Future\<void\>

**RecipeFormProvider Modifications**
- [x] Add `additionalPhotos` (List\<File\>) field
- [x] `addPhotos(List<File>)`, `removePhoto(int index)`, `reorderPhotos(int oldIndex, int newIndex)`
- [x] Submit: upload all photos, update recipe document with returned URLs

**Image Compression**
- [x] Add `flutter_image_compress` dependency
- [x] Resize to max 1200px width, 80% quality JPEG before uploading

**l10n**
- [x] Add keys:
  - `addPhotos` / `photoGallery` / `dragToReorder` / `coverPhoto` / `morePhotos` / `photoOf`

**Tests**
- [x] `test/models/recipe_test.dart` — update: photos field serialization, empty default
- [x] `test/models/recipe_step_test.dart` — update: imageUrl field serialization
- [x] `test/widgets/photo_carousel_test.dart` — renders images, dot indicators, page navigation, count badge
- [x] `test/widgets/photo_viewer_test.dart` — renders full-screen, close button, zoom gesture
- [x] `test/widgets/photo_grid_test.dart` — grid layouts for 1/2/3/4+ images, "+N more" overlay

Status: PUSHED (Push 24b)

---

### Task 8: Cooking History — "Cooked It" Log (Push 25)

**Model: CookingLog**
- [x] Create `lib/models/cooking_log.dart`
- [x] Fields: `id`, `recipeId`, `recipeName` (denormalized), `recipeImageUrl` (denormalized), `userId`, `cookedAt` (DateTime), `personalRating` (int? 1-5), `notes` (String?), `photoUrl` (String?), `servings` (int)
- [x] Include `fromMap()`, `toMap()`, `copyWith()`
- [x] Firestore collection: `cooking_logs`, document ID: auto-generated

**Service: CookingLogService**
- [x] Create `lib/services/cooking_log_service.dart`
- [x] `logCook(CookingLog log)` → Future\<void\>
- [x] `getCookingHistory(String userId, {int limit, DocumentSnapshot? startAfter})` → Future\<List\<CookingLog\>\> — paginated, ordered by cookedAt desc
- [x] `getCookCountForRecipe(String userId, String recipeId)` → Future\<int\>
- [x] `getTotalCooksForRecipe(String recipeId)` → Future\<int\> — all users
- [x] `deleteCookingLog(String logId)` / `updateCookingLog(CookingLog log)`
- [x] `streamCookingHistory(String userId)` → Stream\<List\<CookingLog\>\>
- [x] Accept optional `FirebaseFirestore` for DI

**Provider: CookingLogProvider**
- [x] Create `lib/providers/cooking_log_provider.dart`
- [x] Holds: cookingHistory, loading state, cookCountCache (Map\<String, int\>)
- [x] `init(String userId)` — subscribe to stream
- [x] `logCook(Recipe recipe, {int? personalRating, String? notes, File? photo, int servings})` — upload photo if provided, create CookingLog, auto-add meal entry to DailyTracker (before 11am=breakfast, 11am-3pm=lunch, 3pm-8pm=dinner, after 8pm=snack)
- [x] `getCookCount(String recipeId)` — from cache or fetch
- [x] `deleteCookingLog(String logId)` — call service, update local list
- [x] Register in `main.dart` MultiProvider

**Screen: CookingHistoryScreen**
- [x] Create `lib/screens/cooking_history/cooking_history_screen.dart`
- [x] AppBar: "Cooking History", back button
- [x] ListView.builder of CookingLogCard widgets (newest first)
- [x] Tap card → RecipeDetailScreen; long-press/swipe → delete with confirmation
- [x] Empty state: "You haven't cooked anything yet!" with chef hat icon
- [x] Pull-to-refresh, pagination with ScrollController

**Widget: CookingLogCard**
- [x] Create `lib/screens/cooking_history/widgets/cooking_log_card.dart`
- [x] Row: recipe image (60x60), Column (name, date, rating stars, notes preview), trailing photo thumbnail (40x40)

**RecipeDetailScreen Modifications**
- [x] "I Cooked This" GradientButton below existing action buttons
- [x] Tap → bottom sheet: star rating, notes TextField, image picker, servings selector, "Log Cook" submit
- [x] After logging → SnackBar "Cook logged!"
- [x] Show cook count badge: "Cooked 3 times"

**CookingModeScreen Modifications**
- [x] On last step completion → show "Log This Cook" prompt, auto-open cook logging sheet

**RecipeCard Modifications**
- [x] If cook count > 0, show small badge/chip "Cooked x3"

**Route & Access**
- [x] Add GoRoute path `/cooking-history` under parentNavigatorKey
- [x] Access: "Cooking History" row on ProfileScreen (history/clock icon)

**Firestore Rules**
- [x] `cooking_logs` — owner can read/write own documents only

**l10n**
- [x] Add keys:
  - `cookingHistory` / `iCookedThis` / `logCook` / `cookedOn` / `cookedTimes`
  - `personalNotes` / `addResultPhoto` / `noCookingHistory` / `cookLogged`

**Tests**
- [x] `test/models/cooking_log_test.dart` — fromMap/toMap, copyWith, defaults
- [x] `test/services/cooking_log_service_test.dart` — logCook, getCookingHistory pagination, getCookCountForRecipe, delete
- [x] `test/providers/cooking_log_provider_test.dart` — logCook updates list, getCookCount cached, auto-add to daily tracker
- [x] `test/screens/cooking_history/cooking_history_screen_test.dart` — renders list, empty state, card taps

Status: PUSHED (Push 25)

---

### Task 9: Seasonal & Trending Recipes (Push 26)

**Service: TrendingService**
- [x] Create `lib/services/trending_service.dart` — no own Firestore collection, computes from existing data
- [x] `getTrendingRecipes({int limit = 10, String timeWindow = '7d'})` → Future\<List\<Recipe\>\>
  - Score = (recentFavorites x 3) + (ratingCount x 2) + (averageRating x 1) + recency bonus (+5 if created in last 48h)
  - Sort by score desc, return top N
- [x] `getSeasonalRecipes(int month, {int limit = 10})` → Future\<List\<Recipe\>\> — map months to seasons (Dec-Feb=Winter, Mar-May=Spring, Jun-Aug=Summer, Sep-Nov=Autumn), query matching seasonal category tag
- [x] `getSeasonalIngredients(int month)` → List\<String\> — hard-coded month-to-ingredients map
- [x] Accept optional `FirebaseFirestore`

**Provider: TrendingProvider**
- [x] Create `lib/providers/trending_provider.dart`
- [x] Holds: trendingRecipes, seasonalRecipes, seasonalIngredients, loading, lastRefreshed
- [x] `loadTrending()` — cache for 1 hour (check lastRefreshed)
- [x] `loadSeasonal()` / `loadSeasonalIngredients()` / `refresh()`
- [x] Register in `main.dart` MultiProvider

**HomeScreen Modifications**
- [x] "Popular This Week" section: horizontal scrollable compact RecipeCards (~200px wide), max 10, "See All" → TrendingRecipesScreen
- [x] "What's in Season" section: horizontal chip list of seasonal ingredients, tap chip → SearchScreen pre-filtered
- [x] "Popular Now" badge on RecipeCard for trending recipes (flame icon badge on card corner)

**Screen: TrendingRecipesScreen**
- [x] Create `lib/screens/trending/trending_recipes_screen.dart`
- [x] AppBar: "Trending Recipes", filter chips: "This Week" / "This Month" / "All Time"
- [x] ListView of RecipeCard with trending rank badge (#1, #2, #3...)

**RecipeCard Modifications**
- [x] Add optional `showTrendingBadge` (bool) and `trendingRank` (int?) params
- [x] Flame icon overlay + "#1" rank badge

**Seasonal Tags**
- [x] Add "Spring", "Summer", "Autumn", "Winter" to category or dietary tag system (new SeasonalTag enum or extend DietaryTag)

**Route**
- [x] Add GoRoute path `/trending` under parentNavigatorKey

**l10n**
- [x] Add keys:
  - `popularThisWeek` / `trendingRecipes` / `whatsInSeason` / `popularNow`
  - `thisWeek` / `thisMonth` / `allTime` / `seeAll`
  - `spring` / `summer` / `autumn` / `winter`

**Tests**
- [x] `test/services/trending_service_test.dart` — score calculation, sort order, time window filtering, seasonal ingredients for all 12 months
- [x] `test/providers/trending_provider_test.dart` — loadTrending populates list, caching prevents re-fetch within 1 hour, refresh forces reload

---

### Task 10: Ingredient Substitution Suggestions (Push 27)

**Model: IngredientSubstitution**
- [x] Create `lib/models/ingredient_substitution.dart`
- [x] Fields: `id`, `originalIngredient` (lowercase normalized), `substituteName`, `ratio` (e.g. "1:1"), `notes` (String?), `dietaryTags` (List\<String\>), `submittedBy` (String?), `isVerified` (bool)
- [x] `fromMap()`, `toMap()`
- [x] Firestore collection: `substitutions`

**Service: SubstitutionService**
- [x] Create `lib/services/substitution_service.dart`
- [x] `getSubstitutions(String ingredientName)` — query where originalIngredient == name.toLowerCase().trim()
- [x] `getSubstitutionsByTag(String ingredientName, String dietaryTag)` — array-contains filter
- [x] `submitSubstitution(IngredientSubstitution sub)` — add with isVerified: false
- [x] `getAllSubstitutions()` / `verifySubstitution(String id)` / `deleteSubstitution(String id)`
- [x] Accept optional `FirebaseFirestore`

**Seed Firestore**
- [x] 50+ substitution entries:
  - Butter → coconut oil (1:1, vegan), applesauce (1/2 cup per 1 cup, low-fat), Greek yogurt
  - Eggs → flax egg, chia egg, mashed banana, unsweetened applesauce
  - Milk → oat milk, almond milk, soy milk, coconut milk
  - Flour → almond flour, coconut flour, oat flour
  - Sugar → honey, maple syrup, stevia
  - Cream → coconut cream, cashew cream
  - Sour cream → Greek yogurt, coconut yogurt
  - Heavy cream → full-fat coconut milk
  - Breadcrumbs → crushed cornflakes, almond meal
  - Soy sauce → coconut aminos, tamari

**Widget: SubstitutionSheet**
- [x] Create `lib/widgets/substitution_sheet.dart` — showModalBottomSheet
- [x] Header: "Substitutes for {ingredientName}"
- [x] Optional FilterChip row (Vegan, Gluten-Free, Keto, Dairy-Free)
- [x] ListView of substitution cards: name (bold), ratio, notes, dietary chips, verified checkmark
- [x] "Suggest a Substitution" TextButton → form dialog (name, ratio, notes, tags) → service.submitSubstitution()

**RecipeDetailScreen Modifications**
- [x] Each ingredient row: trailing swap icon button → opens SubstitutionSheet for that ingredient
- [x] If no substitutions found, show "No substitutions available"

**Firestore Rules**
- [x] Anyone can read, authenticated can create (isVerified: false), only admins can update isVerified or delete

**l10n**
- [x] Add keys:
  - `substitutions` / `substitutesFor` / `ratio` / `suggestSubstitution` / `noSubstitutions`
  - `substituteName` / `verified` / `communitySubmitted` / `thankYouSubstitution`

**Tests**
- [x] `test/models/ingredient_substitution_test.dart` — fromMap/toMap, dietaryTags list serialization
- [x] `test/services/substitution_service_test.dart` — getSubstitutions, getSubstitutionsByTag, submitSubstitution with isVerified false
- [x] `test/widgets/substitution_sheet_test.dart` — loads/displays substitutions, filter chips, suggest form

---

### Task 11: Achievement Badges & Gamification (Push 28)

**Model: Achievement**
- [x] Create `lib/models/achievement.dart`
- [x] Fields: `id` (predefined badge ID), `title`, `description`, `iconName`, `criteria` (Map\<String, dynamic\>), `category` ("cooking"/"social"/"health"/"exploration")
- [x] Static definition: `static const List<Achievement> allAchievements = [...]` with 12+ badges:
  1. `first_recipe` — "First Recipe" / publish 1 recipe
  2. `recipe_master` — "Recipe Master" / publish 10 recipes
  3. `streak_7` — "7-Day Streak" / log meals 7 consecutive days
  4. `streak_30` — "30-Day Streak" / log meals 30 consecutive days
  5. `top_rated` — "Top Rated" / 5-star average rating
  6. `home_chef` — "Home Chef" / cook 10 different recipes
  7. `health_nut` — "Health Nut" / hit all macro targets for a week
  8. `hydration_hero` — "Hydration Hero" / hit water goal 7 days in a row
  9. `social_butterfly` — "Social Butterfly" / gain 10 followers
  10. `smart_shopper` — "Smart Shopper" / create 5 shopping lists
  11. `collector` — "Collector" / create 3 recipe collections
  12. `explorer` — "Explorer" / try recipes from 5 categories

**Model: UserAchievement**
- [x] Create `lib/models/user_achievement.dart`
- [x] Fields: `id`, `achievementId`, `userId`, `unlockedAt` (DateTime)
- [x] `fromMap()`, `toMap()`
- [x] Firestore collection: `user_achievements`

**Service: AchievementService**
- [x] Create `lib/services/achievement_service.dart`
- [x] `getUserAchievements(String userId)` / `streamUserAchievements(String userId)`
- [x] `unlockAchievement(String userId, String achievementId)` — check for duplicates first
- [x] `checkAndUnlockAchievements(String userId, {required Map<String, dynamic> context})` → Future\<List\<Achievement\>\> — check all criteria against context, unlock newly met ones, return newly unlocked
- [x] `getProgress(String userId, Achievement achievement)` → Future\<double\> (0.0–1.0)
- [x] Accept optional `FirebaseFirestore`

**Provider: AchievementProvider**
- [x] Create `lib/providers/achievement_provider.dart`
- [x] Holds: unlockedAchievements, progressMap, newlyUnlocked (for celebration UI)
- [x] `init(String userId)` — subscribe to stream, load initial progress
- [x] `checkAchievements()` — gather stats from other providers, call service, update newlyUnlocked
- [x] `getProgress(String achievementId)` / `clearNewlyUnlocked()`
- [x] Call checkAchievements() after key user actions (publish recipe, log meal, gain follower, etc.)
- [x] Register in `main.dart` MultiProvider

**Screen: AchievementsScreen**
- [x] Create `lib/screens/achievements/achievements_screen.dart`
- [x] AppBar: "Achievements", GridView.builder (2 columns)
- [x] Each cell: icon, title, unlocked → full color + gold border + "Unlocked on {date}", locked → greyed + dashed border + progress bar
- [x] Tap card → bottom sheet with full description, criteria, progress
- [x] Category filter chips: All, Cooking, Social, Health, Exploration

**Achievement Celebration Widget**
- [x] Overlay when `newlyUnlocked` is not empty: dark semi-transparent background, centered card with animated icon, title, description, confetti/sparkle animation, "Awesome!" dismiss button
- [x] Show in main shell/scaffold, call `clearNewlyUnlocked()` on dismiss

**ProfileScreen Modifications**
- [x] "Achievements" section: 3 most recent unlocked badges as small icons, "View All" → AchievementsScreen
- [x] "X of 12 achievements unlocked" count

**Route**
- [x] Add GoRoute path `/achievements` under parentNavigatorKey

**Firestore Rules**
- [x] `user_achievements` — owner can read own, system/admin can write

**l10n**
- [x] Add keys:
  - `achievements` / `achievementUnlocked` / `unlockedOn` / `progress` / `awesome`
  - All 12 badge names and their Turkish translations
  - `viewAllAchievements` / `achievementsUnlocked`

**Tests**
- [x] `test/models/achievement_test.dart` — allAchievements completeness, criteria structure
- [x] `test/models/user_achievement_test.dart` — fromMap/toMap round-trip
- [x] `test/services/achievement_service_test.dart` — unlockAchievement, no duplicate, checkAndUnlockAchievements with contexts, getProgress
- [x] `test/providers/achievement_provider_test.dart` — init loads list, checkAchievements detects new, clearNewlyUnlocked

---

### Task 12: Recipe Versioning & Edit History (Push 29)

**Model: RecipeVersion**
- [ ] Create `lib/models/recipe_version.dart`
- [ ] Fields: `id`, `recipeId`, `versionNumber` (int, starts at 1), `changes` (Map — diff: {"title": {"old": "...", "new": "..."}}), `snapshot` (Map — full toMap() for revert), `editedAt` (DateTime), `editedBy` (String)
- [ ] `fromMap()`, `toMap()`
- [ ] Firestore: subcollection `recipes/{recipeId}/versions/{versionId}`

**Service: RecipeVersionService**
- [ ] Create `lib/services/recipe_version_service.dart`
- [ ] `saveVersion(String recipeId, Recipe oldRecipe, Recipe newRecipe, String userId)` — compute diff, determine next versionNumber, save to subcollection
- [ ] `getVersionHistory(String recipeId)` → ordered by versionNumber desc
- [ ] `getVersion(String recipeId, String versionId)` → Future\<RecipeVersion?\>
- [ ] `revertToVersion(String recipeId, String versionId)` — read snapshot, update main recipe, save new version recording revert

**RecipeService Modifications**
- [ ] On recipe update, call `RecipeVersionService.saveVersion()` with old and new data before saving

**Screen: RecipeVersionHistoryScreen**
- [ ] Create `lib/screens/recipe_detail/version_history_screen.dart`
- [ ] Timeline-style ListView: version badge (#1, #2...), date + editor name, change summary, "Revert" button (owner only)
- [ ] Tap entry → detailed diff view (old → new for each changed field)

**RecipeDetailScreen Modifications**
- [ ] "Edit History" in overflow menu (owner only) → RecipeVersionHistoryScreen

**Route**
- [ ] Add GoRoute path `/recipe/:id/versions`

**l10n**
- [ ] Add keys:
  - `editHistory` / `version` / `editedBy` / `revertToVersion` / `confirmRevert` / `changedFields`

**Tests**
- [ ] `test/models/recipe_version_test.dart` — fromMap/toMap, diff structure
- [ ] `test/services/recipe_version_service_test.dart` — saveVersion diff, versionNumber increments, revertToVersion restores, getVersionHistory ordering

---

### Task 13: Advanced Search & Filters (Push 30)

**SearchProvider Enhancements**
- [ ] Add filter fields: `cookTimeRange` (RangeValues?), `calorieRange` (RangeValues?), `difficultyLevel` (String?), `maxIngredientCount` (int?), `sortBy` (String)
- [ ] Apply all active filters simultaneously
- [ ] `searchHistory` (List\<String\>) persisted in SharedPreferences — last 10 searches
- [ ] Search suggestions: matching recipe titles + recent history as user types

**SearchScreen Enhancements**
- [ ] "Filters" button → filter bottom sheet:
  - Cooking time RangeSlider (0–120+ min) + preset chips: Quick (<15), Medium (15-30), Standard (30-60), Long (60+)
  - Calorie range RangeSlider (0–1000+ cal)
  - Difficulty: SegmentedButton (Easy / Medium / Hard)
  - Max ingredients: Slider (1-20)
  - Sort by: ChoiceChip row (Newest, Popular, Rating, Cook Time, Calories)
  - "Apply Filters" + "Clear All" buttons
- [ ] Active filter count badge on Filters button
- [ ] Empty search field → recent search history as chips (tap to re-search, X to remove)
- [ ] Auto-complete suggestions dropdown as user types

**"Search by Ingredients" Feature**
- [ ] Tab/button on SearchScreen for ingredient-based search
- [ ] Chip input pattern: add ingredient names one by one
- [ ] Filter: recipes where ALL entered ingredients exist (case-insensitive contains)
- [ ] Sort by matching ingredient count (best matches first)

**l10n**
- [ ] Add keys:
  - `filters` / `cookingTime` / `quickUnder15` / `medium15to30` / `standard30to60` / `longOver60`
  - `calorieRange` / `difficulty` / `easy` / `medium` / `hard` / `maxIngredients`
  - `sortBy` / `popular` / `applyFilters` / `clearAll` / `recentSearches`
  - `searchByIngredients` / `addIngredient` / `bestMatches`

**Tests**
- [ ] `test/providers/search_provider_test.dart` — multi-filter combos, cookTime range, calorie range, difficulty, sort options, search history persistence, ingredient-based matching, suggestions

---

### Task 14: Offline Support & Caching (Push 31)

**Dependencies**
- [ ] `flutter pub add hive hive_flutter connectivity_plus`

**CacheService**
- [ ] Create `lib/services/cache_service.dart`
- [ ] `initialize()` — Hive.initFlutter(), open boxes: 'recipes', 'food_items', 'daily_logs', 'user_prefs'
- [ ] `cacheRecipes()` / `getCachedRecipes()` / `cacheFoodItems()` / `getCachedFoodItems()`
- [ ] `cacheDailyLog()` / `getCachedDailyLog(DateTime date)`
- [ ] `queueOfflineAction(Map action)` / `getOfflineQueue()` / `clearOfflineQueue()`
- [ ] `getCacheSize()` / `clearAllCaches()`

**ConnectivityService**
- [ ] Create `lib/services/connectivity_service.dart`
- [ ] `isOnline()` → Future\<bool\>
- [ ] `onConnectivityChanged` → Stream\<bool\>

**SyncService**
- [ ] Create `lib/services/sync_service.dart`
- [ ] `syncOfflineQueue(String userId)` — replay queue against Firestore, remove on success, keep on failure
- [ ] `fullSync(String userId)` — download all user recipes/food items/daily logs, cache locally (on app launch when online)

**Provider Modifications**
- [ ] RecipeProvider: if online → stream + cache; if offline → load from CacheService; offline creates → queue action
- [ ] FoodItemProvider: same cache pattern
- [ ] DailyTrackerProvider: cache daily logs, queue offline meal entries

**UI: Connectivity Indicator**
- [ ] Create `lib/widgets/connectivity_indicator.dart`
- [ ] Offline: colored bar "You're offline — changes will sync when connected" (yellow/orange)
- [ ] Online: "Back online — syncing..." briefly, then hide
- [ ] Add to ShellScreen scaffold

**Settings: Cache Management**
- [ ] "Storage & Cache" on ProfileScreen → bottom sheet: cache size, clear buttons, offline queue status

**l10n**
- [ ] Add keys:
  - `youreOffline` / `changesSyncWhenConnected` / `backOnline`
  - `storageAndCache` / `cacheSize` / `clearCache` / `pendingSync`

**Tests**
- [ ] `test/services/cache_service_test.dart` — cache/retrieve, queue, getCacheSize, clearAll
- [ ] `test/services/sync_service_test.dart` — replay queue, handle conflicts, fullSync
- [ ] `test/widgets/connectivity_indicator_test.dart` — offline bar, hide when online

---

### Task 15: Recipe Video Support (Push 32)

**Dependencies**
- [ ] `flutter pub add video_player chewie video_compress`

**Model Updates**
- [ ] Recipe: add `videoUrl` (String?, default null)
- [ ] RecipeStep: add `videoUrl` (String?, default null)
- [ ] Update `fromMap()` / `toMap()` for both

**StorageService Enhancements**
- [ ] `uploadRecipeVideo(String recipeId, File videoFile, {onProgress})` → Future\<String\> — upload to `recipes/{recipeId}/video`, return URL, listen to snapshotEvents for progress
- [ ] `deleteRecipeVideo(String recipeId)`
- [ ] `generateVideoThumbnail(File videoFile)` → Future\<File\> — video_compress first frame

**Widget: VideoPlayerWidget**
- [ ] Create `lib/widgets/video_player_widget.dart`
- [ ] Wraps Chewie player: videoUrl, autoPlay, showControls
- [ ] Dispose controllers, thumbnail/placeholder until loaded, error handling

**Screen Modifications**
- [ ] AddRecipeScreen: "Add Video" button, pickVideo(), thumbnail preview, compress before upload, per-step video option
- [ ] RecipeDetailScreen: VideoPlayerWidget if videoUrl exists (toggle photo/video)
- [ ] CookingModeScreen: VideoPlayerWidget for step videos (compact, above instructions)
- [ ] RecipeCard: play button overlay if recipe has video

**l10n**
- [ ] Add keys: `addVideo` / `recordVideo` / `videoUnavailable` / `uploadingVideo` / `compressingVideo` / `stepVideo`

**Tests**
- [ ] `test/models/recipe_test.dart` — videoUrl serialization
- [ ] `test/widgets/video_player_widget_test.dart` — renders player, placeholder on error

---

### Task 16: Social Features Enhancement (Push 33)

**Recipe Likes (separate from favorites)**
- [ ] Add likeCount + likedBy to Recipe model, or separate `likes` collection
- [ ] `LikeService` — toggleLike, getLikeCount, isLikedBy
- [ ] `LikeProvider` — manages like state
- [ ] UI: heart/thumbs-up button on RecipeCard + RecipeDetailScreen (separate from favorite star)

**Threaded Comments**
- [ ] Update Comment model: add `parentCommentId` (String?)
- [ ] CommentService: `getReplies(recipeId, parentCommentId)`
- [ ] UI: indent replies, "Reply" button, reply count, collapse/expand

**Report System**
- [ ] Model: Report — id, reporterId, targetType, targetId, reason, createdAt, status
- [ ] `ReportService` — submitReport, getReports (admin)
- [ ] UI: "Report" in overflow menu on recipes/comments, reason selection dialog

**Block User**
- [ ] blockedUsers on UserModel or `blocks` collection
- [ ] `BlockService` — blockUser, unblockUser, isBlocked
- [ ] Filter blocked users from feed, search, comments
- [ ] UI: "Block User" on profile overflow menu

**Activity Feed**
- [ ] Model: Activity — id, userId, actorId, actorName, type, targetId, targetName, createdAt, isRead
- [ ] `ActivityService` — write activities on events
- [ ] `ActivityScreen` — recent activities, mark as read, badge count on notification icon

**Other**
- [ ] Share to social media: extend share_plus for platform-specific formatting
- [ ] User mentions: detect @username in comments, linkify, notify mentioned user

**l10n & Tests**
- [ ] Add keys for all social features
- [ ] Tests: LikeService, threaded comments, ReportService, BlockService, ActivityService

---

### Task 17: Recipe Cost Estimation (Push 34)

**Model Updates**
- [ ] FoodItem: add `pricePerUnit` (double?), `currency` (String, default "TRY")

**Cost Calculation**
- [ ] Create `lib/utils/cost_calculator.dart`:
  - `calculateRecipeCost(ingredients, foodItemMap)` → double
  - `calculateCostPerServing(totalCost, servings)` → double

**Currency Support**
- [ ] Create `lib/utils/currency_utils.dart`:
  - Supported: TRY, USD, EUR, GBP
  - `formatCurrency(amount, currencyCode)` → String
  - Hard-coded exchange rates for MVP

**Screen Modifications**
- [ ] RecipeDetailScreen: "Estimated Cost" section below nutrition (only if ingredients have prices)
- [ ] FoodItemDetailScreen / AddFoodItemScreen: price input + currency selector
- [ ] SearchScreen / HomeScreen: "Budget-Friendly" filter or price range slider
- [ ] Settings: currency preference on ProfileScreen

**l10n & Tests**
- [ ] Add keys for cost strings
- [ ] Tests: cost calculation, currency formatting, per-serving math

---

### Task 18: Accessibility & Performance (Push 35)

**Accessibility**
- [ ] Semantic labels: audit all screens, add Semantics widgets, semanticLabel on Icons/Images
- [ ] High contrast mode: detect MediaQuery.highContrast, alt color scheme (WCAG AA 4.5:1)
- [ ] Dynamic font scaling: all Text uses theme TextStyle, test with largest system font, fix overflow

**Performance**
- [ ] Lazy loading / pagination: RecipeProvider paginated stream (.limit() + .startAfterDocument()), ScrollController loadMore(), 10 per page
- [ ] Image lazy loading: CachedNetworkImage, shimmer placeholder, fadeInDuration
- [ ] DevTools profiling: fix jank, const constructors, RepaintBoundary, minimize setState scope

**Bundle Size**
- [ ] Remove unused assets, --split-debug-info, --obfuscate for release, analyze with `flutter build apk --analyze-size`

**Tests**
- [ ] Accessibility widget tests (find.bySemanticsLabel), font scaling overflow tests

---

### Task 19: Recipe AI Suggestions (Push 36)

**Rule-Based Recommendation (no external AI API for MVP)**
- [ ] "Similar Recipes" on RecipeDetailScreen: same category, overlapping tags/ingredients, score by overlap, top 5
- [ ] "You Might Also Like" on HomeScreen: based on cooking history + favorites, same categories, exclude already favorited/cooked
- [ ] "What Should I Cook?" button: random recipe with optional filters, "Try Another" button
- [ ] "Nutritional Recommendations": compare today's nutrition vs goals, suggest recipes filling the gap

**Implementation**
- [ ] `SuggestionService` — `lib/services/suggestion_service.dart`
- [ ] `SuggestionProvider` — `lib/providers/suggestion_provider.dart`
- [ ] RecipeDetailScreen: "Similar Recipes" horizontal list below comments
- [ ] HomeScreen: "You Might Also Like" section
- [ ] "Discover" FAB or screen from HomeScreen

**l10n & Tests**
- [ ] Add keys for suggestion strings
- [ ] Tests: recommendation scoring, filter combos, nutritional gap calculation

---

### Task 20: Multi-Language Recipe Content (Push 37)

- [ ] Recipe model: add `translations` (Map\<String, Map\<String, String\>\>?) — language code → {title, description, steps, ingredients}
- [ ] `TranslationService` — submit/fetch translations
- [ ] UI: language toggle on RecipeDetailScreen, translation request button
- [ ] Community translation submission form
- [ ] l10n keys for translation feature

---

### Task 21: Widgets & Quick Actions (Push 38)

- [ ] iOS/Android home screen widgets (home_widget package): daily nutrition summary, quick "Add Meal" action
- [ ] Quick Actions (quick_actions package): iOS 3D Touch + Android App Shortcuts (Add Recipe, Track Meal, Shopping List)
- [ ] Siri Shortcuts (if applicable)
- [ ] Tests: widget data provider logic

---

### Task 22: Data Export & Backup (Push 39)

- [ ] Export recipes as JSON (serialize → save to downloads or share)
- [ ] Export as PDF cookbook (pdf package: formatted with images, ingredients, steps)
- [ ] Export daily tracker as CSV (date, meal type, food item, calories, protein, carbs, fat)
- [ ] Import recipes from JSON (file picker → parse → create in Firestore)
- [ ] Cloud backup: Google Drive API integration for automatic backup
- [ ] Settings: backup frequency selector (daily/weekly/manual), last backup timestamp
- [ ] l10n keys for export/backup strings
- [ ] Tests: JSON round-trip, CSV validation, PDF generation

---

### Task 23: App Store Preparation (Push 40)

- [ ] App icon: flutter_launcher_icons from high-res source (adaptive Android + standard iOS)
- [ ] Splash screen: flutter_native_splash (logo centered, theme background, light + dark variants)
- [ ] App Store screenshots: iPhone 14 Pro Max (6.7") + iPhone 8 Plus (5.5"), 5-6 key features
- [ ] Play Store: feature graphic (1024x500), screenshots, descriptions
- [ ] Privacy policy page (web or in-app WebView)
- [ ] Terms of service page
- [ ] App Store descriptions in English + Turkish
- [ ] TestFlight: configure App Store Connect, upload via Xcode
- [ ] Google Play: internal testing track, upload AAB
- [ ] Version: semantic versioning (1.0.0), CHANGELOG.md
