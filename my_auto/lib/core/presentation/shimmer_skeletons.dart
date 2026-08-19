import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton for order-detail style hero + text blocks.
class OrderDetailSkeleton extends StatelessWidget {
  const OrderDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = colors.surfaceMuted;
    final hi = colors.surface.withValues(alpha: 0.92);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadius.rXl,
              ),
            ),
            const SizedBox(height: 20),
            _strip(220, 14, colors),
            const SizedBox(height: 10),
            _strip(null, 12, colors),
            const SizedBox(height: 8),
            _strip(null, 12, colors),
            const SizedBox(height: 24),
            _strip(120, 22, colors),
            const SizedBox(height: 16),
            _strip(null, 48, colors),
            const SizedBox(height: 12),
            _strip(null, 48, colors),
            const SizedBox(height: 28),
            _strip(180, 18, colors),
            const SizedBox(height: 14),
            _strip(null, 72, colors),
            const SizedBox(height: 10),
            _strip(null, 72, colors),
          ],
        ),
      ),
    );
  }

  Widget _strip(double? width, double height, AppColors colors) {
    final decoration = BoxDecoration(
      color: colors.surface,
      borderRadius: AppRadius.rM,
    );
    if (width == null) {
      return Container(height: height, decoration: decoration);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: decoration,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
