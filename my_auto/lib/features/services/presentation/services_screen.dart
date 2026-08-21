import 'dart:ui';

import 'package:flutter/material.dart';
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
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/services/data/services_repository.dart';
import 'package:my_auto/features/services/presentation/widgets/service_card.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/widgets/searchInput/index.dart';

enum _ServicesViewMode { discover, nearby, topRated, verified, search }

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _search = TextEditingController();
  List<ServiceListing> _nearby = [];
  List<ServiceListing> _top = [];
  bool _loading = true;
  _ServicesViewMode _mode = _ServicesViewMode.discover;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
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

    final results = await Future.wait([
      servicesRepository.nearbyServices(latitude: lat, longitude: lng),
      servicesRepository.topRated(),
    ]);

    if (!mounted) return;
    setState(() {
      _nearby = results[0];
      _top = results[1];
      _loading = false;
    });
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    setState(() {
      if (trimmed.isEmpty && _mode == _ServicesViewMode.search) {
        _mode = _ServicesViewMode.discover;
      } else if (trimmed.isNotEmpty) {
        _mode = _ServicesViewMode.search;
      }
    });
  }

  void _selectFilter(_ServicesViewMode mode) {
    setState(() {
      if (_mode == mode) {
        _mode = _ServicesViewMode.discover;
        return;
      }
      _mode = mode;
      if (_search.text.isNotEmpty) {
        _search.clear();
      }
    });
  }

  List<ServiceListing> _applySearch(List<ServiceListing> source) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.categoryName.toLowerCase().contains(q) ||
          s.address.toLowerCase().contains(q);
    }).toList();
  }

  List<ServiceListing> get _allServices {
    final ids = <String>{};
    final merged = <ServiceListing>[];
    for (final s in [..._nearby, ..._top]) {
      if (ids.add(s.id)) merged.add(s);
    }
    return merged;
  }

  List<ServiceListing> get _filteredList {
    final base = switch (_mode) {
      _ServicesViewMode.nearby => _nearby,
      _ServicesViewMode.topRated => _top,
      _ServicesViewMode.verified =>
        _allServices.where((s) => s.verified).toList(),
      _ServicesViewMode.search => _allServices,
      _ServicesViewMode.discover => const <ServiceListing>[],
    };
    return _applySearch(base);
  }

  String _filteredTitle(S s) {
    return switch (_mode) {
      _ServicesViewMode.nearby => s.mapFilterNearby,
      _ServicesViewMode.topRated => s.mapFilterTopRated,
      _ServicesViewMode.verified => s.mapFilterVerified,
      _ServicesViewMode.search => s.workshopSearchResults,
      _ServicesViewMode.discover => '',
    };
  }

  bool get _showFiltered =>
      _mode != _ServicesViewMode.discover &&
      (_mode != _ServicesViewMode.search || _search.text.trim().isNotEmpty);

  void _openDetail(ServiceListing service) {
    context.push('${RoutesName.serviceDetail}/${service.id}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      if (context.canPop())
                        IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .backButtonTooltip,
                          onPressed: () => context.pop(),
                          icon: Icon(
                            LucideIcons.arrowLeft,
                            color: colors.textPrimary,
                          ),
                        )
                      else
                        const SizedBox(width: 8),
                      _GlassIcon(
                        icon: LucideIcons.wrench,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.searchHubSectionWorkshops,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              s.servicesHubSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: s.workshopsLiveMap,
                        onPressed: () => context.push(RoutesName.nearbyMap),
                        icon: Icon(LucideIcons.map, color: colors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: CustomSearchInput(
                    controller: _search,
                    hintText: s.searchHubEverythingHint,
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: s.mapFilterNearby,
                        icon: LucideIcons.mapPin,
                        selected: _mode == _ServicesViewMode.nearby,
                        onTap: () => _selectFilter(_ServicesViewMode.nearby),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: s.mapFilterTopRated,
                        icon: LucideIcons.star,
                        selected: _mode == _ServicesViewMode.topRated,
                        onTap: () => _selectFilter(_ServicesViewMode.topRated),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: s.mapFilterVerified,
                        icon: LucideIcons.badgeCheck,
                        selected: _mode == _ServicesViewMode.verified,
                        onTap: () => _selectFilter(_ServicesViewMode.verified),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: _MapPromoCard(
                    title: s.searchHubOpenMap,
                    subtitle: s.servicesHubOpenMapSubtitle,
                    onTap: () => context.push(RoutesName.nearbyMap),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: AdBanner(
                  surface: AdSurface.service,
                  height: 120,
                  margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              if (_loading && !_showFiltered)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (_showFiltered)
                _servicesListSliver(
                  _filteredList,
                  _filteredTitle(s),
                  emptyMessage: _mode == _ServicesViewMode.topRated
                      ? s.servicesHubEmptyTopRated
                      : s.noServices,
                )
              else if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else ...[
                if (_top.isNotEmpty) _topRatedStripSliver(s),
                _servicesListSliver(
                  _nearby,
                  s.mapFilterNearby,
                  emptyMessage: s.servicesHubEmptyNearby,
                  showMapCta: true,
                ),
              ],
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: listPaddingAboveBottomNav(context, navBarHeight: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topRatedStripSliver(S s) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarketSectionTitle(
            title: s.mapFilterTopRated,
            trailingLabel: s.seeAll,
            onTrailing: () => _selectFilter(_ServicesViewMode.topRated),
          ),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: MarketUi.spacingMD),
              itemCount: _top.length > 12 ? 12 : _top.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _CompactServiceCard(
                service: _top[i],
                onTap: () => _openDetail(_top[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _servicesListSliver(
    List<ServiceListing> items,
    String title, {
    required String emptyMessage,
    bool showMapCta = false,
  }) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: _ServicesEmptyState(
          message: emptyMessage,
          showMapCta: showMapCta,
          onMap: () => context.push(RoutesName.nearbyMap),
          onAdd: () => context.push(RoutesName.createWorkshop),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverMainAxisGroup(
        slivers: [
          if (title.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    AdListSlot(
                      listIndex: i,
                      surface: AdSurface.service,
                      interval: 5,
                    ),
                    ServiceCard(
                      service: items[i],
                      onTap: () => _openDetail(items[i]),
                    ),
                  ],
                ),
              ),
              childCount: items.length,
            ),
          ),
        ],
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fg = selected ? colors.onPrimary : colors.textPrimary;
    final bg = selected ? colors.primary : colors.surface;
    final border = selected ? colors.primary : colors.border;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? fg : colors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: fg,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPromoCard extends StatelessWidget {
  const _MapPromoCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rXl,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.primaryHover],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.rXl,
            boxShadow: AppShadows.glow(colors.primary),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.18),
                  borderRadius: AppRadius.rM,
                ),
                child: Icon(
                  LucideIcons.map,
                  color: colors.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.onPrimary.withValues(alpha: 0.85),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: colors.onPrimary.withValues(alpha: 0.9),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactServiceCard extends StatelessWidget {
  const _CompactServiceCard({
    required this.service,
    required this.onTap,
  });

  final ServiceListing service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final img = service.images.isNotEmpty ? service.images.first : null;

    return SizedBox(
      width: 210,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: MarketUi.cardRadius,
          onTap: onTap,
          child: Ink(
            decoration: MarketUi.card(context, colors),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                  child: SizedBox(
                    width: 88,
                    height: 132,
                    child: img != null && img.isNotEmpty
                        ? ImageCacheNetwork(url: img, fit: BoxFit.cover)
                        : ColoredBox(
                            color: colors.surfaceMuted,
                            child: Icon(
                              LucideIcons.wrench,
                              color: colors.textMuted,
                              size: 28,
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            height: 1.2,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (service.categoryName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            service.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.star,
                              size: 14,
                              color: colors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: colors.textPrimary,
                              ),
                            ),
                            if (service.verified) ...[
                              const Spacer(),
                              Icon(
                                LucideIcons.badgeCheck,
                                size: 16,
                                color: colors.primary,
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
      ),
    );
  }
}

class _ServicesEmptyState extends StatelessWidget {
  const _ServicesEmptyState({
    required this.message,
    this.showMapCta = false,
    this.onMap,
    this.onAdd,
  });

  final String message;
  final bool showMapCta;
  final VoidCallback? onMap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
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
              LucideIcons.mapPinOff,
              size: 36,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              height: 1.45,
              fontSize: 15,
            ),
          ),
          if (showMapCta) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onMap,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
              ),
              icon: const Icon(LucideIcons.map, size: 18),
              label: Text(s.searchHubOpenMap),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
              ),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(s.addService),
            ),
          ],
        ],
      ),
    );
  }
}
