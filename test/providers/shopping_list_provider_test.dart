import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/shopping_list_provider.dart';
import 'package:chef_specials/services/shopping_list_service.dart';
import 'package:chef_specials/models/shopping_list.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ShoppingListService service;
  late ShoppingListProvider provider;

  const userId = 'user1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = ShoppingListService(firestore: fakeFirestore);
    provider = ShoppingListProvider(shoppingListService: service);
  });

  group('ShoppingListProvider', () {
    test('initial state has empty lists and is not loading', () {
      expect(provider.lists, isEmpty);
      expect(provider.isLoading, false);
    });

    test('init starts listening to user shopping lists', () async {
      // Pre-populate a shopping list
      final now = DateTime.now();
      await fakeFirestore.collection('shopping_lists').add({
        'userId': userId,
        'name': 'Groceries',
        'items': [],
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      provider.init(userId);
      await Future.delayed(Duration.zero);

      expect(provider.lists, hasLength(1));
      expect(provider.lists.first.name, 'Groceries');
      expect(provider.isLoading, false);
    });

    test('init does not re-subscribe for same user', () async {
      provider.init(userId);
      provider.init(userId); // should be no-op
      await Future.delayed(Duration.zero);

      expect(provider.lists, isEmpty);
    });

    test('createList adds a new shopping list', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      final listId = await provider.createList('Weekend Shop');
      await Future.delayed(Duration.zero);

      expect(listId, isNotEmpty);
      expect(provider.lists, hasLength(1));
      expect(provider.lists.first.name, 'Weekend Shop');
    });

    test('createList returns empty string when userId is null', () async {
      // Don't call init
      final result = await provider.createList('Test');
      expect(result, '');
    });

    test('deleteList removes a shopping list', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      final listId = await provider.createList('ToDelete');
      await Future.delayed(Duration.zero);
      expect(provider.lists, hasLength(1));

      await provider.deleteList(listId);
      await Future.delayed(Duration.zero);

      expect(provider.lists, isEmpty);
    });

    test('toggleItem marks item as checked', () async {
      // Create a list with items
      final now = DateTime.now();
      final doc = await fakeFirestore.collection('shopping_lists').add({
        'userId': userId,
        'name': 'Test List',
        'items': [
          {'name': 'Milk', 'amount': '1', 'unit': 'L', 'isChecked': false},
          {'name': 'Eggs', 'amount': '12', 'unit': 'pcs', 'isChecked': false},
        ],
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.toggleItem(doc.id, 0, true);
      await Future.delayed(Duration.zero);

      // Read from Firestore to verify
      final updated =
          await fakeFirestore.collection('shopping_lists').doc(doc.id).get();
      final items =
          List<Map<String, dynamic>>.from(updated.data()!['items']);
      expect(items[0]['isChecked'], true);
      expect(items[1]['isChecked'], false);
    });

    test('removeItem removes item at index', () async {
      final now = DateTime.now();
      final doc = await fakeFirestore.collection('shopping_lists').add({
        'userId': userId,
        'name': 'Test List',
        'items': [
          {'name': 'Milk', 'amount': '1', 'unit': 'L', 'isChecked': false},
          {'name': 'Eggs', 'amount': '12', 'unit': 'pcs', 'isChecked': false},
        ],
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      await provider.removeItem(doc.id, 0);

      final updated =
          await fakeFirestore.collection('shopping_lists').doc(doc.id).get();
      final items =
          List<Map<String, dynamic>>.from(updated.data()!['items']);
      expect(items, hasLength(1));
      expect(items[0]['name'], 'Eggs');
    });

    test('clearChecked removes checked items', () async {
      final now = DateTime.now();
      final doc = await fakeFirestore.collection('shopping_lists').add({
        'userId': userId,
        'name': 'Test List',
        'items': [
          {'name': 'Milk', 'amount': '1', 'unit': 'L', 'isChecked': true},
          {'name': 'Eggs', 'amount': '12', 'unit': 'pcs', 'isChecked': false},
          {'name': 'Bread', 'amount': '1', 'unit': 'pcs', 'isChecked': true},
        ],
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      await provider.clearChecked(doc.id);

      final updated =
          await fakeFirestore.collection('shopping_lists').doc(doc.id).get();
      final items =
          List<Map<String, dynamic>>.from(updated.data()!['items']);
      expect(items, hasLength(1));
      expect(items[0]['name'], 'Eggs');
    });

    test('addIngredientsToList adds items to existing list', () async {
      final now = DateTime.now();
      final doc = await fakeFirestore.collection('shopping_lists').add({
        'userId': userId,
        'name': 'Test List',
        'items': [
          {'name': 'Milk', 'amount': '1', 'unit': 'L', 'isChecked': false},
        ],
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      await provider.addIngredientsToList(doc.id, [
        ShoppingItem(name: 'Sugar', amount: '500', unit: 'g'),
        ShoppingItem(name: 'Flour', amount: '1', unit: 'kg'),
      ]);

      final updated =
          await fakeFirestore.collection('shopping_lists').doc(doc.id).get();
      final items =
          List<Map<String, dynamic>>.from(updated.data()!['items']);
      expect(items, hasLength(3));
      expect(items[1]['name'], 'Sugar');
      expect(items[2]['name'], 'Flour');
    });

    test('notifies listeners when list data updates', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.createList('New List');
      await Future.delayed(Duration.zero);

      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('multiple lists tracked correctly', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.createList('List 1');
      await provider.createList('List 2');
      await provider.createList('List 3');
      await Future.delayed(Duration.zero);

      expect(provider.lists, hasLength(3));
    });

    test('init sets isLoading true then false', () async {
      provider.init(userId);
      // isLoading was set to true in init before stream fires
      // After stream fires, isLoading goes to false
      await Future.delayed(Duration.zero);
      expect(provider.isLoading, false);
    });
  });
}
