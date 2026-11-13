import 'package:flutter/material.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';

/// Injects a banner into scrollable lists after [firstAfter] items,
/// then every [interval] items thereafter.
///
/// Drop this as the first child inside a list item builder — it renders
/// nothing unless `listIndex` hits a slot, keeping list code clean.
class AdListSlot extends StatelessWidget {
  const AdListSlot({
    super.key,
    required this.listIndex,
    required this.surface,
    this.firstAfter = 6,
    this.interval = 6,
    this.height = 120,
    this.margin = const EdgeInsets.fromLTRB(16, 4, 16, 12),
  });

  final int listIndex;
  final AdSurface surface;

  /// Show the first ad after this many products/orders (0-based index == firstAfter).
  final int firstAfter;
  final int interval;
  final double height;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    if (listIndex < firstAfter) {
      return const SizedBox.shrink();
    }
    if ((listIndex - firstAfter) % interval != 0) {
      return const SizedBox.shrink();
    }
    return AdBanner(
      surface: surface,
      height: height,
      margin: margin,
      showPlaceholder: false,
      keepAlive: false,
    );
  }
}
