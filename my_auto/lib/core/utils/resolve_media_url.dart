import 'file_io.dart';

/// Builds a full URL for MinIO / CDN paths or returns absolute URLs unchanged.
String? resolveMediaUrl(String? path, {required String mediaBase}) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  final base = mediaBase.endsWith('/')
      ? mediaBase.substring(0, mediaBase.length - 1)
      : mediaBase;
  if (base.isEmpty) return trimmed;

  final segment = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  if (segment.startsWith('http://') || segment.startsWith('https://')) {
    return segment;
  }
  return '$base/$segment';
}

/// Strips CDN base prefix so [ImageCacheNetwork] can re-apply [fileUrl] consistently.
String normalizeStoragePath(String path, {required String mediaBase}) {
  var p = path.trim();
  if (p.isEmpty) return p;

  final base = mediaBase.endsWith('/')
      ? mediaBase.substring(0, mediaBase.length - 1)
      : mediaBase;

  if (base.isNotEmpty) {
    if (p.startsWith('$base/')) {
      p = p.substring(base.length + 1);
    } else if (p == base) {
      return '';
    }
  }

  if (p.startsWith('http://') || p.startsWith('https://')) return p;
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
