import 'package:flutter/widgets.dart';

/// Web fallback. `image_picker` on web returns `blob:` URLs which
/// `Image.network` can render natively.
Widget localImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.network(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
