import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';

/// Buy-request hub header: title, subtitle, CTA, search.
class OrdersMarketplaceHeader extends StatelessWidget {
  const OrdersMarketplaceHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onCreate,
    this.activeCount,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCreate;
  final int? activeCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.navWantToBuy,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.wantToBuySubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rXl),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.plus, size: 20),
                const SizedBox(width: 8),
                Text(
                  s.wantToBuyCreateCta,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ListenableBuilder(
            listenable: searchController,
            builder: (context, _) {
              final hasQuery = searchController.text.trim().isNotEmpty;
              return TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.search,
                onSubmitted: onSearchChanged,
                decoration: InputDecoration(
                  hintText: s.wantToBuySearchHint,
                  hintStyle: TextStyle(
                    color: colors.textMuted,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    LucideIcons.search,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                  suffixIcon: hasQuery
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                          icon: Icon(
                            LucideIcons.x,
                            size: 18,
                            color: colors.textMuted,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.rXl,
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.rXl,
                    borderSide: BorderSide(
                      color: colors.border,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.rXl,
                    borderSide: BorderSide(color: colors.primary, width: 1.8),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  s.wantToBuyFeedTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (activeCount != null && activeCount! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    s.wantToBuyRequestsCount(activeCount!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
