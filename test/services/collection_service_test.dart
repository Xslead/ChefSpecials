import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/collection_service.dart';
import 'package:chef_specials/models/recipe_collection.dart';

RecipeCollection _makeCollection({
  String userId = 'user1',
  String name = 'My Collection',
  String? description,
  List<String> recipeIds = const [],
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime(2024, 1, 15);
  return RecipeCollection(
    userId: userId,
    name: name,
    description: description,
    recipeIds: recipeIds,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CollectionService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = CollectionService(firestore: fakeFirestore);
  });

  group('CollectionService', () {
    group('createCollection', () {
      test('should create a collection and return its ID', () async {
        final collection = _makeCollection(name: 'Quick Meals');
        final id = await service.createCollection(collection);

        expect(id, isNotEmpty);

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['name'], 'Quick Meals');
        expect(doc.data()!['userId'], 'user1');
      });

      test('should store recipeIds in the collection', () async {
        final collection = _makeCollection(recipeIds: ['r1', 'r2']);
        final id = await service.createCollection(collection);

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        expect(List<String>.from(doc.data()!['recipeIds']), ['r1', 'r2']);
      });

      test('should store description', () async {
        final collection =
            _makeCollection(description: 'Weekend cooking ideas');
        final id = await service.createCollection(collection);

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        expect(doc.data()!['description'], 'Weekend cooking ideas');
      });
    });

    group('getUserCollections', () {
      test('should return all collections for a user ordered by updatedAt DESC',
          () async {
        await service.createCollection(_makeCollection(
          name: 'Old Collection',
          updatedAt: DateTime(2024, 1, 1),
        ));
        await service.createCollection(_makeCollection(
          name: 'New Collection',
          updatedAt: DateTime(2024, 6, 1),
        ));

        final collections =
            await service.getUserCollections('user1').first;

        expect(collections.length, 2);
        expect(collections[0].name, 'New Collection');
        expect(collections[1].name, 'Old Collection');
      });

      test('should return empty list for user with no collections', () async {
        final collections =
            await service.getUserCollections('nobody').first;
        expect(collections, isEmpty);
      });

      test('should not return collections from other users', () async {
        await service.createCollection(_makeCollection(userId: 'user2'));

        final collections =
            await service.getUserCollections('user1').first;
        expect(collections, isEmpty);
      });
    });

    group('deleteCollection', () {
      test('should delete a collection', () async {
        final id = await service.createCollection(_makeCollection());

        await service.deleteCollection(id);

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        expect(doc.exists, isFalse);
      });
    });

    group('addRecipe', () {
      test('should add a recipe ID to the collection', () async {
        final id = await service.createCollection(_makeCollection());

        await service.addRecipe(id, 'recipe1');

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        final recipeIds = List<String>.from(doc.data()!['recipeIds']);
        expect(recipeIds, contains('recipe1'));
      });

      test('should not duplicate recipe IDs with arrayUnion', () async {
        final id = await service
            .createCollection(_makeCollection(recipeIds: ['recipe1']));

        await service.addRecipe(id, 'recipe1');

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        final recipeIds = List<String>.from(doc.data()!['recipeIds']);
        expect(recipeIds.length, 1);
      });

      test('should add multiple recipes sequentially', () async {
        final id = await service.createCollection(_makeCollection());

        await service.addRecipe(id, 'recipe1');
        await service.addRecipe(id, 'recipe2');
        await service.addRecipe(id, 'recipe3');

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        final recipeIds = List<String>.from(doc.data()!['recipeIds']);
        expect(recipeIds.length, 3);
        expect(recipeIds, containsAll(['recipe1', 'recipe2', 'recipe3']));
      });

      test('should update updatedAt timestamp', () async {
        final id = await service.createCollection(_makeCollection(
          updatedAt: DateTime(2024, 1, 1),
        ));

        await service.addRecipe(id, 'recipe1');

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        expect(doc.data()!['updatedAt'], isNot('2024-01-01T00:00:00.000'));
      });
    });

    group('removeRecipe', () {
      test('should remove a recipe ID from the collection', () async {
        final id = await service
            .createCollection(_makeCollection(recipeIds: ['r1', 'r2', 'r3']));

        await service.removeRecipe(id, 'r2');

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        final recipeIds = List<String>.from(doc.data()!['recipeIds']);
        expect(recipeIds, ['r1', 'r3']);
      });

      test('should handle removing non-existent recipe gracefully', () async {
        final id = await service
            .createCollection(_makeCollection(recipeIds: ['r1']));

        await service.removeRecipe(id, 'nonexistent');

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        final recipeIds = List<String>.from(doc.data()!['recipeIds']);
        expect(recipeIds, ['r1']);
      });

      test('should update updatedAt timestamp', () async {
        final id = await service.createCollection(
          _makeCollection(
            recipeIds: ['r1'],
            updatedAt: DateTime(2024, 1, 1),
          ),
        );

        await service.removeRecipe(id, 'r1');

        final doc =
            await fakeFirestore.collection('collections').doc(id).get();
        expect(doc.data()!['updatedAt'], isNot('2024-01-01T00:00:00.000'));
      });
    });
  });
}
