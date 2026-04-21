import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final Map<String, dynamic> criteria;
  final String category;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.criteria,
    required this.category,
  });

  IconData get icon => _iconFor(iconName);

  Color get color => _palette[id]?.$1 ?? const Color(0xFFF59E0B);
  Color get accentColor => _palette[id]?.$2 ?? const Color(0xFFFBBF24);

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, accentColor],
      );

  static IconData _iconFor(String name) {
    switch (name) {
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'menu_book':
        return Icons.menu_book;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'star':
        return Icons.star;
      case 'soup_kitchen':
        return Icons.soup_kitchen;
      case 'favorite':
        return Icons.favorite;
      case 'water_drop':
        return Icons.water_drop;
      case 'groups':
        return Icons.groups;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'collections_bookmark':
        return Icons.collections_bookmark;
      case 'explore':
        return Icons.explore;
      default:
        return Icons.emoji_events;
    }
  }

  static const Map<String, (Color, Color)> _palette = {
    'first_recipe': (Color(0xFFFB923C), Color(0xFFFDBA74)),
    'recipe_master': (Color(0xFFDC2626), Color(0xFFF87171)),
    'streak_7': (Color(0xFFF59E0B), Color(0xFFFCD34D)),
    'streak_30': (Color(0xFFEA580C), Color(0xFFFB7185)),
    'top_rated': (Color(0xFFEAB308), Color(0xFFFDE047)),
    'home_chef': (Color(0xFF92400E), Color(0xFFD97706)),
    'health_nut': (Color(0xFFEC4899), Color(0xFFF9A8D4)),
    'hydration_hero': (Color(0xFF0EA5E9), Color(0xFF7DD3FC)),
    'social_butterfly': (Color(0xFF8B5CF6), Color(0xFFC4B5FD)),
    'smart_shopper': (Color(0xFF10B981), Color(0xFF6EE7B7)),
    'collector': (Color(0xFF6366F1), Color(0xFFA5B4FC)),
    'explorer': (Color(0xFF14B8A6), Color(0xFF5EEAD4)),
  };

  static const List<Achievement> allAchievements = [
    Achievement(
      id: 'first_recipe',
      title: 'First Recipe',
      description: 'Publish your first recipe',
      iconName: 'restaurant_menu',
      category: 'cooking',
      criteria: {'type': 'recipesPublished', 'target': 1},
    ),
    Achievement(
      id: 'recipe_master',
      title: 'Recipe Master',
      description: 'Publish 10 recipes',
      iconName: 'menu_book',
      category: 'cooking',
      criteria: {'type': 'recipesPublished', 'target': 10},
    ),
    Achievement(
      id: 'streak_7',
      title: '7-Day Streak',
      description: 'Log meals for 7 consecutive days',
      iconName: 'local_fire_department',
      category: 'health',
      criteria: {'type': 'mealStreak', 'target': 7},
    ),
    Achievement(
      id: 'streak_30',
      title: '30-Day Streak',
      description: 'Log meals for 30 consecutive days',
      iconName: 'whatshot',
      category: 'health',
      criteria: {'type': 'mealStreak', 'target': 30},
    ),
    Achievement(
      id: 'top_rated',
      title: 'Top Rated',
      description: 'Reach a 5-star average rating',
      iconName: 'star',
      category: 'social',
      criteria: {'type': 'averageRating', 'target': 5.0},
    ),
    Achievement(
      id: 'home_chef',
      title: 'Home Chef',
      description: 'Cook 10 different recipes',
      iconName: 'soup_kitchen',
      category: 'cooking',
      criteria: {'type': 'uniqueRecipesCooked', 'target': 10},
    ),
    Achievement(
      id: 'health_nut',
      title: 'Health Nut',
      description: 'Hit all macro targets for a week',
      iconName: 'favorite',
      category: 'health',
      criteria: {'type': 'macroTargetsWeek', 'target': 7},
    ),
    Achievement(
      id: 'hydration_hero',
      title: 'Hydration Hero',
      description: 'Hit your water goal 7 days in a row',
      iconName: 'water_drop',
      category: 'health',
      criteria: {'type': 'waterStreak', 'target': 7},
    ),
    Achievement(
      id: 'social_butterfly',
      title: 'Social Butterfly',
      description: 'Gain 10 followers',
      iconName: 'groups',
      category: 'social',
      criteria: {'type': 'followers', 'target': 10},
    ),
    Achievement(
      id: 'smart_shopper',
      title: 'Smart Shopper',
      description: 'Create 5 shopping lists',
      iconName: 'shopping_cart',
      category: 'exploration',
      criteria: {'type': 'shoppingLists', 'target': 5},
    ),
    Achievement(
      id: 'collector',
      title: 'Collector',
      description: 'Create 3 recipe collections',
      iconName: 'collections_bookmark',
      category: 'exploration',
      criteria: {'type': 'collections', 'target': 3},
    ),
    Achievement(
      id: 'explorer',
      title: 'Explorer',
      description: 'Try recipes from 5 categories',
      iconName: 'explore',
      category: 'exploration',
      criteria: {'type': 'categoriesCooked', 'target': 5},
    ),
  ];

  static Achievement? byId(String id) {
    for (final a in allAchievements) {
      if (a.id == id) return a;
    }
    return null;
  }

  static List<String> get categories =>
      const ['cooking', 'social', 'health', 'exploration'];
}
