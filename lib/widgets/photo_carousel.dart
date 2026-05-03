import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'photo_viewer.dart';

class PhotoCarousel extends StatefulWidget {
  final List<String> photos;
  final double height;
  final bool tappable;

  const PhotoCarousel({
    super.key,
    required this.photos,
    this.height = 320,
    this.tappable = true,
  });

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    if (photos.isEmpty) return const SizedBox.shrink();

    if (photos.length == 1) {
      return GestureDetector(
        onTap: widget.tappable
            ? () => PhotoViewer.show(context, photos: photos, initialIndex: 0)
            : null,
        child: CachedNetworkImage(
          imageUrl: photos[0],
          height: widget.height,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, url) => Container(
            color: AppTheme.neutralLight,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, url, err) => _placeholder(),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Images
          PageView.builder(
            controller: _pageController,
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: widget.tappable
                    ? () => PhotoViewer.show(
                          context,
                          photos: photos,
                          initialIndex: index,
                        )
                    : null,
                child: CachedNetworkImage(
                  imageUrl: photos[index],
                  fit: BoxFit.cover,
                  placeholder: (_, url) => Container(
                    color: AppTheme.neutralLight,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, url, err) => _placeholder(),
                ),
              );
            },
          ),
          // Count badge top-right
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentIndex + 1}/${photos.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Dot indicators bottom-center
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (i) {
                final active = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.neutralLight,
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 60,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }
}
