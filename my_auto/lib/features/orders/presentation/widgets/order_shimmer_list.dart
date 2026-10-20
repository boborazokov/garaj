import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:shimmer/shimmer.dart';

class OrderShimmerList extends StatelessWidget {
  const OrderShimmerList({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Shimmer.fromColors(
      baseColor: colors.surfaceMuted,
      highlightColor: colors.surface,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.78,
        ),
        itemCount: count,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: AppRadius.rL,
          ),
        ),
      ),
    );
  }
}
