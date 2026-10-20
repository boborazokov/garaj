import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/card_date_region.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/widgets/favorite_heart_button.dart';

/// Image-first marketplace card for the home infinite feed.
class HomeProductCard extends StatelessWidget {
  const HomeProductCard({super.key, required this.product});

  final Part product;

  String _price(int price, String currency) {
    final raw = price.toString();
    final parts = <String>[];
    for (var i = raw.length; i > 0; i -= 3) {
      final start = i - 3 < 0 ? 0 : i - 3;
      parts.add(raw.substring(start, i));
    }
    return '${parts.reversed.join(' ')} $currency';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final img = product.images.isNotEmpty ? product.images.first : null;

    return Material(
      color: colors.surface,
      borderRadius: MarketUi.cardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.push(RoutesName.productDetailScreen, extra: product.id),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: MarketUi.cardRadius,
            boxShadow: MarketUi.softElev(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.02,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: colors.surfaceMuted,
                      child: img != null && img.isNotEmpty
                          ? ImageCacheNetwork(url: img, fit: BoxFit.cover)
                          : Icon(LucideIcons.imageOff,
                              size: 32, color: colors.textMuted),
                    ),
                    if (product.isPromoted)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colors.primary, colors.primaryHover],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.flame,
                                  size: 11, color: colors.onPrimary),
                              const SizedBox(width: 3),
                              Text(
                                S.of(context).promotedBadge,
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (product.condition == true)
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            S.of(context).newPart,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: FavoriteHeartButton(
                        partId: product.id,
                        onLightImage: true,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _price(product.price, product.currency),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                    if (product.negotiable == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        S.of(context).negotiable,
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CardDateRegion(
                      createdAt: product.createdAt,
                      region: product.region,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
