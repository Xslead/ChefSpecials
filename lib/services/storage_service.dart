import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadRecipeImage(File file, String userId) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('recipe_images/$userId/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadStepImage(File file, String userId) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('step_images/$userId/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadUserAvatar(File file, String userId) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('user_avatars/$userId/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }

  Future<File> compressImage(File file) async {
    try {
      final targetPath =
          '${file.parent.path}/${_uuid.v4()}_compressed.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 80,
        minWidth: 1200,
        minHeight: 1,
      );
      return result != null ? File(result.path) : file;
    } catch (_) {
      // Compression unavailable (e.g. x86 emulator) — use original file
      return file;
    }
  }

  Future<List<String>> uploadRecipePhotos(
    String recipeId,
    List<File> files,
  ) async {
    final urls = <String>[];
    for (final file in files) {
      final compressed = await compressImage(file);
      final fileName = '${_uuid.v4()}.jpg';
      final ref =
          _storage.ref().child('recipe_photos/$recipeId/$fileName');
      await ref.putFile(compressed);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<void> deleteRecipePhotos(String recipeId) async {
    try {
      final ref = _storage.ref().child('recipe_photos/$recipeId');
      final result = await ref.listAll();
      for (final item in result.items) {
        await item.delete();
      }
    } catch (_) {}
  }

  Future<String> uploadRecipeVideo(File file, String userId) async {
    final fileName = '${_uuid.v4()}.mp4';
    final ref = _storage.ref().child('recipe_videos/$userId/$fileName');
    await ref.putFile(file, SettableMetadata(contentType: 'video/mp4'));
    return await ref.getDownloadURL();
  }

  Future<String> uploadStepVideo(File file, String userId) async {
    final fileName = '${_uuid.v4()}.mp4';
    final ref = _storage.ref().child('step_videos/$userId/$fileName');
    await ref.putFile(file, SettableMetadata(contentType: 'video/mp4'));
    return await ref.getDownloadURL();
  }

  Future<void> deleteRecipeVideo(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }

  Future<Uint8List?> generateVideoThumbnail(String videoPath) async {
    try {
      return await VideoCompress.getByteThumbnail(videoPath, quality: 50);
    } catch (_) {
      return null;
    }
  }
}
