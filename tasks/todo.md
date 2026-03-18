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
- [x] Self-test: flutter analyze — 0 issues
- [x] Self-test: flutter build ios + apk — SUCCESS
- **Status:** PUSHED ✅

---

## Push 2: Recipe CRUD + Home Feed + Nutrition
- [x] Models: Recipe, RecipeStep, Ingredient
- [x] Services: RecipeService, StorageService
- [x] Providers: RecipeProvider, RecipeFormProvider
- [x] Screens: HomeScreen (feed), AddRecipeScreen, RecipeDetailScreen
- [x] Widgets: RecipeCard, CategoryFilterBar, IngredientInputList, StepInputList, ImagePickerTile, IngredientListView, StepOverviewList
- [x] Routes updated (add-recipe, recipe/:id)
- [x] RecipeProvider added to MultiProvider
- [x] Self-test: flutter analyze — 0 issues
- **Status:** PUSHED ✅

---

## Push 3: Cooking Mode (Step-by-Step Pages)
- [x] CookingModeScreen (PageView navigation)
- [x] StepPage widget
- [x] CountdownTimerWidget
- [x] Progress indicator (LinearProgressIndicator in AppBar)
- [x] Route: /cooking/:id added to GoRouter
- [x] RecipeDetailScreen "Start Cooking" button wired with extra
- [x] Self-test: flutter analyze — 0 issues
- [x] Self-test: running on Android emulator
- **Status:** PUSHED ✅

---

## Push 4: Search + Favorites
- [x] Models: Favorite
- [x] Services: FavoriteService
- [x] Providers: FavoriteProvider, SearchProvider
- [x] Screens: SearchScreen, FavoritesScreen
- [x] Widgets: SearchResultTile
- [x] Heart icon on recipe cards
- [x] Routes: /search, /favorites added
- [x] FavoriteProvider added to MultiProvider
- [x] Home AppBar: search + favorites icons
- [x] Self-test: flutter analyze — 0 issues
- **Status:** PUSHED ✅

---

## Push 5: Profile + i18n + Utilities + Polish
- [x] Screens: ProfileScreen, EditProfileScreen
- [x] AuthProvider: refreshUser() method added
- [x] StorageService: uploadUserAvatar() method added
- [x] Utils: validators, image_utils, date_utils
- [x] Routes: /profile, /edit-profile added
- [x] Home AppBar: profile icon replaces logout
- [x] Self-test: flutter analyze — 0 issues
- **Status:** PUSHED ✅

---

## Push 6: Ingredient Database (Materials)
- [x] **Model:** FoodItem (name, brand, packetSize, barcode, isVegan, unit: "100g" or "mL", calories, protein, carbs, fat, fiber, sugar, sodium)
- [x] **Firestore collection:** `food_items` — shared database all users can browse
- [x] **Service:** FoodItemService (CRUD + search)
- [x] **Provider:** FoodItemProvider
- [x] **Screens:**
  - [x] FoodItemListScreen — browse/search all materials with category filter
  - [x] AddFoodItemScreen — any user can add a new material with nutrition per 100g or mL
  - [x] FoodItemDetailScreen — view full nutrition breakdown (per 100g + per packet)
- [x] **Widgets:** FoodItemCard, NutritionFactsTable
- [x] Seed Firestore with 28 real food items (real brands, nutrition data from Open Food Facts/USDA)
- [x] Firestore security rules for food_items collection deployed
- [x] Recipe ingredients now link to materials database (food item picker instead of free-text)
- [x] Auto-calculate recipe nutrition from ingredient quantities
- [x] Cook time auto-calculated from step timers (sum of all step timerSeconds)
- [x] Materials accessible from Home screen AppBar (kitchen icon)
- [x] Self-test: flutter analyze — 0 issues
- **Status:** PUSHED ✅

---

## Push 7: Bottom Navigation + My Recipes
- [x] **Bottom Navigation Bar** (5 tabs): Home, Feed, Daily Tracker, Materials, Profile
- [x] ShellScreen with NavigationBar + StatefulShellRoute.indexedStack
- [x] GoRouter updated to StatefulShellRoute with 5 branches
- [x] **My Recipes Tab:**
  - [x] MyRecipesScreen — only logged-in user's recipes
  - [x] Filter/sort options (by date, category)
  - [x] FAB to add new recipe
