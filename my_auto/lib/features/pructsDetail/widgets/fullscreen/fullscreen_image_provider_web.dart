import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';

ImageProvider<Object>? fullScreenImageProvider(String source) {
  final key = source.trim();
  if (key.isEmpty) return null;

  if (isLocalImagePath(key)) {
    return NetworkImage(key);
  }

  final fullUrl = resolveMediaUrl(key, mediaBase: fileUrl);
  if (fullUrl == null || fullUrl.isEmpty) return null;

  return CachedNetworkImageProvider(
    fullUrl,
    cacheManager: DefaultCacheManager(),
  );
}
