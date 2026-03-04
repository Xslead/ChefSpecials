import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (picked == null) return null;
    return File(picked.path);
  }

  static Future<File?> pickFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (picked == null) return null;
    return File(picked.path);
  }
}
