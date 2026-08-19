import 'package:flutter/material.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/productCard/index.dart';

class RelatedProductsSection extends StatelessWidget {
  final List relatedProducts;
  final double itemWidth;

  const RelatedProductsSection({
    super.key,
    required this.relatedProducts,
    required this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedProducts.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          child: Text(
            S.of(context).relatedProducts,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.separated(
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: relatedProducts.length,
            itemBuilder: (_, index) {
              final product = relatedProducts[index];
              return SizedBox(
                width: itemWidth,
                height: 268,
                child: ProductCardGrid(
                  product: product,
                  key: ValueKey('related-${product.id}'),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }
}
