import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';

/// Returns an [ImageProvider] for gallery zoom, or `null` for local paths
/// that should use [localImage] via customChild fallback.
ImageProvider<Object>? fullScreenImageProvider(String source) {
  final key = source.trim();
  if (key.isEmpty) return null;

  if (isLocalImagePath(key)) {
    if (key.startsWith('blob:') || key.startsWith('file://')) {
      return NetworkImage(key);
    }
    return FileImage(File(key));
  }

  final fullUrl = resolveMediaUrl(key, mediaBase: fileUrl);
  if (fullUrl == null || fullUrl.isEmpty) return null;

  return CachedNetworkImageProvider(
    fullUrl,
    cacheManager: DefaultCacheManager(),
  );
}
