import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/provider/add/getCotegories.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/home/presentation/widgets/category_strip.dart';
import 'package:my_auto/features/orders/domain/entities/order.dart';
import 'package:my_auto/features/search/data/search_history_storage.dart';
import 'package:my_auto/features/search/data/unified_search_repository.dart';
import 'package:my_auto/features/search/domain/unified_search_snapshot.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/productCard/index.dart';
import 'package:provider/provider.dart';

/// Unified discovery search that queries products, workshops, services map hits,
/// orders, and seller facets in one coordinated flow without duplicating
/// catalog pagination logic elsewhere.
class GlobalSearchHubScreen extends StatefulWidget {
  const GlobalSearchHubScreen({super.key, this.initialQuery});

  /// Optional prefilled topic (from home trending chips etc.).
  final String? initialQuery;

  @override
  State<GlobalSearchHubScreen> createState() => _GlobalSearchHubScreenState();
}

class _GlobalSearchHubScreenState extends State<GlobalSearchHubScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  int _generation = 0;

  UnifiedSearchSnapshot? _snapshot;
  bool _busy = false;
  List<String> _recent = const [];

  List<String> _trendingQueries(S s) => [
        s.trendingTires,
        s.trendingDiagnostics,
        s.trendingEngineOil,
        s.trendingTowTruck,
        s.trendingDetailing,
        s.trendingAkp,
        s.trendingBattery,
        s.trendingBrakes,
      ];

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusHighlight);
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _controller.text = widget.initialQuery!.trim();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scheduleSearch(immediate: true));
    }
    _loadRecent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cat = context.read<GetCategories>();
      if (cat.categories.isEmpty && !cat.isLoading) {
        cat.loadCategories(type.PART.name);
      }
      _focus.requestFocus();
    });
  }

  Future<void> _loadRecent() async {
    final r = await SearchHistoryStorage.load();
    if (!mounted) return;
    setState(() => _recent = r);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusHighlight);
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scheduleSearch({bool immediate = false}) {
    _debounce?.cancel();
    void run() {
      final gen = ++_generation;
      final raw = _controller.text.trim();
      if (raw.isEmpty) {
        setState(() {
          _snapshot = null;
          _busy = false;
        });
        return;
      }
      setState(() => _busy = true);
      unawaited(SearchHistoryStorage.remember(raw));
      unawaited(_loadRecent());
      unawaited(
        unifiedSearchRepository.search(query: raw).then((snap) {
          if (!mounted || gen != _generation) return;
          setState(() {
            _snapshot = snap;
            _busy = false;
          });
        }).catchError((_) {
          if (!mounted || gen != _generation) return;
          setState(() {
            _snapshot = UnifiedSearchSnapshot.empty(raw);
            _busy = false;
          });
        }),
      );
    }

    if (immediate) {
      run();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 380), run);
  }

  void _onFocusHighlight() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final hasQuery = _controller.text.trim().isNotEmpty;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: AppSafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  MarketUi.spacingMD, 8, MarketUi.spacingMD, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: AppMotion.base,
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: MarketUi.softElev(context),
                        border: Border.all(
                          color: _focus.hasFocus
                              ? colors.primary.withValues(alpha: .38)
                              : colors.border.withValues(alpha: .2),
                          width: _focus.hasFocus ? 1.5 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              LucideIcons.search,
                              color: _focus.hasFocus
                                  ? colors.primary
                                  : colors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focus,
                                autofocus: true,
                                cursorColor: colors.primary,
                                textInputAction: TextInputAction.search,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                                decoration: InputDecoration(
                                  hintText: s.searchHubEverythingHint,
                                  hintStyle: TextStyle(
                                    color: colors.textMuted,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  filled: false,
                                  isDense: true,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(0, 14, 8, 14),
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                  _scheduleSearch();
                                },
                                onSubmitted: (_) =>
                                    _scheduleSearch(immediate: true),
                              ),
                            ),
                            if (hasQuery)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _snapshot = null);
                                },
                                icon:
                                    Icon(Icons.close, color: colors.textMuted),
                              )
                            else
                              const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_busy)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: colors.primary,
                  backgroundColor: colors.surfaceMuted,
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.base,
                child: hasQuery
                    ? (_snapshot == null
                        ? _EmptyPrompt(colors: colors, s: s, busy: _busy)
                        : _UnifiedResults(snapshot: _snapshot!, s: s))
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          MarketUi.spacingMD,
                          MarketUi.spacingMD,
                          MarketUi.spacingMD,
                          MarketUi.spacingXL + systemBottomInset(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_recent.isNotEmpty) ...[
                              _SectionHeader(title: s.searchHubRecent),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 44,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: _recent.map((t) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _RecentChip(
                                        text: t,
                                        onTap: () {
                                          _controller.text = t;
                                          _scheduleSearch(immediate: true);
                                        },
                                        onDismiss: () async {
                                          await SearchHistoryStorage.remove(t);
                                          await _loadRecent();
                                          setState(() {});
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            _SectionHeader(title: s.searchHubTrending),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                children: _trendingQueries(s)
                                    .map(
                                      (t) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: _TrendingChip(
                                          text: t,
                                          onTap: () {
                                            _controller.text = t;
                                            _scheduleSearch(immediate: true);
                                          },
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _SectionHeader(title: s.searchHubCategoryIdeas),
                            const SizedBox(height: 6),
                            Consumer<GetCategories>(
                              builder: (context, cat, ___) {
                                return CategoryStrip(
                                  categories: cat.categories,
                                  isLoading: cat.isLoading,
                                  showHeader: false,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.rM,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.rM,
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.border),
            boxShadow: MarketUi.softElev(context),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.text,
    required this.onTap,
    required this.onDismiss,
  });

  final String text;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.history, size: 14, color: colors.textMuted),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onDismiss,
                borderRadius: BorderRadius.circular(99),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 16, color: colors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  const _TrendingChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
          ),
          child: Text(
            '#$text',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.onMap,
    required this.onCreateOrder,
  });

  final VoidCallback onMap;
  final VoidCallback onCreateOrder;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: LucideIcons.map,
            label: s.searchHubOpenMap,
            onTap: onMap,
            accent: colors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionTile(
            icon: LucideIcons.clipboardList,
            label: s.createOrder,
            onTap: onCreateOrder,
            accent: colors.info,
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rL,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rL,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rL,
            border: Border.all(color: colors.border),
            boxShadow: MarketUi.softElev(context),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.rS,
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: colors.textPrimary,
                    height: 1.2,
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

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt({
    required this.colors,
    required this.s,
    required this.busy,
  });

  final AppColors colors;
  final S s;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 14),
            Text(
              s.searchHubAwaitingTyping,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted),
            ),
          ],
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.18),
                    colors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.search,
                size: 36,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s.searchHubAwaitingTyping,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textMuted,
                height: 1.4,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnifiedResults extends StatelessWidget {
  const _UnifiedResults({required this.snapshot, required this.s});

  final UnifiedSearchSnapshot snapshot;
  final S s;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (!snapshot.hasAnyHits) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
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
                LucideIcons.packageSearch,
                size: 36,
                color: colors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.searchHubNoGroupedHits,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.tryAnotherSearch,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textMuted, height: 1.35),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(
              RoutesName.createOrder,
              extra: snapshot.query,
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
            ),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(s.createOrder),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (snapshot.products.isNotEmpty)
          _HorizontalHitsSection(
            title: s.searchHubSectionProducts,
            icon: LucideIcons.package,
            badge: '${snapshot.products.length}',
            itemWidth: 168,
            itemHeight: 240,
            itemCount: snapshot.products.length,
            itemBuilder: (i) => ProductCardGrid(product: snapshot.products[i]),
            onSeeAll: snapshot.products.length >= 8
                ? () => context.push(RoutesName.search,
                    extra: const {'isAllProduct': true})
                : null,
          ),
        if (snapshot.workshops.isNotEmpty)
          _HorizontalHitsSection(
            title: s.searchHubSectionWorkshops,
            icon: LucideIcons.wrench,
            badge: '${snapshot.workshops.length}',
            itemWidth: 268,
            itemHeight: 200,
            itemCount: snapshot.workshops.length,
            itemBuilder: (i) => _WorkshopHitTile(w: snapshot.workshops[i]),
            onSeeAll: snapshot.workshops.length >= 8
                ? () => context.push(RoutesName.nearbyMap)
                : null,
          ),
        if (snapshot.services.isNotEmpty)
          _HorizontalHitsSection(
            title: s.searchHubSectionServices,
            icon: LucideIcons.circleDot,
            badge: '${snapshot.services.length}',
            itemWidth: 248,
            itemHeight: 200,
            itemCount: snapshot.services.length,
            itemBuilder: (i) => _ServiceHitTile(hit: snapshot.services[i]),
            onSeeAll: snapshot.services.length >= 8
                ? () => context.push(RoutesName.servicesHub)
                : null,
          ),
        if (snapshot.orders.isNotEmpty)
          _HorizontalHitsSection(
            title: s.searchHubSectionOrders,
            icon: LucideIcons.clipboardList,
            badge: '${snapshot.orders.length}',
            itemWidth: 268,
            itemHeight: 200,
            itemCount: snapshot.orders.length,
            itemBuilder: (i) => _OrderHitTile(order: snapshot.orders[i]),
            onSeeAll: snapshot.orders.length >= 8
                ? () => context.push(RoutesName.ordersList)
                : null,
          ),
        if (snapshot.sellers.isNotEmpty)
          _HorizontalHitsSection(
            title: s.searchHubSectionSellers,
            icon: LucideIcons.store,
            badge: '${snapshot.sellers.length}',
            itemWidth: 208,
            itemHeight: 200,
            itemCount: snapshot.sellers.length,
            itemBuilder: (i) => _SellerHitTile(hit: snapshot.sellers[i]),
            onSeeAll: null,
          ),
      ],
    );
  }
}

