import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/app_bar.dart';
import 'package:my_auto/widgets/searchInput/index.dart';

/// Shared shell for seller "my listings" screens (products, workshops).
///
/// Pass [body] for a single searchable list (no tabs).
/// Pass [activeBody]/[inactiveBody] to keep the legacy tab layout.
class MyListingsScaffold extends StatelessWidget {
  const MyListingsScaffold({
    super.key,
    required this.title,
    required this.searchController,
    required this.onSearch,
    this.body,
    this.belowSearch,
    this.searchHint,
    this.activeCount = 0,
    this.inactiveCount = 0,
    this.activeBody,
    this.inactiveBody,
    this.showSummary = true,
    this.isLoading = false,
    this.onRefresh,
    this.autofocusSearch = false,
  }) : assert(
          body != null || (activeBody != null && inactiveBody != null),
          'Provide either body or both activeBody and inactiveBody',
        );

  final String title;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final Widget? body;
  final Widget? belowSearch;
  final String? searchHint;
  final int activeCount;
  final int inactiveCount;
  final Widget? activeBody;
  final Widget? inactiveBody;
  final bool showSummary;
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final bool autofocusSearch;

  bool get _unified => body != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final total = activeCount + inactiveCount;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSummary)
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
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            showSummary ? 0 : AppSpacing.s,
            AppSpacing.screenPadding,
            AppSpacing.s,
          ),
          child: CustomSearchInput(
            controller: searchController,
            hintText: searchHint ?? s.search,
            onChanged: onSearch,
            autoFocus: autofocusSearch,
          ),
        ),
        if (belowSearch != null) belowSearch!,
        if (!_unified) ...[
          const SizedBox(height: AppSpacing.s),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: MarketUi.cardRadius,
                border: Border.all(color: colors.border),
              ),
              child: TabBar(
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                labelColor: colors.textPrimary,
                unselectedLabelColor: colors.textMuted,
                indicator: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: AppRadius.rM,
                  border: Border.all(color: colors.border),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.checkCircle2, size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${s.active} · $activeCount',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.archive, size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${s.inactive} · $inactiveCount',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.s),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : _unified
                  ? _wrapRefresh(body!)
                  : TabBarView(
                      children: [
                        _wrapRefresh(activeBody!),
                        _wrapRefresh(inactiveBody!),
                      ],
                    ),
        ),
      ],
    );

    final scaffold = Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(title: title),
      body: content,
    );

    if (_unified) return scaffold;
    return DefaultTabController(length: 2, child: scaffold);
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: MarketUi.productSection(context, colors),
      child: Row(
        children: [
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
                const SizedBox(height: 4),
                Text(
                  '$total',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  breakdown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          _StatPill(label: '$activeCount', tone: colors.success),
          const SizedBox(width: AppSpacing.s),
          _StatPill(label: '$inactiveCount', tone: colors.textMuted),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: AppRadius.rM,
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: tone,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
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

enum MyListingsStatusFilter { all, active, inactive }

/// Compact status chips for a single listings list (not tabs).
class MyListingsStatusFilters extends StatelessWidget {
  const MyListingsStatusFilters({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.allCount,
    required this.activeCount,
    required this.inactiveCount,
    this.allLabel,
  });

  final MyListingsStatusFilter selected;
  final ValueChanged<MyListingsStatusFilter> onSelected;
  final int allCount;
  final int activeCount;
  final int inactiveCount;
  final String? allLabel;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          AppSpacing.s,
        ),
        children: [
          _FilterChip(
            label: '${allLabel ?? s.seeAll} · $allCount',
            selected: selected == MyListingsStatusFilter.all,
            onTap: () => onSelected(MyListingsStatusFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '${s.active} · $activeCount',
            selected: selected == MyListingsStatusFilter.active,
            onTap: () => onSelected(MyListingsStatusFilter.active),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '${s.inactive} · $inactiveCount',
            selected: selected == MyListingsStatusFilter.inactive,
            onTap: () => onSelected(MyListingsStatusFilter.inactive),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.textPrimary : colors.surface,
      borderRadius: AppRadius.rXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rXl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rXl,
            border: Border.all(
              color: selected ? colors.textPrimary : colors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? colors.background : colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
