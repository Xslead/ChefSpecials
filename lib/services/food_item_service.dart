import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

class FoodItemService {
  final FirebaseFirestore _firestore;

  FoodItemService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _foodItemsRef =>
      _firestore.collection('food_items');

  Stream<List<FoodItem>> getFoodItems() {
    return _foodItemsRef
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<FoodItem>> getFoodItemsByCategory(String category) {
    return _foodItemsRef
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    final snapshot = await _foodItemsRef.orderBy('name').get();
    final allItems = snapshot.docs
        .map((doc) => FoodItem.fromMap(doc.data(), doc.id))
        .toList();
    final lower = query.toLowerCase();
    return allItems.where((item) {
      return item.name.toLowerCase().contains(lower);
    }).toList();
  }

  Future<void> addFoodItem(FoodItem item) async {
    await _foodItemsRef.add(item.toMap());
  }

  Future<void> updateFoodItem(FoodItem item) async {
    await _foodItemsRef.doc(item.id).update(item.toMap());
  }

  Future<void> deleteFoodItem(String id) async {
    await _foodItemsRef.doc(id).delete();
  }

  Future<FoodItem?> getFoodItemById(String id) async {
    final doc = await _foodItemsRef.doc(id).get();
    if (!doc.exists) return null;
    return FoodItem.fromMap(doc.data()!, doc.id);
  }
}
