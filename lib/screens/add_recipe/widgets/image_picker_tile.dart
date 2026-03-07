import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
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
    final provider = context.watch<RecipeFormProvider>();
    final imageFile = provider.imageFile;
    final existingImageUrl = provider.existingImageUrl;
    final hasImage = imageFile != null || existingImageUrl != null;

    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        height: 200,
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppTheme.neutralSoftOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : AppTheme.neutralLightOf(context),
            width: hasImage ? 2 : 1,
          ),
          image: imageFile != null
              ? DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageFile != null
            ? null
            : existingImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: existingImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppTheme.neutralSoftOf(context)),
                    errorWidget: (context, url, error) => _placeholder(context),
                  )
                : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            size: 28,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to add photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textTertiaryOf(context),
          ),
        ),
      ],
    );
  }
}
