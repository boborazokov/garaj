import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Horizontal list-row product card for seller store list mode.
class SellerProductListTile extends StatelessWidget {
  final Part product;

  const SellerProductListTile({super.key, required this.product});

  String _price(int price, String currency) {
    final formatter = NumberFormat('#,###', 'ru');
    return '${formatter.format(price).replaceAll(',', ' ')} $currency';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    final category = product.category?.name ?? '—';
    final seller = product.seller?.name ?? '—';

    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rM,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.push(RoutesName.productDetailScreen, extra: product.id),
        child: Ink(
          height: 132,
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: AppRadius.rM,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 132,
                  height: 132,
                  child: imageUrl != null
                      ? ImageCacheNetwork(url: imageUrl, height: 132, width: 132)
                      : ColoredBox(
                          color: colors.surfaceMuted,
                          child: Icon(LucideIcons.imageOff,
                              color: colors.textMuted),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              seller,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            _price(product.price, product.currency),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.location.isNotEmpty
                            ? product.location
                            : s.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
