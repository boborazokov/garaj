import 'package:flutter/material.dart';
import 'package:my_auto/core/presentation/shimmer_skeletons.dart';

class OrderShimmerList extends StatelessWidget {
  const OrderShimmerList({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ProductGridSkeleton(
      count: count,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
    );
  }
}
