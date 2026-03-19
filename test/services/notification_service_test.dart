import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chef_specials/services/notification_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('NotificationService', () {
    test('can be instantiated with custom Firestore', () {
      final service = NotificationService(
        firestore: fakeFirestore,
        localNotifications: FlutterLocalNotificationsPlugin(),
      );
      expect(service, isNotNull);
    });

    test('saveFcmToken writes token to user document', () async {
      await fakeFirestore.collection('users').doc('user123').set({
        'fullName': 'Test User',
        'email': 'test@example.com',
      });

      final service = NotificationService(
        firestore: fakeFirestore,
        localNotifications: FlutterLocalNotificationsPlugin(),
      );
      await service.saveFcmToken('user123', 'test-fcm-token-abc');

      final doc =
          await fakeFirestore.collection('users').doc('user123').get();
      expect(doc.data()?['fcmToken'], 'test-fcm-token-abc');
    });

    test('saveFcmToken updates existing token', () async {
      await fakeFirestore.collection('users').doc('user456').set({
        'fullName': 'Another User',
        'fcmToken': 'old-token',
      });

      final service = NotificationService(
        firestore: fakeFirestore,
        localNotifications: FlutterLocalNotificationsPlugin(),
      );
      await service.saveFcmToken('user456', 'new-token');

      final doc =
          await fakeFirestore.collection('users').doc('user456').get();
      expect(doc.data()?['fcmToken'], 'new-token');
    });
  });
}
