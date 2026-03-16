import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/shopping_list.dart';

void main() {
  group('ShoppingItem', () {
    group('fromMap', () {
      test('creates ShoppingItem with all fields', () {
        final map = {
          'name': 'Milk',
          'amount': '1',
          'unit': 'liter',
          'isChecked': true,
        };

        final item = ShoppingItem.fromMap(map);

        expect(item.name, 'Milk');
        expect(item.amount, '1');
        expect(item.unit, 'liter');
        expect(item.isChecked, isTrue);
      });

      test('creates ShoppingItem with minimal fields', () {
        final map = {
          'name': 'Bread',
          'amount': '1',
        };

        final item = ShoppingItem.fromMap(map);

        expect(item.name, 'Bread');
        expect(item.amount, '1');
        expect(item.unit, isNull);
        expect(item.isChecked, isFalse);
      });

      test('defaults isChecked to false when missing', () {
        final map = {
          'name': 'Sugar',
          'amount': '500',
          'unit': 'g',
        };

        final item = ShoppingItem.fromMap(map);
        expect(item.isChecked, isFalse);
      });

      test('defaults isChecked to false when null', () {
        final map = {
          'name': 'Salt',
          'amount': '1',
          'isChecked': null,
        };

        final item = ShoppingItem.fromMap(map);
        expect(item.isChecked, isFalse);
      });

      test('handles null unit', () {
        final map = {
          'name': 'Eggs',
          'amount': '12',
          'unit': null,
        };

        final item = ShoppingItem.fromMap(map);
        expect(item.unit, isNull);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final item = ShoppingItem(
          name: 'Butter',
          amount: '250',
          unit: 'g',
          isChecked: true,
        );

        final map = item.toMap();

        expect(map['name'], 'Butter');
        expect(map['amount'], '250');
        expect(map['unit'], 'g');
        expect(map['isChecked'], isTrue);
      });

      test('serializes with null unit', () {
        final item = ShoppingItem(
          name: 'Apples',
          amount: '6',
        );

        final map = item.toMap();

        expect(map['unit'], isNull);
        expect(map['isChecked'], isFalse);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all populated fields', () {
        final originalMap = {
          'name': 'Olive Oil',
          'amount': '500',
          'unit': 'mL',
          'isChecked': true,
        };

        final item = ShoppingItem.fromMap(originalMap);
        final resultMap = item.toMap();

        expect(resultMap, originalMap);
      });

      test('round-trip preserves minimal fields', () {
        final originalMap = {
          'name': 'Garlic',
          'amount': '3',
          'unit': null,
          'isChecked': false,
        };

        final item = ShoppingItem.fromMap(originalMap);
        final resultMap = item.toMap();

        expect(resultMap, originalMap);
      });
    });

    group('constructor', () {
      test('defaults isChecked to false', () {
        final item = ShoppingItem(
          name: 'Test',
          amount: '1',
        );

        expect(item.isChecked, isFalse);
      });
    });

    group('edge cases', () {
      test('handles empty name', () {
        final item = ShoppingItem(name: '', amount: '1');
        expect(item.name, '');
      });

      test('handles empty amount', () {
        final item = ShoppingItem(name: 'Test', amount: '');
        expect(item.amount, '');
      });

      test('handles empty unit string', () {
        final item = ShoppingItem(name: 'Test', amount: '1', unit: '');
        expect(item.unit, '');
      });
    });
  });

  group('ShoppingList', () {
    group('fromMap', () {
      test('creates ShoppingList with all fields', () {
        final map = {
          'userId': 'user1',
          'name': 'Weekly Groceries',
          'items': [
            {
              'name': 'Milk',
              'amount': '2',
              'unit': 'liter',
              'isChecked': false,
            },
            {
              'name': 'Bread',
              'amount': '1',
              'unit': null,
              'isChecked': true,
            },
          ],
          'createdAt': '2024-06-15T10:00:00.000Z',
          'updatedAt': '2024-06-16T14:30:00.000Z',
        };

        final list = ShoppingList.fromMap(map, 'doc1');

        expect(list.id, 'doc1');
        expect(list.userId, 'user1');
        expect(list.name, 'Weekly Groceries');
        expect(list.items.length, 2);
        expect(list.items[0].name, 'Milk');
        expect(list.items[0].amount, '2');
        expect(list.items[0].unit, 'liter');
        expect(list.items[0].isChecked, isFalse);
        expect(list.items[1].name, 'Bread');
        expect(list.items[1].isChecked, isTrue);
        expect(list.createdAt,
            DateTime.parse('2024-06-15T10:00:00.000Z'));
        expect(list.updatedAt,
            DateTime.parse('2024-06-16T14:30:00.000Z'));
      });

      test('defaults items to empty list when null', () {
        final map = {
          'userId': 'user1',
          'name': 'Empty List',
          'items': null,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final list = ShoppingList.fromMap(map, 'doc1');
        expect(list.items, isEmpty);
      });

      test('defaults items to empty list when missing', () {
        final map = {
          'userId': 'user1',
          'name': 'Empty List',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final list = ShoppingList.fromMap(map, 'doc1');
        expect(list.items, isEmpty);
      });

      test('sets id from docId parameter', () {
        final map = {
          'userId': 'user1',
          'name': 'Test',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final list = ShoppingList.fromMap(map, 'myDoc123');
        expect(list.id, 'myDoc123');
      });

      test('parses dates correctly', () {
        final map = {
          'userId': 'user1',
          'name': 'Test',
          'createdAt': '2024-12-31T23:59:59.999Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
        };

        final list = ShoppingList.fromMap(map, 'doc1');

        expect(list.createdAt.year, 2024);
        expect(list.createdAt.month, 12);
        expect(list.updatedAt.year, 2025);
        expect(list.updatedAt.month, 1);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final createdAt = DateTime(2024, 6, 15, 10, 0);
        final updatedAt = DateTime(2024, 6, 16, 14, 30);

        final list = ShoppingList(
          id: 'doc1',
          userId: 'user1',
          name: 'My Groceries',
          items: [
            ShoppingItem(
                name: 'Eggs', amount: '12', unit: null, isChecked: false),
            ShoppingItem(
                name: 'Flour', amount: '1', unit: 'kg', isChecked: true),
          ],
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final map = list.toMap();

        expect(map['userId'], 'user1');
        expect(map['name'], 'My Groceries');
        expect(map['items'], isA<List>());
        expect((map['items'] as List).length, 2);
        expect(map['createdAt'], createdAt.toIso8601String());
        expect(map['updatedAt'], updatedAt.toIso8601String());
      });

      test('does not include id in toMap output', () {
        final list = ShoppingList(
          id: 'doc1',
          userId: 'user1',
          name: 'Test',
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = list.toMap();
        expect(map.containsKey('id'), isFalse);
      });

      test('serializes empty items list', () {
        final list = ShoppingList(
          userId: 'user1',
          name: 'Empty',
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = list.toMap();
        expect(map['items'], isEmpty);
      });

      test('serializes nested items as maps', () {
        final list = ShoppingList(
          userId: 'user1',
          name: 'Test',
          items: [
            ShoppingItem(name: 'Apple', amount: '5', unit: 'pieces'),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = list.toMap();
        final itemsList = map['items'] as List;

        expect(itemsList[0], isA<Map<String, dynamic>>());
        expect(itemsList[0]['name'], 'Apple');
        expect(itemsList[0]['amount'], '5');
        expect(itemsList[0]['unit'], 'pieces');
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all fields', () {
        final originalMap = {
          'userId': 'user1',
          'name': 'Weekly Shopping',
          'items': [
            {
              'name': 'Chicken',
              'amount': '1',
              'unit': 'kg',
              'isChecked': false,
            },
          ],
          'createdAt': '2024-06-15T10:00:00.000',
          'updatedAt': '2024-06-15T10:00:00.000',
        };

        final list = ShoppingList.fromMap(originalMap, 'doc1');
        final resultMap = list.toMap();

        expect(resultMap['userId'], originalMap['userId']);
        expect(resultMap['name'], originalMap['name']);
        expect((resultMap['items'] as List).length, 1);
        expect((resultMap['items'] as List)[0]['name'], 'Chicken');
      });

      test('round-trip preserves empty items list', () {
        final originalMap = {
          'userId': 'user1',
          'name': 'Empty List',
          'items': <Map<String, dynamic>>[],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final list = ShoppingList.fromMap(originalMap, 'doc1');
        final resultMap = list.toMap();

        expect(resultMap['items'], isEmpty);
      });
    });

    group('constructor', () {
      test('allows null id', () {
        final list = ShoppingList(
          userId: 'user1',
          name: 'Test',
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(list.id, isNull);
      });
    });

    group('edge cases', () {
      test('handles empty name', () {
        final list = ShoppingList(
          userId: 'user1',
          name: '',
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(list.name, '');
      });

      test('handles many items', () {
        final items = List.generate(
          100,
          (i) => ShoppingItem(
            name: 'Item $i',
            amount: '${i + 1}',
          ),
        );

        final list = ShoppingList(
          userId: 'user1',
          name: 'Large List',
          items: items,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(list.items.length, 100);
      });

      test('handles empty string docId', () {
        final map = {
          'userId': 'user1',
          'name': 'Test',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final list = ShoppingList.fromMap(map, '');
        expect(list.id, '');
      });

      test('createdAt and updatedAt can differ', () {
        final created = DateTime(2024, 1, 1);
        final updated = DateTime(2024, 6, 15);

        final list = ShoppingList(
          userId: 'user1',
          name: 'Test',
          items: [],
          createdAt: created,
          updatedAt: updated,
        );

        expect(list.createdAt, created);
        expect(list.updatedAt, updated);
        expect(list.updatedAt.isAfter(list.createdAt), isTrue);
      });
    });
  });
}
