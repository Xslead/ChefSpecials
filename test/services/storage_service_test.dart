import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:chef_specials/services/storage_service.dart';

/// Fake [Reference] with controllable delete behaviour.
class FakeReference extends Fake implements Reference {
  int deleteCallCount = 0;
  Exception? deleteError;

  @override
  Future<void> delete() async {
    deleteCallCount++;
    if (deleteError != null) throw deleteError!;
  }
}

/// Fake [FirebaseStorage] that provides controllable [refFromURL].
class FakeFirebaseStorage extends Fake implements FirebaseStorage {
  final Map<String, FakeReference> _refs = {};
  Exception? refFromURLError;

  void addRef(String url, FakeReference ref) => _refs[url] = ref;

  @override
  Reference refFromURL(String url) {
    if (refFromURLError != null) throw refFromURLError!;
    if (_refs.containsKey(url)) return _refs[url]!;
    throw Exception('No ref registered for URL: $url');
  }
}

void main() {
  late FakeFirebaseStorage fakeStorage;
  late StorageService service;

  setUp(() {
    fakeStorage = FakeFirebaseStorage();
    service = StorageService(storage: fakeStorage);
  });

  group('StorageService', () {
    // -----------------------------------------------------------------------
    // deleteImage
    // -----------------------------------------------------------------------
    group('deleteImage', () {
      test('deletes image reference by URL', () async {
        const url =
            'https://firebasestorage.googleapis.com/v0/b/test/image.jpg';
        final ref = FakeReference();
        fakeStorage.addRef(url, ref);

        await service.deleteImage(url);

        expect(ref.deleteCallCount, 1);
      });

      test('silently handles error when refFromURL throws', () async {
        fakeStorage.refFromURLError = Exception('Object not found');

        // Should not throw
        await service.deleteImage('https://example.com/nonexistent.jpg');
      });

      test('silently handles invalid URL', () async {
        fakeStorage.refFromURLError = Exception('Invalid URL');

        // Should not throw
        await service.deleteImage('not-a-url');
      });

      test('silently handles delete failure', () async {
        const url = 'https://example.com/image.jpg';
        final ref = FakeReference()
          ..deleteError = Exception('Permission denied');
        fakeStorage.addRef(url, ref);

        // Should not throw
        await service.deleteImage(url);
        expect(ref.deleteCallCount, 1);
      });
    });

    // -----------------------------------------------------------------------
    // constructor / DI
    // -----------------------------------------------------------------------
    group('constructor', () {
      test('accepts custom FirebaseStorage instance', () {
        expect(service, isNotNull);
      });
    });
  });
}
