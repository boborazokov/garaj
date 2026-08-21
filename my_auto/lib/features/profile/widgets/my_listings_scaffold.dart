import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/app_bar.dart';
import 'package:my_auto/widgets/searchInput/index.dart';

/// Shared shell for seller "my listings" screens (products, workshops).
class MyListingsScaffold extends StatelessWidget {
  const MyListingsScaffold({
    super.key,
    required this.title,
    required this.activeCount,
    required this.inactiveCount,
    required this.searchController,
    required this.onSearch,
    required this.activeBody,
    required this.inactiveBody,
    this.isLoading = false,
    this.onRefresh,
  });

  final String title;
  final int activeCount;
  final int inactiveCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final Widget activeBody;
  final Widget inactiveBody;
  final bool isLoading;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final total = activeCount + inactiveCount;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppTopBar(title: title),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.s,
                AppSpacing.screenPadding,
                AppSpacing.m,
              ),
              child: _SummaryBanner(
                total: total,
                activeCount: activeCount,
                inactiveCount: inactiveCount,
                totalLabel: s.myListingsTotalLabel,
                breakdown: s.myListingsBreakdown(
                  s.active,
                  activeCount,
                  s.inactive,
                  inactiveCount,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: CustomSearchInput(
                controller: searchController,
                hintText: s.search,
                onChanged: onSearch,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: AppRadius.rL,
                  border: Border.all(color: colors.border),
                ),
                child: TabBar(
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  labelColor: colors.onPrimary,
                  unselectedLabelColor: colors.textMuted,
                  indicator: BoxDecoration(
                    color: colors.primary,
                    borderRadius: AppRadius.rM,
                    boxShadow: AppShadows.glow(colors.primary),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.checkCircle2, size: 14),
                          const SizedBox(width: 6),
                          Text(s.active),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.archive, size: 14),
                          const SizedBox(width: 6),
                          Text(s.inactive),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : TabBarView(
                      children: [
                        _wrapRefresh(activeBody),
                        _wrapRefresh(inactiveBody),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wrapRefresh(Widget child) {
    if (onRefresh == null) return child;
    return RefreshIndicator(onRefresh: onRefresh!, child: child);
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.total,
    required this.activeCount,
    required this.inactiveCount,
    required this.totalLabel,
    required this.breakdown,
  });

  final int total;
  final int activeCount;
  final int inactiveCount;
  final String totalLabel;
  final String breakdown;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.14),
            colors.surface,
          ],
        ),
        borderRadius: AppRadius.rL,
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.18),
              borderRadius: AppRadius.rM,
            ),
            child: Icon(
              LucideIcons.layers,
              color: colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$total',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  breakdown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyListingsEmptyState extends StatelessWidget {
  const MyListingsEmptyState({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.14),
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              icon ?? LucideIcons.inbox,
              size: 36,
              color: colors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.textSecondary,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
