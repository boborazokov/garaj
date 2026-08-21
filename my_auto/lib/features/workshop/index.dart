import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/features/workshop/presentation/widgets/workshop_profile_card.dart';
import 'package:my_auto/widgets/searchInput/index.dart';

enum _WorkshopViewMode { discover, openNow, nearby, popular, search }

class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({super.key});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final _search = TextEditingController();
  List<WorkshopProfile> _nearby = [];
  List<WorkshopProfile> _recommended = [];
  List<WorkshopProfile> _openNow = [];
  List<WorkshopProfile> _searchResults = [];
  bool _loading = true;
  bool _searchLoading = false;
  _WorkshopViewMode _mode = _WorkshopViewMode.discover;

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
    final nearby = await workshopsRepository.nearby();
    final recommended = await workshopsRepository.recommended();
    final openNow = await workshopsRepository.openNow();
    if (!mounted) return;
    setState(() {
      _nearby = nearby;
      _recommended = recommended;
      _openNow = openNow;
      _loading = false;
    });
  }

  Future<void> _runSearch(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _mode = _WorkshopViewMode.discover;
        _searchResults = [];
        _searchLoading = false;
      });
      return;
    }

    setState(() {
      _mode = _WorkshopViewMode.search;
      _searchLoading = true;
    });

    final results = await workshopsRepository.smartSearch(query: trimmed);
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _searchLoading = false;
    });
  }

  void _selectFilter(_WorkshopViewMode mode) {
    setState(() {
      if (_mode == mode) {
        _mode = _WorkshopViewMode.discover;
        return;
      }
      _mode = mode;
      if (_search.text.isNotEmpty) {
        _search.clear();
      }
    });
  }

  List<WorkshopProfile> get _filteredList {
    switch (_mode) {
      case _WorkshopViewMode.openNow:
        return _openNow;
      case _WorkshopViewMode.nearby:
        return _nearby;
      case _WorkshopViewMode.popular:
        return _recommended;
      case _WorkshopViewMode.search:
        return _searchResults;
      case _WorkshopViewMode.discover:
        return [];
    }
  }

  String get _filteredTitle {
    switch (_mode) {
      case _WorkshopViewMode.openNow:
        return 'Open now';
      case _WorkshopViewMode.nearby:
        return 'Nearby';
      case _WorkshopViewMode.popular:
        return 'Popular';
      case _WorkshopViewMode.search:
        return 'Search results';
      case _WorkshopViewMode.discover:
        return '';
    }
  }

  bool get _showFiltered =>
      _mode != _WorkshopViewMode.discover &&
      (_mode != _WorkshopViewMode.search || _search.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final busy = _loading || (_mode == _WorkshopViewMode.search && _searchLoading);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
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
                              'Workshops',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Trusted auto businesses near you',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Live map',
                        onPressed: () => context.push(RoutesName.nearbyMap),
                        icon: Icon(LucideIcons.map, color: colors.primary),
                      ),
                      IconButton(
                        tooltip: 'Add workshop',
                        onPressed: () =>
                            context.push(RoutesName.createWorkshop),
                        icon: Icon(LucideIcons.plus, color: colors.primary),
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
                    hintText: 'Search workshops, services, city…',
                    onChanged: _runSearch,
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
                        label: 'Open now',
                        icon: LucideIcons.clock,
                        selected: _mode == _WorkshopViewMode.openNow,
                        onTap: () => _selectFilter(_WorkshopViewMode.openNow),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Nearby',
                        icon: LucideIcons.mapPin,
                        selected: _mode == _WorkshopViewMode.nearby,
                        onTap: () => _selectFilter(_WorkshopViewMode.nearby),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Popular',
                        icon: LucideIcons.trendingUp,
                        selected: _mode == _WorkshopViewMode.popular,
                        onTap: () => _selectFilter(_WorkshopViewMode.popular),
                      ),
                    ],
                  ),
                ),
              ),
              if (busy && !_showFiltered)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (_showFiltered)
                (_loading && _mode != _WorkshopViewMode.search)
                    ? const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    : _gridSliver(_filteredList, _filteredTitle)
              else if (_loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else ...[
                if (_openNow.isNotEmpty)
                  _horizontalSliver('Open now', _openNow),
                if (_recommended.isNotEmpty)
                  _horizontalSliver('Recommended', _recommended),
                _gridSliver(_nearby, 'Nearby workshops'),
              ],
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: listPaddingAboveBottomNav(context, navBarHeight: 100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _horizontalSliver(String title, List<WorkshopProfile> items) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          SizedBox(
            height: 260,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => SizedBox(
                width: 200,
                child: WorkshopProfileCard(
                  workshop: items[i],
                  compact: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridSliver(List<WorkshopProfile> items, String title) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No workshops found',
              style: TextStyle(color: context.appColors.textMuted),
            ),
          ),
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
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => WorkshopProfileCard(workshop: items[i]),
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
