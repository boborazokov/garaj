import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/utils/category_locale.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

class WorkshopProfileCard extends StatelessWidget {
  const WorkshopProfileCard({
    super.key,
    required this.workshop,
    this.compact = false,
  });

  final WorkshopProfile workshop;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final image = workshop.heroImage;

    return MarketCardShell(
      onTap: () => context.push(
        '${RoutesName.workshopDetailScreen}/${workshop.id}',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: compact ? 1.6 : 1.35,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: colors.surfaceMuted,
                  child: image.isNotEmpty
                      ? ImageCacheNetwork(url: image)
                      : Icon(
                          LucideIcons.wrench,
                          size: 40,
                          color: colors.textMuted,
                        ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: MarketBadgeChip(
                    label: workshop.isOpenNow
                        ? s.workshopOpenNow
                        : s.workshopStatusClosed,
                    dense: true,
                  ),
                ),
                if (workshop.verified)
                  const Positioned(
                    right: 10,
                    top: 10,
                    child: _VerifiedBadge(),
                  ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Text(
                    workshop.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.star,
                      size: 14,
                      color: colors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      workshop.rating > 0
                          ? workshop.rating.toStringAsFixed(1)
                          : 'New',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' · ${workshop.reviewCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    if (workshop.fastResponse)
                      Icon(
                        LucideIcons.zap,
                        size: 14,
                        color: colors.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  workshop.displayAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (workshop.categories.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: workshop.categories
                        .take(3)
                        .map(
                          (c) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.rS,
                            ),
                            child: Text(
                              c.localizedName(
                                categoryLanguageCode(context),
                              ),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.badgeCheck, size: 14, color: colors.primary),
          const SizedBox(width: 4),
          Text(
            S.of(context).workshopVerified,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
