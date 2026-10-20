import 'file_io.dart';

final _ephemeralHost = RegExp(
  r'(^localhost$)|(^127\.)|(^10\.)|(^192\.168\.)|(ngrok)',
  caseSensitive: false,
);

bool _isEphemeralMediaHost(String host) => _ephemeralHost.hasMatch(host);

String _stripBase(String path, String base) {
  if (base.isEmpty) return path;
  if (path.startsWith('$base/')) return path.substring(base.length + 1);
  if (path == base) return '';
  return path;
}

/// Builds a full URL for MinIO / CDN paths or returns absolute URLs unchanged.
///
/// Stale localhost / LAN / ngrok hosts are re-based onto [mediaBase] so images
/// keep working after tunnel or LAN IP changes.
String? resolveMediaUrl(String? path, {required String mediaBase}) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;

  final base = mediaBase.endsWith('/')
      ? mediaBase.substring(0, mediaBase.length - 1)
      : mediaBase;

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return trimmed;

      if (base.isNotEmpty && _isEphemeralMediaHost(uri.host)) {
      final segment = uri.path.startsWith('/')
          ? uri.path.substring(1)
          : uri.path;
      if (segment.isEmpty) return base;
      return _mediaUrl(base, segment);
    }
    return trimmed;
  }

  if (base.isEmpty) return trimmed;

  final segment = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  if (segment.startsWith('http://') || segment.startsWith('https://')) {
    return resolveMediaUrl(segment, mediaBase: mediaBase);
  }
  return _mediaUrl(base, segment);
}

/// Storage keys are `bucket/object`. The API serves them under `/media`.
String _mediaUrl(String base, String segment) {
  final s = segment.startsWith('/') ? segment.substring(1) : segment;
  if (s.isEmpty) return base;
  if (s.startsWith('media/')) return '$base/$s';
  return '$base/media/$s';
}

/// Strips CDN base prefix so [ImageCacheNetwork] can re-apply [fileUrl] consistently.
String normalizeStoragePath(String path, {required String mediaBase}) {
  var p = path.trim();
  if (p.isEmpty) return p;

  final base = mediaBase.endsWith('/')
      ? mediaBase.substring(0, mediaBase.length - 1)
      : mediaBase;

  p = _stripBase(p, base);

  if (p.startsWith('http://') || p.startsWith('https://')) {
    final uri = Uri.tryParse(p);
    if (uri != null && _isEphemeralMediaHost(uri.host)) {
      final segment =
          uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
      return segment;
    }
    return p;
  }
  return p.startsWith('/') ? p.substring(1) : p;
}

/// True when the given string points to a local-only asset that we shouldn't
/// try to resolve against the CDN.
///
/// On web, the only "local" paths are `blob:` URLs from `image_picker_web` /
/// `record_web`.
bool isLocalImagePath(String path) {
  final p = path.trim();
  if (p.isEmpty) return false;
  if (p.startsWith('blob:')) return true;
  if (p.startsWith('file://')) return true;
  if (p.startsWith('http://') || p.startsWith('https://')) return false;
  if (platformIsWindows && p.length > 2 && p[1] == ':') return true;
  if (p.startsWith('/data/') ||
      p.startsWith('/storage/') ||
      p.contains('/cache/') ||
      p.contains(r'\cache\')) {
    return true;
  }
  return fileExistsSync(p);
}

bool isRemoteMediaPath(String path) => !isLocalImagePath(path);

/// Headers needed for ephemeral tunnels (ngrok free interstitial).
Map<String, String> mediaRequestHeaders(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return const {};
  if (!uri.host.toLowerCase().contains('ngrok')) return const {};
  return const {'ngrok-skip-browser-warning': 'true'};
}
