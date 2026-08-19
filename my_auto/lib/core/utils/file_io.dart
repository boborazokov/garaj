/// Cross-platform thin wrapper around the few `dart:io` calls we need
/// (delete temp file, sync existence check, platform sniff). The web build
/// gets a no-op stub so importing call sites stay platform-agnostic.
export 'file_io_web.dart' if (dart.library.io) 'file_io_io.dart';
