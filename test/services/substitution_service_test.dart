import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/ingredient_substitution.dart';
import 'package:chef_specials/services/substitution_service.dart';
import 'package:chef_specials/services/substitution_seed_data.dart';

IngredientSubstitution _make({
  String original = 'butter',
  String name = 'Coconut oil',
  String ratio = '1:1',
  String? notes,
  List<String> tags = const [],
  bool verified = false,
  String? submittedBy,
}) {
  return IngredientSubstitution(
    originalIngredient: original,
    substituteName: name,
    ratio: ratio,
    notes: notes,
    dietaryTags: tags,
    isVerified: verified,
    submittedBy: submittedBy,
  );
}

Future<void> _add(FakeFirebaseFirestore db, IngredientSubstitution s) async {
  await db.collection('substitutions').add(s.toMap());
}

void main() {
  late FakeFirebaseFirestore firestore;
  late SubstitutionService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = SubstitutionService(firestore: firestore);
  });

  group('SubstitutionService.getSubstitutions', () {
    test('returns only entries matching the normalized ingredient', () async {
      await _add(firestore, _make(original: 'Butter', name: 'Olive oil'));
      await _add(firestore, _make(original: 'butter', name: 'Greek yogurt'));
      await _add(firestore, _make(original: 'milk', name: 'Oat milk'));

      final results = await service.getSubstitutions('Butter');
      final names = results.map((r) => r.substituteName).toSet();
      expect(results.length, 2);
      expect(names, {'Olive oil', 'Greek yogurt'});
    });

    test('normalizes the query (trim + lowercase)', () async {
      await _add(firestore, _make(original: 'butter', name: 'Coconut oil'));
      final results = await service.getSubstitutions('  BUTTER ');
      expect(results, isNotEmpty);
    });

    test('sorts verified entries before unverified', () async {
      await _add(firestore,
          _make(original: 'butter', name: 'Community entry', verified: false));
      await _add(firestore,
          _make(original: 'butter', name: 'Verified entry', verified: true));

      final results = await service.getSubstitutions('butter');
      expect(results.first.isVerified, true);
      expect(results.first.substituteName, 'Verified entry');
    });

    test('returns empty when no matches', () async {
      await _add(firestore, _make(original: 'butter', name: 'Coconut oil'));
      final results = await service.getSubstitutions('mystery');
      expect(results, isEmpty);
    });
  });

  group('SubstitutionService.getSubstitutionsByTag', () {
    test('filters by dietary tag', () async {
      await _add(firestore,
          _make(original: 'egg', name: 'Flax egg', tags: ['Vegan']));
      await _add(firestore,
          _make(original: 'egg', name: 'Chia egg', tags: ['Vegan']));
      await _add(firestore,
          _make(original: 'egg', name: 'Non-vegan option', tags: []));

      final results = await service.getSubstitutionsByTag('egg', 'Vegan');
      expect(results.length, 2);
      expect(results.every((r) => r.dietaryTags.contains('Vegan')), isTrue);
    });

    test('returns empty when tag has no matches', () async {
      await _add(firestore,
          _make(original: 'egg', name: 'Flax egg', tags: ['Vegan']));
      final results = await service.getSubstitutionsByTag('egg', 'Keto');
      expect(results, isEmpty);
    });
  });

  group('SubstitutionService.submitSubstitution', () {
    test('persists with isVerified forced to false', () async {
      final id = await service.submitSubstitution(_make(
        original: 'flour',
        name: 'My secret flour',
        ratio: '1:1',
        verified: true, // caller lies; service must overwrite.
        submittedBy: 'u1',
      ));

      final doc = await firestore.collection('substitutions').doc(id).get();
      final data = doc.data() as Map<String, dynamic>;
      expect(data['isVerified'], false);
      expect(data['originalIngredient'], 'flour');
      expect(data['submittedBy'], 'u1');
    });

    test('normalizes originalIngredient when persisting', () async {
      final id = await service.submitSubstitution(_make(
        original: '  MILK ',
        name: 'Soy milk',
      ));
      final doc = await firestore.collection('substitutions').doc(id).get();
      final data = doc.data() as Map<String, dynamic>;
      expect(data['originalIngredient'], 'milk');
    });
  });

  group('SubstitutionService.verifySubstitution', () {
    test('flips isVerified to true', () async {
      await _add(firestore, _make(verified: false));
      final all = await service.getAllSubstitutions();
      final id = all.first.id!;
      await service.verifySubstitution(id);

      final doc = await firestore.collection('substitutions').doc(id).get();
      expect((doc.data() as Map<String, dynamic>)['isVerified'], true);
    });
  });

  group('SubstitutionService.deleteSubstitution', () {
    test('removes the document', () async {
      await _add(firestore, _make());
      final all = await service.getAllSubstitutions();
      final id = all.first.id!;
      await service.deleteSubstitution(id);

      final snap = await firestore.collection('substitutions').get();
      expect(snap.docs.any((d) => d.id == id), isFalse);
    });
  });

  group('SubstitutionService.getAllSubstitutions', () {
    test('returns every entry', () async {
      await _add(firestore, _make(original: 'butter', name: 'A'));
      await _add(firestore, _make(original: 'milk', name: 'B'));
      await _add(firestore, _make(original: 'egg', name: 'C'));
      final results = await service.getAllSubstitutions();
      expect(results.length, 3);
    });
  });

  group('seedSubstitutions', () {
    test('seeds the default 50+ verified entries on empty database', () async {
      final added = await seedSubstitutions(firestore);
      expect(added, greaterThanOrEqualTo(50));
      final all = await service.getAllSubstitutions();
      expect(all.length, greaterThanOrEqualTo(50));
      expect(all.every((s) => s.isVerified), isTrue);
    });

    test('does not re-add existing entries on a second run', () async {
      await seedSubstitutions(firestore);
      final added2 = await seedSubstitutions(firestore);
      expect(added2, 0);
    });
  });
}
