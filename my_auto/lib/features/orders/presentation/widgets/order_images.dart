import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Optional photo picker for create-order wizard (up to [maxPhotos]).
class OrderPhotosPicker extends StatelessWidget {
  const OrderPhotosPicker({
    super.key,
    required this.photos,
    required this.onChanged,
    this.maxPhotos = 5,
  });

  final List<File> photos;
  final ValueChanged<List<File>> onChanged;
  final int maxPhotos;

  Future<void> _pick(BuildContext context) async {
    final s = S.of(context);
    if (photos.length >= maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.youCanUploadUpTo5Photos)),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty || !context.mounted) return;

    final room = maxPhotos - photos.length;
    final next = [
      ...photos,
      ...picked.take(room).map((f) => File(f.path)),
    ];
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.photos,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          s.youCanUploadUpTo5Photos,
          style: TextStyle(fontSize: 12, color: colors.textMuted),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (photos.length < maxPhotos)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => _pick(context),
                    borderRadius: AppRadius.rL,
                    child: Ink(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: AppRadius.rL,
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.6),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.imagePlus,
                            color: colors.primary,
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.createProductTapAddPhotos,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ...photos.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.rL,
                        child: Image.file(
                          e.value,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Material(
                          color: colors.danger,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              final next = [...photos]..removeAt(e.key);
                              onChanged(next);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                LucideIcons.x,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

/// Thumbnail for list cards.
class OrderCardThumbnail extends StatelessWidget {
  const OrderCardThumbnail({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.rL,
      child: SizedBox(
        width: 76,
        height: 76,
        child: _OrderImage(path: imagePath, fit: BoxFit.cover),
      ),
    );
  }
}

/// Horizontal gallery for order detail.
class OrderDetailGallery extends StatelessWidget {
  const OrderDetailGallery({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: AppRadius.rL,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _OrderImage(path: images.first, fit: BoxFit.cover),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: images.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: AppRadius.rL,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _OrderImage(path: images[index], fit: BoxFit.cover),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: AppRadius.rM,
                      ),
                      child: Text(
                        '${index + 1}/${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderImage extends StatelessWidget {
  const _OrderImage({required this.path, required this.fit});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (isLocalImagePath(path)) {
      return Image.file(File(path), fit: fit);
    }
    return ImageCacheNetwork(url: path, fit: fit);
  }
}
