import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';
import 'package:my_auto/features/advertisement/presentation/ad_list_slot.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/promotion/presentation/promotion_plan_badge.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/widgets/searchInput/index.dart';

enum _HubFilter { all, openNow, nearby, verified, topRated }

/// Avtoservis hub — workshops marketplace list.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<WorkshopProfile> _items = [];
  List<WorkshopProfile> _searchHits = [];
  bool _loading = true;
  bool _searching = false;
  _HubFilter _filter = _HubFilter.all;
  int _searchGen = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    double lat = 41.2995;
    double lng = 69.2401;
    try {
      final pos = await Geolocator.getCurrentPosition();
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (_) {}

    var nearby = await workshopsRepository.nearby(
      latitude: lat,
      longitude: lng,
      radiusKm: 120,
      limit: 50,
    );
    if (nearby.isEmpty) {
      nearby = await workshopsRepository.list(limit: 50);
    }

    nearby = [...nearby]..sort((a, b) {
        final pa = a.isPromotionActive ? 1 : 0;
        final pb = b.isPromotionActive ? 1 : 0;
        if (pa != pb) return pb.compareTo(pa);
        final ra = a.rating;
        final rb = b.rating;
        if (ra != rb) return rb.compareTo(ra);
        return a.name.compareTo(b.name);
      });

    if (!mounted) return;
    setState(() {
      _items = nearby;
      _loading = false;
    });
    _scheduleSearch(immediate: true);
  }

  void _scheduleSearch({bool immediate = false}) {
    _debounce?.cancel();
    void run() async {
      final q = _search.text.trim();
      final gen = ++_searchGen;
      if (q.length < 2) {
        if (!mounted || gen != _searchGen) return;
        setState(() {
          _searchHits = const [];
          _searching = false;
        });
        return;
      }
      setState(() => _searching = true);
      try {
        final hits = await workshopsRepository.smartSearch(query: q);
        if (!mounted || gen != _searchGen) return;
        setState(() {
          _searchHits = hits;
          _searching = false;
        });
      } catch (_) {
        if (!mounted || gen != _searchGen) return;
        setState(() {
          _searchHits = const [];
          _searching = false;
        });
      }
    }

    if (immediate) {
      unawaited(Future(run));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 280), run);
  }

  List<WorkshopProfile> get _baseList {
    final q = _search.text.trim();
    if (q.length >= 2 && _searchHits.isNotEmpty) {
      return _searchHits;
    }
    return _items;
  }

  List<WorkshopProfile> get _visible {
    var list = _baseList;
    switch (_filter) {
      case _HubFilter.openNow:
        list = list.where((w) => w.isOpenNow || w.open24Hours).toList();
      case _HubFilter.nearby:
        // Feed is already nearby-first from API; keep promotion/rating order.
        break;
      case _HubFilter.verified:
        list = list.where((w) => w.verified).toList();
      case _HubFilter.topRated:
        list = [...list.where((w) => w.rating >= 4)]
          ..sort((a, b) => b.rating.compareTo(a.rating));
      case _HubFilter.all:
        break;
    }

    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    if (q.length >= 2 && _searchHits.isNotEmpty) return list;

    return list.where((w) {
      return w.name.toLowerCase().contains(q) ||
          w.city.toLowerCase().contains(q) ||
          w.displayAddress.toLowerCase().contains(q) ||
          w.categories.any((c) => c.name.toLowerCase().contains(q));
    }).toList();
  }

  int _countFor(_HubFilter filter) {
    final source = _baseList;
    switch (filter) {
      case _HubFilter.all:
        return source.length;
      case _HubFilter.openNow:
        return source.where((w) => w.isOpenNow || w.open24Hours).length;
      case _HubFilter.nearby:
        return source.length;
      case _HubFilter.verified:
        return source.where((w) => w.verified).length;
      case _HubFilter.topRated:
        return source.where((w) => w.rating >= 4).length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);
    final visible = _visible;
    final query = _search.text.trim();

    return Scaffold(
      backgroundColor: colors.background,
      body: AppSafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketUi.spacingMD,
                    AppSpacing.s,
                    MarketUi.spacingMD,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.services,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s),
                            Text(
                              s.servicesHubSubtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      _RoundAction(
                        icon: LucideIcons.map,
                        tooltip: s.searchHubOpenMap,
                        onTap: () => context.push(RoutesName.nearbyMap),
                      ),
                      const SizedBox(width: 6),
                      _RoundAction(
                        icon: LucideIcons.plus,
                        tooltip: s.addService,
                        onTap: () => context.push(RoutesName.createWorkshop),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketUi.spacingMD,
                    AppSpacing.l,
                    MarketUi.spacingMD,
                    AppSpacing.m,
                  ),
                  child: CustomSearchInput(
                    controller: _search,
                    hintText: s.searchHubEverythingHint,
                    onChanged: (_) {
                      setState(() {});
                      _scheduleSearch();
                    },
                    onSubmitted: (_) => _scheduleSearch(immediate: true),
                  ),
                ),
              ),
              if (_searching)
                SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: colors.primary,
                    backgroundColor: colors.surfaceMuted,
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: MarketUi.spacingMD,
                    ),
                    children: [
                      _FilterChip(
                        label: '${s.seeAll} · ${_countFor(_HubFilter.all)}',
                        selected: _filter == _HubFilter.all,
                        onTap: () => setState(() => _filter = _HubFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label:
                            '${s.mapFilterOpenNow} · ${_countFor(_HubFilter.openNow)}',
                        icon: LucideIcons.clock,
                        selected: _filter == _HubFilter.openNow,
                        onTap: () =>
                            setState(() => _filter = _HubFilter.openNow),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: s.mapFilterNearby,
                        icon: LucideIcons.mapPin,
                        selected: _filter == _HubFilter.nearby,
                        onTap: () =>
                            setState(() => _filter = _HubFilter.nearby),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label:
                            '${s.mapFilterVerified} · ${_countFor(_HubFilter.verified)}',
                        icon: LucideIcons.badgeCheck,
                        selected: _filter == _HubFilter.verified,
                        onTap: () =>
                            setState(() => _filter = _HubFilter.verified),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label:
                            '${s.mapFilterTopRated} · ${_countFor(_HubFilter.topRated)}',
                        icon: LucideIcons.star,
                        selected: _filter == _HubFilter.topRated,
                        onTap: () =>
                            setState(() => _filter = _HubFilter.topRated),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.m)),
              const SliverToBoxAdapter(
                child: AdBanner(
                  surface: AdSurface.service,
                  height: 132,
                  margin: EdgeInsets.fromLTRB(
                    MarketUi.spacingMD,
                    0,
                    MarketUi.spacingMD,
                    12,
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (visible.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyHub(
                    searching: query.isNotEmpty,
                    onMap: () => context.push(RoutesName.nearbyMap),
                    onAdd: () => context.push(RoutesName.createWorkshop),
                    onClearSearch: query.isEmpty
                        ? null
                        : () {
                            _search.clear();
                            setState(() {
                              _searchHits = const [];
                              _filter = _HubFilter.all;
                            });
                          },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketUi.spacingMD,
                    0,
                    MarketUi.spacingMD,
                    0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AdListSlot(
                            listIndex: i,
                            surface: AdSurface.service,
                            interval: 5,
                            height: 110,
                            margin: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AvtoservisCard(workshop: visible[i]),
                          ),
                        ],
                      ),
                      childCount: visible.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: listPaddingAboveBottomNav(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: colors.surface,
        foregroundColor: colors.textSecondary,
        side: BorderSide(color: colors.border),
        minimumSize: const Size(44, 44),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected ? colors.background : colors.textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? colors.background : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvtoservisCard extends StatelessWidget {
  const _AvtoservisCard({required this.workshop});

  final WorkshopProfile workshop;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);
    final image = workshop.heroImage;
    final place = workshop.displayAddress;
    final isOpen = workshop.isOpenNow || workshop.open24Hours;
    final name =
        workshop.name.trim().isEmpty ? s.services : workshop.name.trim();
    final category = workshop.categories.isNotEmpty
        ? workshop.categories.first.name
        : '';

    return Material(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: MarketUi.cardRadius,
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push(
            '${RoutesName.workshopDetailScreen}/${workshop.id}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppRadius.rM,
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: colors.surfaceMuted,
                        child: image.isNotEmpty
                            ? ImageCacheNetwork(
                                url: image,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Icon(
                                  LucideIcons.wrench,
                                  size: 28,
                                  color: colors.textMuted,
                                ),
                              ),
                      ),
                      if (workshop.isPromotionActive)
                        Positioned(
                          left: 6,
                          top: 6,
                          child: PromotionPlanBadge(
                            plan: workshop.promotionPlan,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 88,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                letterSpacing: -0.2,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          if (workshop.verified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.badgeCheck,
                              size: 16,
                              color: colors.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color:
                                  isOpen ? colors.success : colors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOpen
                                ? s.workshopStatusOpen
                                : s.workshopStatusClosed,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color:
                                  isOpen ? colors.success : colors.textMuted,
                            ),
                          ),
                          if (category.isNotEmpty) ...[
                            Text(
                              '  ·  ',
                              style: TextStyle(
                                color: colors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (place.isNotEmpty && place != '—') ...[
                            Icon(
                              LucideIcons.mapPin,
                              size: 13,
                              color: colors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                place,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                          ] else
                            const Spacer(),
                          if (workshop.rating > 0) ...[
                            const SizedBox(width: 6),
                            Icon(
                              LucideIcons.star,
                              size: 13,
                              color: colors.warning,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              workshop.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
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
    );
  }
}

class _EmptyHub extends StatelessWidget {
  const _EmptyHub({
    required this.onMap,
    required this.onAdd,
    required this.searching,
    this.onClearSearch,
  });

  final VoidCallback onMap;
  final VoidCallback onAdd;
  final bool searching;
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              searching ? LucideIcons.searchX : LucideIcons.carFront,
              size: 36,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            searching ? s.searchHubNoGroupedHits : s.servicesHubEmptyNearby,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.textSecondary,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (onClearSearch != null) ...[
            FilledButton(
              onPressed: onClearSearch,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
              ),
              child: Text(s.searchHubClearRecent),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          FilledButton.icon(
            onPressed: onMap,
            icon: const Icon(LucideIcons.map, size: 18),
            label: Text(s.searchHubOpenMap),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(s.addService),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
            ),
          ),
        ],
      ),
    );
  }
}
