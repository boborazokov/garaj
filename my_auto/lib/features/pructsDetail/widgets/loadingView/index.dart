import 'package:flutter/material.dart';
import 'package:my_auto/core/presentation/shimmer_skeletons.dart';
import 'package:my_auto/core/theme/colors/index.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: const DetailPageSkeleton(),
    );
  }
}
