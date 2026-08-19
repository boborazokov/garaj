import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:shimmer/shimmer.dart';

class OrderShimmerList extends StatelessWidget {
  const OrderShimmerList({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Shimmer.fromColors(
      baseColor: colors.surfaceMuted,
      highlightColor: colors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 168,
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: AppRadius.rXl,
          ),
        ),
      ),
    );
  }
}
