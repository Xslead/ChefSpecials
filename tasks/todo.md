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

## App Statistics

 Total Dart files: 110 (lib) + 58 (test) = 168
 Tests: 1029 (0 failures)
 Screens implemented: 29
 Models: 15 (added MealPlan, PlannedMeal)
 Services: 14 (added MealPlanService)
 Providers: 15 (added MealPlanProvider)
 Routes: 26
 l10n keys: 246 (EN + TR)

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

### Task 2: Weekly/Monthly Reports (Push 19)

**Provider: ReportsProvider**
- [ ] Create `lib/providers/reports_provider.dart`
- [ ] Extends `ChangeNotifier`, does NOT need its own Firestore collection — reads existing `daily_logs` via DailyTrackerService
- [ ] Holds: selectedTab (weekly/monthly), selectedDateRange, aggregated data maps, loading state
- [ ] `loadWeeklyData(String userId, DateTime weekStart)` — query daily_logs for 7 days, aggregate into List\<DailyNutritionSummary\> with {date, totalCalories, totalProtein, totalCarbs, totalFat} for bar chart
- [ ] `loadMonthlyData(String userId, DateTime month)` — query daily_logs for entire month (1st to last day), aggregate daily summaries for line charts
- [ ] `calculateMacroDistribution()` → {protein: %, carbs: %, fat: %} — for pie chart
- [ ] `calculateStreak(String userId)` → Future\<int\> — count consecutive days with at least one meal entry
- [ ] `calculateAverages()` → {avgCalories, avgProtein, avgCarbs, avgFat} — arithmetic mean over loaded period
- [ ] `setDateRange(DateTime start, DateTime end)` — for custom report periods, reload data
- [ ] Register in `main.dart` MultiProvider

**Screen: ReportsScreen**
- [ ] Create `lib/screens/reports/reports_screen.dart`
- [ ] Full-screen page, AppBar: "Reports", back button
- [ ] TabBarView with 2 tabs — "Weekly" and "Monthly"
- [ ] **Weekly tab:**
  - Week selector row (left/right arrows + "Mar 10 – Mar 16" label)
  - fl_chart BarChart: x-axis = 7 day labels (Mon–Sun), y-axis = calories, tap bar for tooltip
  - Average daily intake card: Row of 4 stat items (Avg Cal, Avg Protein, Avg Carbs, Avg Fat)
  - Streak card: "Current Streak: X days" with fire icon
- [ ] **Monthly tab:**
  - Month selector row (left/right arrows + "March 2026" label)
  - fl_chart LineChart: x-axis = day numbers (1-31), 4 colored lines for calories/protein/carbs/fat, legend below
  - fl_chart PieChart: macro distribution (protein/carbs/fat as percentages)
  - Monthly averages card
- [ ] Bottom: "Export as Image" button — RepaintBoundary + toImage() → share via share_plus
- [ ] Use `Consumer<ReportsProvider>`

**Route**
- [ ] Add GoRoute path `/reports` in `lib/config/routes.dart` under parentNavigatorKey
- [ ] Access point: "Reports" row/button on ProfileScreen

**l10n**
- [ ] Add keys to `app_en.arb` and `app_tr.arb`:
  - `reports` / "Reports" / "Raporlar"
  - `weekly` / "Weekly" / "Haftalik"
  - `monthly` / "Monthly" / "Aylik"
  - `averageDailyIntake` / "Average Daily Intake" / "Gunluk Ortalama Alim"
  - `currentStreak` / "Current Streak" / "Mevcut Seri"
  - `days` / "days" / "gun"
  - `macroDistribution` / "Macro Distribution" / "Makro Dagilimi"
  - `exportAsImage` / "Export as Image" / "Gorsel Olarak Disa Aktar"
  - `noDataForPeriod` / "No data for this period" / "Bu donem icin veri yok"

**Tests**
- [ ] `test/providers/reports_provider_test.dart` — loadWeeklyData aggregation, loadMonthlyData across month boundaries, calculateStreak with gaps, calculateAverages, calculateMacroDistribution sums to 100, custom date range
- [ ] `test/screens/reports/reports_screen_test.dart` — tabs render, bar chart shows 7 bars for weekly, line chart renders for monthly, export button exists

---

### Task 3: Push Notifications (Push 20b)

