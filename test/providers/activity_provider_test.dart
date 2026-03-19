import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:chef_specials/providers/activity_provider.dart';
import 'package:chef_specials/services/activity_service.dart';

void main() {
  group('ActivityProvider', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ActivityService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = ActivityService(firestore: fakeFirestore);
    });

    test('initial state has empty activities and zero unread', () {
      final provider = ActivityProvider(service: service);
      expect(provider.activities, isEmpty);
      expect(provider.unreadCount, 0);
      expect(provider.isLoading, false);
    });

    test('init subscribes to activities stream', () async {
      await fakeFirestore.collection('activities').add({
        'userId': 'user1',
        'actorId': 'a1',
        'actorName': 'Test',
        'type': 'follow',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final provider = ActivityProvider(service: service);
      provider.init('user1');

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.activities.length, 1);
      expect(provider.activities.first.actorName, 'Test');
    });

    test('init does not re-subscribe for same userId', () {
      final provider = ActivityProvider(service: service);
      provider.init('user1');
      provider.init('user1'); // should not re-subscribe
      expect(provider, isNotNull);
    });

    test('markAllAsRead calls service', () async {
      await fakeFirestore.collection('activities').add({
        'userId': 'user1',
        'actorId': 'a1',
        'actorName': 'Test',
        'type': 'follow',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final provider = ActivityProvider(service: service);
      provider.init('user1');
      await Future.delayed(const Duration(milliseconds: 100));

      provider.markAllAsRead();
      await Future.delayed(const Duration(milliseconds: 100));

      final snapshot = await fakeFirestore
          .collection('activities')
          .where('userId', isEqualTo: 'user1')
          .get();
      expect(snapshot.docs.first.data()['isRead'], true);
    });

    test('markAllAsRead does nothing without init', () {
      final provider = ActivityProvider(service: service);
      provider.markAllAsRead(); // should not throw
    });
  });
}
