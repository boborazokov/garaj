import 'package:flutter/material.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';

/// Injects a banner into scrollable lists every [interval] items.
///
/// Drop this as the first child inside a list item builder — it renders
/// nothing unless `listIndex` hits the interval, keeping list code clean.
class AdListSlot extends StatelessWidget {
  const AdListSlot({
    super.key,
    required this.listIndex,
    required this.surface,
    this.interval = 6,
    this.height = 120,
  });

  final int listIndex;
  final AdSurface surface;
  final int interval;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (listIndex <= 0 || listIndex % interval != 0) {
      return const SizedBox.shrink();
    }
    return AdBanner(
      surface: surface,
      height: height,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
    );
  }
}
