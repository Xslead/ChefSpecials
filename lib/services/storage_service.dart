import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadRecipeImage(File file) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('recipe_images/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadStepImage(File file) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('step_images/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadUserAvatar(File file) async {
    final ref = _storage
        .ref()
        .child('user_avatars/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
