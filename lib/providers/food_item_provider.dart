import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/food_item_service.dart';

class FoodItemProvider extends ChangeNotifier {
  final FoodItemService _foodItemService = FoodItemService();

  List<FoodItem> _foodItems = [];
  List<FoodItem> _searchResults = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String _searchQuery = '';
  StreamSubscription? _subscription;

  bool _initialized = false;

  List<FoodItem> get foodItems => _foodItems;
  List<FoodItem> get searchResults => _searchResults;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void ensureInitialized() {
    if (!_initialized) {
      _initialized = true;
      listenToFoodItems();
    }
  }

  void listenToFoodItems() {
    _isLoading = true;
    _subscription?.cancel();

    final stream = _selectedCategory == 'All'
        ? _foodItemService.getFoodItems()
        : _foodItemService.getFoodItemsByCategory(_selectedCategory);

    _subscription = stream.listen(
      (items) {
        _foodItems = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setCategory(String category) {
    _selectedCategory = category;
    listenToFoodItems();
  }

  Future<void> searchFoodItems(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    _searchResults = await _foodItemService.searchFoodItems(query);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFoodItem(FoodItem item) async {
    await _foodItemService.addFoodItem(item);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
