import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_collection.dart';

class CollectionService {
  final FirebaseFirestore _firestore;

  CollectionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final String _collection = 'collections';

  Future<String> createCollection(RecipeCollection collection) async {
    final doc =
        await _firestore.collection(_collection).add(collection.toMap());
    return doc.id;
  }

  Stream<List<RecipeCollection>> getUserCollections(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => RecipeCollection.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    });
  }

  Future<void> deleteCollection(String collectionId) async {
    await _firestore.collection(_collection).doc(collectionId).delete();
  }

  Future<void> addRecipe(String collectionId, String recipeId) async {
    await _firestore.collection(_collection).doc(collectionId).update({
      'recipeIds': FieldValue.arrayUnion([recipeId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeRecipe(String collectionId, String recipeId) async {
    await _firestore.collection(_collection).doc(collectionId).update({
      'recipeIds': FieldValue.arrayRemove([recipeId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