**Firebase Cloud Messaging Setup**
- [ ] Add `firebase_messaging` dependency (`flutter pub add firebase_messaging`)
- [ ] Add `flutter_local_notifications` dependency
- [ ] Android: update `AndroidManifest.xml` with notification channel metadata + RECEIVE permission, add default notification icon in `drawable/`
- [ ] iOS: enable Push Notifications capability in Xcode, request permission via `FirebaseMessaging.instance.requestPermission()`
- [ ] Initialize FCM in `main.dart` after `Firebase.initializeApp()`:
  - `await FirebaseMessaging.instance.requestPermission();`
  - `FirebaseMessaging.onBackgroundMessage(_backgroundHandler);`

**Service: NotificationService**
- [ ] Create `lib/services/notification_service.dart`
- [ ] `initialize()` — set up flutter_local_notifications plugin, create Android channel "meal_reminders" (high importance), set up FCM onMessage foreground listener, set up onMessageOpenedApp for navigation
- [ ] `getFcmToken()` → Future\<String?\>
- [ ] `saveFcmToken(String userId, String token)` — write to Firestore users/{userId}
- [ ] `subscribeToTopic(String topic)` / `unsubscribeFromTopic(String topic)` — for "new_recipes", "followed_users"
- [ ] `scheduleMealReminder(String mealType, int hour, int minute)` — zonedSchedule daily local notification, ID = hash of mealType
- [ ] `cancelMealReminder(String mealType)` / `cancelAllReminders()`
- [ ] Accept optional `FirebaseFirestore` parameter for DI

**Provider: NotificationProvider**
- [ ] Create `lib/providers/notification_provider.dart`
- [ ] Extends `ChangeNotifier`, holds: notificationsEnabled, mealReminderSettings (Map\<String, TimeOfDay?\>), followedUserAlerts, commentAlerts, followAlerts
- [ ] Persist settings in SharedPreferences
- [ ] `init()` — load settings, call service.initialize()
- [ ] `toggleMealReminder(String mealType, bool enabled, TimeOfDay? time)` — save to prefs, schedule/cancel
- [ ] `toggleFollowedUserAlerts(bool)` — subscribe/unsubscribe FCM topic
- [ ] `toggleCommentAlerts(bool)` / `toggleFollowAlerts(bool)` — save to prefs
- [ ] Register in `main.dart` MultiProvider

**Screen: NotificationSettingsScreen**
- [ ] Create `lib/screens/profile/notification_settings_screen.dart`
- [ ] Full-screen page, AppBar: "Notification Settings", back button
- [ ] ListView with SwitchListTile items:
  - "Breakfast Reminder" toggle + time picker (default 08:00)
  - "Lunch Reminder" toggle + time picker (default 12:00)
  - "Dinner Reminder" toggle + time picker (default 19:00)
  - "New Recipes from Followed Users" toggle
  - "Comments on My Recipes" toggle
  - "New Followers" toggle
- [ ] Time pickers: tap trailing time label → showTimePicker
- [ ] Use `Consumer<NotificationProvider>`

**Route**
- [ ] Add GoRoute path `/notification-settings` under parentNavigatorKey
- [ ] Access point: "Notifications" row on ProfileScreen (bell icon) above theme toggle

**l10n**
- [ ] Add keys to `app_en.arb` and `app_tr.arb`:
  - `notificationSettings` / "Notification Settings" / "Bildirim Ayarlari"
  - `breakfastReminder` / "Breakfast Reminder" / "Kahvalti Hatirlatici"
  - `lunchReminder` / "Lunch Reminder" / "Ogle Yemegi Hatirlatici"
  - `dinnerReminder` / "Dinner Reminder" / "Aksam Yemegi Hatirlatici"
  - `newRecipeAlerts` / "New Recipes from Followed Users" / "Takip Ettiklerden Yeni Tarifler"
  - `commentAlerts` / "Comments on My Recipes" / "Tariflerime Yapilan Yorumlar"
  - `followerAlerts` / "New Followers" / "Yeni Takipciler"
  - `timeForMeal` / "Time for {meal}!" / "{meal} vakti!"

**Tests**
- [ ] `test/services/notification_service_test.dart` — token retrieval, topic subscribe/unsubscribe
- [ ] `test/providers/notification_provider_test.dart` — toggle states, SharedPreferences persistence, meal reminder scheduling calls

---

### Task 4: Admin Panel (Push 21)

**UserModel Update**
- [ ] Add `isAdmin` (bool, default false) to `lib/models/user_model.dart`
- [ ] Update `fromMap()`: read `'isAdmin' ?? false`
- [ ] Update `toMap()`: include `'isAdmin'`
- [ ] Manually set `isAdmin: true` on your own user document in Firestore console for testing

