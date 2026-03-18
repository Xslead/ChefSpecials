ChefSpecials — Build Progress

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

Push 17: Share Recipe

 [x] Added share_plus dependency to pubspec.yaml
 [x] Added l10n keys: shareRecipe, shareRecipeText (EN + TR)
 [x] Share glass circle button in RecipeDetailScreen AppBar
 [x] Share GradientButton below "Add to Collection"
 [x] _shareRecipe() method formats title, author, ingredients list
Status: IMPLEMENTED (not yet pushed)

Push 20: Testing

 [x] 765 tests passing across all layers (70 files, 12,099 lines)
 [x] DI constructors added to all 11 services and 11 providers
 [x] Dev dependencies: fake_cloud_firestore, mockito, build_runner
 [x] Test helpers: 26 factory functions for all 13 models
Unit Tests (test/)
 [x] Models (233 tests): Recipe, Ingredient, ShoppingList, ShoppingItem, FoodItem, DailyLog, MealEntry, NutritionGoal, UserModel, Rating, Comment, Favorite, RecipeStep
 [x] fromMap() / toMap() round-trip correctness
 [x] Default values, null handling, edge cases, computed properties, copyWith, enums
 [x] Services (133 tests, fake_cloud_firestore):
 [x] RecipeService — CRUD, streams, category filter, feed pagination, author name batch update
 [x] FavoriteService — toggle, isFavorite, streams
 [x] ShoppingListService — CRUD, toggle, clear checked, remove, add items
 [x] FoodItemService — CRUD, search, category filter
 [x] DailyTrackerService — CRUD, date queries, nutrition goals
 [x] RatingService — set/delete with transaction, average calculation
 [x] CommentService — subcollection CRUD, transaction counters
 [x] FollowService — follow/unfollow batch writes, streams
 [x] UserService — CRUD, username claim transaction, search, migration
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
 [x] CI-ready: flutter test runs 765 tests in ~9 seconds
Status: PUSHED

App Statistics

 Total Dart files: 104
 Lines of code (lib/): 24,230
 Lines of code (test/): 13,527
 Total lines: 37,757
 Screens implemented: 28
 Models: 13
 Services: 13
 Providers: 14
 Routes: 24
 l10n keys: 229 (EN + TR)

---

BUGS TO FIX

P0 — Critical
1. Food item edit not implemented — food_item_detail_screen.dart:93 has // TODO: Navigate to edit screen
2. Food item delete broken — food_item_detail_screen.dart:535 has // TODO: Call provider.deleteFoodItem() and pop screen — dialog dismisses but item is NOT deleted

P1 — High
3. Missing test: recipe_import_service_test.dart — only service without a test file

---

Remaining — What's Left To Do

