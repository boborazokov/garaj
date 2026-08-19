import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Horizontal premium cards for nearby services.
class ServicesNearStrip extends StatelessWidget {
  const ServicesNearStrip({
    super.key,
    required this.items,
    required this.loading,
  });

  final List<ServiceListing> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    if (!loading && items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketSectionTitle(
          title: s.services,
          trailingLabel: s.seeAll,
          onTrailing: () => context.push(RoutesName.servicesHub),
        ),
        SizedBox(
          height: 132,
          child: loading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: MarketUi.spacingMD),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => Container(
                    width: 210,
                    decoration: MarketUi.card(context, colors),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: MarketUi.spacingMD),
                  itemCount: items.length > 14 ? 14 : items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final e = items[i];
                    final img =
                        e.images.isNotEmpty ? e.images.first : null;
                    return SizedBox(
                      width: 210,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: MarketUi.cardRadius,
                          onTap: () => context.push(
                            '${RoutesName.serviceDetail}/${e.id}',
                          ),
                          child: Ink(
                            decoration: MarketUi.card(context, colors),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(20),
                                  ),
                                  child: SizedBox(
                                    width: 88,
                                    height: 132,
                                    child: img != null && img.isNotEmpty
                                        ? ImageCacheNetwork(
                                            url: img,
                                            fit: BoxFit.cover,
                                          )
                                        : ColoredBox(
                                            color: colors.surfaceMuted,
                                            child: Icon(
                                              LucideIcons.circleDot,
                                              color: colors.textMuted,
                                              size: 28,
                                            ),
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            height: 1.2,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                        if (e.categoryName.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            e.categoryName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: colors.textMuted,
                                            ),
                                          ),
                                        ],
                                        const Spacer(),
                                        Row(
                                          children: [
                                            Icon(
                                              LucideIcons.star,
                                              size: 14,
                                              color: colors.warning,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              e.rating.toStringAsFixed(1),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                            if (e.isEmergency) ...[
                                              const Spacer(),
                                              Icon(
                                                LucideIcons.siren,
                                                size: 16,
                                                color: colors.danger,
                                              ),
                                            ],
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
                  },
                ),
        ),
      ],
    );
  }
}
