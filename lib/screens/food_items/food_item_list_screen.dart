import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/food_item_provider.dart';
import 'widgets/food_item_card.dart';

const List<String> _foodItemCategories = [
  'All',
  'Protein',
  'Dairy',
  'Grains',
  'Vegetables',
  'Fruits',
  'Oils & Fats',
  'Beverages',
  'Other',
];

class FoodItemListScreen extends StatelessWidget {
  const FoodItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodItemProvider()..listenToFoodItems(),
      child: const _FoodItemListBody(),
    );
  }
}

class _FoodItemListBody extends StatefulWidget {
  const _FoodItemListBody();

  @override
  State<_FoodItemListBody> createState() => _FoodItemListBodyState();
}

class _FoodItemListBodyState extends State<_FoodItemListBody> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<FoodItemProvider>().searchFoodItems('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FoodItemProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search food items...',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            provider.searchFoodItems('');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                  provider.searchFoodItems(value);
                },
              )
            : const Text('Materials'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isSearching) _buildCategoryFilterBar(provider),
          Expanded(
            child: _buildBody(provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-food-item'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilterBar(FoodItemProvider provider) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _foodItemCategories.map((category) {
          final isSelected = provider.selectedCategory ==
              (category == 'All' ? 'All' : category);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => provider.setCategory(category),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color:
                    isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(FoodItemProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _isSearching && provider.searchQuery.isNotEmpty
        ? provider.searchResults
        : provider.foodItems;

    if (items.isEmpty) {
      return Center(
        child: Text(
          _isSearching ? 'No results found' : 'No food items yet',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return FoodItemCard(foodItem: items[index]);
      },
    );
  }
}
