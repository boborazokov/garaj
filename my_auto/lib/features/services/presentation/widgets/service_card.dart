import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/utils/place_label.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Service row card — title, street address, rating.
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

    return MarketCardShell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 108,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: colors.surfaceMuted,
                    child: image != null
                        ? ImageCacheNetwork(
                            url: image,
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
                      left: 8,
                      top: 8,
                      child: MarketBadgeChip(
                        label: s.promotedBadge,
                        emphasized: true,
                        dense: true,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                              fontWeight: FontWeight.w600,
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
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
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textMuted,
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
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
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
    );
  }
}
