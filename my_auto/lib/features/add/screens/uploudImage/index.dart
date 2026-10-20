import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_auto/core/provider/add/addPartProvider.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/button/index.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:provider/provider.dart';

class UploadImage extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const UploadImage({super.key, this.onNext, this.onBack});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  Future<void> _pickImages(BuildContext context) async {
    final provider = context.read<AddPartProvider>();
    if (provider.allImages.length >= 5) {
      Toaster.error(S.of(context).youCanUploadUpTo5Photos);
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final newFiles =
          result.paths.whereType<String>().map((e) => File(e)).toList();
      await provider.addImages(newFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddPartProvider>();
    final images = provider.allImages;

    return Scaffold(
      body: AppSafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            stickyBottomPadding(context, keyboardExtra: 0, homeExtra: 20),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).photos,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            if (images.isEmpty)
              GestureDetector(
                onTap: () => _pickImages(context),
                child: const DottedBorderBox(),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...provider.allImages.map((item) {
                    final isNetwork = item is String;

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: isNetwork
                              ? ImageCacheNetwork(
                                  url: item,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  item as File,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => provider.removeImage(item),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  if (provider.allImages.length < 5)
                    AddPhotoButton(onTap: () => _pickImages(context)),
                ],
              ),
            const SizedBox(height: 24),
            images.isEmpty
                ? TextButton(
                    onPressed: widget.onNext,
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                    ),
                    child: Text(
                      S.of(context).continueWithoutPhotos,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16),
                    ),
                  )
                : Button(
                    title: S.of(context).next,
                    onTap: widget.onNext,
                    padding: EdgeInsetsGeometry.zero,
                  ),
          ],
          ),
        ),
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary, size: 36),
            const SizedBox(height: 8),
            Text(
              S.of(context).addPhoto,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddPhotoButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add,
                color: Theme.of(context).colorScheme.primary, size: 32),
            Text(
              S.of(context).addPhoto,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