**Service: AdminService**
- [ ] Create `lib/services/admin_service.dart`
- [ ] `getDashboardStats()` → Future\<Map\<String, int\>\> — count docs in `users`, `recipes`, `comments`, count active-today users
- [ ] `getAllUsers({String? searchQuery, int limit, DocumentSnapshot? startAfter})` → Future\<List\<UserModel\>\> — paginated, searchable
- [ ] `banUser(String userId)` / `unbanUser(String userId)` — set isBanned field
- [ ] `getAllRecipes({String? searchQuery, int limit, DocumentSnapshot? startAfter})` → Future\<List\<Recipe\>\> — paginated admin review
- [ ] `deleteRecipe(String recipeId)` — cascade cleanup (favorites, ratings, comments, collections)
- [ ] `getFlaggedComments()` → Future\<List\<Comment\>\> — query where isFlagged == true
- [ ] `deleteComment(String recipeId, String commentId)`
- [ ] `getCategories()` / `addCategory(String name)` / `deleteCategory(String categoryId)`
- [ ] Accept optional `FirebaseFirestore` parameter for DI

**Provider: AdminProvider**
- [ ] Create `lib/providers/admin_provider.dart`
- [ ] Extends `ChangeNotifier`, holds: dashboardStats, usersList, recipesList, flaggedComments, categories, loading states
- [ ] Methods wrap AdminService calls + notifyListeners()
- [ ] Register in `main.dart` MultiProvider (only if user.isAdmin)

**Screens**
- [ ] `AdminDashboardScreen` — `lib/screens/admin/admin_dashboard_screen.dart`
  - GridView: 4 stat cards (total users, recipes, comments, active today)
  - Navigation items: Manage Users, Recipes, Comments, Categories, Food Items
- [ ] `AdminUsersScreen` — `lib/screens/admin/admin_users_screen.dart`
  - Search, paginated list, avatar/name/email/date/banned badge, swipe to ban/unban
- [ ] `AdminRecipesScreen` — `lib/screens/admin/admin_recipes_screen.dart`
  - Search, paginated list, image/title/author/date/rating, popup: View/Delete
- [ ] `AdminCommentsScreen` — `lib/screens/admin/admin_comments_screen.dart`
  - Flagged comments list, actions: Delete Comment, View Recipe
- [ ] `AdminCategoriesScreen` — `lib/screens/admin/admin_categories_screen.dart`
  - Category list with delete, FAB to add new (text input dialog), swipe-to-delete

**Route & Access**
- [ ] Admin route guard: redirect if `!user.isAdmin` → home
- [ ] Routes: `/admin`, `/admin/users`, `/admin/recipes`, `/admin/comments`, `/admin/categories` (all under parentNavigatorKey)
- [ ] ProfileScreen: "Admin Panel" ListTile (shield icon) — visible only when `isAdmin == true`

**Firestore Rules**
- [ ] Add admin rules for user updates, deploy with `firebase deploy --only firestore:rules`

**l10n**
- [ ] Add keys:
  - `adminPanel` / "Admin Panel" / "Yonetici Paneli"
  - `adminDashboard` / "Admin Dashboard" / "Yonetici Panosu"
  - `totalUsers` / `totalRecipes` / `totalComments` / `activeToday`
  - `manageUsers` / `manageRecipes` / `moderateComments` / `manageCategories`
  - `banUser` / `unbanUser` / `banned` / `confirmDelete`

**Tests**
- [ ] `test/services/admin_service_test.dart` — getDashboardStats, ban/unban toggle, getAllUsers pagination + search, deleteRecipe cascade
- [ ] `test/providers/admin_provider_test.dart` — loadDashboard updates stats, banUser updates list, categories CRUD

---

### Task 5: Unit Converter + Recipe Scaling (Push 22)

**Utility: UnitConverter**
- [ ] Create `lib/utils/unit_converter.dart` — pure static class
- [ ] `convertWeight(double value, WeightUnit from, WeightUnit to)` — Enums: g, kg, oz, lb (1 kg=1000g, 1 oz=28.3495g, 1 lb=453.592g)
- [ ] `convertVolume(double value, VolumeUnit from, VolumeUnit to)` — Enums: mL, L, cups, tbsp, tsp, flOz (1 L=1000mL, 1 cup=236.588mL, 1 tbsp=14.787mL, 1 tsp=4.929mL, 1 fl oz=29.5735mL)
- [ ] `convertTemperature(double value, TempUnit from, TempUnit to)` — celsius/fahrenheit
- [ ] `scaleIngredient(double originalAmount, int originalServings, int newServings)` → double
- [ ] `smartFormat(double value, String unit)` → String — auto-simplify (1000g→kg, 1000mL→L), round 1 decimal

