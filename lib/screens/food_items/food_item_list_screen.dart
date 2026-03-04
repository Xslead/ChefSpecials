import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
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

class FoodItemListScreen extends StatefulWidget {
  const FoodItemListScreen({super.key});

  @override
  State<FoodItemListScreen> createState() => _FoodItemListScreenState();
}

class _FoodItemListScreenState extends State<FoodItemListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FoodItemProvider>().ensureInitialized();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<FoodItemProvider>();

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, provider),
          Expanded(child: _buildBody(l10n, provider)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          heroTag: 'materials_fab',
          onPressed: () => context.push('/add-food-item'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    FoodItemProvider provider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_basket,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.materials,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        l10n.itemCount(provider.foodItems.length),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_isSearching)
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AppTheme.textSecondary,
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                        });
                        provider.searchFoodItems('');
                      },
                    ),
                ],
              ),
              const SizedBox(height: 14),
              // Search bar
              GestureDetector(
                onTap: () {
                  if (!_isSearching) {
                    setState(() => _isSearching = true);
                  }
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _isSearching
                      ? Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: l10n.searchFoodItems,
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                onChanged: (value) {
                                  provider.searchFoodItems(value);
                                },
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  provider.searchFoodItems('');
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.clear,
                                    size: 18,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.searchFoodItems,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 14),
              // Category pills
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _foodItemCategories.map((category) {
                    final isSelected = provider.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => provider.setCategory(category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            category == 'All' ? l10n.all : category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, FoodItemProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _isSearching && provider.searchQuery.isNotEmpty
        ? provider.searchResults
        : provider.foodItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_basket,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching ? l10n.noResults : l10n.noFoodItems,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FoodItemCard(foodItem: items[index]),
        );
      },
    );
  }
}
