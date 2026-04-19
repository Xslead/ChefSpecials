import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_substitution.dart';

class SubstitutionService {
  final FirebaseFirestore _db;

  SubstitutionService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _ref => _db.collection('substitutions');

  Future<List<IngredientSubstitution>> getSubstitutions(
      String ingredientName) async {
    final normalized = IngredientSubstitution.normalize(ingredientName);
    final snap = await _ref
        .where('originalIngredient', isEqualTo: normalized)
        .get();
    final items = snap.docs
        .map((d) => IngredientSubstitution.fromMap(
            d.data() as Map<String, dynamic>, d.id))
        .toList();
    // Sort verified first, then by name.
    items.sort((a, b) {
      if (a.isVerified != b.isVerified) return b.isVerified ? 1 : -1;
      return a.substituteName
          .toLowerCase()
          .compareTo(b.substituteName.toLowerCase());
    });
    return items;
  }

  Future<List<IngredientSubstitution>> getSubstitutionsByTag(
    String ingredientName,
    String dietaryTag,
  ) async {
    final normalized = IngredientSubstitution.normalize(ingredientName);
    final snap = await _ref
        .where('originalIngredient', isEqualTo: normalized)
        .where('dietaryTags', arrayContains: dietaryTag)
        .get();
    return snap.docs
        .map((d) => IngredientSubstitution.fromMap(
            d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<String> submitSubstitution(IngredientSubstitution sub) async {
    final data = {
      ...sub.toMap(),
      'isVerified': false,
    };
    final ref = await _ref.add(data);
    return ref.id;
  }

  Future<List<IngredientSubstitution>> getAllSubstitutions() async {
    final snap = await _ref.get();
    return snap.docs
        .map((d) => IngredientSubstitution.fromMap(
            d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> verifySubstitution(String id) async {
    await _ref.doc(id).update({'isVerified': true});
  }

  Future<void> deleteSubstitution(String id) async {
    await _ref.doc(id).delete();
  }
}
