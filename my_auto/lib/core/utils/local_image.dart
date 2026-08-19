/// Cross-platform widget for rendering locally picked images.
///
/// On native platforms (`dart:io` available) we use `Image.file`; on web
/// the input path is a `blob:` URL that `Image.network` understands.
export 'local_image_web.dart' if (dart.library.io) 'local_image_io.dart';
