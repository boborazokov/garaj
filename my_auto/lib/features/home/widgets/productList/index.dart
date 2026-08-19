import 'package:flutter/material.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';
import 'package:my_auto/features/profile/widgets/my_product_card/index.dart';
import 'package:my_auto/widgets/productCard/index.dart';

class ProductGrid extends StatelessWidget {
  final List<Part> products;
  final ScrollController? controller;
  final bool isMine;
  final bool isDepleted;
  final ScrollPhysics? physics;
  final AdSurface? inlineAdSurface;
  final int inlineAdEveryRows;

  const ProductGrid({
    super.key,
    required this.products,
    this.controller,
    this.isDepleted = false,
    this.isMine = false,
    this.physics,
    this.inlineAdSurface,
    this.inlineAdEveryRows = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (isMine) {
      return ListView.builder(
        controller: controller,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return MyProductCard(
            product: product,
            isMine: isMine,
            isDepleted: isDepleted,
          );
        },
      );
    }

    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final crossAxisCount = isPortrait ? 2 : 4;
    final screenWidth = size.width;

    double aspectRatio;
    if (screenWidth < 360) {
      aspectRatio = 0.62;
    } else if (screenWidth < 420) {
      aspectRatio = 0.66;
    } else if (screenWidth < 600) {
      aspectRatio = 0.70;
    } else {
      aspectRatio = 0.74;
    }

    if (inlineAdSurface == null) {
      return GridView.builder(
        itemCount: products.length,
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        controller: controller,
        physics: physics ?? const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio,
        ),
        itemBuilder: (context, index) {
          return ProductCardGrid(
            product: products[index],
            key: ValueKey(products[index].id),
          );
        },
      );
    }

    final productRows = (products.length + crossAxisCount - 1) ~/ crossAxisCount;
    final blockSize = inlineAdEveryRows + 1;
    final virtualRows = productRows == 0
        ? 0
        : productRows + (productRows - 1) ~/ inlineAdEveryRows;

    return ListView.builder(
      controller: controller,
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      physics: physics ?? const NeverScrollableScrollPhysics(),
      itemCount: virtualRows,
      itemBuilder: (context, virtualRow) {
        final isAd = (virtualRow + 1) % blockSize == 0;
        if (isAd) {
          return AdBanner(
            surface: inlineAdSurface!,
            height: 110,
            margin: const EdgeInsets.fromLTRB(0, 4, 0, 12),
          );
        }

        final blockIndex = virtualRow ~/ blockSize;
        final posInBlock = virtualRow % blockSize;
        final productRow = blockIndex * inlineAdEveryRows + posInBlock;
        final start = productRow * crossAxisCount;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var col = 0; col < crossAxisCount; col++)
                if (start + col < products.length)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: col == 0 ? 0 : 5,
                        right: col == crossAxisCount - 1 ? 0 : 5,
                      ),
                      child: AspectRatio(
                        aspectRatio: aspectRatio,
                        child: ProductCardGrid(
                          product: products[start + col],
                          key: ValueKey(products[start + col].id),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
