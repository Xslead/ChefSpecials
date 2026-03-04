import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../home/widgets/recipe_card.dart';

enum _SortOption { newest, oldest, category }

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  String? _selectedCategory;
  _SortOption _sortOption = _SortOption.newest;

  List<Recipe> _filterAndSort(List<Recipe> recipes) {
    var filtered = _selectedCategory != null
        ? recipes.where((r) => r.category == _selectedCategory).toList()
        : recipes;

    switch (_sortOption) {
      case _SortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOption.category:
        filtered.sort((a, b) => a.category.compareTo(b.category));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final recipeProvider = context.watch<RecipeProvider>();
    final user = authProvider.userModel;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userRecipes =
        recipeProvider.allRecipes.where((r) => r.authorId == user.uid).toList();
    final categories =
        userRecipes.map((r) => r.category).toSet().toList()..sort();
    final displayedRecipes = _filterAndSort(userRecipes);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myRecipes),
        actions: [
          PopupMenuButton<_SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sortBy,
            onSelected: (option) => setState(() => _sortOption = option),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _SortOption.newest,
                child: Text(l10n.newest),
              ),
              PopupMenuItem(
                value: _SortOption.oldest,
                child: Text(l10n.oldest),
              ),
              PopupMenuItem(
                value: _SortOption.category,
                child: Text(l10n.category),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(l10n.all),
                      selected: _selectedCategory == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                  ),
                  ...categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: displayedRecipes.isEmpty
                ? Center(
                    child: Text(
                      l10n.noRecipes,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedRecipes.length,
                    itemBuilder: (context, index) =>
                        RecipeCard(recipe: displayedRecipes[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'my_recipes_fab',
        onPressed: () => context.push('/add-recipe'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