Push 18: Weekly Meal Planner

 [ ] Model: MealPlan — create lib/models/meal_plan.dart
     Fields: id (String), userId (String), weekStartDate (DateTime — always Monday of that week),
     meals (List<PlannedMeal>), createdAt (DateTime), updatedAt (DateTime).
     Include fromMap(Map<String, dynamic>) factory constructor that reads Firestore Timestamps
     and converts them to DateTime. Include toMap() method that converts DateTime back to Timestamps.
     Include copyWith() method for immutable updates.
     Firestore collection: "meal_plans", document ID: auto-generated.

 [ ] Model: PlannedMeal — define as a nested class inside meal_plan.dart or as a separate file lib/models/planned_meal.dart
     Fields: day (int — 0=Monday through 6=Sunday), mealType (String — one of "breakfast", "lunch", "dinner", "snack"),
     recipeId (String — references a recipe document ID from the "recipes" collection),
     recipeName (String — denormalized recipe title for display without extra read),
     recipeImageUrl (String? — denormalized cover image URL),
     servings (int — how many servings planned, default 1).
     Include fromMap() and toMap() methods.

 [ ] Service: MealPlanService — create lib/services/meal_plan_service.dart
     Stateless class that talks to Firestore "meal_plans" collection. Methods:
     - getMealPlan(String userId, DateTime weekStart) → Future<MealPlan?> — query by userId + weekStartDate
     - streamMealPlan(String userId, DateTime weekStart) → Stream<MealPlan?> — real-time listener
     - createMealPlan(MealPlan plan) → Future<void> — add new document
     - updateMealPlan(MealPlan plan) → Future<void> — update existing document
     - addMealToDay(String planId, PlannedMeal meal) → Future<void> — arrayUnion the meal into meals list
     - removeMealFromDay(String planId, PlannedMeal meal) → Future<void> — arrayRemove the meal
     - deleteMealPlan(String planId) → Future<void> — delete document
     - copyFromPreviousWeek(String userId, DateTime currentWeekStart) → Future<MealPlan?> —
       read previous week's plan, clone it with new weekStartDate, save as new document
     Accept optional FirebaseFirestore parameter in constructor for DI in tests.

 [ ] Provider: MealPlanProvider — create lib/providers/meal_plan_provider.dart
     Extends ChangeNotifier. Holds current week's MealPlan, selected week DateTime, loading state.
     Methods:
     - init(String userId) — subscribe to streamMealPlan for current week
     - goToNextWeek() / goToPreviousWeek() — shift selectedWeek by 7 days, re-subscribe stream
     - addMeal(int day, String mealType, Recipe recipe, int servings) — calls service.addMealToDay
     - removeMeal(int day, String mealType, String recipeId) — calls service.removeMealFromDay
     - copyFromLastWeek() — calls service.copyFromPreviousWeek
     - getWeeklyNutrition() → Map<String, double> — iterate all PlannedMeals, look up recipe nutrition
       from RecipeProvider, multiply by servings, sum totals for calories/protein/carbs/fat
     - generateShoppingList() → List<ShoppingItem> — aggregate all ingredients from all planned recipes,
       merge duplicates by name+unit, return as ShoppingItem list ready to save via ShoppingListService
     Register in main.dart MultiProvider. Dispose stream subscription in dispose().

 [ ] Screen: MealPlannerScreen — create lib/screens/meal_planner/meal_planner_screen.dart
     Full-screen page pushed on top of shell (not a bottom nav tab).
     Layout: AppBar with week selector (left/right arrows + "Mar 17 – Mar 23" label),
     overflow menu with "Copy from last week" and "Generate shopping list" options.
     Body: horizontal scrollable Row of 7 DayColumn widgets (Mon–Sun).
     Each DayColumn shows the day name header + 4 meal slots (breakfast, lunch, dinner, snack).
     Each meal slot: if empty, show a dashed-border "+" button that opens a recipe picker bottom sheet
     (list of user's recipes from RecipeProvider, searchable, tap to assign).
     If filled, show a MealSlotCard with recipe thumbnail, name, calorie count.
     Tap filled slot to view recipe detail, long-press to remove.
     Bottom section: weekly nutrition summary bar (total calories, protein, carbs, fat across all 7 days).
     Use Consumer<MealPlanProvider> for reactive updates.

 [ ] Widget: DayColumn — create lib/screens/meal_planner/widgets/day_column.dart
     Receives: dayIndex (int), dayName (String), meals (List<PlannedMeal> filtered for this day),
     onAddMeal callback, onRemoveMeal callback.
     Renders: Column with day name Text at top, then 4 MealSlotCard or empty slot widgets.

 [ ] Widget: MealSlotCard — create lib/screens/meal_planner/widgets/meal_slot_card.dart
     Receives: PlannedMeal data, onTap callback, onLongPress callback.
     Renders: compact Card with recipe image (40x40 rounded), recipe name (1 line ellipsis),
     servings count, calorie text. Match existing app card styling (PremiumCard or similar shadow/radius).

 [ ] Route: add GoRoute path "/meal-planner" in lib/config/routes.dart under parentNavigatorKey
     (pushes on top of shell, not inside bottom nav). Builder returns MealPlannerScreen().
     Access point: add a "Meal Planner" button/card on HomeScreen or ProfileScreen.

 [ ] l10n: add keys to lib/l10n/app_en.arb and lib/l10n/app_tr.arb, then regenerate:
     mealPlanner / "Meal Planner" / "Yemek Planlayıcı"
     weekOf / "Week of {date}" / "{date} Haftası"
     copyFromLastWeek / "Copy from Last Week" / "Geçen Haftadan Kopyala"
     generateShoppingListFromPlan / "Generate Shopping List" / "Alışveriş Listesi Oluştur"
     addMealToSlot / "Add Meal" / "Yemek Ekle"
     removeMeal / "Remove Meal" / "Yemeği Kaldır"
     weeklyNutritionSummary / "Weekly Nutrition" / "Haftalık Beslenme"
     monday/tuesday/wednesday/thursday/friday/saturday/sunday with Turkish translations
     noMealsPlanned / "No meals planned" / "Planlanmış yemek yok"
     Run: flutter gen-l10n (or let flutter build handle it)

 [ ] Tests — create test files mirroring lib structure:
     test/models/meal_plan_test.dart — fromMap/toMap round-trip, copyWith, default values,
       PlannedMeal serialization, weekStartDate always normalized to Monday
     test/services/meal_plan_service_test.dart — use fake_cloud_firestore:
       create/read/update/delete, stream updates, addMealToDay, removeMealFromDay, copyFromPreviousWeek
     test/providers/meal_plan_provider_test.dart — week navigation, addMeal/removeMeal state changes,
       getWeeklyNutrition calculation, generateShoppingList aggregation
     test/screens/meal_planner/meal_planner_screen_test.dart — widget test: renders day columns,
       shows meal slots, tap empty slot opens picker, weekly nutrition displays

Push 19: Weekly/Monthly Reports

 [ ] Provider: ReportsProvider — create lib/providers/reports_provider.dart
     Extends ChangeNotifier. Does NOT need its own Firestore collection — reads existing "daily_logs"
     collection via DailyTrackerService. Holds: selectedTab (weekly/monthly), selectedDateRange,
     aggregated data maps, loading state.
     Methods:
     - loadWeeklyData(String userId, DateTime weekStart) — query daily_logs for 7 days starting from weekStart,
       aggregate into a List<DailyNutritionSummary> with {date, totalCalories, totalProtein, totalCarbs, totalFat}
       for each day. Used to build the bar chart.
     - loadMonthlyData(String userId, DateTime month) — query daily_logs for the entire month (1st to last day),
       aggregate into daily summaries. Used to build line charts showing trends over 28-31 days.
     - calculateMacroDistribution() → {protein: %, carbs: %, fat: %} — from the loaded data,
       compute the percentage breakdown of macros. Used for the pie chart.
     - calculateStreak(String userId) → Future<int> — query daily_logs ordered by date descending,
       count consecutive days that have at least one meal entry. Stop counting at the first gap.
     - calculateAverages() → {avgCalories, avgProtein, avgCarbs, avgFat} — arithmetic mean over the loaded period.
     - setDateRange(DateTime start, DateTime end) — for custom report periods, reload data.
     Register in main.dart MultiProvider.

 [ ] Screen: ReportsScreen — create lib/screens/reports/reports_screen.dart
     Full-screen page pushed on top of shell via parentNavigatorKey.
     Layout: AppBar with title "Reports", back button.
     Body: TabBarView with 2 tabs — "Weekly" and "Monthly".
     Weekly tab contents:
       - Week selector row (left/right arrows + "Mar 10 – Mar 16" label)
       - fl_chart BarChart: x-axis = 7 day labels (Mon–Sun), y-axis = calories.
         Each bar colored with app primary color. Tap bar to show tooltip with exact value.
       - Average daily intake card below the chart: Row of 4 stat items (Avg Cal, Avg Protein, Avg Carbs, Avg Fat)
       - Streak card: "Current Streak: X days" with fire icon
     Monthly tab contents:
       - Month selector row (left/right arrows + "March 2026" label)
       - fl_chart LineChart: x-axis = day numbers (1-31), 4 colored lines for calories/protein/carbs/fat.
         Include legend below chart. Tap points for tooltips.
       - fl_chart PieChart: macro distribution (protein/carbs/fat as percentages with colored segments)
       - Monthly averages card: same layout as weekly but computed over the month
     Bottom: "Export as Image" button — uses RepaintBoundary + RenderRepaintBoundary.toImage()
       to capture the chart area as PNG, then share via share_plus.
     Use Consumer<ReportsProvider> for reactive updates.

 [ ] Route: add GoRoute path "/reports" in lib/config/routes.dart under parentNavigatorKey.
     Access point: add a "Reports" row/button on ProfileScreen (below existing settings items).

 [ ] l10n: add keys to app_en.arb and app_tr.arb:
     reports / "Reports" / "Raporlar"
     weekly / "Weekly" / "Haftalık"
     monthly / "Monthly" / "Aylık"
     averageDailyIntake / "Average Daily Intake" / "Günlük Ortalama Alım"
     currentStreak / "Current Streak" / "Mevcut Seri"
     days / "days" / "gün"
     macroDistribution / "Macro Distribution" / "Makro Dağılımı"
     exportAsImage / "Export as Image" / "Görsel Olarak Dışa Aktar"
     noDataForPeriod / "No data for this period" / "Bu dönem için veri yok"

 [ ] Tests:
     test/providers/reports_provider_test.dart — loadWeeklyData aggregation correctness,
       loadMonthlyData across month boundaries, calculateStreak with gaps, calculateAverages,
       calculateMacroDistribution percentages sum to 100, custom date range
     test/screens/reports/reports_screen_test.dart — widget test: tabs render,
       bar chart shows 7 bars for weekly, line chart renders for monthly, export button exists

Push 20b: Push Notifications

 [ ] Firebase Cloud Messaging setup:
     - Add firebase_messaging dependency to pubspec.yaml (flutter pub add firebase_messaging)
     - Add flutter_local_notifications dependency (flutter pub add flutter_local_notifications)
     - Android: update android/app/src/main/AndroidManifest.xml with notification channel metadata
       and RECEIVE permission. Add default notification icon in android/app/src/main/res/drawable/.
     - iOS: enable Push Notifications capability in Xcode (Runner.xcodeproj → Signing & Capabilities).
       Request notification permission via FirebaseMessaging.instance.requestPermission().
     - Initialize FCM in main.dart after Firebase.initializeApp():
       await FirebaseMessaging.instance.requestPermission();
       FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

 [ ] Service: NotificationService — create lib/services/notification_service.dart
     Stateless class. Methods:
     - initialize() — set up flutter_local_notifications plugin, create Android notification channel
       "meal_reminders" with high importance. Set up FCM onMessage foreground listener that shows
       local notification. Set up onMessageOpenedApp for navigation on tap.
     - getFcmToken() → Future<String?> — get device FCM token
     - saveFcmToken(String userId, String token) — write token to Firestore users/{userId}/fcmTokens subcollection
       or as a field "fcmToken" on the user document.
     - subscribeToTopic(String topic) / unsubscribeFromTopic(String topic) — for "new_recipes", "followed_users" topics
     - scheduleMealReminder(String mealType, int hour, int minute) — use flutter_local_notifications
       zonedSchedule to fire a daily local notification at the specified time with message like
       "Time for {mealType}!" Notification ID: hash of mealType to avoid duplicates.
     - cancelMealReminder(String mealType) — cancel by notification ID
     - cancelAllReminders() — cancel all scheduled notifications
     Accept optional FirebaseFirestore parameter in constructor for DI in tests.

 [ ] Provider: NotificationProvider — create lib/providers/notification_provider.dart
     Extends ChangeNotifier. Holds: notificationsEnabled (bool), mealReminderSettings (Map<String, TimeOfDay?>
     for breakfast/lunch/dinner), followedUserAlerts (bool), commentAlerts (bool), followAlerts (bool).
     Persist settings in SharedPreferences.
     Methods:
     - init() — load settings from SharedPreferences, call service.initialize()
     - toggleMealReminder(String mealType, bool enabled, TimeOfDay? time) — save to prefs,
       schedule or cancel the reminder via service
     - toggleFollowedUserAlerts(bool enabled) — subscribe/unsubscribe FCM topic
     - toggleCommentAlerts(bool enabled) — save to prefs
     - toggleFollowAlerts(bool enabled) — save to prefs
     Register in main.dart MultiProvider.

 [ ] Screen: NotificationSettingsScreen — create lib/screens/profile/notification_settings_screen.dart
     Full-screen page pushed on top of shell. AppBar with "Notification Settings" title, back button.
     Body: ListView with SwitchListTile items:
     - "Breakfast Reminder" toggle + time picker (default 08:00)
     - "Lunch Reminder" toggle + time picker (default 12:00)
     - "Dinner Reminder" toggle + time picker (default 19:00)
     - "New Recipes from Followed Users" toggle
     - "Comments on My Recipes" toggle
     - "New Followers" toggle
     When user toggles a switch, call the corresponding provider method.
     Time pickers: tap the trailing time label to open showTimePicker dialog.
     Use Consumer<NotificationProvider>.

 [ ] Route: add GoRoute path "/notification-settings" in lib/config/routes.dart under parentNavigatorKey.
     Access point: add a "Notifications" row on ProfileScreen (with bell icon) above the theme toggle.

 [ ] l10n: add keys to app_en.arb and app_tr.arb:
     notificationSettings / "Notification Settings" / "Bildirim Ayarları"
     breakfastReminder / "Breakfast Reminder" / "Kahvaltı Hatırlatıcı"
     lunchReminder / "Lunch Reminder" / "Öğle Yemeği Hatırlatıcı"
     dinnerReminder / "Dinner Reminder" / "Akşam Yemeği Hatırlatıcı"
     newRecipeAlerts / "New Recipes from Followed Users" / "Takip Ettiklerden Yeni Tarifler"
     commentAlerts / "Comments on My Recipes" / "Tariflerime Yapılan Yorumlar"
     followerAlerts / "New Followers" / "Yeni Takipçiler"
     timeForMeal / "Time for {meal}!" / "{meal} vakti!"

 [ ] Tests:
     test/services/notification_service_test.dart — token retrieval, topic subscribe/unsubscribe
     test/providers/notification_provider_test.dart — toggle states, SharedPreferences persistence,
       meal reminder scheduling calls

Push 21: Admin Panel

 [ ] Update UserModel: add isAdmin (bool, default false) field to lib/models/user_model.dart.
     Update fromMap() to read 'isAdmin' ?? false. Update toMap() to include 'isAdmin'.
     Manually set isAdmin: true on your own user document in Firestore console for testing.

 [ ] Service: AdminService — create lib/services/admin_service.dart
     Stateless class. Reads from multiple existing collections for aggregation. Methods:
     - getDashboardStats() → Future<Map<String, int>> — run Firestore aggregation queries:
       count documents in "users", "recipes", "comments" collections,
       count users where lastLoginAt is within last 24 hours for "activeToday"
     - getAllUsers({String? searchQuery, int limit = 20, DocumentSnapshot? startAfter}) → Future<List<UserModel>>
       — paginated user list, optional search by displayName or email contains query
     - banUser(String userId) → Future<void> — set "isBanned: true" on users/{userId} document
     - unbanUser(String userId) → Future<void> — set "isBanned: false"
     - getAllRecipes({String? searchQuery, int limit = 20, DocumentSnapshot? startAfter}) → Future<List<Recipe>>
       — paginated recipe list for admin review
     - deleteRecipe(String recipeId) → Future<void> — delete from "recipes" collection
       (also clean up related favorites, ratings, comments, collection references)
     - getFlaggedComments() → Future<List<Comment>> — query comments where isFlagged == true
     - deleteComment(String recipeId, String commentId) → Future<void> — delete from subcollection
     - getCategories() → Future<List<String>> — read from "categories" collection
     - addCategory(String name) → Future<void> — add document to "categories"
     - deleteCategory(String categoryId) → Future<void> — delete from "categories"
     Accept optional FirebaseFirestore parameter in constructor for DI in tests.

 [ ] Provider: AdminProvider — create lib/providers/admin_provider.dart
     Extends ChangeNotifier. Holds: dashboardStats (Map), usersList (List<UserModel>),
     recipesList (List<Recipe>), flaggedComments (List<Comment>), categories (List<String>),
     loading states for each section.
     Methods wrap AdminService calls and call notifyListeners() after each state change.
     Register in main.dart MultiProvider (only instantiated if user.isAdmin).

 [ ] Screen: AdminDashboardScreen — create lib/screens/admin/admin_dashboard_screen.dart
     Full-screen page. AppBar: "Admin Dashboard", back button.
     Body: GridView with 4 stat cards (total users, total recipes, total comments, active today).
     Each card: icon + number + label. Below grid: ListView of navigation items:
     - "Manage Users" → AdminUsersScreen
     - "Manage Recipes" → AdminRecipesScreen
     - "Moderate Comments" → AdminCommentsScreen
     - "Manage Categories" → AdminCategoriesScreen
     - "Manage Food Items" → FoodItemListScreen (existing, but with admin edit/delete powers)
     Use Consumer<AdminProvider>.

 [ ] Screen: AdminUsersScreen — create lib/screens/admin/admin_users_screen.dart
     AppBar with search field. Body: paginated ListView of users.
     Each user tile: avatar, displayName, email, registration date, isBanned badge.
     Swipe actions or trailing popup menu: "Ban User" / "Unban User".
     Pull-to-refresh. Infinite scroll pagination via ScrollController.

 [ ] Screen: AdminRecipesScreen — create lib/screens/admin/admin_recipes_screen.dart
     AppBar with search field. Body: paginated ListView of all recipes (public + private).
     Each tile: recipe image, title, author name, date, rating.
     Trailing popup menu: "View", "Delete" (with confirmation dialog).

 [ ] Screen: AdminCommentsScreen — create lib/screens/admin/admin_comments_screen.dart
     Body: ListView of flagged/reported comments.
     Each tile: comment text, author name, recipe name, date.
     Actions: "Delete Comment", "View Recipe".

 [ ] Screen: AdminCategoriesScreen — create lib/screens/admin/admin_categories_screen.dart
     Body: ListView of existing categories with delete icon.
     FAB or AppBar action to add new category (shows text input dialog).
     Swipe-to-delete with confirmation.

 [ ] Admin route guard: in lib/config/routes.dart, add a redirect function on admin routes
     that checks AuthProvider.currentUser.isAdmin — if false, redirect to home.
     Routes: /admin (dashboard), /admin/users, /admin/recipes, /admin/comments, /admin/categories.
     All under parentNavigatorKey.

 [ ] Access point: on ProfileScreen, add a "Admin Panel" ListTile (with shield icon) that is
     only visible when AuthProvider.currentUser.isAdmin == true. Taps navigate to /admin.

 [ ] Firestore security rules: add rules for admin operations —
     match /users/{userId} { allow update: if request.auth.token.admin == true; }
     or check the isAdmin field on the requesting user's document.
     Deploy with: firebase deploy --only firestore:rules

 [ ] l10n: add keys to app_en.arb and app_tr.arb:
     adminPanel / "Admin Panel" / "Yönetici Paneli"
     adminDashboard / "Admin Dashboard" / "Yönetici Panosu"
     totalUsers / "Total Users" / "Toplam Kullanıcı"
     totalRecipes / "Total Recipes" / "Toplam Tarif"
     totalComments / "Total Comments" / "Toplam Yorum"
     activeToday / "Active Today" / "Bugün Aktif"
     manageUsers / "Manage Users" / "Kullanıcıları Yönet"
     manageRecipes / "Manage Recipes" / "Tarifleri Yönet"
     moderateComments / "Moderate Comments" / "Yorumları Yönet"
     manageCategories / "Manage Categories" / "Kategorileri Yönet"
     banUser / "Ban User" / "Kullanıcıyı Yasakla"
     unbanUser / "Unban User" / "Yasağı Kaldır"
     banned / "Banned" / "Yasaklı"
     confirmDelete / "Are you sure you want to delete this?" / "Bunu silmek istediğinize emin misiniz?"

 [ ] Tests:
     test/services/admin_service_test.dart — fake_cloud_firestore: getDashboardStats counts,
       banUser/unbanUser toggle, getAllUsers pagination + search, deleteRecipe cascade cleanup
     test/providers/admin_provider_test.dart — loadDashboard updates stats, banUser updates list,
       categories CRUD

Push 22: Unit Converter + Recipe Scaling

 [ ] Utility: UnitConverter — create lib/utils/unit_converter.dart
     Pure static class with no dependencies. Methods:
     - convertWeight(double value, WeightUnit from, WeightUnit to) → double
       Enum WeightUnit { g, kg, oz, lb }
       Conversion factors: 1 kg = 1000 g, 1 oz = 28.3495 g, 1 lb = 453.592 g
     - convertVolume(double value, VolumeUnit from, VolumeUnit to) → double
       Enum VolumeUnit { mL, L, cups, tbsp, tsp, flOz }
       Conversion factors: 1 L = 1000 mL, 1 cup = 236.588 mL, 1 tbsp = 14.787 mL,
       1 tsp = 4.929 mL, 1 fl oz = 29.5735 mL
     - convertTemperature(double value, TempUnit from, TempUnit to) → double
       Enum TempUnit { celsius, fahrenheit }
       C→F: (C × 9/5) + 32, F→C: (F - 32) × 5/9
     - scaleIngredient(double originalAmount, int originalServings, int newServings) → double
       Returns: originalAmount × (newServings / originalServings)
     - smartFormat(double value, String unit) → String — auto-simplify display:
       if value in grams >= 1000, show as kg; if mL >= 1000, show as L;
       round to 1 decimal place, strip trailing zeros

 [ ] Widget: UnitConverterSheet — create lib/widgets/unit_converter_sheet.dart
     A showModalBottomSheet bottom sheet. Contains:
     - TextField for input value (numeric keyboard)
     - Two DropdownButton widgets: "From unit" and "To unit" (populated based on selected category)
     - SegmentedButton or ToggleButtons to switch category: Weight | Volume | Temperature
     - Result display Text (large, bold)
     - "Copy" button to copy result to clipboard
     Triggered from: RecipeDetailScreen ingredient list (tap any ingredient → show converter
     pre-filled with that ingredient's amount and unit) and CookingModeScreen (icon button in AppBar).

 [ ] Widget: ServingSizeSelector — create lib/widgets/serving_size_selector.dart
     A Row widget with: minus IconButton, serving count Text, plus IconButton.
     Receives: currentServings (int), originalServings (int), onChanged callback.
     Min value: 1, max value: 20. Displays "Serves X" text.
     Placed on RecipeDetailScreen below recipe info, above ingredient list.

 [ ] RecipeDetailScreen modifications (lib/screens/recipe_detail/recipe_detail_screen.dart):
     - Add a ServingSizeSelector widget between recipe info section and ingredients section
     - Track selectedServings in local state (default = recipe.servings)
     - When selectedServings changes, recalculate all ingredient amounts using
       UnitConverter.scaleIngredient(ingredient.amount, recipe.servings, selectedServings)
     - Also recalculate displayed nutrition totals: multiply per-serving nutrition × selectedServings
     - Each ingredient row: onTap opens UnitConverterSheet pre-filled with that ingredient's
       scaled amount and unit

 [ ] CookingModeScreen modification (lib/screens/cooking_mode/cooking_mode_screen.dart):
     - Add a unit converter icon button in the AppBar that opens UnitConverterSheet (empty, for quick conversions)

 [ ] l10n: add keys to app_en.arb and app_tr.arb:
     unitConverter / "Unit Converter" / "Birim Dönüştürücü"
     serves / "Serves {count}" / "{count} Kişilik"
     fromUnit / "From" / "Birimden"
     toUnit / "To" / "Birime"
     weight / "Weight" / "Ağırlık"
     volume / "Volume" / "Hacim"
     temperature / "Temperature" / "Sıcaklık"
     tapToConvert / "Tap ingredient to convert" / "Dönüştürmek için malzemeye dokunun"
     copied / "Copied!" / "Kopyalandı!"

 [ ] Tests:
     test/utils/unit_converter_test.dart — all weight conversions (g↔oz, g↔lb, g↔kg, oz↔lb, etc.),
       all volume conversions (mL↔cups, mL↔tbsp, mL↔tsp, mL↔flOz, mL↔L, etc.),
       temperature conversions (0°C=32°F, 100°C=212°F, -40°C=-40°F),
       scaleIngredient (2 servings → 4 servings doubles amount, 4→2 halves),
       smartFormat (1000g→"1 kg", 500mL→"500 mL", 1500mL→"1.5 L")
     test/widgets/unit_converter_sheet_test.dart — category switching, input/output display,
       pre-fill from ingredient data
     test/widgets/serving_size_selector_test.dart — increment/decrement, min/max bounds,
       callback fires with correct value

Push 23: Onboarding Flow

 [ ] Screen: OnboardingScreen — create lib/screens/onboarding/onboarding_screen.dart
     Full-screen page (no AppBar, no bottom nav). Shown ONLY on first launch.
     Uses a PageView with PageController. 4 pages total. Bottom area: dot indicators
     (Row of AnimatedContainer circles), "Skip" TextButton (top-right), "Next" button
     that advances to next page, "Get Started" button on last page that saves preferences
     and navigates to LoginScreen/HomeScreen.

     Page 1 — Welcome:
       Center column: app icon/logo (Image.asset or Icon), "Welcome to ChefSpecials" title,
       "Discover, cook, and share delicious recipes" subtitle. Animated fade-in.

     Page 2 — Features Overview:
       3 feature rows: each with icon + title + description:
       - Track icon + "Track Your Nutrition" + "Log meals and monitor your daily intake"
       - Calendar icon + "Plan Your Meals" + "Organize your weekly meal plan"
       - Share icon + "Share Recipes" + "Connect with food lovers and share your creations"

     Page 3 — Dietary Preferences:
       "Select your dietary preferences" title.
       Wrap widget with FilterChip items for each dietary tag from the existing DietaryTag enum
       (Vegan, Vegetarian, Gluten-Free, Keto, Halal, Dairy-Free, Nut-Free, Low-Carb).
       Multi-select. Store selections in local state.

     Page 4 — Nutrition Goals:
       "Set your daily goals" title.
       4 Slider or TextField inputs:
       - Calories (1000–4000, default 2000)
       - Protein (30–300g, default 50g)
       - Carbs (50–500g, default 250g)
       - Fat (20–200g, default 65g)
       Store values in local state.

     On "Get Started" tap:
       1. Save hasCompletedOnboarding = true to SharedPreferences
       2. If user is logged in, save dietary preferences to user document in Firestore
          (update UserModel with dietaryPreferences field)
       3. If user is logged in, save nutrition goals via DailyTrackerService.setNutritionGoal()
       4. Navigate to LoginScreen (if not logged in) or HomeScreen (if logged in)

 [ ] Route logic: in lib/config/routes.dart, add initial redirect logic:
     On app start, check SharedPreferences for 'hasCompletedOnboarding'.
     If false or null → redirect to /onboarding.
     Route: /onboarding → OnboardingScreen. No back button, no bottom nav.

 [ ] l10n: add keys to app_en.arb and app_tr.arb:
     welcome / "Welcome to ChefSpecials" / "ChefSpecials'a Hoş Geldiniz"
     discoverCookShare / "Discover, cook, and share delicious recipes" / "Lezzetli tarifleri keşfedin, pişirin ve paylaşın"
     trackYourNutrition / "Track Your Nutrition" / "Beslenmeni Takip Et"
     planYourMeals / "Plan Your Meals" / "Yemeklerini Planla"
     shareRecipes / "Share Recipes" / "Tarifleri Paylaş"
     selectDietaryPreferences / "Select your dietary preferences" / "Diyet tercihlerinizi seçin"
     setDailyGoals / "Set your daily goals" / "Günlük hedeflerinizi belirleyin"
     skip / "Skip" / "Atla"
     next / "Next" / "İleri"
     getStarted / "Get Started" / "Başla"

 [ ] Tests:
     test/screens/onboarding/onboarding_screen_test.dart — widget tests:
       4 pages render, dot indicators update on swipe, Skip navigates away,
       Next advances page, Get Started saves prefs, dietary chips are selectable,
       nutrition sliders accept input

Push 24: Recipe Photo Gallery

 [ ] Update Recipe model in lib/models/recipe.dart:
     Add field: photos (List<String>, default empty list) — list of image URLs in addition to imageUrl.
     Update fromMap(): read 'photos' as List<String> ?? [].
     Update toMap(): write 'photos'.
     The existing imageUrl field remains as the primary/cover image. photos is for additional gallery images.

 [ ] Update RecipeStep model (wherever it's defined, likely lib/models/recipe_step.dart or inline):
     Add field: imageUrl (String?, default null) — optional photo for each cooking step.
     Update fromMap() and toMap().

 [ ] Widget: PhotoCarousel — create lib/widgets/photo_carousel.dart
     Receives: imageUrls (List<String>), height (double, default 250).
     Uses PageView.builder to show images. Below: Row of dot indicators (small circles,
     active dot is primary color, inactive is grey). Shows image count badge "1/5" in top-right corner.
     Tap image: opens PhotoViewer (full-screen).
     If only 1 image, show single image without dots/pagination.

 [ ] Widget: PhotoViewer — create lib/widgets/photo_viewer.dart
     Full-screen overlay (Dialog or new route). Black background.
     InteractiveViewer wrapping Image.network for pinch-to-zoom and pan.
     Close button (X) in top-right. Swipe left/right to navigate between images if multiple.
     AppBar with transparent background, image counter "2 of 5".

 [ ] Widget: PhotoGrid — create lib/widgets/photo_grid.dart
     Receives: imageUrls (List<String>), maxDisplay (int, default 4).
     Renders: if 1 image → full-width image. If 2 → two side-by-side. If 3 → one large + two small.
     If 4+ → 2x2 grid, last cell shows "+N more" overlay. Tap any image opens PhotoViewer at that index.

 [ ] AddRecipeScreen modifications (lib/screens/add_recipe/add_recipe_screen.dart):
     - Replace single ImagePickerTile with a multi-image picker section.
     - Show a horizontal scrollable list of selected images with an "Add Photo" button at the end.
     - ReorderableListView or LongPressDraggable to allow drag-to-reorder.
     - First image in the list becomes the cover image (imageUrl field).
     - Use image_picker package (already a dependency) with ImagePicker().pickMultiImage().

 [ ] RecipeDetailScreen modifications:
     - Replace the single cover image with PhotoCarousel if recipe.photos is not empty.
     - If recipe.photos is empty, fall back to single imageUrl display (backward compatible).

 [ ] CookingModeScreen modifications:
     - If a RecipeStep has an imageUrl, show it above the step instruction text on the StepPage.
     - Use a compact image display (height ~150, rounded corners).

 [ ] StorageService modifications (lib/services/storage_service.dart):
     - Add method: uploadRecipePhotos(String recipeId, List<File> files, {void Function(int, int)? onProgress})
       → Future<List<String>> — upload each file to Firebase Storage under recipes/{recipeId}/photos/{index},
       return list of download URLs. Call onProgress(completedCount, totalCount) after each upload.
     - Add method: deleteRecipePhotos(String recipeId) → Future<void> — delete all photos in the folder.

 [ ] RecipeFormProvider modifications (lib/providers/recipe_form_provider.dart):
     - Add field: additionalPhotos (List<File>) for the form state.
     - Add methods: addPhotos(List<File>), removePhoto(int index), reorderPhotos(int oldIndex, int newIndex).
     - Update submit logic: after creating recipe document, upload all photos via StorageService,
       then update recipe document with the returned photo URLs.

 [ ] Image compression: before uploading, compress images using flutter_image_compress package
     (add dependency). Resize to max 1200px width, 80% quality JPEG. This reduces upload time and storage.

 [ ] l10n: add keys to app_en.arb and app_tr.arb:
     addPhotos / "Add Photos" / "Fotoğraf Ekle"
     photoGallery / "Photo Gallery" / "Fotoğraf Galerisi"
     dragToReorder / "Drag to reorder" / "Sıralamak için sürükleyin"
     coverPhoto / "Cover Photo" / "Kapak Fotoğrafı"
     morePhotos / "+{count} more" / "+{count} daha"
     photoOf / "{current} of {total}" / "{current} / {total}"

 [ ] Tests:
     test/models/recipe_test.dart — update existing tests: photos field serialization, empty default
     test/models/recipe_step_test.dart — update: imageUrl field serialization
     test/widgets/photo_carousel_test.dart — renders images, dot indicators, page navigation, count badge
     test/widgets/photo_viewer_test.dart — renders full-screen, close button, zoom gesture
     test/widgets/photo_grid_test.dart — grid layouts for 1/2/3/4+ images, "+N more" overlay

Push 25: Cooking History ("Cooked It" Log)

 [ ] Model: CookingLog — create lib/models/cooking_log.dart
     Fields: id (String), recipeId (String), recipeName (String — denormalized for display),
     recipeImageUrl (String? — denormalized), userId (String), cookedAt (DateTime),
     personalRating (int? — 1-5 personal rating, separate from public rating),
     notes (String? — personal notes about this cook), photoUrl (String? — photo of the result),
     servings (int — how many servings were made).
     Include fromMap(), toMap(), copyWith().
     Firestore collection: "cooking_logs", document ID: auto-generated.

 [ ] Service: CookingLogService — create lib/services/cooking_log_service.dart
     Methods:
     - logCook(CookingLog log) → Future<void> — add document to "cooking_logs"
     - getCookingHistory(String userId, {int limit = 20, DocumentSnapshot? startAfter})
       → Future<List<CookingLog>> — paginated, ordered by cookedAt descending
     - getCookCountForRecipe(String userId, String recipeId) → Future<int> — count documents
       matching userId + recipeId
     - getTotalCooksForRecipe(String recipeId) → Future<int> — count all cooks across all users
     - deleteCookingLog(String logId) → Future<void>
     - updateCookingLog(CookingLog log) → Future<void>
     - streamCookingHistory(String userId) → Stream<List<CookingLog>> — real-time ordered stream
     Accept optional FirebaseFirestore parameter in constructor for DI in tests.

 [ ] Provider: CookingLogProvider — create lib/providers/cooking_log_provider.dart
     Extends ChangeNotifier. Holds: cookingHistory (List<CookingLog>), loading state,
     cookCountCache (Map<String, int> — recipeId → cook count for current user).
     Methods:
     - init(String userId) — subscribe to streamCookingHistory
     - logCook(Recipe recipe, {int? personalRating, String? notes, File? photo, int servings = 1})
       — if photo provided, upload via StorageService first, then create CookingLog and save.
       Also optionally call DailyTrackerService to auto-add a meal entry with the recipe's nutrition
       (add to the current day's log under the appropriate meal type based on current time:
       before 11am = breakfast, 11am-3pm = lunch, 3pm-8pm = dinner, after 8pm = snack).
     - getCookCount(String recipeId) → int — return from cache or fetch from service
     - deleteCookingLog(String logId) — call service, update local list
     Register in main.dart MultiProvider.

 [ ] Screen: CookingHistoryScreen — create lib/screens/cooking_history/cooking_history_screen.dart
     Full-screen page pushed on top of shell. AppBar: "Cooking History", back button.
     Body: ListView.builder of CookingLogCard widgets, ordered by date (newest first).
     Each card shows: recipe image thumbnail, recipe name, "Cooked on Mar 15, 2026",
     personal rating stars (if rated), notes preview (1 line), photo thumbnail (if exists).
     Tap card: navigate to RecipeDetailScreen for that recipe.
     Long-press or swipe: delete with confirmation.
     Empty state: centered text "You haven't cooked anything yet!" with chef hat icon.
     Pull-to-refresh. Pagination with ScrollController for infinite scroll.

 [ ] Widget: CookingLogCard — create lib/screens/cooking_history/widgets/cooking_log_card.dart
     Receives: CookingLog data, onTap, onDelete callbacks.
     Layout: Row with leading recipe image (60x60 rounded), Column with recipe name (bold),
     date text (grey), personal rating stars (small, gold), notes text (grey, 1 line ellipsis).
     Trailing: result photo thumbnail (40x40) if exists. Use PremiumCard wrapper for consistent styling.

 [ ] RecipeDetailScreen modifications:
     - Add "I Cooked This!" button (GradientButton) below the existing action buttons.
     - Tap opens a bottom sheet dialog with:
       - Star rating row (1-5, tap to select)
       - TextField for personal notes (optional)
       - Image picker button for result photo (optional)
       - Servings count selector
       - "Log Cook" submit button
     - After logging, show SnackBar "Cook logged!"
     - Show cook count badge near the button: "Cooked 3 times" (from CookingLogProvider.getCookCount)

 [ ] CookingModeScreen modifications:
     - When user finishes the last step (reaches completion page), show a "Log This Cook" prompt
       instead of just "Done". Auto-open the same cook logging bottom sheet.

 [ ] RecipeCard modifications (lib/widgets/recipe_card.dart):
     - If cook count > 0 for current user, show a small badge/chip "Cooked ×3" on the card.

 [ ] Route: add GoRoute path "/cooking-history" in lib/config/routes.dart under parentNavigatorKey.
     Access point: add "Cooking History" row on ProfileScreen (with history/clock icon).

 [ ] Firestore security rules: cooking_logs — owner can read/write their own documents only.
     match /cooking_logs/{logId} { allow read, write: if request.auth.uid == resource.data.userId; }

 [ ] l10n: add keys to app_en.arb and app_tr.arb:
     cookingHistory / "Cooking History" / "Pişirme Geçmişi"
     iCookedThis / "I Cooked This!" / "Bunu Pişirdim!"
     logCook / "Log Cook" / "Pişirmeyi Kaydet"
     cookedOn / "Cooked on {date}" / "{date} tarihinde pişirildi"
     cookedTimes / "Cooked {count} times" / "{count} kez pişirildi"
     personalNotes / "Personal notes..." / "Kişisel notlar..."
     addResultPhoto / "Add a photo of your result" / "Sonucunuzun fotoğrafını ekleyin"
     noCookingHistory / "You haven't cooked anything yet!" / "Henüz hiçbir şey pişirmediniz!"
     cookLogged / "Cook logged!" / "Pişirme kaydedildi!"

 [ ] Tests:
     test/models/cooking_log_test.dart — fromMap/toMap, copyWith, default values
     test/services/cooking_log_service_test.dart — fake_cloud_firestore: logCook, getCookingHistory pagination,
       getCookCountForRecipe, deleteCookingLog
     test/providers/cooking_log_provider_test.dart — logCook updates list, getCookCount returns cached value,
       auto-add to daily tracker logic
     test/screens/cooking_history/cooking_history_screen_test.dart — renders list, empty state, card taps

Push 26: Seasonal & Trending Recipes

 [ ] Service: TrendingService — create lib/services/trending_service.dart
     Stateless class. Does NOT need its own Firestore collection — computes trending from existing data.
     Methods:
     - getTrendingRecipes({int limit = 10, String timeWindow = '7d'}) → Future<List<Recipe>>
       Algorithm: for each recipe in "recipes" collection (public only, isPrivate != true):
       1. Count favorites created in last 7 days (query "favorites" where recipeId == X and createdAt > 7 days ago)
       2. Read averageRating and ratingCount from recipe document
       3. Calculate trending score = (recentFavorites × 3) + (ratingCount × 2) + (averageRating × 1)
          + recency bonus (recipes created in last 48 hours get +5 points)
       4. Sort by score descending, return top N
       Note: for performance, consider caching scores or using a Cloud Function to pre-compute.
       For MVP, compute on-demand with a reasonable limit.
     - getSeasonalRecipes(int month, {int limit = 10}) → Future<List<Recipe>>
       Map months to seasons: Dec-Feb = Winter, Mar-May = Spring, Jun-Aug = Summer, Sep-Nov = Autumn.
       Query recipes that have the seasonal category tag matching current season.
       Fallback: if no seasonal tags exist, return recently popular recipes.
     - getSeasonalIngredients(int month) → List<String>
       Hard-coded map of month → seasonal ingredient names. Example:
       March: ["asparagus", "peas", "spinach", "strawberries", "artichokes"]
       July: ["tomatoes", "corn", "watermelon", "peaches", "zucchini"]
       December: ["pomegranate", "sweet potato", "cranberries", "brussels sprouts", "pumpkin"]
     Accept optional FirebaseFirestore parameter.

 [ ] Provider: TrendingProvider — create lib/providers/trending_provider.dart
     Extends ChangeNotifier. Holds: trendingRecipes (List<Recipe>), seasonalRecipes (List<Recipe>),
     seasonalIngredients (List<String>), loading state, lastRefreshed (DateTime).
     Methods:
     - loadTrending() — call service.getTrendingRecipes(), cache for 1 hour (check lastRefreshed)
     - loadSeasonal() — call service.getSeasonalRecipes(DateTime.now().month)
     - loadSeasonalIngredients() — call service.getSeasonalIngredients(DateTime.now().month)
     - refresh() — force reload all data
     Register in main.dart MultiProvider.

 [ ] HomeScreen modifications (lib/screens/home/home_screen.dart):
     - Add "Popular This Week" section above or below the existing recipe list.
       Horizontal scrollable list of RecipeCard widgets (compact variant, ~200px wide).
       Show max 10 trending recipes. "See All" link navigates to TrendingRecipesScreen.
     - Add "What's in Season" section: horizontal chip list of seasonal ingredients.
       Tap a chip to navigate to SearchScreen pre-filtered by that ingredient name.
     - Show "Popular Now" badge on RecipeCard for recipes that appear in trending list.
       Add a small flame/fire icon badge on the card corner.

 [ ] Screen: TrendingRecipesScreen — create lib/screens/trending/trending_recipes_screen.dart
     Full-screen page. AppBar: "Trending Recipes", back button.
     Filter chips at top: "This Week", "This Month", "All Time".
     Body: ListView of RecipeCard widgets showing trending recipes for selected time window.
     Each card shows trending rank number (#1, #2, #3...) as a badge.

 [ ] RecipeCard modifications:
     - Add optional showTrendingBadge (bool) and trendingRank (int?) parameters.
     - If showTrendingBadge, show a small flame icon overlay on the image corner.
     - If trendingRank != null, show "#1" rank badge.

 [ ] Update Recipe model or add seasonal tags:
     Add "Spring", "Summer", "Autumn", "Winter" to the existing category or dietary tag system
     so users can tag their recipes as seasonal. Consider adding to the DietaryTag enum or
     creating a separate SeasonalTag enum.

 [ ] Route: add GoRoute path "/trending" in lib/config/routes.dart under parentNavigatorKey.

 [ ] l10n: add keys:
     popularThisWeek / "Popular This Week" / "Bu Hafta Popüler"
     trendingRecipes / "Trending Recipes" / "Trend Tarifler"
     whatsInSeason / "What's in Season" / "Mevsiminde Ne Var?"
     popularNow / "Popular Now" / "Şu An Popüler"
     thisWeek / "This Week" / "Bu Hafta"
     thisMonth / "This Month" / "Bu Ay"
     allTime / "All Time" / "Tüm Zamanlar"
     seeAll / "See All" / "Tümünü Gör"
     spring / "Spring" / "İlkbahar"
     summer / "Summer" / "Yaz"
     autumn / "Autumn" / "Sonbahar"
     winter / "Winter" / "Kış"

 [ ] Tests:
     test/services/trending_service_test.dart — trending score calculation, sort order,
       time window filtering, seasonal ingredient mapping for all 12 months
     test/providers/trending_provider_test.dart — loadTrending populates list,
       caching prevents re-fetch within 1 hour, refresh forces reload

Push 27: Ingredient Substitution Suggestions

 [ ] Model: IngredientSubstitution — create lib/models/ingredient_substitution.dart
     Fields: id (String), originalIngredient (String — lowercase normalized name, e.g. "butter"),
     substituteName (String — e.g. "coconut oil"), ratio (String — e.g. "1:1", "3/4 cup per 1 cup"),
     notes (String? — e.g. "Works best in baking, may alter flavor slightly"),
     dietaryTags (List<String> — e.g. ["vegan", "dairy-free"]),
     submittedBy (String? — userId if community-submitted), isVerified (bool — admin-approved).
     Include fromMap(), toMap().
     Firestore collection: "substitutions", document ID: auto-generated.

 [ ] Service: SubstitutionService — create lib/services/substitution_service.dart
     Methods:
     - getSubstitutions(String ingredientName) → Future<List<IngredientSubstitution>>
       — query "substitutions" where originalIngredient == ingredientName.toLowerCase().trim()
     - getSubstitutionsByTag(String ingredientName, String dietaryTag) → Future<List<IngredientSubstitution>>
       — query where originalIngredient matches AND dietaryTags array-contains dietaryTag
     - submitSubstitution(IngredientSubstitution sub) → Future<void> — add to collection with isVerified: false
     - getAllSubstitutions() → Future<List<IngredientSubstitution>> — admin use, get all
     - verifySubstitution(String id) → Future<void> — set isVerified: true (admin only)
     - deleteSubstitution(String id) → Future<void>
     Accept optional FirebaseFirestore.

 [ ] Seed Firestore: create a seed script or Cloud Function that populates "substitutions" with 50+ entries:
     Butter → coconut oil (1:1, vegan), applesauce (1/2 cup per 1 cup, low-fat), Greek yogurt (1/2 cup per 1 cup)
     Eggs → flax egg (1 tbsp ground flax + 3 tbsp water per egg, vegan), chia egg (1 tbsp chia + 3 tbsp water, vegan),
       mashed banana (1/4 cup per egg, vegan), unsweetened applesauce (1/4 cup per egg)
     Milk → oat milk (1:1, vegan/dairy-free), almond milk (1:1, vegan/dairy-free/nut),
       soy milk (1:1, vegan/dairy-free), coconut milk (1:1, vegan/dairy-free)
     All-purpose flour → almond flour (1:1 but add binding agent, gluten-free/keto),
       coconut flour (1/4 cup per 1 cup flour, gluten-free/keto), oat flour (1:1, gluten-free)
     Sugar → honey (3/4 cup per 1 cup, reduce liquid by 1/4), maple syrup (3/4 cup per 1 cup),
       stevia (1 tsp per 1 cup sugar, keto)
     Cream → coconut cream (1:1, vegan), cashew cream (1:1, vegan)
     Sour cream → Greek yogurt (1:1), coconut yogurt (1:1, vegan)
     Heavy cream → full-fat coconut milk (1:1, vegan)
     Breadcrumbs → crushed cornflakes (1:1, gluten-free), almond meal (1:1, gluten-free/keto)
     Soy sauce → coconut aminos (1:1, soy-free), tamari (1:1, gluten-free)
     Use a Dart script run via `flutter run` or a standalone script to seed data.

 [ ] Widget: SubstitutionSheet — create lib/widgets/substitution_sheet.dart
     A showModalBottomSheet bottom sheet. Receives: ingredientName (String).
     Fetches substitutions from SubstitutionService on open (show CircularProgressIndicator while loading).
     Header: "Substitutes for {ingredientName}".
     Optional filter: row of FilterChip for dietary tags (Vegan, Gluten-Free, Keto, Dairy-Free).
     Body: ListView of substitution cards. Each card shows:
       - Substitute name (bold)
       - Ratio text (e.g. "Use 1:1 ratio")
       - Notes text (grey, if exists)
       - Dietary tag chips (small colored chips)
       - Verified checkmark icon if isVerified
     Bottom: "Suggest a Substitution" TextButton that opens a simple form dialog
       (substitute name TextField, ratio TextField, notes TextField, dietary tag multi-select)
       and calls service.submitSubstitution() with submittedBy = current userId.

 [ ] RecipeDetailScreen modifications:
     - On each ingredient row in the ingredient list, add a trailing icon button (swap/arrow icon).
     - Tap opens SubstitutionSheet for that ingredient's name.
     - If no substitutions found, show "No substitutions available" message in the sheet.

 [ ] Firestore security rules: substitutions collection —
     anyone can read, authenticated users can create (with isVerified: false),
     only admins can update isVerified or delete.

 [ ] l10n: add keys:
     substitutions / "Substitutions" / "Alternatifler"
     substitutesFor / "Substitutes for {ingredient}" / "{ingredient} için alternatifler"
     ratio / "Ratio: {ratio}" / "Oran: {ratio}"
     suggestSubstitution / "Suggest a Substitution" / "Alternatif Öner"
     noSubstitutions / "No substitutions available" / "Mevcut alternatif yok"
     substituteName / "Substitute name" / "Alternatif adı"
     verified / "Verified" / "Doğrulanmış"
     communitySubmitted / "Community submitted" / "Topluluk tarafından önerildi"
     thankYouSubstitution / "Thanks! Your suggestion will be reviewed." / "Teşekkürler! Öneriniz incelenecek."

 [ ] Tests:
     test/models/ingredient_substitution_test.dart — fromMap/toMap, dietaryTags list serialization
     test/services/substitution_service_test.dart — fake_cloud_firestore: getSubstitutions returns matches,
       getSubstitutionsByTag filters correctly, submitSubstitution creates with isVerified false
     test/widgets/substitution_sheet_test.dart — loads and displays substitutions, filter chips work,
       "Suggest" form submits correctly

Push 28: Achievement Badges & Gamification

 [ ] Model: Achievement — create lib/models/achievement.dart
     Fields: id (String — predefined badge ID like "first_recipe", "streak_7"),
     title (String), description (String), iconName (String — Flutter Icons name or asset path),
     criteria (Map<String, dynamic> — e.g. {"type": "recipe_count", "target": 1}),
     category (String — "cooking", "social", "health", "exploration").
     This is a static definition, not stored per-user. Define as a constant list in the file:
     static const List<Achievement> allAchievements = [ ... ] with all 12+ badge definitions.

 [ ] Model: UserAchievement — create lib/models/user_achievement.dart
     Fields: id (String), achievementId (String — references Achievement.id),
     userId (String), unlockedAt (DateTime).
     Include fromMap(), toMap().
     Firestore collection: "user_achievements", document ID: auto-generated.

 [ ] Badge definitions (define in Achievement.allAchievements):
     1. first_recipe — "First Recipe" / "Publish your first recipe" / criteria: {type: "recipe_count", target: 1}
     2. recipe_master — "Recipe Master" / "Publish 10 recipes" / criteria: {type: "recipe_count", target: 10}
     3. streak_7 — "7-Day Streak" / "Log meals for 7 consecutive days" / criteria: {type: "streak", target: 7}
     4. streak_30 — "30-Day Streak" / "Log meals for 30 consecutive days" / criteria: {type: "streak", target: 30}
     5. top_rated — "Top Rated" / "Get a 5-star average rating" / criteria: {type: "avg_rating", target: 5.0}
     6. home_chef — "Home Chef" / "Cook 10 different recipes" / criteria: {type: "unique_cooks", target: 10}
     7. health_nut — "Health Nut" / "Hit all macro targets for a week" / criteria: {type: "macro_streak", target: 7}
     8. hydration_hero — "Hydration Hero" / "Hit water goal 7 days in a row" / criteria: {type: "water_streak", target: 7}
     9. social_butterfly — "Social Butterfly" / "Gain 10 followers" / criteria: {type: "follower_count", target: 10}
     10. smart_shopper — "Smart Shopper" / "Create 5 shopping lists" / criteria: {type: "shopping_list_count", target: 5}
     11. collector — "Collector" / "Create 3 recipe collections" / criteria: {type: "collection_count", target: 3}
     12. explorer — "Explorer" / "Try recipes from 5 categories" / criteria: {type: "unique_categories_cooked", target: 5}

 [ ] Service: AchievementService — create lib/services/achievement_service.dart
     Methods:
     - getUserAchievements(String userId) → Future<List<UserAchievement>> — query user_achievements by userId
     - streamUserAchievements(String userId) → Stream<List<UserAchievement>>
     - unlockAchievement(String userId, String achievementId) → Future<void> — create UserAchievement document
       (check if already unlocked first to avoid duplicates)
     - checkAndUnlockAchievements(String userId, {required Map<String, dynamic> context})
       → Future<List<Achievement>> — the main method. Takes a context map with current user stats:
       {"recipeCount": 5, "streak": 8, "followerCount": 12, "cookCount": 3, ...}
       Iterates all Achievement definitions, checks criteria against context,
       for any newly met criteria that aren't already unlocked, calls unlockAchievement.
       Returns list of newly unlocked achievements (for showing celebration UI).
     - getProgress(String userId, Achievement achievement) → Future<double>
       — returns 0.0 to 1.0 progress toward the achievement target.
       Queries the relevant data source based on achievement.criteria.type.
     Accept optional FirebaseFirestore.

 [ ] Provider: AchievementProvider — create lib/providers/achievement_provider.dart
     Extends ChangeNotifier. Holds: unlockedAchievements (List<UserAchievement>),
     progressMap (Map<String, double> — achievementId → progress 0.0-1.0),
     newlyUnlocked (List<Achievement> — for showing celebration, cleared after display).
     Methods:
     - init(String userId) — subscribe to streamUserAchievements, load initial progress
     - checkAchievements() — gather current stats from other providers (RecipeProvider.recipes.length,
       DailyTrackerProvider.currentStreak, FollowProvider.followerCount, etc.),
       call service.checkAndUnlockAchievements, if any newly unlocked → add to newlyUnlocked, notifyListeners
     - getProgress(String achievementId) → double — from progressMap
     - clearNewlyUnlocked() — called after celebration UI is shown
     Call checkAchievements() after key user actions: publishing recipe, logging meal, gaining follower, etc.
     Register in main.dart MultiProvider.

 [ ] Screen: AchievementsScreen — create lib/screens/achievements/achievements_screen.dart
     Full-screen page. AppBar: "Achievements", back button.
     Body: GridView.builder with 2 columns. Each cell is an achievement card:
     - Achievement icon (large, centered)
     - Title text below icon
     - If unlocked: full color icon, gold border, "Unlocked on {date}" subtitle
     - If locked: greyed-out icon, dashed border, progress bar showing X% toward target
     - Tap card: show bottom sheet with full description, criteria details, progress bar
     Category filter chips at top: All, Cooking, Social, Health, Exploration.
     Use Consumer<AchievementProvider>.

 [ ] Achievement celebration widget:
     When AchievementProvider.newlyUnlocked is not empty, show a celebration overlay/dialog:
     - Semi-transparent dark overlay
     - Centered card with achievement icon (large, animated scale-up), title, description
     - Confetti or sparkle animation (use simple AnimatedContainer or a confetti package)
     - "Awesome!" dismiss button
     Show this overlay in the main shell/scaffold when newlyUnlocked changes.
     After dismiss, call provider.clearNewlyUnlocked().

 [ ] ProfileScreen modifications:
     - Add "Achievements" section showing the 3 most recent unlocked badges as small icons in a Row.
     - "View All" link navigates to AchievementsScreen.
     - Show total count: "X of 12 achievements unlocked".

 [ ] Route: add GoRoute path "/achievements" in lib/config/routes.dart under parentNavigatorKey.

 [ ] Firestore security rules: user_achievements — owner can read their own, system/admin can write.
     match /user_achievements/{docId} { allow read: if request.auth.uid == resource.data.userId; }

 [ ] l10n: add keys:
     achievements / "Achievements" / "Başarılar"
     achievementUnlocked / "Achievement Unlocked!" / "Başarı Kazanıldı!"
     unlockedOn / "Unlocked on {date}" / "{date} tarihinde kazanıldı"
     progress / "{percent}% complete" / "%{percent} tamamlandı"
     awesome / "Awesome!" / "Harika!"
     firstRecipe / "First Recipe" / "İlk Tarif"
     recipeMaster / "Recipe Master" / "Tarif Ustası"
     sevenDayStreak / "7-Day Streak" / "7 Günlük Seri"
     thirtyDayStreak / "30-Day Streak" / "30 Günlük Seri"
     topRated / "Top Rated" / "En Çok Beğenilen"
     homeChef / "Home Chef" / "Ev Şefi"
     healthNut / "Health Nut" / "Sağlık Tutkunu"
     hydrationHero / "Hydration Hero" / "Hidrasyon Kahramanı"
     socialButterfly / "Social Butterfly" / "Sosyal Kelebek"
     smartShopper / "Smart Shopper" / "Akıllı Alışverişçi"
     collectorBadge / "Collector" / "Koleksiyoncu"
     explorerBadge / "Explorer" / "Kaşif"
     viewAllAchievements / "View All Achievements" / "Tüm Başarıları Gör"
     achievementsUnlocked / "{count} of {total} unlocked" / "{total} başarıdan {count} kazanıldı"

 [ ] Tests:
     test/models/achievement_test.dart — allAchievements list completeness, criteria structure
     test/models/user_achievement_test.dart — fromMap/toMap round-trip
     test/services/achievement_service_test.dart — fake_cloud_firestore:
       unlockAchievement creates doc, no duplicate unlock, checkAndUnlockAchievements with various contexts,
       getProgress calculations for each criteria type
     test/providers/achievement_provider_test.dart — init loads unlocked list,
       checkAchievements detects newly met criteria, clearNewlyUnlocked empties list

Push 29: Recipe Versioning & Edit History

 [ ] Model: RecipeVersion — create lib/models/recipe_version.dart
     Fields: id (String), recipeId (String), versionNumber (int — starts at 1, increments),
     changes (Map<String, dynamic> — diff of what changed: {"title": {"old": "...", "new": "..."},
     "ingredients": {"added": [...], "removed": [...]}}),
     snapshot (Map<String, dynamic> — full recipe toMap() at this version for revert),
     editedAt (DateTime), editedBy (String — userId).
     Include fromMap(), toMap().
     Firestore: stored as subcollection under recipes/{recipeId}/versions/{versionId}.

 [ ] Service: RecipeVersionService — create lib/services/recipe_version_service.dart
     Methods:
     - saveVersion(String recipeId, Recipe oldRecipe, Recipe newRecipe, String userId) → Future<void>
       — compute diff between old and new, determine next versionNumber, save to subcollection.
       Diff logic: compare each field, record only changed fields in the changes map.
     - getVersionHistory(String recipeId) → Future<List<RecipeVersion>> — ordered by versionNumber desc
     - getVersion(String recipeId, String versionId) → Future<RecipeVersion?>
     - revertToVersion(String recipeId, String versionId) → Future<void> — read version snapshot,
       update the main recipe document with the snapshot data, save a new version recording the revert.

 [ ] RecipeService modifications: when updating a recipe, call RecipeVersionService.saveVersion()
     with the old and new recipe data before saving the update.

 [ ] Screen: RecipeVersionHistoryScreen — create lib/screens/recipe_detail/version_history_screen.dart
     Full-screen page. AppBar: "Edit History", back button.
     Body: Timeline-style ListView. Each entry shows:
     - Version number badge (#1, #2, #3...)
     - Date and editor name
     - Summary of changes (e.g. "Changed title, added 2 ingredients, removed 1 step")
     - "Revert" button (only visible to recipe owner)
     Tap entry: show detailed diff view (side-by-side or inline showing old → new for each changed field).

 [ ] RecipeDetailScreen modifications:
     - Add "Edit History" option in the overflow menu (three-dot menu) — only visible to recipe owner.
     - Navigates to RecipeVersionHistoryScreen.

 [ ] Route: add GoRoute path "/recipe/:id/versions" in lib/config/routes.dart.

 [ ] l10n: add keys:
     editHistory / "Edit History" / "Düzenleme Geçmişi"
     version / "Version {number}" / "Sürüm {number}"
     editedBy / "Edited by {name}" / "{name} tarafından düzenlendi"
     revertToVersion / "Revert to this version" / "Bu sürüme geri dön"
     confirmRevert / "Revert to version {number}? Current changes will be saved as a new version." / "Sürüm {number}'e geri dönülsün mü? Mevcut değişiklikler yeni sürüm olarak kaydedilecek."
     changedFields / "Changed: {fields}" / "Değişen: {fields}"

 [ ] Tests:
     test/models/recipe_version_test.dart — fromMap/toMap, diff structure
     test/services/recipe_version_service_test.dart — saveVersion computes correct diff,
       versionNumber increments, revertToVersion restores snapshot, getVersionHistory ordering

Push 30: Advanced Search & Filters

 [ ] SearchProvider enhancements (lib/providers/search_provider.dart):
     Add new filter fields: cookTimeRange (RangeValues?), calorieRange (RangeValues?),
     difficultyLevel (String?), maxIngredientCount (int?), sortBy (String — "newest", "popular",
     "rating", "cookTime", "calories").
     Update the search/filter method to apply all active filters simultaneously.
     Add searchHistory (List<String>) persisted in SharedPreferences — save last 10 searches.
     Add searchSuggestions logic: as user types, show matching recipe titles from cached recipes
     + recent search history items.

 [ ] SearchScreen enhancements (lib/screens/search/search_screen.dart):
     - Below the search TextField, add a "Filters" button that opens a filter bottom sheet.
     - Filter bottom sheet contents:
       - Cooking time slider: RangeSlider with labels "0 min" to "120+ min",
         preset chips: "Quick (< 15 min)", "Medium (15-30 min)", "Standard (30-60 min)", "Long (60+ min)"
       - Calorie range slider: RangeSlider "0 cal" to "1000+ cal"
       - Difficulty level: SegmentedButton with Easy / Medium / Hard
       - Max ingredients: Slider 1-20 with labels
       - Sort by: ChoiceChip row with "Newest", "Popular", "Rating", "Cook Time", "Calories"
       - "Apply Filters" button, "Clear All" button
     - Show active filter count badge on the Filters button.
     - When search field is empty, show recent search history as chips (tap to re-search, X to remove).
     - As user types, show auto-complete suggestions dropdown below the search field.

 [ ] "Recipes with ingredients I have" feature:
     - Add a "Search by Ingredients" tab or button on SearchScreen.
     - Shows a TextField where user can add ingredient names one by one (Chip input pattern).
     - Filter: find recipes where ALL entered ingredients exist in the recipe's ingredient list
       (match by ingredient name contains, case-insensitive).
     - Show results sorted by how many matching ingredients (best matches first).

 [ ] l10n: add keys:
     filters / "Filters" / "Filtreler"
     cookingTime / "Cooking Time" / "Pişirme Süresi"
     quickUnder15 / "Quick (< 15 min)" / "Hızlı (< 15 dk)"
     medium15to30 / "Medium (15-30 min)" / "Orta (15-30 dk)"
     standard30to60 / "Standard (30-60 min)" / "Standart (30-60 dk)"
     longOver60 / "Long (60+ min)" / "Uzun (60+ dk)"
     calorieRange / "Calorie Range" / "Kalori Aralığı"
     difficulty / "Difficulty" / "Zorluk"
     easy / "Easy" / "Kolay"
     medium / "Medium" / "Orta"
     hard / "Hard" / "Zor"
     maxIngredients / "Max Ingredients" / "Maks Malzeme"
     sortBy / "Sort By" / "Sırala"
     popular / "Popular" / "Popüler"
     applyFilters / "Apply Filters" / "Filtreleri Uygula"
     clearAll / "Clear All" / "Tümünü Temizle"
     recentSearches / "Recent Searches" / "Son Aramalar"
     searchByIngredients / "Search by Ingredients" / "Malzemeye Göre Ara"
     addIngredient / "Add ingredient..." / "Malzeme ekle..."
     bestMatches / "Best Matches" / "En İyi Eşleşmeler"

 [ ] Tests:
     test/providers/search_provider_test.dart — update existing tests:
       multi-filter combinations, cookTime range filtering, calorie range, difficulty filter,
       sort by each option, search history persistence, ingredient-based matching,
       searchSuggestions returns matching titles

Push 31: Offline Support & Caching

 [ ] Add dependency: flutter pub add hive hive_flutter connectivity_plus
     Hive for local key-value/object storage. connectivity_plus for network state detection.

 [ ] CacheService — create lib/services/cache_service.dart
     Manages all Hive boxes. Methods:
     - initialize() — call Hive.initFlutter(), open boxes: 'recipes', 'food_items', 'daily_logs', 'user_prefs'
     - cacheRecipes(List<Recipe> recipes) — store all recipes in 'recipes' box as JSON maps
     - getCachedRecipes() → List<Recipe> — read from 'recipes' box
     - cacheFoodItems(List<FoodItem> items) — store in 'food_items' box
     - getCachedFoodItems() → List<FoodItem>
     - cacheDailyLog(DailyLog log) — store in 'daily_logs' box keyed by date string
     - getCachedDailyLog(DateTime date) → DailyLog?
     - queueOfflineAction(Map<String, dynamic> action) — add to 'offline_queue' box:
       {type: "create_recipe", data: {...}, timestamp: ...}
     - getOfflineQueue() → List<Map<String, dynamic>>
     - clearOfflineQueue() — clear queue after successful sync
     - getCacheSize() → Future<int> — calculate total bytes across all boxes
     - clearAllCaches() → Future<void> — clear all boxes

 [ ] ConnectivityService — create lib/services/connectivity_service.dart
     Wraps connectivity_plus. Methods:
     - isOnline() → Future<bool>
     - onConnectivityChanged → Stream<bool>

 [ ] SyncService — create lib/services/sync_service.dart
     Methods:
     - syncOfflineQueue(String userId) — read offline queue, replay each action against Firestore,
       on success remove from queue, on failure keep for retry.
       Handle conflicts: if document already exists (create conflict), skip or merge.
       Handle recipe updates: last-write-wins strategy.
     - fullSync(String userId) — download all user's recipes, food items, and recent daily logs
       from Firestore, cache locally. Called on app launch when online.

 [ ] Provider modifications:
     - RecipeProvider: on init, if online → stream from Firestore + cache locally.
       If offline → load from CacheService. When creating/editing recipe offline,
       queue via CacheService.queueOfflineAction().
     - FoodItemProvider: same pattern — cache food items, serve from cache when offline.
     - DailyTrackerProvider: cache daily logs, queue meal entries when offline.

 [ ] UI: Add a network status indicator:
     - Create lib/widgets/connectivity_indicator.dart — listens to ConnectivityService.onConnectivityChanged.
       When offline, show a small colored bar at the top of the scaffold (below AppBar) with
       "You're offline — changes will sync when connected" message. Yellow/orange background.
       When back online, show green "Back online — syncing..." briefly, then hide.
     - Add this widget to the ShellScreen scaffold so it appears on all tabs.

 [ ] Settings: Add cache management on ProfileScreen:
     - "Storage & Cache" row that opens a bottom sheet showing:
       - Cache size: "X MB used"
       - "Clear Recipe Cache" button
       - "Clear Food Item Cache" button
       - "Clear All Caches" button
       - Offline queue status: "X actions pending sync"

 [ ] l10n: add keys:
     youreOffline / "You're offline" / "Çevrimdışısınız"
     changesSyncWhenConnected / "Changes will sync when connected" / "Değişiklikler bağlanınca senkronize edilecek"
     backOnline / "Back online — syncing..." / "Tekrar çevrimiçi — senkronize ediliyor..."
     storageAndCache / "Storage & Cache" / "Depolama ve Önbellek"
     cacheSize / "Cache size: {size}" / "Önbellek boyutu: {size}"
     clearCache / "Clear Cache" / "Önbelleği Temizle"
     pendingSync / "{count} actions pending sync" / "{count} işlem senkronizasyon bekliyor"

 [ ] Tests:
     test/services/cache_service_test.dart — cache and retrieve recipes, food items, daily logs,
       queue offline actions, getCacheSize, clearAllCaches
     test/services/sync_service_test.dart — syncOfflineQueue replays actions, handles conflicts,
       fullSync downloads and caches
     test/widgets/connectivity_indicator_test.dart — shows offline bar, hides when online

Push 32: Recipe Video Support

 [ ] Add dependencies: flutter pub add video_player chewie video_compress
     video_player for playback, chewie for nice player UI, video_compress for compression.

 [ ] Update Recipe model: add videoUrl (String?, default null) field.
     Update fromMap() and toMap().

 [ ] Update RecipeStep model: add videoUrl (String?, default null) field for per-step videos.
     Update fromMap() and toMap().

 [ ] StorageService enhancements:
     - uploadRecipeVideo(String recipeId, File videoFile, {void Function(double)? onProgress})
       → Future<String> — upload to Firebase Storage at recipes/{recipeId}/video,
       return download URL. Use putFile with StorageMetadata(contentType: 'video/mp4').
       Listen to task.snapshotEvents for upload progress percentage.
     - deleteRecipeVideo(String recipeId) → Future<void>
     - generateVideoThumbnail(File videoFile) → Future<File> — use video_compress to extract
       first frame as thumbnail image.

 [ ] Widget: VideoPlayerWidget — create lib/widgets/video_player_widget.dart
     Wraps Chewie player. Receives: videoUrl (String), autoPlay (bool, default false),
     showControls (bool, default true).
     Initializes VideoPlayerController.networkUrl(Uri.parse(videoUrl)).
     Wraps in ChewieController with aspectRatio, autoPlay, looping: false.
     Dispose controllers in dispose(). Show thumbnail/placeholder until video loads.
     Error handling: if video fails to load, show "Video unavailable" placeholder.

 [ ] AddRecipeScreen modifications:
     - Add "Add Video" button in the media section (below photo picker).
     - Use ImagePicker().pickVideo() to select a video from gallery or record.
     - Show video thumbnail preview after selection.
     - Compress video before upload using VideoCompress.compressVideo().
     - Upload during recipe save, store URL in recipe.videoUrl.
     - Per-step video: in each step input card, add optional "Add Step Video" button.

 [ ] RecipeDetailScreen modifications:
     - If recipe.videoUrl is not null, show VideoPlayerWidget at the top of the detail page
       (above or instead of the cover image, with a toggle to switch between photo and video).
     - Auto-generate and show video thumbnail on RecipeCard.

 [ ] CookingModeScreen modifications:
     - If a RecipeStep has videoUrl, show VideoPlayerWidget on the StepPage
       (compact, above step instruction text).

 [ ] RecipeCard modifications:
     - If recipe has videoUrl, show a small play button overlay on the recipe card image.

 [ ] l10n: add keys:
     addVideo / "Add Video" / "Video Ekle"
     recordVideo / "Record Video" / "Video Kaydet"
     videoUnavailable / "Video unavailable" / "Video kullanılamıyor"
     uploadingVideo / "Uploading video..." / "Video yükleniyor..."
     compressingVideo / "Compressing video..." / "Video sıkıştırılıyor..."
     stepVideo / "Step Video" / "Adım Videosu"

 [ ] Tests:
     test/models/recipe_test.dart — update: videoUrl serialization
     test/widgets/video_player_widget_test.dart — renders player, shows placeholder on error

Push 33: Social Features Enhancement

 [ ] Recipe likes (separate from favorites):
     - Add likeCount (int, default 0) and likedBy (List<String>) to Recipe model, or create
       a separate "likes" Firestore collection with {recipeId, userId, createdAt} documents.
     - LikeService — create lib/services/like_service.dart: toggleLike, getLikeCount, isLikedBy
     - LikeProvider — create lib/providers/like_provider.dart: manages like state
     - UI: heart/thumbs-up button on RecipeCard and RecipeDetailScreen (separate from favorite star)
       showing public like count.

 [ ] Threaded comments:
     - Update Comment model: add parentCommentId (String?, null for top-level).
     - CommentService: add getReplies(recipeId, parentCommentId) method.
     - UI: indent replies below parent comment. "Reply" button on each comment opens reply input.
       Show reply count on parent comment. Collapse/expand replies.

 [ ] Report system:
     - Model: Report — create lib/models/report.dart
       Fields: id, reporterId, targetType ("recipe" | "comment" | "user"), targetId, reason, createdAt, status ("pending" | "reviewed")
     - ReportService — create lib/services/report_service.dart: submitReport, getReports (admin)
     - UI: "Report" option in overflow menu on RecipeDetailScreen and on each comment.
       Opens dialog: "Why are you reporting this?" with reason options (Inappropriate, Spam, Harassment, Other).

 [ ] Block user:
     - Add blockedUsers (List<String>) to UserModel, or create "blocks" collection.
     - BlockService — create lib/services/block_service.dart: blockUser, unblockUser, isBlocked
     - Filter blocked users from feed, search results, comments.
     - UI: "Block User" option in profile overflow menu.

 [ ] Activity feed:
     - Model: Activity — create lib/models/activity.dart
       Fields: id, userId (who receives), actorId, actorName, type ("like" | "comment" | "follow" | "rating"),
       targetId, targetName, createdAt, isRead (bool).
     - ActivityService — write activity documents when events happen (like, comment, follow, rate).
     - ActivityScreen — list of recent activities, mark as read on view.
     - Badge count on notification icon.

 [ ] Share to social media: extend existing share_plus usage to format for specific platforms.

 [ ] User mentions: detect @username in comment text, linkify, send notification to mentioned user.

 [ ] l10n: add keys for all social features (likes, replies, report, block, activity, mentions)

 [ ] Tests: LikeService, threaded comment queries, ReportService, BlockService filtering, ActivityService

Push 34: Recipe Cost Estimation

 [ ] Update FoodItem model: add pricePerUnit (double?, default null) and currency (String, default "TRY").
     Update fromMap() and toMap().

 [ ] Cost calculation utility — create lib/utils/cost_calculator.dart:
     - calculateRecipeCost(List<Ingredient> ingredients, Map<String, FoodItem> foodItemMap) → double
       For each ingredient, find its FoodItem, calculate: (ingredient.amount / 100) * foodItem.pricePerUnit.
       Sum all ingredient costs.
     - calculateCostPerServing(double totalCost, int servings) → double

 [ ] Currency support — create lib/utils/currency_utils.dart:
     - Supported currencies: TRY, USD, EUR, GBP
     - formatCurrency(double amount, String currencyCode) → String (e.g. "₺25.50", "$3.20")
     - Exchange rates: hard-coded or fetched from a free API. For MVP, hard-code approximate rates.

 [ ] RecipeDetailScreen modifications:
     - Show "Estimated Cost: ₺25.50 (₺4.25/serving)" section below nutrition info.
     - Only show if ingredients have linked FoodItems with prices.

 [ ] FoodItemDetailScreen / AddFoodItemScreen modifications:
     - Add price input field (optional) with currency selector dropdown.

 [ ] SearchScreen / HomeScreen filter: add "Budget-Friendly" filter chip or price range slider.

 [ ] Settings: add currency preference on ProfileScreen or EditProfileScreen.

 [ ] l10n: add keys for cost strings (estimatedCost, costPerServing, budgetFriendly, currency names)

 [ ] Tests: cost calculation with various quantities, currency formatting, per-serving math

Push 35: Accessibility & Performance

 [ ] Semantic labels: audit all screens, add Semantics widgets wrapping interactive elements,
     add semanticLabel to all Icon and Image widgets, add excludeSemantics where needed.
     Test with TalkBack (Android) and VoiceOver (iOS).

 [ ] High contrast mode: detect MediaQuery.highContrast, provide alternative color scheme
     with stronger contrast ratios (4.5:1 minimum for text per WCAG AA).

 [ ] Dynamic font scaling: ensure all Text widgets use theme TextStyle (not hardcoded fontSize),
     test with system font size set to largest. Fix any overflow issues caused by large text.

 [ ] Lazy loading / pagination:
     - RecipeProvider: implement paginated stream using Firestore .limit() + .startAfterDocument().
     - HomeScreen / FeedScreen: use ScrollController to detect near-bottom, trigger loadMore().
     - Show CircularProgressIndicator at bottom while loading next page.
     - Page size: 10 recipes per page.

 [ ] Image lazy loading:
     - Replace all Image.network with CachedNetworkImage (cached_network_image package).
     - Add shimmer placeholder while loading (shimmer package or custom Container with gradient animation).
     - Add fadeInDuration for smooth appearance.

 [ ] Performance:
     - Run Flutter DevTools profiler, identify jank in scrolling, fix with const constructors,
       RepaintBoundary wrapping expensive widgets, avoiding rebuilds.
     - Use const wherever possible in widget trees.
     - Minimize setState scope — only rebuild what changed.

 [ ] Bundle size: remove unused assets, use --split-debug-info for smaller APK,
     enable --obfuscate for release builds. Check with `flutter build apk --analyze-size`.

 [ ] Tests: accessibility widget tests using find.bySemanticsLabel, font scaling overflow tests

Push 36: Recipe AI Suggestions

 [ ] Recommendation algorithm (no external AI API needed for MVP — rule-based):
     - "Similar Recipes" on RecipeDetailScreen: query recipes with same category,
       overlapping dietary tags, or overlapping ingredients. Score by overlap count, show top 5.
     - "You Might Also Like" on HomeScreen: based on user's cooking history and favorites,
       find recipes in same categories the user prefers. Exclude already favorited/cooked.
     - "What Should I Cook?" button: random recipe generator with optional filters
       (category, dietary tags, max cook time). Show one recipe with "Try Another" button.
     - "Nutritional Recommendations": compare today's logged nutrition vs goals,
       suggest recipes that fill the gap (e.g. if protein is low, suggest high-protein recipes).

 [ ] SuggestionService — create lib/services/suggestion_service.dart
 [ ] SuggestionProvider — create lib/providers/suggestion_provider.dart
 [ ] RecipeDetailScreen: add "Similar Recipes" horizontal list below comments
 [ ] HomeScreen: add "You Might Also Like" section
 [ ] Create a "Discover" floating action button or screen accessible from HomeScreen

 [ ] l10n: add keys for suggestion strings
 [ ] Tests: recommendation scoring, filter combinations, nutritional gap calculation

Push 37: Multi-Language Recipe Content

 [ ] Recipe model: add translations (Map<String, Map<String, String>>?) field —
     maps language code → {title: "...", description: "...", stepInstructions: [...], ingredientNames: [...]}
 [ ] TranslationService — submit/fetch translations
 [ ] UI: language toggle on RecipeDetailScreen, translation request button
 [ ] Community translation submission form
 [ ] l10n: add keys for translation feature

Push 38: Widgets & Quick Actions

 [ ] iOS/Android home screen widgets (home_widget package):
     - Daily nutrition summary widget showing calories/macros progress
     - Quick "Add Meal" action widget
 [ ] Quick Actions (quick_actions package):
     - iOS 3D Touch shortcuts: Add Recipe, Track Meal, Shopping List
     - Android App Shortcuts: same actions
 [ ] Siri Shortcuts (if applicable, using relevant Flutter plugin)
 [ ] Tests: widget data provider logic

Push 39: Data Export & Backup

 [ ] Export recipes as JSON: serialize all user's recipes to JSON file, save to downloads or share
 [ ] Export as PDF cookbook: use pdf package to generate formatted PDF with recipe images, ingredients, steps
 [ ] Export daily tracker as CSV: date, meal type, food item, calories, protein, carbs, fat per row
 [ ] Import recipes from JSON: file picker → parse JSON → create recipe documents in Firestore
 [ ] Cloud backup: Google Drive API integration for automatic backup of user data
 [ ] Settings: backup frequency selector (daily/weekly/manual), last backup timestamp display
 [ ] l10n: add keys for export/backup strings
 [ ] Tests: JSON serialization/deserialization round-trip, CSV format validation, PDF generation

Push 40: App Store Preparation

 [ ] App icon: create adaptive icon (Android) and standard icon (iOS) in multiple required sizes.
     Use flutter_launcher_icons package to generate from a single high-res source image.
 [ ] Splash screen: use flutter_native_splash package. Configure with app logo centered,
     background color matching app theme. Both light and dark variants.
 [ ] App Store screenshots: capture on iOS Simulator (iPhone 14 Pro Max for 6.7",
     iPhone 8 Plus for 5.5"). 5-6 screenshots showing key features.
 [ ] Play Store: feature graphic (1024x500), screenshots, short/long description
 [ ] Privacy policy page: create a simple web page or in-app WebView with privacy policy text
 [ ] Terms of service page: same as privacy policy
 [ ] App Store descriptions in English and Turkish
 [ ] TestFlight: configure in App Store Connect, upload build via Xcode
 [ ] Google Play: create internal testing track, upload AAB
 [ ] Version: semantic versioning (1.0.0), maintain CHANGELOG.md
