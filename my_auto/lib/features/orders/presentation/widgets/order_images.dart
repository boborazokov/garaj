import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  const OrderCardThumbnail({
    super.key,
    required this.imagePath,
    this.width = 76,
    this.height = 76,
  });

  final String imagePath;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.rL,
      child: SizedBox(
        width: width,
        height: height,
        child: _OrderImage(path: imagePath, fit: BoxFit.cover),
      ),
    );
  }
}

/// Full-bleed gallery for order detail (page dots + counter).
class OrderDetailGallery extends StatefulWidget {
  const OrderDetailGallery({
    super.key,
    required this.images,
    this.height = 280,
  });

  final List<String> images;
  final double height;

  @override
  State<OrderDetailGallery> createState() => _OrderDetailGalleryState();
}

class _OrderDetailGalleryState extends State<OrderDetailGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, index) {
              return _OrderImage(path: images[index], fit: BoxFit.cover);
            },
          ),
          if (images.length > 1) ...[
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_index + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : null;
        final h =
            constraints.maxHeight.isFinite ? constraints.maxHeight : null;
        return ImageCacheNetwork(
          url: path,
          fit: fit,
          width: w,
          height: h,
        );
      },
    );
  }
}
