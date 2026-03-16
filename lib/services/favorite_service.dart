import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chef_specials/models/favorite.dart';

class FavoriteService {
  final FirebaseFirestore _firestore;

  FavoriteService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final String _collection = 'favorites';

  Future<void> toggleFavorite(String userId, String recipeId) async {
    final query = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: recipeId)
        .get();

    if (query.docs.isNotEmpty) {
      // Favorite exists, delete it
      await _firestore.collection(_collection).doc(query.docs.first.id).delete();
    } else {
      // Favorite doesn't exist, add it
      await _firestore.collection(_collection).add(
        Favorite(
          userId: userId,
          recipeId: recipeId,
          createdAt: DateTime.now(),
        ).toMap(),
      );
    }
  }

  Future<bool> isFavorite(String userId, String recipeId) async {
    final query = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: recipeId)
        .get();

    return query.docs.isNotEmpty;
  }

  Stream<List<String>> getUserFavoriteIds(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc['recipeId'] as String)
            .toList());
  }

  Stream<List<Favorite>> getUserFavorites(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Favorite.fromMap(doc.data(), doc.id))
            .toList());
  }
}
