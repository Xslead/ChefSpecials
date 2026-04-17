import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/recipe_form_provider.dart';
import '../../../widgets/photo_viewer.dart';

class MultiImagePicker extends StatelessWidget {
  const MultiImagePicker({super.key});

  Future<void> _pickCoverImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (picked != null && context.mounted) {
      context.read<RecipeFormProvider>().setImage(File(picked.path));
    }
  }

  Future<void> _pickAdditionalImages(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (picked.isNotEmpty && context.mounted) {
      context
          .read<RecipeFormProvider>()
          .addAdditionalPhotos(picked.map((x) => File(x.path)).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeFormProvider>();
    final l10n = AppLocalizations.of(context)!;

    final hasCover =
        provider.imageFile != null || provider.existingImageUrl != null;
    final hasAnyPhoto = hasCover ||
        provider.existingAdditionalPhotos.isNotEmpty ||
        provider.additionalPhotoFiles.isNotEmpty;

    if (!hasAnyPhoto) {
      return _EmptyState(onTap: () => _pickCoverImage(context), l10n: l10n);
    }

    // Build unified display list
    final List<_PhotoItem> items = [];

    items.add(_PhotoItem(
      file: provider.imageFile,
      url: provider.existingImageUrl,
      isCover: true,
    ));

    for (final url in provider.existingAdditionalPhotos) {
      items.add(_PhotoItem(url: url));
    }

    for (final file in provider.additionalPhotoFiles) {
      items.add(_PhotoItem(file: file));
    }

    final networkUrls =
        items.where((i) => i.url != null).map((i) => i.url!).toList();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: items.length + 1,
        separatorBuilder: (_, _i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _AddMoreButton(
              onTap: () => _pickAdditionalImages(context),
            );
          }

          final item = items[index];
          return _PhotoThumbnail(
            item: item,
            networkUrls: networkUrls,
            onDelete: item.isCover
                ? () => provider.clearCoverImage()
                : () => provider.removeAdditionalPhoto(index - 1),
            onTap: item.url != null
                ? () {
                    final idx = items
                        .where((i) => i.url != null)
                        .toList()
                        .indexOf(item);
                    if (networkUrls.isNotEmpty && idx >= 0) {
                      PhotoViewer.show(context,
                          photos: networkUrls, initialIndex: idx);
                    }
                  }
                : null,
          );
        },
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _EmptyState({required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppTheme.neutralSoftOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: AppTheme.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addPhotos,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.coverPhoto,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Thumbnail ────────────────────────────────────────────────────────────────

class _PhotoThumbnail extends StatelessWidget {
  final _PhotoItem item;
  final List<String> networkUrls;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const _PhotoThumbnail({
    required this.item,
    required this.networkUrls,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Image container
          Container(
            width: 100,
            height: 100,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppTheme.neutralSoftOf(context),
              borderRadius: BorderRadius.circular(12),
              border: item.isCover
                  ? Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.6),
                      width: 2,
                    )
                  : Border.all(
                      color: AppTheme.neutralLightOf(context),
                      width: 1,
                    ),
            ),
            child: _buildImage(),
          ),

          // Cover badge — small chip top-left
          if (item.isCover)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppLocalizations.of(context)!.coverPhoto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

          // Delete button — top-right
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close, color: Colors.white, size: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (item.file != null && item.file!.path.isNotEmpty) {
      return Image.file(item.file!, fit: BoxFit.cover,
          width: double.infinity, height: double.infinity);
    } else if (item.url != null) {
      return CachedNetworkImage(
        imageUrl: item.url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, _u) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, _u, _e) => const Icon(Icons.broken_image),
      );
    } else {
      return const Center(
        child: Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryColor),
      );
    }
  }
}

// ── Add more button ──────────────────────────────────────────────────────────

class _AddMoreButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.add_photo_alternate_outlined,
          color: AppTheme.primaryColor,
          size: 28,
        ),
      ),
    );
  }
}

// ── Data class ───────────────────────────────────────────────────────────────

class _PhotoItem {
  final File? file;
  final String? url;
  final bool isCover;

  const _PhotoItem({this.file, this.url, this.isCover = false});
}
