import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/core/utils/shimmer.dart';

class ImageCacheNetwork extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ImageCacheNetwork({
    super.key,
    required this.url,
    this.width,
    this.height,
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

    final w = width != null && width!.isFinite ? width : null;
    final h = height != null && height!.isFinite ? height : null;

    return CachedNetworkImage(
      imageUrl: fullUrl,
      cacheManager: DefaultCacheManager(),
      cacheKey: fullUrl,
      width: w,
      height: h,
      fit: fit,
      httpHeaders: mediaRequestHeaders(fullUrl),
      fadeInDuration: const Duration(milliseconds: 120),
      placeholder: (context, _) => shimmerPlaceholder(context),
      errorWidget: (context, _, __) => _errorBox(context),
    );
  }

  Widget _errorBox(BuildContext context) {
    final colors = context.appColors;
    return ColoredBox(
      color: colors.surfaceMuted,
      child: Center(
        child: Icon(
          LucideIcons.imageOff,
          color: colors.textMuted.withValues(alpha: 0.7),
          size: 28,
        ),
      ),
    );
  }
}
