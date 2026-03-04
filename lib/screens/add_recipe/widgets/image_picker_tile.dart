import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/recipe_form_provider.dart';

class ImagePickerTile extends StatelessWidget {
  const ImagePickerTile({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null && context.mounted) {
      context.read<RecipeFormProvider>().setImage(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = context.watch<RecipeFormProvider>().imageFile;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
          image: imageFile != null
              ? DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add photo',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
