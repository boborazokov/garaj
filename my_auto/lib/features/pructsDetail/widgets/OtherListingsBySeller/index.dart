import 'package:flutter/material.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/productCard/index.dart';

class OtherListingsBySeller extends StatelessWidget {
  final List products;
  final ScrollController scrollController;
  final bool hasMore;
  final bool isMoreLoading;
  final double itemWidth;

  const OtherListingsBySeller({
    super.key,
    required this.products,
    required this.scrollController,
    required this.hasMore,
    required this.isMoreLoading,
    required this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (products.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context).moreFromSeller,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length + (hasMore ? 1 : 0),
            itemBuilder: (_, index) {
              if (index == products.length) {
                return SizedBox(
                  width: itemWidth,
                  child: Center(
                    child: isMoreLoading
                        ? CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              }
              return SizedBox(
                width: itemWidth,
                height: 268,
                child: ProductCardGrid(
                  product: products[index],
                  key: ValueKey(products[index].id),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}
