import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/catalog/vehicle_catalog_repository.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/features/create_product/data/models/category_node.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/orders/domain/entities/order.dart';
import 'package:my_auto/features/search/data/search_history_storage.dart';
import 'package:my_auto/features/search/data/unified_search_repository.dart';
import 'package:my_auto/features/search/domain/unified_search_snapshot.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/widgets/searchInput/index.dart';
import 'package:provider/provider.dart';

enum _ResultTab { all, products, workshops, services, orders, sellers }

/// Unified discovery search — explore idle + cross-entity results.
class GlobalSearchHubScreen extends StatefulWidget {
  const GlobalSearchHubScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<GlobalSearchHubScreen> createState() => _GlobalSearchHubScreenState();
}

class _GlobalSearchHubScreenState extends State<GlobalSearchHubScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  final VehicleCatalogRepository _catalogRepo = VehicleCatalogRepository();
  Timer? _debounce;
  int _generation = 0;

  UnifiedSearchSnapshot? _snapshot;
  bool _busy = false;
  List<String> _recent = const [];
  List<CategoryNode> _brands = const [];
  bool _brandsLoading = false;
  _ResultTab _tab = _ResultTab.all;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _controller.text = widget.initialQuery!.trim();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scheduleSearch(immediate: true));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
    _loadRecent();
    _loadBrands();
  }

  Future<void> _loadRecent() async {
    final r = await SearchHistoryStorage.load();
    if (!mounted) return;
    setState(() => _recent = r);
  }

  Future<void> _loadBrands() async {
    setState(() => _brandsLoading = true);
    try {
      final data = await _catalogRepo.load();
      if (!mounted) return;
      final brands =
          data.brands.where((b) => b.isBrand || b.type.isEmpty).toList();
      setState(() {
        _brands = brands.isNotEmpty ? brands : data.brands;
        _brandsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _brands = const [];
        _brandsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _applyQuery(String q, {bool search = true}) {
    _controller.text = q;
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    setState(() {});
    if (search) _scheduleSearch(immediate: true);
  }

  _ResultTab _resolveTab(UnifiedSearchSnapshot snap, _ResultTab preferred) {
    if (preferred == _ResultTab.all) return _ResultTab.all;
    final ok = switch (preferred) {
      _ResultTab.products => snap.products.isNotEmpty,
      _ResultTab.workshops => snap.workshops.isNotEmpty,
      _ResultTab.services => snap.services.isNotEmpty,
      _ResultTab.orders => snap.orders.isNotEmpty,
      _ResultTab.sellers => snap.sellers.isNotEmpty,
      _ResultTab.all => true,
    };
    return ok ? preferred : _ResultTab.all;
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
          _tab = _ResultTab.all;
        });
        return;
      }
      if (raw.length < 2) {
        setState(() {
          _snapshot = null;
          _busy = false;
        });
        return;
      }
      final keepTab = _tab;
      setState(() => _busy = true);
      unawaited(SearchHistoryStorage.remember(raw));
      unawaited(_loadRecent());
      unawaited(
        unifiedSearchRepository.search(query: raw).then((snap) {
          if (!mounted || gen != _generation) return;
          setState(() {
            _snapshot = snap;
            _busy = false;
            _tab = _resolveTab(snap, keepTab);
          });
        }).catchError((_) {
          if (!mounted || gen != _generation) return;
          setState(() {
            _snapshot = UnifiedSearchSnapshot.empty(raw);
            _busy = false;
            _tab = _ResultTab.all;
          });
        }),
      );
    }

    if (immediate) {
      run();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 280), run);
  }

  void _clearQuery() {
    _controller.clear();
    setState(() {
      _snapshot = null;
      _busy = false;
      _tab = _ResultTab.all;
    });
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final query = _controller.text.trim();
    final hasQuery = query.isNotEmpty;
    final awaitingShort = hasQuery && query.length < 2;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: AppSafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchAppBar(
              controller: _controller,
              focus: _focus,
              canPop: canPop,
              hasQuery: hasQuery,
              hint: s.searchHubExploreHint,
              onChanged: () {
                setState(() {});
                _scheduleSearch();
              },
              onSubmitted: () => _scheduleSearch(immediate: true),
              onClear: _clearQuery,
              onBack: () {
                if (hasQuery) {
                  _clearQuery();
                } else if (canPop) {
                  context.pop();
                }
              },
            ),
            if (_busy)
              LinearProgressIndicator(
                minHeight: 2,
                color: colors.primary,
                backgroundColor: colors.surfaceMuted,
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                child: !hasQuery
                    ? KeyedSubtree(
                        key: const ValueKey('idle'),
                        child: _ExploreBody(
                          recent: _recent,
                          brands: _brands,
                          brandsLoading: _brandsLoading,
                          onQuery: _applyQuery,
                          onClearRecent: () async {
                            await SearchHistoryStorage.clear();
                            await _loadRecent();
                          },
                          onRemoveRecent: (t) async {
                            await SearchHistoryStorage.remove(t);
                            await _loadRecent();
                          },
                        ),
                      )
                    : awaitingShort
                        ? KeyedSubtree(
                            key: const ValueKey('short'),
                            child: _HintState(
                              message: s.searchHubAwaitingTyping,
                            ),
                          )
                        : KeyedSubtree(
                            key: ValueKey(
                              'results-${_snapshot?.query ?? 'busy'}',
                            ),
                            child: _snapshot == null
                                ? _SearchingState(busy: _busy)
                                : _ResultsBody(
                                    snapshot: _snapshot!,
                                    tab: _tab,
                                    onTab: (t) => setState(() => _tab = t),
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

// ── Sticky search bar ──────────────────────────────────────────────────

class _SearchAppBar extends StatelessWidget {
  const _SearchAppBar({
    required this.controller,
    required this.focus,
    required this.canPop,
    required this.hasQuery,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final bool canPop;
  final bool hasQuery;
  final String hint;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s,
          AppSpacing.s,
          MarketUi.spacingMD,
          AppSpacing.s,
        ),
        child: Row(
          children: [
            if (canPop || hasQuery)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onBack,
                icon: Icon(LucideIcons.arrowLeft, color: colors.textPrimary),
              ),
            Expanded(
              child: CustomSearchInput(
                controller: controller,
                focusNode: focus,
                hintText: hint,
                autoFocus: false,
                onChanged: (_) => onChanged(),
                onSubmitted: (_) => onSubmitted(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Explore (idle) ─────────────────────────────────────────────────────

class _ExploreBody extends StatelessWidget {
  const _ExploreBody({
    required this.recent,
    required this.brands,
    required this.brandsLoading,
    required this.onQuery,
    required this.onClearRecent,
    required this.onRemoveRecent,
  });

  final List<String> recent;
  final List<CategoryNode> brands;
  final bool brandsLoading;
  final void Function(String q, {bool search}) onQuery;
  final Future<void> Function() onClearRecent;
  final Future<void> Function(String) onRemoveRecent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        MarketUi.spacingMD,
        AppSpacing.s,
        MarketUi.spacingMD,
        listPaddingAboveBottomNav(context),
      ),
      children: [
        Text(
          s.searchHubExploreTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          s.searchHubExploreHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickChip(
              icon: LucideIcons.package,
              label: s.searchHubQuickParts,
              onTap: () => context.push(
                RoutesName.search,
                extra: const {'isAllProduct': true},
              ),
            ),
            _QuickChip(
              icon: LucideIcons.mapPin,
              label: s.searchHubQuickNearby,
              onTap: () => context.push(RoutesName.nearbyMap),
            ),
            _QuickChip(
              icon: LucideIcons.clipboardList,
              label: s.navWantToBuy,
              onTap: () => context.push(RoutesName.createOrder),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        const AdBanner(
          surface: AdSurface.tuning,
          height: 120,
          margin: EdgeInsets.zero,
        ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  s.searchHubRecent,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => onClearRecent(),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(s.searchHubClearRecent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent.take(8).map((t) {
              return InputChip(
                label: Text(t),
                avatar: Icon(
                  LucideIcons.history,
                  size: 16,
                  color: colors.textMuted,
                ),
                onPressed: () => onQuery(t),
                onDeleted: () => onRemoveRecent(t),
                deleteIconColor: colors.textMuted,
                side: BorderSide(color: colors.border),
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.rXl),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          s.searchHubCarBrands,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        if (brandsLoading && brands.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else if (brands.isEmpty)
          Text(s.noAvailable, style: TextStyle(color: colors.textMuted))
        else
          _BrandExploreGrid(
            brands: brands,
            onTap: (b) {
              final lang =
                  context.read<LocaleNotifier>().locale?.languageCode ??
                      Localizations.localeOf(context).languageCode;
              onQuery(b.localizedName(lang));
            },
          ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rXl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rXl,
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: colors.textSecondary),
              const SizedBox(width: 8),
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

class _BrandExploreGrid extends StatelessWidget {
  const _BrandExploreGrid({required this.brands, required this.onTap});

  final List<CategoryNode> brands;
  final void Function(CategoryNode) onTap;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleNotifier>().locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final colors = context.appColors;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: brands.length.clamp(0, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, i) {
        final brand = brands[i];
        final name = brand.localizedName(lang);
        final logo = brand.iconUrl?.trim();
        return Material(
          color: colors.surface,
          borderRadius: MarketUi.cardRadius,
          child: InkWell(
            onTap: () => onTap(brand),
            borderRadius: MarketUi.cardRadius,
            child: Ink(
              decoration: MarketUi.card(context, colors),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: AppRadius.rS,
                        border: Border.all(color: colors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: logo != null && logo.isNotEmpty
                          ? ImageCacheNetwork(
                              url: logo,
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              LucideIcons.car,
                              size: 18,
                              color: colors.textMuted,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: colors.textPrimary,
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
    );
  }
}

// ── Results ────────────────────────────────────────────────────────────

class _HintState extends StatelessWidget {
  const _HintState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textMuted, height: 1.4),
        ),
      ),
    );
  }
}

class _SearchingState extends StatelessWidget {
  const _SearchingState({required this.busy});
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy) ...[
            const CircularProgressIndicator.adaptive(),
            const SizedBox(height: 14),
            Text(
              s.searchHubSearching,
              style: TextStyle(
                color: colors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else
            Text(
              s.searchHubAwaitingTyping,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted),
            ),
        ],
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.snapshot,
    required this.tab,
    required this.onTab,
  });

  final UnifiedSearchSnapshot snapshot;
  final _ResultTab tab;
  final ValueChanged<_ResultTab> onTab;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    if (!snapshot.hasAnyHits) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
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
                LucideIcons.searchX,
                size: 36,
                color: colors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            s.searchHubNoGroupedHits,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            s.tryAnotherSearch,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => context.push(
              RoutesName.createOrder,
              extra: snapshot.query,
            ),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(s.wantToBuyCreateCta),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
            ),
          ),
        ],
      );
    }

    final tabs = <(_ResultTab, String, int)>[
      (_ResultTab.all, s.searchHubUnifiedTitle, _countAll(snapshot)),
      if (snapshot.products.isNotEmpty)
        (
          _ResultTab.products,
          s.searchHubSectionProducts,
          snapshot.products.length
        ),
      if (snapshot.workshops.isNotEmpty)
        (
          _ResultTab.workshops,
          s.searchHubSectionWorkshops,
          snapshot.workshops.length
        ),
      if (snapshot.services.isNotEmpty)
        (
          _ResultTab.services,
          s.searchHubSectionServices,
          snapshot.services.length
        ),
      if (snapshot.orders.isNotEmpty)
        (_ResultTab.orders, s.searchHubSectionOrders, snapshot.orders.length),
      if (snapshot.sellers.isNotEmpty)
        (
          _ResultTab.sellers,
          s.searchHubSectionSellers,
          snapshot.sellers.length
        ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: MarketUi.spacingMD,
            ),
            itemCount: tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final t = tabs[i];
              final selected = tab == t.$1;
              return Material(
                color: selected ? colors.textPrimary : colors.surface,
                borderRadius: AppRadius.rXl,
                child: InkWell(
                  onTap: () => onTab(t.$1),
                  borderRadius: AppRadius.rXl,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.rXl,
                      border: Border.all(
                        color: selected ? colors.textPrimary : colors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${t.$2} · ${t.$3}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color:
                            selected
                                ? colors.background
                                : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Expanded(
          child: _ResultsList(
            snapshot: snapshot,
            tab: tab,
            onSeeAll: onTab,
          ),
        ),
      ],
    );
  }

  int _countAll(UnifiedSearchSnapshot s) =>
      s.products.length +
      s.workshops.length +
      s.services.length +
      s.orders.length +
      s.sellers.length;
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.snapshot,
    required this.tab,
    required this.onSeeAll,
  });

  final UnifiedSearchSnapshot snapshot;
  final _ResultTab tab;
  final ValueChanged<_ResultTab> onSeeAll;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final children = <Widget>[];
    final showAll = tab == _ResultTab.all;

    void addSection({
      required String title,
      required _ResultTab sectionTab,
      required List<Widget> tiles,
      required int total,
      required int preview,
    }) {
      if (tiles.isEmpty) return;
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MarketUi.spacingMD,
            AppSpacing.m,
            MarketUi.spacingMD,
            AppSpacing.s,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (showAll && total > preview)
                TextButton(
                  onPressed: () => onSeeAll(sectionTab),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(s.seeAll),
                ),
            ],
          ),
        ),
      );
      children.addAll(tiles);
    }

    if (showAll || tab == _ResultTab.products) {
      final preview = showAll ? 6 : 40;
      addSection(
        title: s.searchHubSectionProducts,
        sectionTab: _ResultTab.products,
        total: snapshot.products.length,
        preview: preview,
        tiles: snapshot.products
            .take(preview)
            .map((p) => _ProductRow(product: p))
            .toList(),
      );
    }
    if (showAll || tab == _ResultTab.workshops) {
      final preview = showAll ? 5 : 40;
      addSection(
        title: s.searchHubSectionWorkshops,
        sectionTab: _ResultTab.workshops,
        total: snapshot.workshops.length,
        preview: preview,
        tiles: snapshot.workshops
            .take(preview)
            .map((w) => _WorkshopRow(w: w))
            .toList(),
      );
    }
    if (showAll || tab == _ResultTab.services) {
      final preview = showAll ? 5 : 40;
      addSection(
        title: s.searchHubSectionServices,
        sectionTab: _ResultTab.services,
        total: snapshot.services.length,
        preview: preview,
        tiles: snapshot.services
            .take(preview)
            .map((e) => _ServiceRow(hit: e))
            .toList(),
      );
    }
    if (showAll || tab == _ResultTab.orders) {
      final preview = showAll ? 5 : 40;
      addSection(
        title: s.searchHubSectionOrders,
        sectionTab: _ResultTab.orders,
        total: snapshot.orders.length,
        preview: preview,
        tiles: snapshot.orders
            .take(preview)
            .map((o) => _OrderRow(order: o))
            .toList(),
      );
    }
    if (showAll || tab == _ResultTab.sellers) {
      final preview = showAll ? 5 : 40;
      addSection(
        title: s.searchHubSectionSellers,
        sectionTab: _ResultTab.sellers,
        total: snapshot.sellers.length,
        preview: preview,
        tiles: snapshot.sellers
            .take(preview)
            .map((e) => _SellerRow(hit: e))
            .toList(),
      );
    }

    children.add(SizedBox(height: listPaddingAboveBottomNav(context)));
    return ListView(children: children);
  }
}

class _HitCard extends StatelessWidget {
  const _HitCard({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MarketUi.spacingMD,
        0,
        MarketUi.spacingMD,
        AppSpacing.s,
      ),
      child: Material(
        color: colors.surface,
        borderRadius: MarketUi.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: MarketUi.cardRadius,
          child: Ink(
            decoration: MarketUi.card(context, colors),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});
  final Part product;

  String _formatPrice(int price, String currency) {
    final normalized = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
    return '$normalized $currency';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final thumb = product.images.isNotEmpty ? product.images.first : '';
    final subtitle = [
      if (product.brand != null)
        product.brand!.localizedName(
          Localizations.localeOf(context).languageCode,
        ),
      if (product.region?.isNotEmpty == true) product.region!,
    ].where((e) => e.trim().isNotEmpty).join(' · ');

    return _HitCard(
      onTap: () =>
          context.push(RoutesName.productDetailScreen, extra: product.id),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.rS,
            child: thumb.isEmpty
                ? Container(
                    width: 56,
                    height: 56,
                    color: colors.surfaceMuted,
                    child: Icon(LucideIcons.package, color: colors.textMuted),
                  )
                : ImageCacheNetwork(url: thumb, width: 56, height: 56),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.negotiable == true && product.price <= 0
                      ? s.negotiable
                      : _formatPrice(product.price, product.currency),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textMuted, fontSize: 12),
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

class _WorkshopRow extends StatelessWidget {
  const _WorkshopRow({required this.w});
  final WorkshopProfile w;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _HitCard(
      onTap: () =>
          context.push('${RoutesName.workshopDetailScreen}/${w.id}'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.rS,
              border: Border.all(color: colors.border),
            ),
            child: Icon(LucideIcons.wrench, color: colors.textSecondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  w.displayAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.star, size: 14, color: colors.warning),
          const SizedBox(width: 4),
          Text(
            w.rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.hit});
  final UnifiedServiceHit hit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _HitCard(
      onTap: () => context.push('${RoutesName.serviceDetail}/${hit.id}'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.rS,
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              LucideIcons.circleDot,
              color: colors.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hit.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (hit.categoryName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    hit.categoryName!,
                    style: TextStyle(color: colors.textMuted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (hit.rating != null)
            Text(
              hit.rating!.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final budget = order.budget <= 0
        ? s.negotiable
        : '${order.budget} ${order.currency ?? ''}'.trim();
    return _HitCard(
      onTap: () => context.push('${RoutesName.orderDetail}/${order.id}'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.rS,
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              LucideIcons.clipboardList,
              color: colors.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budget,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                    fontSize: 13,
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

class _SellerRow extends StatelessWidget {
  const _SellerRow({required this.hit});
  final UnifiedSellerHit hit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final avatarUrl = resolveMediaUrl(hit.image, mediaBase: fileUrl);

    return _HitCard(
      onTap: () => context.push(RoutesName.sellerProfile, extra: hit.id),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl) : null,
            backgroundColor: colors.surfaceMuted,
            child: avatarUrl == null
                ? Text(
                    hit.name.isNotEmpty ? hit.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hit.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  s.homeListingCountHint(hit.productsInSearch),
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: colors.textMuted),
        ],
      ),
    );
  }
}
