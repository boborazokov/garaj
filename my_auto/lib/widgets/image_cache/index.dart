import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';

/// Shared disk cache — creating [DefaultCacheManager] per build was expensive
/// during fast list scrolls.
final BaseCacheManager appImageCacheManager = DefaultCacheManager();

class ImageCacheNetwork extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Optional decode width in logical px. When null, inferred from [width]
  /// or a list-friendly default so old devices don't decode full-res photos.
  final double? cacheWidth;

  const ImageCacheNetwork({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
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
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final logicalCache = cacheWidth ?? w ?? 360;
    final memW = (logicalCache * dpr).round().clamp(64, 900);
    final colors = context.appColors;

    return CachedNetworkImage(
      imageUrl: fullUrl,
      cacheManager: appImageCacheManager,
      cacheKey: fullUrl,
      width: w,
      height: h,
      fit: fit,
      memCacheWidth: memW,
      filterQuality: FilterQuality.low,
      httpHeaders: mediaRequestHeaders(fullUrl),
      // No shimmer / fade — animated placeholders drop FPS on fling.
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (context, _) => ColoredBox(color: colors.surfaceMuted),
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
