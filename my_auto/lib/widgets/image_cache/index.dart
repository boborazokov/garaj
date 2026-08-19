import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/core/utils/shimmer.dart';

class ImageCacheNetwork extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;

  const ImageCacheNetwork({
    super.key,
    required this.url,
    this.width = double.infinity,
    this.height = 200,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final key = url.trim();
    if (key.isEmpty) {
      return _errorBox(context);
    }

    final fullUrl = resolveMediaUrl(key, mediaBase: fileUrl);
    if (fullUrl == null || fullUrl.isEmpty) {
      return _errorBox(context);
    }

    return ClipRRect(
      child: CachedNetworkImage(
        imageUrl: fullUrl,
        cacheManager: DefaultCacheManager(),
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, _) => shimmerPlaceholder(context),
        errorWidget: (context, _, __) => _errorBox(context),
      ),
    );
  }

  Widget _errorBox(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
        size: 48,
      ),
    );
  }
}
