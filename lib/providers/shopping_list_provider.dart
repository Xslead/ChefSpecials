import 'dart:async';
import 'package:flutter/material.dart';
import '../models/shopping_list.dart';
import '../services/shopping_list_service.dart';

class ShoppingListProvider extends ChangeNotifier {
  final ShoppingListService _service;

  ShoppingListProvider({ShoppingListService? shoppingListService})
      : _service = shoppingListService ?? ShoppingListService();

  List<ShoppingList> _lists = [];
  StreamSubscription? _subscription;
  String? _userId;
  bool _isLoading = false;

  List<ShoppingList> get lists => _lists;
  bool get isLoading => _isLoading;

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _isLoading = true;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _service.getUserShoppingLists(userId).listen(
      (data) {
        _lists = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<String> createList(String name) async {
    if (_userId == null) return '';
    final now = DateTime.now();
    final list = ShoppingList(
      userId: _userId!,
      name: name,
      items: [],
      createdAt: now,
      updatedAt: now,
    );
    return _service.createShoppingList(list);
  }

  /// Create or update the meal-planner shopping list for a given week.
  /// Returns the list ID (existing or newly created).
  Future<String> upsertMealPlanList(
      String name, List<ShoppingItem> items, String weekStartIso) async {
    if (_userId == null) return '';

    final existing =
        await _service.getMealPlanShoppingList(_userId!, weekStartIso);

    if (existing != null) {
      // Update existing list: replace items and name
      await _service.updateShoppingList(existing.id!, {
        'name': name,
        'items': items.map((e) => e.toMap()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return existing.id!;
    }

    // Create new
    final now = DateTime.now();
    final list = ShoppingList(
      userId: _userId!,
      name: name,
      items: items,
      createdAt: now,
      updatedAt: now,
      mealPlanWeekStart: weekStartIso,
    );
    return _service.createShoppingList(list);
  }

  Future<void> deleteList(String listId) async {
    await _service.deleteShoppingList(listId);
  }

  Future<void> toggleItem(String listId, int itemIndex, bool isChecked) async {
    await _service.toggleItemChecked(listId, itemIndex, isChecked);
  }

  Future<void> removeItem(String listId, int itemIndex) async {
    await _service.removeItem(listId, itemIndex);
  }

  Future<void> clearChecked(String listId) async {
    await _service.clearCheckedItems(listId);
  }

  Future<void> addIngredientsToList(
      String listId, List<ShoppingItem> items) async {
    await _service.addItemsToList(listId, items);
  }

  /// Auto-sync: if a meal-plan shopping list exists for this week, update its items.
  /// Does nothing if no list exists yet (user creates it via the shopping cart button).
  Future<void> syncMealPlanList(
      String weekStartIso, List<ShoppingItem> items) async {
    if (_userId == null) return;
    final existing =
        await _service.getMealPlanShoppingList(_userId!, weekStartIso);
    if (existing == null) return; // No list yet — skip
    await _service.updateShoppingList(existing.id!, {
      'items': items.map((e) => e.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
