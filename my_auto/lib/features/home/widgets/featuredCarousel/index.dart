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

/// Horizontal carousel of promoted (TOP) listings used at the top of the
/// home feed. Items are bigger and visually distinct from the regular grid.
class FeaturedCarousel extends StatelessWidget {
  final List<Part> items;
  const FeaturedCarousel({super.key, required this.items});

  String _formatPrice(int price, String currency) {
    final formatter = NumberFormat('#,###', 'ru');
    final normalized = formatter.format(price).replaceAll(',', ' ');
    return '$normalized $currency';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final colors = context.appColors;

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final p = items[i];
          final image = p.images.isNotEmpty ? p.images.first : null;
          return SizedBox(
            width: 240,
            child: Material(
              color: colors.surface,
              borderRadius: AppRadius.rL,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context
                    .push(RoutesName.productDetailScreen, extra: p.id),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.rL,
                    border: Border.all(
                      color: colors.primary.withOpacity(0.5),
                      width: 1.4,
                    ),
                    boxShadow: AppShadows.glow(colors.primary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.4,
                            child: Container(
                              color: colors.surfaceMuted,
                              child: image != null && image.isNotEmpty
                                  ? ImageCacheNetwork(url: image)
                                  : Icon(LucideIcons.imageOff,
                                      size: 36, color: colors.textMuted),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colors.primary,
                                    colors.primaryHover
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.flame,
                                      size: 12, color: colors.onPrimary),
                                  const SizedBox(width: 4),
                                  Text(
                                    S.of(context).promotedBadge,
                                    style: TextStyle(
                                      color: colors.onPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatPrice(p.price, p.currency),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
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
