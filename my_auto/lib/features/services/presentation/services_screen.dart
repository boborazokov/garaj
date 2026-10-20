import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/widgets/searchInput/index.dart';

enum _HubFilter { all, openNow, nearby }

/// Avtoservis hub — clean marketplace list of workshops.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _search = TextEditingController();
  List<WorkshopProfile> _items = [];
  bool _loading = true;
  _HubFilter _filter = _HubFilter.all;

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

    var nearby = await workshopsRepository.nearby(
      latitude: lat,
      longitude: lng,
      radiusKm: 120,
      limit: 50,
    );
    if (nearby.isEmpty) {
      nearby = await workshopsRepository.list(limit: 50);
    }

    // Prefer promoted / rated first for a healthier feed.
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
  }

  List<WorkshopProfile> get _visible {
    var list = _items;
    switch (_filter) {
      case _HubFilter.openNow:
        list = list.where((w) => w.isOpenNow || w.open24Hours).toList();
      case _HubFilter.nearby:
        list = list; // already nearby-first from API
      case _HubFilter.all:
        break;
    }

    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((w) {
      return w.name.toLowerCase().contains(q) ||
          w.city.toLowerCase().contains(q) ||
          w.displayAddress.toLowerCase().contains(q) ||
          w.categories.any((c) => c.name.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);
    final visible = _visible;

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
                  padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.services,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.servicesHubSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: CustomSearchInput(
                    controller: _search,
                    hintText: s.searchHubEverythingHint,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => setState(() {}),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: s.seeAll,
                        selected: _filter == _HubFilter.all,
                        onTap: () => setState(() => _filter = _HubFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: s.mapFilterOpenNow,
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
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (visible.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyHub(
                    onMap: () => context.push(RoutesName.nearbyMap),
                    onAdd: () => context.push(RoutesName.createWorkshop),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AvtoservisCard(workshop: visible[i]),
                      ),
                      childCount: visible.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: listPaddingAboveBottomNav(context, navBarHeight: 20),
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
        backgroundColor: colors.primary.withValues(alpha: 0.1),
        foregroundColor: colors.primary,
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
      color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.border.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected ? colors.onPrimary : colors.primary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? colors.onPrimary : colors.textPrimary,
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
    final name = workshop.name.trim().isEmpty ? s.services : workshop.name.trim();
    final category = workshop.categories.isNotEmpty
        ? workshop.categories.first.name
        : '';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.rL,
        color: colors.surface,
        border: Border.all(color: colors.border.withValues(alpha: 0.45)),
        boxShadow: MarketUi.softElev(context),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.rL,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push(
              '${RoutesName.workshopDetailScreen}/${workshop.id}',
            );
          },
          child: SizedBox(
            height: 112,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 112,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: colors.primary.withValues(alpha: 0.08),
                        child: image.isNotEmpty
                            ? ImageCacheNetwork(url: image, fit: BoxFit.cover)
                            : Center(
                                child: Icon(
                                  LucideIcons.wrench,
                                  size: 32,
                                  color: colors.primary.withValues(alpha: 0.55),
                                ),
                              ),
                      ),
                      if (workshop.isPromotionActive)
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.warning,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.promotedBadge,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  letterSpacing: -0.2,
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
                                color: isOpen ? colors.success : colors.danger,
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
                                color: isOpen
                                    ? colors.success
                                    : colors.textMuted,
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
                                    fontWeight: FontWeight.w600,
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
                                  fontWeight: FontWeight.w800,
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
      ),
    );
  }
}

class _EmptyHub extends StatelessWidget {
  const _EmptyHub({required this.onMap, required this.onAdd});

  final VoidCallback onMap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.carFront, size: 36, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            s.servicesHubEmptyNearby,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              height: 1.45,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onMap,
            icon: const Icon(LucideIcons.map, size: 18),
            label: Text(s.searchHubOpenMap),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(s.addService),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
            ),
          ),
        ],
      ),
    );
  }
}
