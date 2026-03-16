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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
