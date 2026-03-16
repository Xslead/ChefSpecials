import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/services/shopping_list_service.dart';
import 'package:chef_specials/models/shopping_list.dart';

ShoppingList _makeShoppingList({
  String userId = 'user1',
  String name = 'Groceries',
  List<ShoppingItem>? items,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime(2024, 1, 15);
  return ShoppingList(
    userId: userId,
    name: name,
    items: items ?? [],
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

ShoppingItem _makeItem({
  String name = 'Milk',
  String amount = '1',
  String? unit = 'L',
  bool isChecked = false,
}) {
  return ShoppingItem(
    name: name,
    amount: amount,
    unit: unit,
    isChecked: isChecked,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ShoppingListService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = ShoppingListService(firestore: fakeFirestore);
  });

  group('ShoppingListService', () {
    group('createShoppingList', () {
      test('should create a shopping list and return its ID', () async {
        final list = _makeShoppingList(name: 'Weekly Groceries');
        final id = await service.createShoppingList(list);

        expect(id, isNotEmpty);

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['name'], 'Weekly Groceries');
        expect(doc.data()!['userId'], 'user1');
      });

      test('should store items in the shopping list', () async {
        final list = _makeShoppingList(items: [
          _makeItem(name: 'Eggs', amount: '12', unit: 'pcs'),
          _makeItem(name: 'Bread', amount: '1', unit: 'loaf'),
        ]);
        final id = await service.createShoppingList(list);

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        final items = doc.data()!['items'] as List;
        expect(items.length, 2);
      });
    });

    group('getUserShoppingLists', () {
      test('should return all lists for a user ordered by updatedAt DESC',
          () async {
        await service.createShoppingList(_makeShoppingList(
          name: 'Old List',
          updatedAt: DateTime(2024, 1, 1),
        ));
        await service.createShoppingList(_makeShoppingList(
          name: 'New List',
          updatedAt: DateTime(2024, 6, 1),
        ));

        final lists = await service.getUserShoppingLists('user1').first;

        expect(lists.length, 2);
        expect(lists[0].name, 'New List');
        expect(lists[1].name, 'Old List');
      });

      test('should return empty list for user with no lists', () async {
        final lists = await service.getUserShoppingLists('nobody').first;
        expect(lists, isEmpty);
      });

      test('should not return lists from other users', () async {
        await service
            .createShoppingList(_makeShoppingList(userId: 'user2'));

        final lists = await service.getUserShoppingLists('user1').first;
        expect(lists, isEmpty);
      });
    });

    group('updateShoppingList', () {
      test('should update shopping list fields', () async {
        final id = await service
            .createShoppingList(_makeShoppingList(name: 'Old Name'));

        await service.updateShoppingList(id, {'name': 'New Name'});

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        expect(doc.data()!['name'], 'New Name');
      });
    });

    group('deleteShoppingList', () {
      test('should delete a shopping list', () async {
        final id = await service.createShoppingList(_makeShoppingList());

        await service.deleteShoppingList(id);

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        expect(doc.exists, isFalse);
      });
    });

    group('toggleItemChecked', () {
      test('should toggle an item checked state to true', () async {
        final id = await service.createShoppingList(_makeShoppingList(
          items: [_makeItem(name: 'Milk', isChecked: false)],
        ));

        await service.toggleItemChecked(id, 0, true);

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        final items =
            List<Map<String, dynamic>>.from(doc.data()!['items']);
        expect(items[0]['isChecked'], true);
      });

      test('should toggle an item checked state to false', () async {
        final id = await service.createShoppingList(_makeShoppingList(
          items: [_makeItem(name: 'Milk', isChecked: true)],
        ));

        await service.toggleItemChecked(id, 0, false);

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        final items =
            List<Map<String, dynamic>>.from(doc.data()!['items']);
        expect(items[0]['isChecked'], false);
      });

      test('should not throw for out-of-bounds index', () async {
        final id = await service.createShoppingList(_makeShoppingList(
          items: [_makeItem()],
        ));

        // Index 5 is out of bounds for a list with 1 item
        await expectLater(
          service.toggleItemChecked(id, 5, true),
          completes,
        );
      });

      test('should handle non-existent list gracefully', () async {
        await expectLater(
          service.toggleItemChecked('nonexistent', 0, true),
          completes,
        );
      });
    });

    group('removeItem', () {
      test('should remove an item at the specified index', () async {
        final id = await service.createShoppingList(_makeShoppingList(
          items: [
            _makeItem(name: 'Milk'),
            _makeItem(name: 'Bread'),
            _makeItem(name: 'Eggs'),
          ],
        ));

        await service.removeItem(id, 1); // Remove 'Bread'

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        final items =
            List<Map<String, dynamic>>.from(doc.data()!['items']);
        expect(items.length, 2);
        expect(items[0]['name'], 'Milk');
        expect(items[1]['name'], 'Eggs');
      });

      test('should not throw for out-of-bounds index', () async {
        final id = await service.createShoppingList(_makeShoppingList(
          items: [_makeItem()],
        ));

        await expectLater(
          service.removeItem(id, 10),
          completes,
        );
      });

      test('should handle non-existent list gracefully', () async {
        await expectLater(
          service.removeItem('nonexistent', 0),
          completes,
        );
      });
    });

    group('clearCheckedItems', () {
      test('should remove all checked items', () async {
        final id = await service.createShoppingList(_makeShoppingList(
          items: [
            _makeItem(name: 'Milk', isChecked: true),
            _makeItem(name: 'Bread', isChecked: false),
            _makeItem(name: 'Eggs', isChecked: true),
          ],
        ));

        await service.clearCheckedItems(id);

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        final items =
            List<Map<String, dynamic>>.from(doc.data()!['items']);
        expect(items.length, 1);
        expect(items[0]['name'], 'Bread');
      });

      test('should do nothing when no items are checked', () async {
        final id = await service.createShoppingList(_makeShoppingList(
          items: [
            _makeItem(name: 'Milk', isChecked: false),
            _makeItem(name: 'Bread', isChecked: false),
          ],
        ));

        await service.clearCheckedItems(id);

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        final items =
            List<Map<String, dynamic>>.from(doc.data()!['items']);
        expect(items.length, 2);
      });

      test('should handle non-existent list gracefully', () async {
        await expectLater(
          service.clearCheckedItems('nonexistent'),
          completes,
        );
      });
    });

    group('addItemsToList', () {
      test('should add new items to an existing list', () async {
        final id = await service.createShoppingList(_makeShoppingList(
          items: [_makeItem(name: 'Milk')],
        ));

        await service.addItemsToList(id, [
          _makeItem(name: 'Butter'),
          _makeItem(name: 'Cheese'),
        ]);

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        final items =
            List<Map<String, dynamic>>.from(doc.data()!['items']);
        expect(items.length, 3);
        expect(items[1]['name'], 'Butter');
        expect(items[2]['name'], 'Cheese');
      });

      test('should add items to an empty list', () async {
        final id = await service.createShoppingList(_makeShoppingList());

        await service.addItemsToList(id, [
          _makeItem(name: 'Salt'),
        ]);

        final doc =
            await fakeFirestore.collection('shopping_lists').doc(id).get();
        final items =
            List<Map<String, dynamic>>.from(doc.data()!['items']);
        expect(items.length, 1);
        expect(items[0]['name'], 'Salt');
      });

      test('should handle non-existent list gracefully', () async {
        await expectLater(
          service.addItemsToList('nonexistent', [_makeItem()]),
          completes,
        );
      });
    });
  });
}
