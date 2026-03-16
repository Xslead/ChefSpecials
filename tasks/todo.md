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
- [ ] Add dietary tags to Recipe model (Vegan, Gluten-Free, Keto, Halal, etc.)
- [ ] Dietary tag picker on AddRecipeScreen
- [ ] Filter recipes by dietary tags on HomeScreen/SearchScreen

### Push 13: Shopping List
- [ ] **Model:** ShoppingList, ShoppingItem (name, quantity, unit, checked)
- [ ] **Service:** ShoppingListService (Firestore CRUD)
- [ ] **Provider:** ShoppingListProvider
- [ ] **ShoppingListScreen** — view/manage grocery list with checkboxes
- [ ] Auto-generate shopping list from a recipe's ingredients (button on RecipeDetailScreen)
- [ ] Check off items as you shop
- [ ] Clear completed items

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
- [ ] **Recipe Import from URL:** paste a recipe link and auto-parse ingredients/steps
- [ ] Import screen with URL input

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
