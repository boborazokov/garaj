import 'package:flutter/material.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_list_slot.dart';
import 'package:my_auto/features/profile/widgets/my_product_card/index.dart';
import 'package:my_auto/widgets/productCard/index.dart';

class ProductGrid extends StatelessWidget {
  final List<Part> products;
  final ScrollController? controller;
  final bool isMine;
  final bool isDepleted;
  final ScrollPhysics? physics;

  const ProductGrid({
    super.key,
    required this.products,
    this.controller,
    this.isDepleted = false,
    this.isMine = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (isMine) {
      return ListView.builder(
        controller: controller,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        itemCount: products.length,
        addAutomaticKeepAlives: false,
        itemBuilder: (context, index) {
          final product = products[index];
          final depleted = isDepleted || product.status.isInactive;
          return MyProductCard(
            product: product,
            isMine: isMine,
            isDepleted: depleted,
          );
        },
      );
    }

    final metrics = _ProductGridMetrics.of(context);
    final rowCount = (products.length / metrics.crossAxisCount).ceil();
    final effectivePhysics =
        physics ?? const NeverScrollableScrollPhysics();
    // Nested in another scroll view → shrinkWrap. Primary scroller → lazy.
    final nested = effectivePhysics is NeverScrollableScrollPhysics;

    return ListView.builder(
      itemCount: rowCount,
      shrinkWrap: nested,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      controller: controller,
      physics: effectivePhysics,
      addAutomaticKeepAlives: false,
      itemBuilder: (context, rowIndex) {
        return _ProductGridRow(
          products: products,
          rowIndex: rowIndex,
          metrics: metrics,
          contentWidth: metrics.contentWidth,
        );
      },
    );
  }
}

/// Lazy product rows for [CustomScrollView] — only builds visible tiles.
class ProductSliverGrid extends StatelessWidget {
  const ProductSliverGrid({
    super.key,
    required this.products,
    this.padding = const EdgeInsets.fromLTRB(8, 0, 8, 8),
  });

  final List<Part> products;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final metrics = _ProductGridMetrics.of(context);
    final rowCount = (products.length / metrics.crossAxisCount).ceil();
    final pad = padding.resolve(Directionality.of(context));
    final contentWidth =
        metrics.screenWidth - pad.left - pad.right;

    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, rowIndex) {
            return _ProductGridRow(
              products: products,
              rowIndex: rowIndex,
              metrics: metrics,
              contentWidth: contentWidth,
            );
          },
          childCount: rowCount,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
        ),
      ),
    );
  }
}

class _ProductGridMetrics {
  const _ProductGridMetrics({
    required this.crossAxisCount,
    required this.aspectRatio,
    required this.screenWidth,
    required this.contentWidth,
  });

  final int crossAxisCount;
  final double aspectRatio;
  final double screenWidth;
  final double contentWidth;

  static _ProductGridMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final crossAxisCount = isPortrait ? 2 : 4;
    final screenWidth = size.width;

    final double aspectRatio;
    if (screenWidth < 360) {
      aspectRatio = 0.50;
    } else if (screenWidth < 420) {
      aspectRatio = 0.52;
    } else if (screenWidth < 600) {
      aspectRatio = 0.54;
    } else {
      aspectRatio = 0.56;
    }

    // Default grid horizontal padding (8+8) when used without SliverPadding.
    const defaultPad = 16.0;
    return _ProductGridMetrics(
      crossAxisCount: crossAxisCount,
      aspectRatio: aspectRatio,
      screenWidth: screenWidth,
      contentWidth: screenWidth - defaultPad,
    );
  }
}

class _ProductGridRow extends StatelessWidget {
  const _ProductGridRow({
    required this.products,
    required this.rowIndex,
    required this.metrics,
    required this.contentWidth,
  });

  final List<Part> products;
  final int rowIndex;
  final _ProductGridMetrics metrics;
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = metrics.crossAxisCount;
    final start = rowIndex * crossAxisCount;
    final tileWidth =
        (contentWidth - (crossAxisCount - 1) * 8) / crossAxisCount;
    final tileHeight = tileWidth / metrics.aspectRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdListSlot(
          listIndex: start,
          surface: AdSurface.part,
          interval: 6,
          height: 110,
          margin: const EdgeInsets.fromLTRB(0, 4, 0, 12),
        ),
        SizedBox(
          height: tileHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < crossAxisCount; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: start + i < products.length
                      ? ProductCardGrid(
                          product: products[start + i],
                          key: ValueKey(products[start + i].id),
                          expandImage: true,
                          imageCacheWidth: tileWidth,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