**Widget: UnitConverterSheet**
- [ ] Create `lib/widgets/unit_converter_sheet.dart` — showModalBottomSheet
- [ ] TextField for input value, two DropdownButtons (From/To unit), SegmentedButton for category (Weight | Volume | Temperature)
- [ ] Result display (large, bold), "Copy" button
- [ ] Triggered from: RecipeDetailScreen ingredient list (tap → pre-filled) and CookingModeScreen AppBar icon

**Widget: ServingSizeSelector**
- [ ] Create `lib/widgets/serving_size_selector.dart`
- [ ] Row: minus IconButton, serving count Text, plus IconButton
- [ ] Min 1, max 20, displays "Serves X"
- [ ] Placed on RecipeDetailScreen below recipe info, above ingredient list

**RecipeDetailScreen Modifications**
- [ ] Add ServingSizeSelector between recipe info and ingredients
- [ ] Track selectedServings in local state (default = recipe.servings)
- [ ] Recalculate ingredient amounts via `UnitConverter.scaleIngredient()`
- [ ] Recalculate displayed nutrition totals: per-serving nutrition x selectedServings
- [ ] Each ingredient row: onTap opens UnitConverterSheet pre-filled

**CookingModeScreen Modification**
- [ ] Add unit converter icon button in AppBar → opens empty UnitConverterSheet

**l10n**
- [ ] Add keys:
  - `unitConverter` / `serves` / `fromUnit` / `toUnit`
  - `weight` / `volume` / `temperature`
  - `tapToConvert` / `copied`

**Tests**
- [ ] `test/utils/unit_converter_test.dart` — all weight conversions, all volume conversions, temperature (0C=32F, 100C=212F, -40C=-40F), scaleIngredient, smartFormat
- [ ] `test/widgets/unit_converter_sheet_test.dart` — category switching, input/output, pre-fill from ingredient
- [ ] `test/widgets/serving_size_selector_test.dart` — increment/decrement, min/max bounds, callback

---

### Task 6: Onboarding Flow (Push 23)

**Screen: OnboardingScreen**
- [ ] Create `lib/screens/onboarding/onboarding_screen.dart`
- [ ] Full-screen (no AppBar, no bottom nav), shown ONLY on first launch
- [ ] PageView with PageController, 4 pages, dot indicators, "Skip" (top-right), "Next" / "Get Started" (last page)
- [ ] **Page 1 — Welcome:** app icon/logo, "Welcome to ChefSpecials", "Discover, cook, and share delicious recipes", animated fade-in
- [ ] **Page 2 — Features Overview:** 3 rows (icon + title + description):
  - Track icon + "Track Your Nutrition" + "Log meals and monitor your daily intake"
  - Calendar icon + "Plan Your Meals" + "Organize your weekly meal plan"
  - Share icon + "Share Recipes" + "Connect with food lovers and share your creations"
- [ ] **Page 3 — Dietary Preferences:** "Select your dietary preferences" + Wrap of FilterChips (Vegan, Vegetarian, Gluten-Free, Keto, Halal, Dairy-Free, Nut-Free, Low-Carb), multi-select
- [ ] **Page 4 — Nutrition Goals:** "Set your daily goals" + 4 Sliders/TextFields:
  - Calories (1000–4000, default 2000)
  - Protein (30–300g, default 50g)
  - Carbs (50–500g, default 250g)
  - Fat (20–200g, default 65g)
- [ ] On "Get Started" tap:
  1. Save `hasCompletedOnboarding = true` to SharedPreferences
  2. If logged in → save dietary preferences to user document
  3. If logged in → save nutrition goals via `DailyTrackerService.setNutritionGoal()`
  4. Navigate to LoginScreen (not logged in) or HomeScreen (logged in)

**Route**
- [ ] Initial redirect in `lib/config/routes.dart`: check SharedPreferences for `hasCompletedOnboarding`, if false → `/onboarding`
- [ ] Route: `/onboarding` → OnboardingScreen (no back button, no bottom nav)

**l10n**
- [ ] Add keys:
  - `welcome` / `discoverCookShare` / `trackYourNutrition` / `planYourMeals` / `shareRecipes`
  - `selectDietaryPreferences` / `setDailyGoals` / `skip` / `next` / `getStarted`

