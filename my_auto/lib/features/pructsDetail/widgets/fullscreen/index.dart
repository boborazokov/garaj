import 'package:flutter/material.dart';
import 'package:my_auto/core/utils/local_image.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'fullscreen_image_provider.dart';

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _closeIfNotZoomed(
    BuildContext context,
    TapUpDetails details,
    PhotoViewControllerValue controllerValue,
  ) {
    final scale = controllerValue.scale ?? 1.0;
    if (scale <= 1.01) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount: widget.images.length,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              onPageChanged: (index) => setState(() => _currentIndex = index),
              builder: (context, index) {
                final source = widget.images[index];
                final provider = fullScreenImageProvider(source);

                if (provider != null) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: provider,
                    minScale: PhotoViewComputedScale.contained,
                    initialScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.contained * 4,
                    heroAttributes: PhotoViewHeroAttributes(tag: source),
                    onTapUp: _closeIfNotZoomed,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
                  );
                }

                return PhotoViewGalleryPageOptions.customChild(
                  child: SizedBox(
                    width: viewport.width,
                    height: viewport.height,
                    child: _FullScreenImage(source: source),
                  ),
                  childSize: viewport,
                  minScale: PhotoViewComputedScale.contained,
                  initialScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 4,
                  onTapUp: _closeIfNotZoomed,
                );
              },
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(
                  color: Colors.white54,
                  strokeWidth: 2,
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: _buildIconButton(
                icon: Icons.close_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: 24,
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  const _FullScreenImage({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    if (isLocalImagePath(source)) {
      return localImage(
        source,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.broken_image_outlined,
          color: Colors.white54,
          size: 64,
        ),
      );
    }
    return ImageCacheNetwork(
      url: source,
      fit: BoxFit.contain,
    );
  }
}
