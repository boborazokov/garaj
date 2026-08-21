import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';

/// Single compact row — map preview without large hero card.
class CompactMapRow extends StatelessWidget {
  const CompactMapRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MarketUi.spacingMD,
        MarketUi.spacingMD,
        MarketUi.spacingMD,
        MarketUi.spacingXL,
      ),
      child: Material(
        color: colors.surface,
        borderRadius: MarketUi.cardRadius,
        elevation: 0,
        shadowColor: Colors.transparent,
        child: InkWell(
          borderRadius: MarketUi.cardRadius,
          onTap: () => context.push(RoutesName.nearbyMap),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: MarketUi.cardRadius,
              gradient: LinearGradient(
                colors: [
                  colors.primary.withValues(alpha: 0.1),
                  colors.surfaceMuted.withValues(alpha: 0.4),
                ],
              ),
              boxShadow: MarketUi.softElev(context),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      Icon(LucideIcons.mapPin, color: colors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.nearYou,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.searchHubOpenMap,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight,
                    color: colors.textMuted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
