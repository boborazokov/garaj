import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/catalog/vehicle_catalog_repository.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/data/models/category_node.dart';
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

/// Explore-style discovery search: title, pill field, shortcuts, category grid.
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
      final brands = data.brands.where((b) => b.isBrand || b.type.isEmpty).toList();
      // Tree roots are brands; if type missing, still treat as brands.
      setState(() {
        _brands = brands.isNotEmpty
            ? brands
            : data.brands;
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
      setState(() {
        _busy = true;
        _tab = _ResultTab.all;
      });
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
    _debounce = Timer(const Duration(milliseconds: 320), run);
  }

  void _clearQuery() {
    _controller.clear();
    setState(() {
      _snapshot = null;
      _busy = false;
      _tab = _ResultTab.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final hasQuery = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: colors.surface,
      resizeToAvoidBottomInset: true,
      body: AppSafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasQuery)
              _ResultsSearchBar(
                controller: _controller,
                focus: _focus,
                hasQuery: hasQuery,
                canPop: canPop,
                hint: s.searchHubExploreHint,
                onChanged: () {
                  setState(() {});
                  _scheduleSearch();
                },
                onSubmitted: () => _scheduleSearch(immediate: true),
                onClear: _clearQuery,
              ),
            if (_busy)
              LinearProgressIndicator(
                minHeight: 2,
                color: colors.primary,
                backgroundColor: colors.surfaceMuted,
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: hasQuery
                    ? KeyedSubtree(
                        key: ValueKey('results-${_snapshot?.query ?? 'busy'}'),
                        child: _snapshot == null
                            ? _SearchingState(busy: _busy)
                            : _ResultsBody(
                                snapshot: _snapshot!,
                                tab: _tab,
                                onTab: (t) => setState(() => _tab = t),
                              ),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('idle'),
                        child: _ExploreBody(
                          controller: _controller,
                          focus: _focus,
                          canPop: canPop,
                          recent: _recent,
                          brands: _brands,
                          brandsLoading: _brandsLoading,
                          onChanged: () {
                            setState(() {});
                            _scheduleSearch();
                          },
                          onSubmitted: () =>
                              _scheduleSearch(immediate: true),
                          onClear: _clearQuery,
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
                      ),
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
    required this.controller,
    required this.focus,
    required this.canPop,
    required this.recent,
    required this.brands,
    required this.brandsLoading,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onQuery,
    required this.onClearRecent,
    required this.onRemoveRecent,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final bool canPop;
  final List<String> recent;
  final List<CategoryNode> brands;
  final bool brandsLoading;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;
  final void Function(String q, {bool search}) onQuery;
  final Future<void> Function() onClearRecent;
  final Future<void> Function(String) onRemoveRecent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        listPaddingAboveBottomNav(context),
      ),
      children: [
        Row(
          children: [
            if (canPop)
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () => context.pop(),
                icon: Icon(LucideIcons.arrowLeft, color: colors.textPrimary),
              ),
            Expanded(
              child: Text(
                s.searchHubExploreTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.15,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CustomSearchInput(
          controller: controller,
          focusNode: focus,
          hintText: s.searchHubExploreHint,
          onChanged: (_) => onChanged(),
          onSubmitted: (_) => onSubmitted(),
        ),
        const SizedBox(height: 8),
        _ExploreLinkTile(
          icon: LucideIcons.package,
          label: s.searchHubQuickParts,
          onTap: () => context.push(
            RoutesName.search,
            extra: const {'isAllProduct': true},
          ),
        ),
        _ExploreLinkTile(
          icon: LucideIcons.mapPin,
          label: s.searchHubQuickNearby,
          onTap: () => context.push(RoutesName.nearbyMap),
        ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  s.searchHubRecent,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => onClearRecent(),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  s.searchHubClearRecent,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          ...recent.take(5).map(
                (t) => _ExploreLinkTile(
                  icon: LucideIcons.history,
                  label: t,
                  onTap: () => onQuery(t),
                  onTrailing: () => onRemoveRecent(t),
                  trailingIsClear: true,
                ),
              ),
        ],
        const SizedBox(height: 18),
        Text(
          s.searchHubCarBrands,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (brandsLoading && brands.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else if (brands.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              s.noAvailable,
              style: TextStyle(color: colors.textMuted),
            ),
          )
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

class _ExploreLinkTile extends StatelessWidget {
  const _ExploreLinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onTrailing,
    this.trailingIsClear = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onTrailing;
  final bool trailingIsClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (trailingIsClear && onTrailing != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onTrailing,
                icon: Icon(LucideIcons.x, size: 16, color: colors.textMuted),
              )
            else
              Icon(LucideIcons.chevronRight, size: 20, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _BrandExploreGrid extends StatelessWidget {
  const _BrandExploreGrid({
    required this.brands,
    required this.onTap,
  });

  final List<CategoryNode> brands;
  final void Function(CategoryNode) onTap;

  /// Soft brand tiles — green/grey family aligned to AppPalette.
  static const _accents = <List<Color>>[
    [AppPalette.primary800, AppPalette.primary500],
    [AppPalette.secondary700, AppPalette.secondary400],
    [AppPalette.primary900, AppPalette.primary600],
    [Color(0xFF1F3A2A), AppPalette.primary400],
    [AppPalette.secondary800, AppPalette.secondary500],
    [AppPalette.primary700, AppPalette.primary300],
    [Color(0xFF243028), AppPalette.primary500],
    [AppPalette.secondary600, AppPalette.secondary300],
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleNotifier>().locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: brands.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (context, i) {
        final brand = brands[i];
        final name = brand.localizedName(lang);
        final accent = _accents[i % _accents.length];
        return _BrandExploreCard(
          title: name,
          logoUrl: brand.iconUrl,
          colors: accent,
          onTap: () => onTap(brand),
        );
      },
    );
  }
}

class _BrandExploreCard extends StatelessWidget {
  const _BrandExploreCard({
    required this.title,
    required this.logoUrl,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String? logoUrl;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final logo = logoUrl?.trim();

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Soft photo-like wash on the right (Explore-style).
                Positioned(
                  right: -20,
                  top: -10,
                  bottom: -10,
                  width: 120,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.centerRight,
                        radius: 0.95,
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                if (logo != null && logo.isNotEmpty)
                  Positioned(
                    right: -6,
                    bottom: -8,
                    child: Opacity(
                      opacity: 0.55,
                      child: ImageCacheNetwork(
                        url: logo,
                        width: 92,
                        height: 92,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  Positioned(
                    right: 8,
                    bottom: 4,
                    child: Icon(
                      LucideIcons.car,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 48, 12),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        height: 1.15,
                        shadows: [
                          Shadow(
                            color: Color(0x73000000),
                            blurRadius: 8,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Results header ─────────────────────────────────────────────────────

class _ResultsSearchBar extends StatelessWidget {
  const _ResultsSearchBar({
    required this.controller,
    required this.focus,
    required this.hasQuery,
    required this.canPop,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final bool hasQuery;
  final bool canPop;
  final String hint;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () {
                if (hasQuery) {
                  onClear();
                } else {
                  context.pop();
                }
              },
              icon: Icon(LucideIcons.arrowLeft, color: colors.textPrimary),
            ),
          Expanded(
            child: CustomSearchInput(
              controller: controller,
              focusNode: focus,
              hintText: hint,
              onChanged: (_) => onChanged(),
              onSubmitted: (_) => onSubmitted(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Results ────────────────────────────────────────────────────────────

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
            CircularProgressIndicator(color: colors.primary),
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
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
        children: [
          Icon(LucideIcons.searchX, size: 48, color: colors.textMuted),
          const SizedBox(height: 14),
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
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.push(
              RoutesName.createOrder,
              extra: snapshot.query,
            ),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(s.createOrder),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final t = tabs[i];
              final selected = tab == t.$1;
              return ChoiceChip(
                selected: selected,
                label: Text('${t.$2} ${t.$3}'),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? colors.onPrimary : colors.textPrimary,
                ),
                selectedColor: colors.primary,
                backgroundColor: colors.surfaceMuted,
                side: BorderSide(
                  color: selected ? colors.primary : colors.border,
                ),
                onSelected: (_) => onTab(t.$1),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _ResultsList(snapshot: snapshot, tab: tab),
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
  const _ResultsList({required this.snapshot, required this.tab});

  final UnifiedSearchSnapshot snapshot;
  final _ResultTab tab;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final children = <Widget>[];

    void addSection(String title, List<Widget> tiles) {
      if (tiles.isEmpty) return;
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      );
      children.addAll(tiles);
    }

    final showAll = tab == _ResultTab.all;

    if (showAll || tab == _ResultTab.products) {
      addSection(
        s.searchHubSectionProducts,
        snapshot.products
            .take(showAll ? 6 : 40)
            .map((p) => _ProductRow(product: p))
            .toList(),
      );
    }
    if (showAll || tab == _ResultTab.workshops) {
      addSection(
        s.searchHubSectionWorkshops,
        snapshot.workshops
            .take(showAll ? 5 : 40)
            .map((w) => _WorkshopRow(w: w))
            .toList(),
      );
    }
    if (showAll || tab == _ResultTab.services) {
      addSection(
        s.searchHubSectionServices,
        snapshot.services
            .take(showAll ? 5 : 40)
            .map((e) => _ServiceRow(hit: e))
            .toList(),
      );
    }
    if (showAll || tab == _ResultTab.orders) {
      addSection(
        s.searchHubSectionOrders,
        snapshot.orders
            .take(showAll ? 5 : 40)
            .map((o) => _OrderRow(order: o))
            .toList(),
      );
    }
    if (showAll || tab == _ResultTab.sellers) {
      addSection(
        s.searchHubSectionSellers,
        snapshot.sellers
            .take(showAll ? 5 : 40)
            .map((e) => _SellerRow(hit: e))
            .toList(),
      );
    }

    children.add(SizedBox(height: listPaddingAboveBottomNav(context)));

    return ListView(children: children);
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
      if (product.location.isNotEmpty) product.location,
    ].where((e) => e.trim().isNotEmpty).join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: thumb.isEmpty
            ? Container(
                width: 56,
                height: 56,
                color: colors.surfaceMuted,
                child: Icon(LucideIcons.package, color: colors.textMuted),
              )
            : ImageCacheNetwork(url: thumb, width: 56, height: 56),
      ),
      title: Text(
        product.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 110),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              product.negotiable == true && product.price <= 0
                  ? s.negotiable
                  : _formatPrice(product.price, product.currency),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: colors.primary,
                fontSize: 13,
              ),
            ),
            if (product.negotiable == true && product.price > 0)
              Text(
                s.negotiable,
                style: TextStyle(color: colors.textMuted, fontSize: 11),
              ),
          ],
        ),
      ),
      onTap: () =>
          context.push(RoutesName.productDetailScreen, extra: product.id),
    );
  }
}

class _WorkshopRow extends StatelessWidget {
  const _WorkshopRow({required this.w});
  final WorkshopProfile w;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: colors.primary.withValues(alpha: 0.12),
        child: Icon(LucideIcons.wrench, color: colors.primary, size: 18),
      ),
      title: Text(w.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        w.displayAddress,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colors.textMuted, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.star, size: 14, color: colors.warning),
          const SizedBox(width: 4),
          Text(w.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      onTap: () =>
          context.push('${RoutesName.workshopDetailScreen}/${w.id}'),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.hit});
  final UnifiedServiceHit hit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: colors.info.withValues(alpha: 0.12),
        child: Icon(LucideIcons.circleDot, color: colors.info, size: 18),
      ),
      title: Text(hit.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: hit.categoryName == null
          ? null
          : Text(hit.categoryName!,
              style: TextStyle(color: colors.textMuted, fontSize: 12)),
      trailing: hit.rating == null
          ? null
          : Text(
              hit.rating!.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
      onTap: () => context.push('${RoutesName.serviceDetail}/${hit.id}'),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: colors.warning.withValues(alpha: 0.15),
        child:
            Icon(LucideIcons.clipboardList, color: colors.warning, size: 18),
      ),
      title: Text(order.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        order.location ?? order.region ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colors.textMuted, fontSize: 12),
      ),
      trailing: Text(
        '${order.budget} ${order.currency ?? ''}',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: colors.primary,
          fontSize: 13,
        ),
      ),
      onTap: () => context.push('${RoutesName.orderDetail}/${order.id}'),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        backgroundImage:
            (hit.image != null && hit.image!.isNotEmpty) ? NetworkImage(hit.image!) : null,
        backgroundColor: colors.primary.withValues(alpha: 0.12),
        child: (hit.image == null || hit.image!.isEmpty)
            ? Text(
                hit.name.isNotEmpty ? hit.name[0].toUpperCase() : '?',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: colors.primary),
              )
            : null,
      ),
      title: Text(hit.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        s.homeListingCountHint(hit.productsInSearch),
        style: TextStyle(color: colors.textMuted, fontSize: 12),
      ),
      trailing: Icon(LucideIcons.chevronRight, size: 18, color: colors.textMuted),
      onTap: () => context.push(RoutesName.sellerProfile, extra: hit.id),
    );
  }
}
