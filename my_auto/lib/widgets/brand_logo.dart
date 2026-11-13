import 'package:flutter/material.dart';

/// Theme-aware Garage wordmark — light uses dark text, dark uses white text.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.width,
    this.height,
    this.semanticLabel = 'Garage',
  }) : assert(width != null || height != null, 'Provide width or height');

  final double? width;
  final double? height;
  final String semanticLabel;

  static String assetFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/logo_dark.png'
          : 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Image.asset(
      assetFor(brightness),
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: semanticLabel,
    );
  }
}
