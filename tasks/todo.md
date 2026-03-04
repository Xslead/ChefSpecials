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
- **Status:** READY TO PUSH

---

## Push 7: Bottom Navigation + My Recipes
- [x] **Bottom Navigation Bar** (5 tabs): Home, My Recipes, Daily Tracker, Materials, Profile
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
- **Status:** READY TO PUSH

---

## Push 8: Daily Tracker + Nutrition Goals
- [ ] **Models:** DailyLog, MealEntry (breakfast, lunch, dinner, snack), NutritionGoal
- [ ] **Services:** DailyTrackerService (Firestore CRUD)
- [ ] **Providers:** DailyTrackerProvider
- [ ] **DailyTrackerScreen** — date picker + meal sections
- [ ] Meal sections: Breakfast, Lunch, Dinner, Snack
- [ ] Add food items (from materials DB) or full recipes to a meal slot
- [ ] Specify quantity (e.g. 150g chicken, 200mL milk)
- [ ] Auto-calculate nutrition based on quantity × per-100g values
- [ ] Daily nutrition summary: total calories, protein, carbs, fat
- [ ] Per-meal nutrition breakdown
- [ ] Circular/bar charts for macro visualization
- [ ] **Nutrition Goals:** set daily calorie/protein/carbs/fat targets
- [ ] Progress rings showing current vs target on Daily Tracker
- [ ] DailyTrackerProvider added to MultiProvider
- [ ] Self-test: flutter analyze + build
- **Status:** PENDING

---

## Push 9: Ratings, Comments & Dietary Filters
- [ ] **Models:** Rating, Comment
- [ ] **Services:** RatingService, CommentService
- [ ] **Providers:** RatingProvider, CommentProvider
- [ ] Star rating widget (1–5 stars) on RecipeDetailScreen
- [ ] Average rating displayed on RecipeCard
- [ ] Comments section on RecipeDetailScreen (add/view/delete)
- [ ] **Dietary tags** on Recipe model: Vegan, Gluten-Free, Keto, Halal, etc.
- [ ] Dietary tag picker on AddRecipeScreen
- [ ] Filter recipes by dietary tags on HomeScreen/SearchScreen
- [ ] Self-test: flutter analyze + build
- **Status:** PENDING

---

## Push 10: Shopping List
- [ ] **Model:** ShoppingList, ShoppingItem (name, quantity, unit, checked)
- [ ] **Service:** ShoppingListService (Firestore CRUD)
- [ ] **Provider:** ShoppingListProvider
- [ ] **ShoppingListScreen** — view/manage grocery list with checkboxes
- [ ] Auto-generate shopping list from a recipe's ingredients (button on RecipeDetailScreen)
- [ ] Check off items as you shop
- [ ] Clear completed items
- [ ] Self-test: flutter analyze + build
- **Status:** PENDING

---

## Push 11: Recipe Collections
- [ ] **Model:** RecipeCollection (name, description, recipeIds, coverImage)
- [ ] **Service:** CollectionService (Firestore CRUD)
- [ ] **Provider:** CollectionProvider
- [ ] **CollectionListScreen** — view all user's collections
- [ ] **CollectionDetailScreen** — view recipes in a collection
- [ ] Create/edit/delete custom folders (e.g. "Quick Meals", "Keto", "Weekend")
- [ ] Add/remove recipes to collections from RecipeDetailScreen
- [ ] Self-test: flutter analyze + build
- **Status:** PENDING

---

## Push 12: Social Feed + Follow Users
- [ ] **Models:** Follow, ActivityFeedItem
- [ ] **Services:** FollowService, FeedService
- [ ] **Providers:** FollowProvider, FeedProvider
- [ ] Follow/unfollow button on user profiles
- [ ] Social feed tab showing new recipes from followed users
- [ ] Follower/following counts on ProfileScreen
- [ ] Self-test: flutter analyze + build
- **Status:** PENDING

---

## Push 13: Share Recipe + Recipe Import
- [ ] **Share Recipe:** share recipe as link or image card via WhatsApp, Instagram, etc. (share_plus package)
- [ ] Generate shareable recipe card image
- [ ] Share button on RecipeDetailScreen
- [ ] **Recipe Import from URL:** paste a recipe link and auto-parse ingredients/steps
- [ ] Import screen with URL input
- [ ] Web scraping / parsing logic for common recipe sites
- [ ] Self-test: flutter analyze + build
- **Status:** PENDING

---

## Push 14: Weekly Meal Planner
- [ ] **Models:** MealPlan, PlannedMeal (day, mealType, recipeId)
- [ ] **Services:** MealPlanService (Firestore CRUD)
- [ ] **Providers:** MealPlanProvider
- [ ] **MealPlannerScreen** — weekly calendar view (Mon–Sun)
- [ ] Drag/assign recipes to days and meal slots
- [ ] Weekly nutrition totals summary
- [ ] Auto-generate shopping list from weekly plan
- [ ] Self-test: flutter analyze + build
- **Status:** PENDING

---

## Push 15: Weekly/Monthly Reports
- [ ] **ReportsScreen** — nutrition summary over time
- [ ] Weekly averages: calories, protein, carbs, fat
- [ ] Monthly trends with line/bar charts (fl_chart)
- [ ] Streak tracking (consecutive days logged)
- [ ] Export report as PDF or image
- [ ] Self-test: flutter analyze + build
- **Status:** PENDING

---

## Push 16: Dark Mode + Push Notifications
- [ ] **Dark Mode:** theme toggle in ProfileScreen/Settings
- [ ] ThemeProvider with light/dark/system modes
- [ ] Persist theme preference (SharedPreferences)
- [ ] All screens support dark theme colors
- [ ] **Push Notifications:** Firebase Cloud Messaging setup
- [ ] Meal reminders ("Time for lunch!")
- [ ] New recipe alerts from followed users
- [ ] Notification settings screen (toggle per type)
- [ ] Self-test: flutter analyze + build
- **Status:** PENDING

---

## Push 17: Admin Panel
- [ ] Services: AdminService
- [ ] Providers: AdminProvider
- [ ] Screens: AdminDashboard, AdminRecipes, AdminUsers, AdminCategories, AdminNotifications
- [ ] Widgets: StatsCard, UserListTile, AdminRecipeTile, CategoryEditDialog
- [ ] Admin route guard
- [ ] Firestore security rules
- [ ] Self-test: flutter analyze + build
- **Status:** PENDING