- [x] Profile tab — existing ProfileScreen moved into bottom nav
- [x] Materials tab — FoodItemListScreen in bottom nav
- [x] FoodItemProvider moved to global MultiProvider
- [x] HomeScreen AppBar cleaned (removed Materials + Profile icons, kept Search + Favorites)
- [x] DailyTrackerScreen placeholder created
- [x] l10n updated (EN + TR): myRecipes, dailyTracker, materials, sortBy, newest, oldest, all, comingSoon
- [x] Sub-screens (add-recipe, recipe detail, cooking mode, etc.) push on top of shell via parentNavigatorKey
- [x] Self-test: flutter analyze — 0 issues
- **Status:** PUSHED ✅

---

## Push 8: Daily Tracker + Nutrition Goals
- [x] **Models:** DailyLog, MealEntry (breakfast, lunch, dinner, snack), NutritionGoal
- [x] **Services:** DailyTrackerService (Firestore CRUD)
- [x] **Providers:** DailyTrackerProvider
- [x] **DailyTrackerScreen** — date picker + meal sections
- [x] Meal sections: Breakfast, Lunch, Dinner, Snack
- [x] Add food items (from materials DB) or full recipes to a meal slot
- [x] Specify quantity (e.g. 150g chicken, 200mL milk)
- [x] Auto-calculate nutrition based on quantity × per-100g values
- [x] Daily nutrition summary: total calories, protein, carbs, fat
- [x] Per-meal nutrition breakdown
- [x] Circular/bar charts for macro visualization (fl_chart BarChart + custom CalorieRingPainter)
- [x] **Nutrition Goals:** set daily calorie/protein/carbs/fat targets
- [x] Progress rings showing current vs target on Daily Tracker
- [x] DailyTrackerProvider added to MultiProvider
- [x] Firestore security rules deployed (daily_logs, nutrition_goals)
- [x] l10n updated (EN + TR): breakfast, lunch, dinner, snack, nutritionGoals, dailySummary, etc.
- [x] Routes: /add-meal-entry, /nutrition-goals added
- [x] Self-test: flutter analyze — 0 issues
- **Status:** PUSHED ✅

---

## Push 9: Ratings & Comments
- [x] **Models:** Rating, Comment
- [x] **Services:** RatingService, CommentService
- [x] **Providers:** RatingProvider, CommentProvider
- [x] Star rating widget (1–5 stars) on RecipeDetailScreen
- [x] Average rating displayed on RecipeCard
- [x] Comments section on RecipeDetailScreen (add/view/delete)
- **Status:** PUSHED ✅

---

## Push 10: Recipe Privacy + Social Feed + Follow System
- [x] **Recipe Privacy:** isPrivate field on Recipe model, visibility toggle on AddRecipeScreen
- [x] **FollowService:** follow/unfollow, getFollowerIds, getFollowingIds
- [x] **FollowProvider:** real-time follow state, follower/following counts
- [x] **FeedScreen:** recipes from followed users + user search by username
- [x] **Feed tab** added to bottom nav (Tab 2)
- [x] **PublicProfileScreen:** view other users' public recipes
- [x] **FollowListScreen:** followers/following tabs with follow/unfollow buttons
- [x] Follow/unfollow button on public profiles
- [x] Follower/following counts on ProfileScreen (tappable stat cards)
- [x] **Username system:** unique username field on UserModel, search by username
- [x] Navigation icons on follow list tabs + chevron on stat cards
- **Status:** PUSHED ✅

---

## Push 11: Dark Mode
- [x] **ThemeProvider** with light/dark/system modes
- [x] Persist theme preference (SharedPreferences)
- [x] Dark mode toggle on ProfileScreen (sun/moon icon)
- [x] All screens support dark theme colors via AppTheme helper methods
- **Status:** PUSHED ✅

---

## Remaining — What's Left To Do

### Push 12: Dietary Tags
- [x] Add dietary tags to Recipe model (Vegan, Gluten-Free, Keto, Halal, etc.)
- [x] Dietary tag picker on AddRecipeScreen
- [x] Filter recipes by dietary tags on HomeScreen/SearchScreen
- [x] Unified filter sheet (category + dietary tags + sort) on Home and Materials screens
- [x] Fix: filter icon alignment when badge is visible

