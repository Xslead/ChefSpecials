import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeService {
  final FirebaseFirestore _firestore;

  RecipeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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

  Stream<List<Recipe>> getRecipesStream({int? limit}) {
    Query<Map<String, dynamic>> query =
        _recipesRef.orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);
    return query.snapshots().map((snapshot) {
      final recipes = <Recipe>[];
      for (final doc in snapshot.docs) {
        try {
          recipes.add(Recipe.fromMap(doc.data(), doc.id));
        } catch (e) {
          // Skip malformed documents so one bad doc doesn't break the stream
        }
      }
      return recipes;
    });
  }

  Future<List<Recipe>> loadMoreRecipes({
    required DateTime beforeCreatedAt,
    int limit = 10,
  }) async {
    final snapshot = await _recipesRef
        .orderBy('createdAt', descending: true)
        .where('createdAt', isLessThan: Timestamp.fromDate(beforeCreatedAt))
        .limit(limit)
        .get();
    final recipes = <Recipe>[];
    for (final doc in snapshot.docs) {
      try {
        recipes.add(Recipe.fromMap(doc.data(), doc.id));
      } catch (_) {}
    }
    return recipes;
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

  /// Fetch public recipes from a list of authors.
  /// Batches whereIn queries in groups of 10 (Firestore limit), then
  /// filters and sorts in memory to avoid composite index requirements.
  Future<List<Recipe>> getFeedRecipes(
    List<String> authorIds, {
    int limit = 20,
    DateTime? before,
  }) async {
    if (authorIds.isEmpty) return [];

    final batches = <List<String>>[];
    for (var i = 0; i < authorIds.length; i += 10) {
      batches.add(authorIds.sublist(
          i, i + 10 > authorIds.length ? authorIds.length : i + 10));
    }

    // Fetch without orderBy/isPrivate filter to avoid composite index
    final futures = batches.map((batch) =>
        _recipesRef.where('authorId', whereIn: batch).get());

    final snapshots = await Future.wait(futures);
    final all = <Recipe>[];
    for (final snap in snapshots) {
      for (final doc in snap.docs) {
        try {
          all.add(Recipe.fromMap(doc.data(), doc.id));
        } catch (_) {}
      }
    }

    // Filter and sort in memory
    var filtered = all.where((r) => !r.isPrivate).toList();
    if (before != null) {
      filtered = filtered.where((r) => r.createdAt.isBefore(before)).toList();
    }
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.take(limit).toList();
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