**Tests**
- [ ] `test/screens/onboarding/onboarding_screen_test.dart` — 4 pages render, dot indicators update on swipe, Skip navigates away, Next advances page, Get Started saves prefs, dietary chips selectable, nutrition sliders accept input

---

### Task 7: Recipe Photo Gallery (Push 24)

**Model Updates**
- [ ] Update `lib/models/recipe.dart`: add `photos` (List\<String\>, default []) — additional gallery images alongside existing `imageUrl`
- [ ] Update `fromMap()`: read `'photos' as List<String> ?? []`
- [ ] Update `toMap()`: write `'photos'`
- [ ] Update RecipeStep model: add `imageUrl` (String?, default null) — optional photo per step
- [ ] Update RecipeStep `fromMap()` and `toMap()`

**Widget: PhotoCarousel**
- [ ] Create `lib/widgets/photo_carousel.dart`
- [ ] PageView.builder, dot indicators, image count badge "1/5" in top-right
- [ ] Tap image → opens PhotoViewer (full-screen)
- [ ] Single image: show without dots/pagination

**Widget: PhotoViewer**
- [ ] Create `lib/widgets/photo_viewer.dart`
- [ ] Full-screen overlay, black background, InteractiveViewer (pinch-to-zoom, pan)
- [ ] Close button (X), swipe left/right for multiple images, counter "2 of 5"

**Widget: PhotoGrid**
- [ ] Create `lib/widgets/photo_grid.dart`
- [ ] 1 image → full-width; 2 → side-by-side; 3 → one large + two small; 4+ → 2x2 grid, last cell "+N more" overlay
- [ ] Tap any image → PhotoViewer at that index

**AddRecipeScreen Modifications**
- [ ] Replace single ImagePickerTile with multi-image picker section
- [ ] Horizontal scrollable list + "Add Photo" button at end
- [ ] ReorderableListView / LongPressDraggable for drag-to-reorder
- [ ] First image = cover image (imageUrl field)
- [ ] Use `ImagePicker().pickMultiImage()`

**RecipeDetailScreen Modifications**
- [ ] Replace single cover image with PhotoCarousel if `recipe.photos` is not empty
- [ ] Fallback to single `imageUrl` display (backward compatible)

**CookingModeScreen Modifications**
- [ ] If RecipeStep has imageUrl, show it above step instruction text (height ~150, rounded corners)

**StorageService Modifications**
- [ ] `uploadRecipePhotos(String recipeId, List<File> files, {onProgress})` → Future\<List\<String\>\> — upload to `recipes/{recipeId}/photos/{index}`
- [ ] `deleteRecipePhotos(String recipeId)` → Future\<void\>

**RecipeFormProvider Modifications**
- [ ] Add `additionalPhotos` (List\<File\>) field
- [ ] `addPhotos(List<File>)`, `removePhoto(int index)`, `reorderPhotos(int oldIndex, int newIndex)`
- [ ] Submit: upload all photos, update recipe document with returned URLs

**Image Compression**
- [ ] Add `flutter_image_compress` dependency
- [ ] Resize to max 1200px width, 80% quality JPEG before uploading

**l10n**
- [ ] Add keys:
  - `addPhotos` / `photoGallery` / `dragToReorder` / `coverPhoto` / `morePhotos` / `photoOf`

**Tests**
- [ ] `test/models/recipe_test.dart` — update: photos field serialization, empty default
- [ ] `test/models/recipe_step_test.dart` — update: imageUrl field serialization
- [ ] `test/widgets/photo_carousel_test.dart` — renders images, dot indicators, page navigation, count badge
- [ ] `test/widgets/photo_viewer_test.dart` — renders full-screen, close button, zoom gesture
- [ ] `test/widgets/photo_grid_test.dart` — grid layouts for 1/2/3/4+ images, "+N more" overlay

---

### Task 8: Cooking History — "Cooked It" Log (Push 25)

**Model: CookingLog**
- [ ] Create `lib/models/cooking_log.dart`
- [ ] Fields: `id`, `recipeId`, `recipeName` (denormalized), `recipeImageUrl` (denormalized), `userId`, `cookedAt` (DateTime), `personalRating` (int? 1-5), `notes` (String?), `photoUrl` (String?), `servings` (int)
- [ ] Include `fromMap()`, `toMap()`, `copyWith()`
- [ ] Firestore collection: `cooking_logs`, document ID: auto-generated

