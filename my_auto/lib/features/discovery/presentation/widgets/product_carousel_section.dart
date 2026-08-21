import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/home/widgets/sectionHeader/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/productCard/index.dart';

class ProductCarouselSection extends StatelessWidget {
  const ProductCarouselSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.products,
    this.isLoading = false,
    this.onSeeAll,
    this.compact = false,
  });

  final String title;
  /// When null or empty in compact mode, subtitle row is omitted.
  final String? subtitle;
  final IconData icon;
  final List<Part> products;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  /// Tighter carousel for home feed density.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && products.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.appColors;
    final frac = compact ? 0.42 : 0.45;
    final width = MediaQuery.sizeOf(context).width * frac;
    final rowHeight = compact ? 246.0 : 280.0;
    final useSubtitle =
        subtitle != null && subtitle!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compact)
          MarketSectionTitle(
            title: title,
            leading: Icon(icon, size: 20, color: colors.primary),
            trailingLabel:
                onSeeAll != null ? S.of(context).seeAll : null,
            onTrailing: onSeeAll,
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SectionHeader(
              title: title,
              subtitle: useSubtitle ? subtitle : null,
              icon: icon,
              onSeeAll: onSeeAll,
            ),
          ),
        SizedBox(
          height: rowHeight,
          child: isLoading
              ? _ShimmerRow(colors: colors, itemWidth: width)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        compact ? MarketUi.spacingMD : 16,
                  ),
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: compact ? 12 : 12),
                  itemBuilder: (_, index) {
                    return SizedBox(
                      width: width,
                      child: ProductCardGrid(
                        product: products[index],
                        key: ValueKey('carousel-${products[index].id}'),
                      ),
                    );
                  },
                ),
        ),
        SizedBox(height: compact ? 4 : 8),
      ],
    );
  }
}

class _ShimmerRow extends StatefulWidget {
  const _ShimmerRow({required this.colors, required this.itemWidth});

  final AppColors colors;
  final double itemWidth;

  @override
  State<_ShimmerRow> createState() => _ShimmerRowState();
}

class _ShimmerRowState extends State<_ShimmerRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) {
            return Container(
              width: widget.itemWidth,
              decoration: BoxDecoration(
                borderRadius: AppRadius.rL,
                gradient: LinearGradient(
                  begin: Alignment(-1 + _controller.value * 2, 0),
                  end: Alignment(1 + _controller.value * 2, 0),
                  colors: [
                    widget.colors.surfaceMuted,
                    widget.colors.surface,
                    widget.colors.surfaceMuted,
                  ],
                ),
              ),
              child: const Center(
                child: Icon(LucideIcons.image, size: 32),
              ),
            );
          },
        );
      },
    );
  }
}
