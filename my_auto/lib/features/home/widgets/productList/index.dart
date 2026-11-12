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

    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final crossAxisCount = isPortrait ? 2 : 4;
    final screenWidth = size.width;

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

    final rowCount = (products.length / crossAxisCount).ceil();

    return ListView.builder(
      itemCount: rowCount,
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      controller: controller,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      itemBuilder: (context, rowIndex) {
        final start = rowIndex * crossAxisCount;
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
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * 8) /
                        crossAxisCount;
                final tileHeight = tileWidth / aspectRatio;
                return SizedBox(
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
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
