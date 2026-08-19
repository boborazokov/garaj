import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';

/// Compact header for the public requests feed: title, search, create CTA.
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  LucideIcons.clipboardList,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.searchHubSectionOrders,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.createRequestSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (activeCount != null && activeCount! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.12),
                    borderRadius: AppRadius.rM,
                    border: Border.all(
                      color: colors.success.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '$activeCount',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: s.search,
              prefixIcon: Icon(
                LucideIcons.search,
                size: 20,
                color: colors.textMuted,
              ),
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.rXl,
                borderSide: BorderSide(color: colors.border.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.rXl,
                borderSide: BorderSide(color: colors.border.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.rXl,
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(LucideIcons.plus, size: 20),
            label: Text(s.createRequest),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rXl),
            ),
          ),
        ],
      ),
    );
  }
}
