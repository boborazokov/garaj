import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:shimmer/shimmer.dart';

/// Shared shimmer wrapper — calm 1.6s cycle, reduce-motion → static bones.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final base = colors.surfaceMuted;
    final highlight = colors.surface.withValues(alpha: 0.92);

    if (reduceMotion) {
      return child;
    }

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1600),
      child: child,
    );
  }
}

/// Single bone block used inside skeletons.
class SkeletonBone extends StatelessWidget {
  const SkeletonBone({
    super.key,
    this.width,
    this.height = 14,
    this.radius,
  });

  final double? width;
  final double height;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final decoration = BoxDecoration(
      color: colors.surfaceMuted,
      borderRadius: radius ?? AppRadius.rM,
    );

    if (width == null) {
      return Container(height: height, decoration: decoration);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: decoration,
      ),
    );
  }
}

/// 2-column product/listing grid skeleton (marketplace cards).
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({
    super.key,
    this.count = 6,
    this.padding = const EdgeInsets.fromLTRB(8, 8, 8, 24),
    this.shrinkWrap = false,
    this.physics,
  });

  final int count;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final crossAxisCount = isPortrait ? 2 : 4;

    double aspectRatio;
    if (screenWidth < 360) {
      aspectRatio = 0.50;
    } else if (screenWidth < 420) {
      aspectRatio = 0.52;
    } else if (screenWidth < 600) {
      aspectRatio = 0.54;
    } else {
      aspectRatio = 0.56;
    }

    return AppShimmer(
      child: GridView.builder(
        addAutomaticKeepAlives: false,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics ??
            (shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics()),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: aspectRatio,
        ),
        itemCount: count,
        itemBuilder: (_, __) => _ProductCardBone(color: colors.surfaceMuted),
      ),
    );
  }
}

class _ProductCardBone extends StatelessWidget {
  const _ProductCardBone({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.rL,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          margin: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.rXs,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          margin: const EdgeInsets.only(right: 48),
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.rXs,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          width: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.rXs,
          ),
        ),
      ],
    );
  }
}

/// Product / workshop / service detail: hero media + text blocks.
class DetailPageSkeleton extends StatelessWidget {
  const DetailPageSkeleton({
    super.key,
    this.heroHeight = 280,
  });

  final double heroHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: heroHeight, color: colors.surfaceMuted),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SkeletonBone(width: 220, height: 20),
                  const SizedBox(height: 10),
                  const SkeletonBone(width: 140, height: 16),
                  const SizedBox(height: 16),
                  const SkeletonBone(height: 12),
                  const SizedBox(height: 8),
                  const SkeletonBone(height: 12),
                  const SizedBox(height: 8),
                  const SkeletonBone(width: 180, height: 12),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: AppRadius.rM,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: AppRadius.rM,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const SkeletonBone(width: 160, height: 16),
                  const SizedBox(height: 12),
                  Container(
                    height: 88,
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: AppRadius.rL,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 88,
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: AppRadius.rL,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for order-detail style hero + text blocks.
class OrderDetailSkeleton extends StatelessWidget {
  const OrderDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailPageSkeleton(heroHeight: 200);
  }
}

/// Horizontal carousel strip (home featured / orders / workshops).
class HomeStripSkeleton extends StatelessWidget {
  const HomeStripSkeleton({
    super.key,
    this.itemWidth = 148,
    this.itemHeight = 180,
    this.count = 4,
  });

  final double itemWidth;
  final double itemHeight;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppShimmer(
      child: SizedBox(
        height: itemHeight,
        child: ListView.separated(
          addAutomaticKeepAlives: false,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => Container(
            width: itemWidth,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.rL,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chat / notification style list rows.
class ListTileSkeleton extends StatelessWidget {
  const ListTileSkeleton({
    super.key,
    this.count = 8,
    this.leadingSize = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final int count;
  final double leadingSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppShimmer(
      child: ListView.builder(
        addAutomaticKeepAlives: false,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: count,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: leadingSize,
                height: leadingSize,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: 140,
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: AppRadius.rXs,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 11,
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: AppRadius.rXs,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: AppRadius.rXs,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vertical card list (listings, workshops, seller matching).
class CardListSkeleton extends StatelessWidget {
  const CardListSkeleton({
    super.key,
    this.count = 5,
    this.cardHeight = 112,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
    this.shrinkWrap = false,
    this.physics,
  });

  final int count;
  final double cardHeight;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppShimmer(
      child: ListView.separated(
        addAutomaticKeepAlives: false,
        shrinkWrap: shrinkWrap,
        physics: physics ??
            (shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics()),
        padding: padding,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: AppRadius.rL,
          ),
        ),
      ),
    );
  }
}

/// Category grid skeleton.
class CategoryGridSkeleton extends StatelessWidget {
  const CategoryGridSkeleton({
    super.key,
    this.count = 12,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppShimmer(
      child: GridView.builder(
        addAutomaticKeepAlives: false,
        padding: const EdgeInsets.only(bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.88,
        ),
        itemCount: count,
        itemBuilder: (_, __) => Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: AppRadius.rL,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 11,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: AppRadius.rXs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile header + stats strip.
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: AppRadius.rL,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                4,
                (_) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: AppRadius.rM,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wallet balance card + transaction rows.
class WalletSkeleton extends StatelessWidget {
  const WalletSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.rL,
            ),
          ),
          const SizedBox(height: 16),
          const SkeletonBone(width: 140, height: 16),
          const SizedBox(height: 12),
          for (var i = 0; i < 5; i++) ...[
            Container(
              height: 64,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: AppRadius.rM,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Edit-profile / form page skeleton.
class FormPageSkeleton extends StatelessWidget {
  const FormPageSkeleton({super.key, this.fields = 5});

  final int fields;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < fields; i++) ...[
            const SkeletonBone(width: 100, height: 12),
            const SizedBox(height: 8),
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: AppRadius.rM,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.rM,
            ),
          ),
        ],
      ),
    );
  }
}
