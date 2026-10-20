import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/place_label.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/generated/l10n.dart';

/// Clear service row card — title, street address, rating.
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.onTap});

  final ServiceListing service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final image = service.images.isNotEmpty ? service.images.first : null;
    final place = humanPlaceLabel(
      address: service.address,
      fallback: service.categoryName.isNotEmpty ? service.categoryName : '—',
    );
    final rating =
        '${service.rating.toStringAsFixed(1)} · ${service.reviewCount}';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.rL,
        boxShadow: MarketUi.softElev(context),
      ),
      child: Material(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 104,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: colors.surfaceMuted,
                        child: image != null
                            ? CachedNetworkImage(
                                imageUrl: image,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                LucideIcons.wrench,
                                color: colors.textMuted,
                                size: 28,
                              ),
                      ),
                      if (service.isPromotionActive)
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.promotedBadge,
                              style: TextStyle(
                                color: colors.onPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  height: 1.25,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            if (service.verified) ...[
                              const SizedBox(width: 6),
                              Icon(
                                LucideIcons.badgeCheck,
                                size: 18,
                                color: colors.primary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          place,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (service.categoryName.isNotEmpty &&
                            place != service.categoryName) ...[
                          const SizedBox(height: 2),
                          Text(
                            service.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.star,
                              size: 14,
                              color: colors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
