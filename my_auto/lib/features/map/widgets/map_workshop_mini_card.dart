import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/map/domain/map_open_status.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';

class MapWorkshopMiniCard extends StatelessWidget {
  const MapWorkshopMiniCard({
    super.key,
    required this.pin,
    required this.colors,
    this.workshop,
    required this.onTap,
    this.highlight = false,
  });

  final MapPin pin;
  final AppColors colors;
  final WorkshopProfile? workshop;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final open = workshop != null
        ? workshopOpenStatusLine(workshop!)
        : (pin.isOpenNow ? 'Open now' : 'Closed');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.rL,
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rL,
            gradient: LinearGradient(
              colors: highlight
                  ? [
                      colors.primary.withValues(alpha: 0.2),
                      colors.primary.withValues(alpha: 0.08),
                    ]
                  : [colors.surface, colors.surface],
            ),
            border: Border.all(
              color: highlight
                  ? colors.primary.withValues(alpha: 0.55)
                  : colors.border.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: pin.coverImage != null && pin.coverImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: pin.coverImage!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Icon(LucideIcons.building2, color: colors.textMuted),
                        )
                      : ColoredBox(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                          child: Icon(
                            LucideIcons.building2,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pin.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      open,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: pin.isOpenNow || workshop?.open24Hours == true
                            ? colors.success
                            : colors.textMuted,
                      ),
                    ),
                    if (pin.rating > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(LucideIcons.star, size: 12, color: colors.warning),
                          const SizedBox(width: 4),
                          Text(
                            pin.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: colors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