### Push 13: Shopping List
- [x] **Model:** ShoppingList, ShoppingItem (name, amount, unit, isChecked)
- [x] **Service:** ShoppingListService (Firestore CRUD, toggle, clear checked, add items)
- [x] **Provider:** ShoppingListProvider (stream subscription, all CRUD methods)
- [x] **ShoppingListsScreen** — view all user's lists with progress circles, swipe-to-delete
- [x] **ShoppingListDetailScreen** — check/uncheck items, strikethrough, clear checked, swipe-to-delete
- [x] Auto-generate shopping list from recipe ingredients (button on RecipeDetailScreen)
- [x] Bottom sheet: pick existing list or create new list from recipe detail
- [x] Shopping cart icon on Home screen header for quick access
- [x] Firestore security rules deployed (owner-only read/write)
- [x] Firestore composite index deployed (userId + updatedAt)
- [x] l10n: 13 new keys in EN + TR
- [x] UI redesigned to match app design patterns (custom headers, shadows, adaptive colors)
- **Status:** PUSHED ✅

### Push 14: Recipe Collections
- [ ] **Model:** RecipeCollection (name, description, recipeIds, coverImage)
- [ ] **Service:** CollectionService (Firestore CRUD)
- [ ] **Provider:** CollectionProvider
- [ ] **CollectionListScreen** — view all user's collections
- [ ] **CollectionDetailScreen** — view recipes in a collection
- [ ] Create/edit/delete custom folders (e.g. "Quick Meals", "Keto", "Weekend")
- [ ] Add/remove recipes to collections from RecipeDetailScreen

### Push 15: Share Recipe + Recipe Import
- [ ] **Share Recipe:** share recipe as link or image card via share_plus
- [ ] Generate shareable recipe card image
- [ ] Share button on RecipeDetailScreen
- [x] **Recipe Import from URL:** paste a recipe link and auto-parse ingredients/steps
- [x] Import screen with URL input

### Push 16: Weekly Meal Planner
- [ ] **Models:** MealPlan, PlannedMeal (day, mealType, recipeId)
- [ ] **Services:** MealPlanService (Firestore CRUD)
- [ ] **Providers:** MealPlanProvider
- [ ] **MealPlannerScreen** — weekly calendar view (Mon–Sun)
- [ ] Drag/assign recipes to days and meal slots
- [ ] Weekly nutrition totals summary
- [ ] Auto-generate shopping list from weekly plan

### Push 17: Weekly/Monthly Reports
- [ ] **ReportsScreen** — nutrition summary over time
- [ ] Weekly averages: calories, protein, carbs, fat
- [ ] Monthly trends with line/bar charts (fl_chart)
- [ ] Streak tracking (consecutive days logged)
- [ ] Export report as PDF or image

### Push 18: Push Notifications
- [ ] Firebase Cloud Messaging setup
- [ ] Meal reminders ("Time for lunch!")
- [ ] New recipe alerts from followed users
- [ ] Notification settings screen (toggle per type)

### Push 19: Admin Panel
- [ ] Services: AdminService
- [ ] Providers: AdminProvider
- [ ] Screens: AdminDashboard, AdminRecipes, AdminUsers, AdminCategories, AdminNotifications
- [ ] Widgets: StatsCard, UserListTile, AdminRecipeTile, CategoryEditDialog
- [ ] Admin route guard
- [ ] Firestore security rules

### Push 20: Testing (Unit + Widget + Integration)
- [x] **765 tests passing** across all layers (70 files, 12,099 lines)
- [x] DI constructors added to all 11 services and 11 providers
- [x] Dev dependencies: fake_cloud_firestore, mockito, build_runner
- [x] Test helpers: 26 factory functions for all 13 models

#### Unit Tests (`test/`) ✅
- [x] **Models (233 tests):** Recipe, Ingredient, ShoppingList, ShoppingItem, FoodItem, DailyLog, MealEntry, NutritionGoal, UserModel, Rating, Comment, Favorite, RecipeStep
  - [x] `fromMap()` / `toMap()` round-trip correctness
  - [x] Default values, null handling, edge cases, computed properties, copyWith, enums
- [x] **Services (133 tests, fake_cloud_firestore):**
  - [x] RecipeService — CRUD, streams, category filter, feed pagination, author name batch update
  - [x] FavoriteService — toggle, isFavorite, streams
  - [x] ShoppingListService — CRUD, toggle, clear checked, remove, add items
  - [x] FoodItemService — CRUD, search, category filter
  - [x] DailyTrackerService — CRUD, date queries, nutrition goals
  - [x] RatingService — set/delete with transaction, average calculation
  - [x] CommentService — subcollection CRUD, transaction counters
  - [x] FollowService — follow/unfollow batch writes, streams
  - [x] UserService — CRUD, username claim transaction, search, migration
