import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'photo_viewer.dart';

class PhotoGrid extends StatelessWidget {
  final List<String> photos;
  final double height;

  const PhotoGrid({
    super.key,
    required this.photos,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: _buildGrid(context),
    );
  }

  Widget _buildGrid(BuildContext context) {
    switch (photos.length) {
      case 1:
        return _tile(context, 0, flex: 1);
      case 2:
        return Row(children: [
          Expanded(child: _tile(context, 0)),
          const SizedBox(width: 2),
          Expanded(child: _tile(context, 1)),
        ]);
      case 3:
        return Row(children: [
          Expanded(flex: 2, child: _tile(context, 0)),
          const SizedBox(width: 2),
          Expanded(
            child: Column(children: [
              Expanded(child: _tile(context, 1)),
              const SizedBox(height: 2),
              Expanded(child: _tile(context, 2)),
            ]),
          ),
        ]);
      default:
        final remaining = photos.length - 4;
        return Row(children: [
          Expanded(
            child: Column(children: [
              Expanded(child: _tile(context, 0)),
              const SizedBox(height: 2),
              Expanded(child: _tile(context, 1)),
            ]),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(children: [
              Expanded(child: _tile(context, 2)),
              const SizedBox(height: 2),
              Expanded(
                child: remaining > 0
                    ? _overlayTile(context, 3, remaining)
                    : _tile(context, 3),
              ),
            ]),
          ),
        ]);
    }
  }

  Widget _tile(BuildContext context, int index, {int flex = 1}) {
    return GestureDetector(
      onTap: () => PhotoViewer.show(context, photos: photos, initialIndex: index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: photos[index],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, _u) =>
              Container(color: AppTheme.neutralLight),
          errorWidget: (_, _u, _e) => Container(
            color: AppTheme.neutralLight,
            child: const Icon(
              Icons.broken_image,
              color: AppTheme.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _overlayTile(BuildContext context, int index, int remaining) {
    return GestureDetector(
      onTap: () => PhotoViewer.show(context, photos: photos, initialIndex: index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: photos[index],
              fit: BoxFit.cover,
              placeholder: (_, _u) =>
                  Container(color: AppTheme.neutralLight),
              errorWidget: (_, _u, _e) =>
                  Container(color: AppTheme.neutralLight),
            ),
            Container(
              color: Colors.black54,
              child: Center(
                child: Text(
                  '+$remaining',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