class _HorizontalHitsSection extends StatelessWidget {
  const _HorizontalHitsSection({
    required this.title,
    required this.icon,
    required this.badge,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemCount,
    required this.itemBuilder,
    this.onSeeAll,
  });

  final String title;
  final IconData icon;
  final String badge;
  final double itemWidth;
  final double itemHeight;
  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: colors.primary,
                    ),
                  ),
                ),
                if (onSeeAll != null) ...[
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: onSeeAll,
                    child: Text(S.of(context).seeAll),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: itemHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: itemCount,
              itemBuilder: (_, i) => SizedBox(
                width: itemWidth,
                child: itemBuilder(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkshopHitTile extends StatelessWidget {
  const _WorkshopHitTile({required this.w});

  final WorkshopProfile w;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rL,
      child: InkWell(
        borderRadius: AppRadius.rL,
        onTap: () => context.push('${RoutesName.workshopDetailScreen}/${w.id}'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rL,
            border: Border.all(color: colors.border),
            boxShadow: AppShadows.card(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      w.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (w.isOpenNow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        'Open',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: colors.success,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                w.displayAddress,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(LucideIcons.star, size: 14, color: colors.warning),
                  const SizedBox(width: 4),
                  Text(
                    w.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceHitTile extends StatelessWidget {
  const _ServiceHitTile({required this.hit});

  final UnifiedServiceHit hit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rL,
      child: InkWell(
        borderRadius: AppRadius.rL,
        onTap: () => context.push(RoutesName.servicesHub),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rL,
            border: Border.all(color: colors.border),
            boxShadow: AppShadows.card(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hit.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (hit.isEmergency)
                    Icon(LucideIcons.siren, size: 18, color: colors.danger),
                ],
              ),
              if (hit.categoryName != null) ...[
                const SizedBox(height: 6),
                Text(
                  hit.categoryName!,
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Icon(LucideIcons.star, size: 14, color: colors.warning),
                  const SizedBox(width: 4),
                  Text(
                    (hit.rating ?? 0).toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderHitTile extends StatelessWidget {
  const _OrderHitTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rL,
      child: InkWell(
        borderRadius: AppRadius.rL,
        onTap: () => context.push('${RoutesName.orderDetail}/${order.id}'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rL,
            border: Border.all(color: colors.border),
            boxShadow: AppShadows.card(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${order.budget} ${order.currency ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const Spacer(),
              Text(
                order.location ?? order.region ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerHitTile extends StatelessWidget {
  const _SellerHitTile({required this.hit});

  final UnifiedSellerHit hit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rL,
      child: InkWell(
        borderRadius: AppRadius.rL,
        onTap: () => context.push(RoutesName.sellerProfile, extra: hit.id),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rL,
            border: Border.all(color: colors.border),
            boxShadow: AppShadows.card(context),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: (hit.image != null && hit.image!.isNotEmpty)
                    ? NetworkImage(hit.image!)
                    : null,
                child: (hit.image == null || hit.image!.isEmpty)
                    ? Text(
                        hit.name.isNotEmpty ? hit.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                hit.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                S.of(context).homeListingCountHint(hit.productsInSearch),
                style: TextStyle(fontSize: 11, color: colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
