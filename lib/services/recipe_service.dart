import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _recipesRef =>
      _firestore.collection('recipes');

  Future<String> createRecipe(Recipe recipe) async {
    final doc = await _recipesRef.add(recipe.toMap());
    return doc.id;
  }

  Future<void> updateRecipe(String id, Map<String, dynamic> data) async {
    await _recipesRef.doc(id).update(data);
  }

  Future<void> deleteRecipe(String id) async {
    await _recipesRef.doc(id).delete();
  }

  Future<Recipe?> getRecipe(String id) async {
    final doc = await _recipesRef.doc(id).get();
    if (!doc.exists) return null;
    return Recipe.fromMap(doc.data()!, doc.id);
  }

  Stream<List<Recipe>> getRecipesStream() {
    return _recipesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Recipe>> getRecipesByCategory(String category) {
    return _recipesRef
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Recipe>> getUserRecipes(String userId) {
    return _recipesRef
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateAuthorName(String userId, String newName) async {
    final snapshot =
        await _recipesRef.where('authorId', isEqualTo: userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'authorName': newName});
    }
    await batch.commit();
  }
}
