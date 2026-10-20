import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/card_date_region.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Horizontal carousel of promoted (TOP) listings — price-first, light chrome.
class FeaturedCarousel extends StatelessWidget {
  final List<Part> items;
  const FeaturedCarousel({super.key, required this.items});

  String _formatPrice(int price, String currency) {
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
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = context.appColors;
    final theme = Theme.of(context);

    return SizedBox(
      height: 214,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final p = items[i];
          final image = p.images.isNotEmpty ? p.images.first : null;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.rL,
              boxShadow: MarketUi.softElev(context),
            ),
            child: SizedBox(
              width: 200,
              child: Material(
                color: colors.surface,
                borderRadius: AppRadius.rL,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push(
                    RoutesName.productDetailScreen,
                    extra: p.id,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(
                              color: colors.surfaceMuted,
                              child: image != null && image.isNotEmpty
                                  ? ImageCacheNetwork(
                                      url: image,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      LucideIcons.imageOff,
                                      size: 32,
                                      color: colors.textMuted,
                                    ),
                            ),
                            Positioned(
                              left: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.flame,
                                      size: 11,
                                      color: colors.onPrimary,
                                    ),
                                    const SizedBox(width: 4),
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
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatPrice(p.price, p.currency),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                                letterSpacing: -0.2,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            CardDateRegion(
                              createdAt: p.createdAt,
                              region: p.region,
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
    );
  }
}
