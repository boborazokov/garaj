import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Edge-to-feeling trending row with snap paging and image-first premium cards.
class TrendingProductStrip extends StatefulWidget {
  const TrendingProductStrip({
    super.key,
    required this.products,
    required this.loading,
    this.viewportFraction = 0.76,
    this.paddingBottom = MarketUi.spacingMD,
  });

  final List<Part> products;
  final bool loading;
  final double viewportFraction;
  final double paddingBottom;

  static String formatPrice(int price, String currency) {
    final raw = price.toString();
    final parts = <String>[];
    for (var i = raw.length; i > 0; i -= 3) {
      final start = i - 3 < 0 ? 0 : i - 3;
      parts.add(raw.substring(start, i));
    }
    return '${parts.reversed.join(' ')} $currency';
  }

  @override
  State<TrendingProductStrip> createState() => _TrendingProductStripState();
}

class _TrendingProductStripState extends State<TrendingProductStrip> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    if (!widget.loading && widget.products.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.loading) {
      return Padding(
        padding: EdgeInsets.only(bottom: widget.paddingBottom),
        child: SizedBox(
          height: 246,
          child: TrendingSkeleton(colors: colors),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: widget.paddingBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarketSectionTitle(
            leading: Icon(
              LucideIcons.flame,
              color: colors.primary,
              size: 22,
            ),
            title: s.trendingNow,
          ),
          SizedBox(
            height: 248,
            child: PageView.builder(
              controller: _pageController,
              padEnds: false,
              physics: const PageScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: widget.products.length,
              itemBuilder: (_, i) {
                final p = widget.products[i];
                final img = p.images.isNotEmpty ? p.images.first : null;
                return Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: MarketUi.cardRadius,
                      onTap: () => context.push(
                        RoutesName.productDetailScreen,
                        extra: p.id,
                      ),
                      child: Ink(
                        decoration: MarketUi.card(context, colors),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (img != null && img.isNotEmpty)
                                    ImageCacheNetwork(
                                        url: img, fit: BoxFit.cover)
                                  else
                                    ColoredBox(
                                      color: colors.surfaceMuted,
                                      child: Icon(
                                        LucideIcons.package,
                                        size: 40,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black
                                              .withValues(alpha: 0.02),
                                          Colors.black
                                              .withValues(alpha: .45),
                                        ],
                                        stops: const [0.55, 1],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 12,
                                    top: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            colors.primary,
                                            colors.primaryHover,
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(LucideIcons.flame,
                                              size: 14,
                                              color: colors.onPrimary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Hot',
                                            style: TextStyle(
                                              color: colors.onPrimary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  14, 10, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    TrendingProductStrip.formatPrice(
                                        p.price, p.currency),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: colors.primary,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                      color: colors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle shimmer-style placeholder while trending loads.
class TrendingSkeleton extends StatefulWidget {
  const TrendingSkeleton({super.key, required this.colors});
  final AppColors colors;

  @override
  State<TrendingSkeleton> createState() => _TrendingSkeletonState();
}

class _TrendingSkeletonState extends State<TrendingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final PageController _placeController;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _placeController = PageController(viewportFraction: 0.76);
  }

  @override
  void dispose() {
    _c.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return PageView.builder(
          controller: _placeController,
          itemCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          padEnds: false,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: ClipRRect(
              borderRadius: MarketUi.cardRadius,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + _c.value * 2, 0),
                    end: Alignment(1 + _c.value * 2, 0),
                    colors: [
                      widget.colors.surfaceMuted,
                      widget.colors.surfaceElevated.withValues(alpha: .6),
                      widget.colors.surfaceMuted,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