**Service: CookingLogService**
- [ ] Create `lib/services/cooking_log_service.dart`
- [ ] `logCook(CookingLog log)` → Future\<void\>
- [ ] `getCookingHistory(String userId, {int limit, DocumentSnapshot? startAfter})` → Future\<List\<CookingLog\>\> — paginated, ordered by cookedAt desc
- [ ] `getCookCountForRecipe(String userId, String recipeId)` → Future\<int\>
- [ ] `getTotalCooksForRecipe(String recipeId)` → Future\<int\> — all users
- [ ] `deleteCookingLog(String logId)` / `updateCookingLog(CookingLog log)`
- [ ] `streamCookingHistory(String userId)` → Stream\<List\<CookingLog\>\>
- [ ] Accept optional `FirebaseFirestore` for DI

**Provider: CookingLogProvider**
- [ ] Create `lib/providers/cooking_log_provider.dart`
- [ ] Holds: cookingHistory, loading state, cookCountCache (Map\<String, int\>)
- [ ] `init(String userId)` — subscribe to stream
- [ ] `logCook(Recipe recipe, {int? personalRating, String? notes, File? photo, int servings})` — upload photo if provided, create CookingLog, auto-add meal entry to DailyTracker (before 11am=breakfast, 11am-3pm=lunch, 3pm-8pm=dinner, after 8pm=snack)
- [ ] `getCookCount(String recipeId)` — from cache or fetch
- [ ] `deleteCookingLog(String logId)` — call service, update local list
- [ ] Register in `main.dart` MultiProvider

**Screen: CookingHistoryScreen**
- [ ] Create `lib/screens/cooking_history/cooking_history_screen.dart`
- [ ] AppBar: "Cooking History", back button
- [ ] ListView.builder of CookingLogCard widgets (newest first)
- [ ] Tap card → RecipeDetailScreen; long-press/swipe → delete with confirmation
- [ ] Empty state: "You haven't cooked anything yet!" with chef hat icon
- [ ] Pull-to-refresh, pagination with ScrollController

**Widget: CookingLogCard**
- [ ] Create `lib/screens/cooking_history/widgets/cooking_log_card.dart`
- [ ] Row: recipe image (60x60), Column (name, date, rating stars, notes preview), trailing photo thumbnail (40x40)

**RecipeDetailScreen Modifications**
- [ ] "I Cooked This!" GradientButton below existing action buttons
- [ ] Tap → bottom sheet: star rating, notes TextField, image picker, servings selector, "Log Cook" submit
- [ ] After logging → SnackBar "Cook logged!"
- [ ] Show cook count badge: "Cooked 3 times"

**CookingModeScreen Modifications**
- [ ] On last step completion → show "Log This Cook" prompt, auto-open cook logging sheet

**RecipeCard Modifications**
- [ ] If cook count > 0, show small badge/chip "Cooked x3"

**Route & Access**
- [ ] Add GoRoute path `/cooking-history` under parentNavigatorKey
- [ ] Access: "Cooking History" row on ProfileScreen (history/clock icon)

**Firestore Rules**
- [ ] `cooking_logs` — owner can read/write own documents only

**l10n**
- [ ] Add keys:
  - `cookingHistory` / `iCookedThis` / `logCook` / `cookedOn` / `cookedTimes`
  - `personalNotes` / `addResultPhoto` / `noCookingHistory` / `cookLogged`

**Tests**
- [ ] `test/models/cooking_log_test.dart` — fromMap/toMap, copyWith, defaults
- [ ] `test/services/cooking_log_service_test.dart` — logCook, getCookingHistory pagination, getCookCountForRecipe, delete
- [ ] `test/providers/cooking_log_provider_test.dart` — logCook updates list, getCookCount cached, auto-add to daily tracker
- [ ] `test/screens/cooking_history/cooking_history_screen_test.dart` — renders list, empty state, card taps

---

### Task 9: Seasonal & Trending Recipes (Push 26)

**Service: TrendingService**
- [ ] Create `lib/services/trending_service.dart` — no own Firestore collection, computes from existing data
- [ ] `getTrendingRecipes({int limit = 10, String timeWindow = '7d'})` → Future\<List\<Recipe\>\>
  - Score = (recentFavorites x 3) + (ratingCount x 2) + (averageRating x 1) + recency bonus (+5 if created in last 48h)
  - Sort by score desc, return top N
