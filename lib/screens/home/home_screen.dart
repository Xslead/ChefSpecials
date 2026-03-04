import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import 'widgets/recipe_card.dart';
import 'widgets/category_filter_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipeProvider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CategoryFilterBar(
            selectedCategory: recipeProvider.selectedCategory,
            onSelected: recipeProvider.setCategory,
          ),
          Expanded(
            child: recipeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : recipeProvider.recipes.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noRecipes,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: recipeProvider.recipes.length,
                        itemBuilder: (context, index) {
                          return RecipeCard(
                            recipe: recipeProvider.recipes[index],
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-recipe'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
