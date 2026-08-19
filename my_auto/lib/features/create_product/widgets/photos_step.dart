import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/bloc/create_product_bloc.dart';
import 'package:my_auto/features/create_product/domain/entities/product_photo.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_auto/generated/l10n.dart';

class PhotosStep extends StatelessWidget {
  const PhotosStep({super.key, this.compact = false});

  /// Non-scroll outer parent (section editor): shrink-wrap contents.
  final bool compact;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    if (source == ImageSource.camera) {
      final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (file != null && context.mounted) {
        context.read<CreateProductBloc>().add(
              CreateProductPhotosPicked([File(file.path)]),
            );
      }
      return;
    }
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty && context.mounted) {
      context.read<CreateProductBloc>().add(
            CreateProductPhotosPicked(files.map((f) => File(f.path)).toList()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final photos = context.select((CreateProductBloc b) => b.state.draft.photos);

    return ListView(
      shrinkWrap: compact,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.fromLTRB(
        compact ? 0 : 16,
        compact ? 0 : 8,
        compact ? 0 : 16,
        compact ? 0 : 120,
      ),
      children: [
        Text(
          s.createProductPhotosTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          s.createProductPhotosHint,
          style: TextStyle(color: colors.textMuted),
        ),
        const SizedBox(height: 20),
        if (photos.isEmpty)
          _UploadZone(
            onGallery: () => _pick(context, ImageSource.gallery),
            onCamera: () => _pick(context, ImageSource.camera),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: photos.length,
            onReorder: (oldIndex, newIndex) {
              HapticFeedback.selectionClick();
              context.read<CreateProductBloc>().add(
                    CreateProductPhotosReordered(oldIndex, newIndex),
                  );
            },
            itemBuilder: (context, index) {
              final photo = photos[index];
              return _PhotoTile(
                key: ValueKey(photo.id),
                photo: photo,
                isCover: index == 0,
                onRemove: () => context.read<CreateProductBloc>().add(
                      CreateProductPhotoRemoved(photo.id),
                    ),
              );
            },
          ),
        if (photos.isNotEmpty && photos.length < 8) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _pick(context, ImageSource.gallery),
            icon: const Icon(LucideIcons.plus),
            label: Text(s.createProductAddMorePhotos),
          ),
        ],
      ],
    );
  }
}

class _UploadZone extends StatelessWidget {
  const _UploadZone({required this.onGallery, required this.onCamera});

  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.rXl,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.35),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.image, size: 48, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            s.createProductTapAddPhotos,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.tonal(
                onPressed: onGallery,
                child: Text(s.createProductGallery),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: onCamera,
                child: Text(s.createProductCamera),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    super.key,
    required this.photo,
    required this.isCover,
    required this.onRemove,
  });

  final ProductPhoto photo;
  final bool isCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: photo.isNetwork
                  ? ImageCacheNetwork(url: photo.networkUrl!, fit: BoxFit.cover)
                  : Image.file(photo.file!, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCover)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          borderRadius: AppRadius.rS,
                        ),
                        child: Text(
                          s.createProductCover.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(LucideIcons.gripVertical,
                            size: 18, color: colors.textMuted),
                        const SizedBox(width: 8),
                        Text(s.createProductDragReorder,
                            style: TextStyle(
                                fontSize: 12, color: colors.textMuted)),
                        const Spacer(),
                        IconButton(
                          onPressed: onRemove,
                          icon: Icon(LucideIcons.trash2, color: colors.danger),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
