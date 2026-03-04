import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/add_recipe/add_recipe_screen.dart';
import '../screens/recipe_detail/recipe_detail_screen.dart';
import '../screens/cooking_mode/cooking_mode_screen.dart';

final GoRouter router = GoRouter(
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
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-recipe',
      builder: (context, state) => const AddRecipeScreen(),
    ),
    GoRoute(
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
      path: '/cooking/:id',
      builder: (context, state) {
        final recipe = state.extra as Recipe?;
        if (recipe == null) {
          return const Scaffold(body: Center(child: Text('Recipe not found')));
        }
        return CookingModeScreen(recipe: recipe);
      },
    ),
  ],
);
