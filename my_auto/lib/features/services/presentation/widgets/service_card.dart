import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/generated/l10n.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.onTap});

  final ServiceListing service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final image = service.images.isNotEmpty ? service.images.first : null;

    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rXl,
      child: InkWell(
        borderRadius: AppRadius.rXl,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.rXl,
            border: Border.all(color: colors.border.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: image != null
                      ? CachedNetworkImage(imageUrl: image, fit: BoxFit.cover)
                      : ColoredBox(
                          color: colors.primary.withValues(alpha: 0.12),
                          child: Icon(LucideIcons.wrench, color: colors.primary),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (service.isPromotionActive)
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                S.of(context).promotedBadge,
                                style: TextStyle(
                                  color: colors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          if (service.verified)
                            Icon(LucideIcons.badgeCheck,
                                size: 18, color: colors.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.categoryName,
                        style: TextStyle(color: colors.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(LucideIcons.star,
                              size: 14, color: colors.warning),
                          Text(
                            ' ${service.rating.toStringAsFixed(1)} (${service.reviewCount})',
                            style: const TextStyle(fontSize: 12),
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
    );
  }
}
