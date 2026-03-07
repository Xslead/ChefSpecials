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
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<FoodItemProvider>().ensureInitialized();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _isSearching) {
        setState(() {
          _isSearching = false;
          _searchController.clear();
        });
        context.read<FoodItemProvider>().searchFoodItems('');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
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
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          heroTag: 'materials_fab',
          onPressed: () => context.push('/add-food-item'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
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
        boxShadow: [AppTheme.warmShadowLight()],
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
                      Icons.inventory_2_outlined,
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
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
                  key: _searchBarKey,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.warmBeige,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _isSearching
                      ? Row(
                          children: [
                            const SizedBox(width: 14),
                            const Icon(
                              Icons.search_outlined,
                              color: AppTheme.textTertiary,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: l10n.searchFoodItems,
                                  hintStyle: const TextStyle(
                                    color: AppTheme.textTertiary,
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
                                  setState(() {});
                                },
                                onTapOutside: (event) {
                                  final box = _searchBarKey.currentContext
                                      ?.findRenderObject() as RenderBox?;
                                  if (box != null) {
                                    final localPos =
                                        box.globalToLocal(event.position);
                                    if (box.paintBounds.contains(localPos)) {
                                      return;
                                    }
                                  }
                                  // Delay so list item taps are processed first
                                  Future.delayed(
                                    const Duration(milliseconds: 200),
                                    () { if (mounted) _closeSearch(); },
                                  );
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_searchController.text.isEmpty) {
                                  _closeSearch();
                                } else {
                                  _searchController.clear();
                                  provider.searchFoodItems('');
                                  setState(() {});
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const SizedBox(width: 14),
                            const Icon(
                              Icons.search_outlined,
                              color: AppTheme.textTertiary,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.searchFoodItems,
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
                                : AppTheme.neutralLight,
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
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.warmBeige,
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching ? l10n.noResults : l10n.noFoodItems,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textTertiary,
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