- [ ] `getSeasonalRecipes(int month, {int limit = 10})` → Future\<List\<Recipe\>\> — map months to seasons (Dec-Feb=Winter, Mar-May=Spring, Jun-Aug=Summer, Sep-Nov=Autumn), query matching seasonal category tag
- [ ] `getSeasonalIngredients(int month)` → List\<String\> — hard-coded month-to-ingredients map
- [ ] Accept optional `FirebaseFirestore`

**Provider: TrendingProvider**
- [ ] Create `lib/providers/trending_provider.dart`
- [ ] Holds: trendingRecipes, seasonalRecipes, seasonalIngredients, loading, lastRefreshed
- [ ] `loadTrending()` — cache for 1 hour (check lastRefreshed)
- [ ] `loadSeasonal()` / `loadSeasonalIngredients()` / `refresh()`
- [ ] Register in `main.dart` MultiProvider

**HomeScreen Modifications**
- [ ] "Popular This Week" section: horizontal scrollable compact RecipeCards (~200px wide), max 10, "See All" → TrendingRecipesScreen
- [ ] "What's in Season" section: horizontal chip list of seasonal ingredients, tap chip → SearchScreen pre-filtered
- [ ] "Popular Now" badge on RecipeCard for trending recipes (flame icon badge on card corner)

