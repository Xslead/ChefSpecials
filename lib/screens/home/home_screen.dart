import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/favorite_provider.dart';
import 'widgets/recipe_card.dart';
import 'widgets/category_filter_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().ensureInitialized();
      final user = context.read<AuthProvider>().userModel;
      if (user != null) {
        context.read<FavoriteProvider>().listenToFavorites(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipeProvider = context.watch<RecipeProvider>();

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, recipeProvider),
          Expanded(
            child: recipeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : recipeProvider.recipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: AppTheme.warmBeige,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noRecipes,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: recipeProvider.recipes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: RecipeCard(
                              recipe: recipeProvider.recipes[index],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: FloatingActionButton(
            heroTag: 'home_fab',
            onPressed: () => context.push('/add-recipe'),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    RecipeProvider recipeProvider,
  ) {
    final user = context.watch<AuthProvider>().userModel;
    final firstName = user?.firstName ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [AppTheme.warmShadowLight()],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting text
              if (firstName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${_getGreeting()}, $firstName!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ),
              // Logo row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'ChefSpecials',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.favorite_outline),
                    color: AppTheme.textSecondary,
                    onPressed: () => context.push('/favorites'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Search bar
              GestureDetector(
                onTap: () => context.push('/search'),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.warmBeige,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.search,
                        color: AppTheme.textTertiary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.searchRecipeOrIngredient,
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Category filter
              CategoryFilterBar(
                selectedCategory: recipeProvider.selectedCategory,
                onSelected: recipeProvider.setCategory,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
