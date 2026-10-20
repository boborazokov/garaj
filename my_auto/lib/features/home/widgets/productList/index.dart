import 'package:flutter/material.dart';
import 'package:my_auto/core/model/product/index.dart';
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
      aspectRatio = 0.50;
    } else if (screenWidth < 420) {
      aspectRatio = 0.52;
    } else if (screenWidth < 600) {
      aspectRatio = 0.54;
    } else {
      aspectRatio = 0.56;
    }

    return GridView.builder(
        itemCount: products.length,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        controller: controller,
        physics: physics ?? const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
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
}
