import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Picks [Image.file] for local paths or [ImageCacheNetwork] for storage/CDN keys.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.path,
    this.width = double.infinity,
    this.height = 200,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? path;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final p = path?.trim();
    if (p == null || p.isEmpty) {
      return _placeholder(context);
    }

    Widget child;
    if (isLocalImagePath(p)) {
      final file = File(p);
      child = file.existsSync()
          ? Image.file(file, width: width, height: height, fit: fit)
          : _placeholder(context);
    } else {
      child = ImageCacheNetwork(
        url: normalizeStoragePath(p, mediaBase: fileUrl),
        width: width,
        height: height,
        fit: fit,
      );
    }

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}