- [x] **Providers (195 tests, fake_cloud_firestore + real services):**
  - [x] LocaleProvider, ThemeProvider — simple state tests
  - [x] RecipeProvider — stream, filter, CRUD, author name update
  - [x] FavoriteProvider — stream, toggle, isFavorite
  - [x] ShoppingListProvider — init, CRUD, toggle, clear
  - [x] DailyTrackerProvider — meals, water, progress, goals
  - [x] FoodItemProvider — filters, sort, search, category
  - [x] RatingProvider / CommentProvider — optimistic updates, transactions
  - [x] SearchProvider — multi-field query filtering
  - [x] FollowProvider — optimistic follow/unfollow
  - [x] RecipeFormProvider — nutrition calc, step management, form state
- [x] **Utils (66 tests):**
  - [x] Validators (email, password, required, confirmPassword)
  - [x] Date utils (timeAgo, formatDate)

#### Widget Tests (`test/widgets/`) ✅
- [x] **Shared Widgets (136 tests):**
  - [x] RecipeCard — title, author, category, rating, comments, nutrition, dietary tags
  - [x] FoodItemCard — name, brand, calories, vegan badge, verified icon, nutrition bar
  - [x] NutritionFactsTable — per-unit, per-packet, macros, micros, progress bars
  - [x] GradientButton — label, onPressed, disabled state, icon, height
  - [x] PremiumCard — child, padding, gradient, borderRadius, shadow
  - [x] CountdownTimerWidget — start, pause, reset, Done!, MM:SS format
  - [x] CategoryFilterBar — all chips, selection callback, l10n
  - [x] SearchResultTile — title, category, time, calorie badge
  - [x] IngredientListView — names, amounts, alternating rows
  - [x] StepOverviewList — numbers, instructions, timer formatting

#### Test Infrastructure ✅
- [x] Add `flutter_test`, `mockito`, `fake_cloud_firestore` to dev_dependencies
- [x] Test helpers: 26 factory functions (test/helpers/test_helpers.dart)
- [x] CI-ready: `flutter test` runs 765 tests in ~9 seconds
- **Status:** PUSHED ✅

### Push 21: Unit Converter + Recipe Scaling
- [ ] **Measurement Converter:** tap any ingredient to convert between metric/imperial (g↔oz, mL↔cups, °C↔°F)
- [ ] Converter utility class with all common cooking unit conversions
- [ ] Inline conversion popup/bottom sheet on ingredient tap
- [ ] **Recipe Scaling:** multiply/divide ingredient quantities (e.g. serves 2 → serves 6)
- [ ] Serving size selector on RecipeDetailScreen
- [ ] Auto-recalculate all ingredient amounts and nutrition totals

### Push 22: Onboarding Flow
- [ ] First-launch walkthrough (3–4 pages) showing key app features
- [ ] Dietary preference setup during onboarding (Vegan, Keto, Halal, etc.)
- [ ] Save preferences to user profile
- [ ] Skip option for returning users
- [ ] SharedPreferences flag to show only once

### Push 23: Recipe Photo Gallery
- [ ] Multiple photos per recipe (gallery instead of single cover image)
- [ ] Photo carousel on RecipeDetailScreen
- [ ] Step-by-step photos in cooking mode (optional photo per step)
- [ ] Image picker for multiple photos on AddRecipeScreen

### Push 24: Cooking History ("Cooked It" Log)
- [ ] **Model:** CookingLog (recipeId, userId, cookedAt, rating, notes)
- [ ] **Service:** CookingLogService (Firestore CRUD)
- [ ] "I Cooked This" button on RecipeDetailScreen / end of cooking mode
- [ ] Cooking history screen — list of cooked recipes with dates
- [ ] Integration with daily tracker (auto-log nutrition when marking as cooked)

### Push 25: Seasonal & Trending Recipes
- [ ] Trending section on HomeScreen (most favorited/rated this week)
- [ ] Seasonal recipe suggestions based on current month
- [ ] "Popular Now" badge on recipe cards
- [ ] Algorithm: weighted score from favorites + ratings + recency

### Push 26: Ingredient Substitution Suggestions
- [ ] Substitution database (e.g. butter → coconut oil, milk → oat milk)
- [ ] "Suggest Substitute" button on ingredient items
- [ ] Filter substitutions by dietary tag (vegan, dairy-free, etc.)
- [ ] Community-sourced substitutions (users can suggest)

### Push 27: Achievement Badges & Gamification
- [ ] **Model:** UserAchievement (badgeId, unlockedAt)
- [ ] Badge definitions: First Recipe, 7-Day Streak, 50 Recipes Cooked, Master Chef, etc.
- [ ] Achievement unlock notifications
- [ ] Badges displayed on profile screen
- [ ] Streak tracking (consecutive days logged/cooked)