**Screen: TrendingRecipesScreen**
- [ ] Create `lib/screens/trending/trending_recipes_screen.dart`
- [ ] AppBar: "Trending Recipes", filter chips: "This Week" / "This Month" / "All Time"
- [ ] ListView of RecipeCard with trending rank badge (#1, #2, #3...)

**RecipeCard Modifications**
- [ ] Add optional `showTrendingBadge` (bool) and `trendingRank` (int?) params
- [ ] Flame icon overlay + "#1" rank badge

**Seasonal Tags**
- [ ] Add "Spring", "Summer", "Autumn", "Winter" to category or dietary tag system (new SeasonalTag enum or extend DietaryTag)

**Route**
- [ ] Add GoRoute path `/trending` under parentNavigatorKey

**l10n**
- [ ] Add keys:
  - `popularThisWeek` / `trendingRecipes` / `whatsInSeason` / `popularNow`
  - `thisWeek` / `thisMonth` / `allTime` / `seeAll`
  - `spring` / `summer` / `autumn` / `winter`

**Tests**
- [ ] `test/services/trending_service_test.dart` — score calculation, sort order, time window filtering, seasonal ingredients for all 12 months
- [ ] `test/providers/trending_provider_test.dart` — loadTrending populates list, caching prevents re-fetch within 1 hour, refresh forces reload

---

### Task 10: Ingredient Substitution Suggestions (Push 27)

**Model: IngredientSubstitution**
- [ ] Create `lib/models/ingredient_substitution.dart`
- [ ] Fields: `id`, `originalIngredient` (lowercase normalized), `substituteName`, `ratio` (e.g. "1:1"), `notes` (String?), `dietaryTags` (List\<String\>), `submittedBy` (String?), `isVerified` (bool)
- [ ] `fromMap()`, `toMap()`
- [ ] Firestore collection: `substitutions`

**Service: SubstitutionService**
- [ ] Create `lib/services/substitution_service.dart`
- [ ] `getSubstitutions(String ingredientName)` — query where originalIngredient == name.toLowerCase().trim()
- [ ] `getSubstitutionsByTag(String ingredientName, String dietaryTag)` — array-contains filter
- [ ] `submitSubstitution(IngredientSubstitution sub)` — add with isVerified: false
- [ ] `getAllSubstitutions()` / `verifySubstitution(String id)` / `deleteSubstitution(String id)`
- [ ] Accept optional `FirebaseFirestore`

**Seed Firestore**
- [ ] 50+ substitution entries:
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
- [ ] Create `lib/widgets/substitution_sheet.dart` — showModalBottomSheet
- [ ] Header: "Substitutes for {ingredientName}"
- [ ] Optional FilterChip row (Vegan, Gluten-Free, Keto, Dairy-Free)
- [ ] ListView of substitution cards: name (bold), ratio, notes, dietary chips, verified checkmark
- [ ] "Suggest a Substitution" TextButton → form dialog (name, ratio, notes, tags) → service.submitSubstitution()

**RecipeDetailScreen Modifications**
- [ ] Each ingredient row: trailing swap icon button → opens SubstitutionSheet for that ingredient
- [ ] If no substitutions found, show "No substitutions available"

**Firestore Rules**
- [ ] Anyone can read, authenticated can create (isVerified: false), only admins can update isVerified or delete

**l10n**
- [ ] Add keys:
  - `substitutions` / `substitutesFor` / `ratio` / `suggestSubstitution` / `noSubstitutions`
  - `substituteName` / `verified` / `communitySubmitted` / `thankYouSubstitution`

**Tests**
- [ ] `test/models/ingredient_substitution_test.dart` — fromMap/toMap, dietaryTags list serialization
- [ ] `test/services/substitution_service_test.dart` — getSubstitutions, getSubstitutionsByTag, submitSubstitution with isVerified false
- [ ] `test/widgets/substitution_sheet_test.dart` — loads/displays substitutions, filter chips, suggest form

---

### Task 11: Achievement Badges & Gamification (Push 28)

**Model: Achievement**
- [ ] Create `lib/models/achievement.dart`
- [ ] Fields: `id` (predefined badge ID), `title`, `description`, `iconName`, `criteria` (Map\<String, dynamic\>), `category` ("cooking"/"social"/"health"/"exploration")
- [ ] Static definition: `static const List<Achievement> allAchievements = [...]` with 12+ badges:
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
- [ ] Create `lib/models/user_achievement.dart`
- [ ] Fields: `id`, `achievementId`, `userId`, `unlockedAt` (DateTime)
- [ ] `fromMap()`, `toMap()`
- [ ] Firestore collection: `user_achievements`

**Service: AchievementService**
- [ ] Create `lib/services/achievement_service.dart`
- [ ] `getUserAchievements(String userId)` / `streamUserAchievements(String userId)`
- [ ] `unlockAchievement(String userId, String achievementId)` — check for duplicates first
- [ ] `checkAndUnlockAchievements(String userId, {required Map<String, dynamic> context})` → Future\<List\<Achievement\>\> — check all criteria against context, unlock newly met ones, return newly unlocked
- [ ] `getProgress(String userId, Achievement achievement)` → Future\<double\> (0.0–1.0)
- [ ] Accept optional `FirebaseFirestore`

**Provider: AchievementProvider**
- [ ] Create `lib/providers/achievement_provider.dart`
- [ ] Holds: unlockedAchievements, progressMap, newlyUnlocked (for celebration UI)
- [ ] `init(String userId)` — subscribe to stream, load initial progress
- [ ] `checkAchievements()` — gather stats from other providers, call service, update newlyUnlocked
- [ ] `getProgress(String achievementId)` / `clearNewlyUnlocked()`
- [ ] Call checkAchievements() after key user actions (publish recipe, log meal, gain follower, etc.)
- [ ] Register in `main.dart` MultiProvider

**Screen: AchievementsScreen**
- [ ] Create `lib/screens/achievements/achievements_screen.dart`
- [ ] AppBar: "Achievements", GridView.builder (2 columns)
- [ ] Each cell: icon, title, unlocked → full color + gold border + "Unlocked on {date}", locked → greyed + dashed border + progress bar
- [ ] Tap card → bottom sheet with full description, criteria, progress
- [ ] Category filter chips: All, Cooking, Social, Health, Exploration

**Achievement Celebration Widget**
- [ ] Overlay when `newlyUnlocked` is not empty: dark semi-transparent background, centered card with animated icon, title, description, confetti/sparkle animation, "Awesome!" dismiss button
- [ ] Show in main shell/scaffold, call `clearNewlyUnlocked()` on dismiss

**ProfileScreen Modifications**
- [ ] "Achievements" section: 3 most recent unlocked badges as small icons, "View All" → AchievementsScreen
- [ ] "X of 12 achievements unlocked" count

**Route**
- [ ] Add GoRoute path `/achievements` under parentNavigatorKey

**Firestore Rules**
- [ ] `user_achievements` — owner can read own, system/admin can write

**l10n**
- [ ] Add keys:
  - `achievements` / `achievementUnlocked` / `unlockedOn` / `progress` / `awesome`
  - All 12 badge names and their Turkish translations
  - `viewAllAchievements` / `achievementsUnlocked`

**Tests**
- [ ] `test/models/achievement_test.dart` — allAchievements completeness, criteria structure
- [ ] `test/models/user_achievement_test.dart` — fromMap/toMap round-trip
- [ ] `test/services/achievement_service_test.dart` — unlockAchievement, no duplicate, checkAndUnlockAchievements with contexts, getProgress
- [ ] `test/providers/achievement_provider_test.dart` — init loads list, checkAchievements detects new, clearNewlyUnlocked

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
