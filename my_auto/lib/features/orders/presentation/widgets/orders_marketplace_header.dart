import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/searchInput/index.dart';

/// Buy-request hub header: title, search, filters, create CTA.
class OrdersMarketplaceHeader extends StatelessWidget {
  const OrdersMarketplaceHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onCreate,
    this.activeCount,
    this.filters,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCreate;
  final int? activeCount;
  final Widget? filters;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MarketUi.spacingMD,
        AppSpacing.s,
        MarketUi.spacingMD,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  s.navWantToBuy,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    height: 1.1,
                  ),
                ),
              ),
              if (activeCount != null && activeCount! > 0)
                Text(
                  s.wantToBuyRequestsCount(activeCount!),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            s.wantToBuySubtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          CustomSearchInput(
            controller: searchController,
            hintText: s.wantToBuySearchHint,
            onChanged: onSearchChanged,
            onSubmitted: onSearchChanged,
          ),
          if (filters != null) ...[
            const SizedBox(height: AppSpacing.m),
            filters!,
          ],
          const SizedBox(height: AppSpacing.m),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(
              s.wantToBuyCreateCta,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
            ),
          ),
        ],
      ),
    );
  }
}
