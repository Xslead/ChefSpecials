import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../models/food_item.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/shell/shell_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/my_recipes/my_recipes_screen.dart';
import '../screens/daily_tracker/daily_tracker_screen.dart';
import '../screens/food_items/food_item_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/add_recipe/add_recipe_screen.dart';
import '../screens/edit_recipe/edit_recipe_screen.dart';
import '../screens/recipe_detail/recipe_detail_screen.dart';
import '../screens/cooking_mode/cooking_mode_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/food_items/add_food_item_screen.dart';
import '../screens/food_items/food_item_detail_screen.dart';
import '../screens/daily_tracker/add_meal_entry_screen.dart';
import '../screens/daily_tracker/nutrition_goals_screen.dart';
import '../models/meal_entry.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Bottom navigation shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScreen(navigationShell: navigationShell),
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: My Recipes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-recipes',
              builder: (context, state) => const MyRecipesScreen(),
            ),
          ],
        ),
        // Tab 2: Daily Tracker
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/daily-tracker',
              builder: (context, state) => const DailyTrackerScreen(),
            ),
          ],
        ),
        // Tab 3: Materials
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/materials',
              builder: (context, state) => const FoodItemListScreen(),
            ),
          ],
        ),
        // Tab 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Sub-screens that push on top of the shell
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/add-recipe',
      builder: (context, state) => const AddRecipeScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/edit-recipe/:id',
      builder: (context, state) {
        final recipe = state.extra as Recipe?;
        if (recipe == null) {
          return const Scaffold(body: Center(child: Text('Recipe not found')));
        }
        return EditRecipeScreen(recipe: recipe);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/recipe/:id',
      builder: (context, state) {
        final recipe = state.extra as Recipe?;
        if (recipe == null) {
          return const Scaffold(body: Center(child: Text('Recipe not found')));
        }
        return RecipeDetailScreen(recipe: recipe);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/add-food-item',
      builder: (context, state) => const AddFoodItemScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/food-item/:id',
      builder: (context, state) {
        final foodItem = state.extra as FoodItem?;
        if (foodItem == null) {
          return const Scaffold(
              body: Center(child: Text('Food item not found')));
        }
        return FoodItemDetailScreen(foodItem: foodItem);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/add-meal-entry',
      builder: (context, state) {
        final mealType = state.extra as MealType? ?? MealType.snack;
        return AddMealEntryScreen(mealType: mealType);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/nutrition-goals',
      builder: (context, state) => const NutritionGoalsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/cooking/:id',
      builder: (context, state) {
        final recipe = state.extra as Recipe?;
        if (recipe == null) {
          return const Scaffold(
              body: Center(child: Text('Recipe not found')));
        }
        return CookingModeScreen(recipe: recipe);
      },
    ),
  ],
);
