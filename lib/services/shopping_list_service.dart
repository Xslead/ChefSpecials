import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_list.dart';

class ShoppingListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'shopping_lists';

  Future<String> createShoppingList(ShoppingList list) async {
    final doc = await _firestore.collection(_collection).add(list.toMap());
    return doc.id;
  }

  Stream<List<ShoppingList>> getUserShoppingLists(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShoppingList.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateShoppingList(
      String listId, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(listId).update(data);
  }

  Future<void> deleteShoppingList(String listId) async {
    await _firestore.collection(_collection).doc(listId).delete();
  }

  Future<void> toggleItemChecked(
      String listId, int itemIndex, bool isChecked) async {
    final doc = await _firestore.collection(_collection).doc(listId).get();
    if (!doc.exists) return;
    final items = List<Map<String, dynamic>>.from(doc.data()!['items'] ?? []);
    if (itemIndex < items.length) {
      items[itemIndex]['isChecked'] = isChecked;
      await _firestore.collection(_collection).doc(listId).update({
        'items': items,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> removeItem(String listId, int itemIndex) async {
    final doc = await _firestore.collection(_collection).doc(listId).get();
    if (!doc.exists) return;
    final items = List<Map<String, dynamic>>.from(doc.data()!['items'] ?? []);
    if (itemIndex < items.length) {
      items.removeAt(itemIndex);
      await _firestore.collection(_collection).doc(listId).update({
        'items': items,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> clearCheckedItems(String listId) async {
    final doc = await _firestore.collection(_collection).doc(listId).get();
    if (!doc.exists) return;
    final items = List<Map<String, dynamic>>.from(doc.data()!['items'] ?? []);
    items.removeWhere((item) => item['isChecked'] == true);
    await _firestore.collection(_collection).doc(listId).update({
      'items': items,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addItemsToList(
      String listId, List<ShoppingItem> newItems) async {
    final doc = await _firestore.collection(_collection).doc(listId).get();
    if (!doc.exists) return;
    final items = List<Map<String, dynamic>>.from(doc.data()!['items'] ?? []);
    items.addAll(newItems.map((e) => e.toMap()));
    await _firestore.collection(_collection).doc(listId).update({
      'items': items,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
