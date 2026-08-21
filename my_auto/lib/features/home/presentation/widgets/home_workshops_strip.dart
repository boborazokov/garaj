import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:url_launcher/url_launcher.dart';

/// Premium horizontal workshop cards with distance + quick actions.
class HomeWorkshopsStrip extends StatefulWidget {
  const HomeWorkshopsStrip({
    super.key,
    required this.workshops,
    required this.loading,
    this.userLatLng,
  });

  final List<WorkshopProfile> workshops;
  final bool loading;
  final LatLng? userLatLng;

  @override
  State<HomeWorkshopsStrip> createState() => _HomeWorkshopsStripState();
}

class _HomeWorkshopsStripState extends State<HomeWorkshopsStrip> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String? _distanceKm(WorkshopProfile w) {
    final g = w.geo;
    final u = widget.userLatLng;
    if (g == null || u == null) return null;
    const d = Distance();
    final km = d.as(LengthUnit.Kilometer, u, g.latLng);
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    if (widget.loading) {
      return SizedBox(
        height: 212,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: MarketUi.spacingMD),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => Container(
            width: MediaQuery.sizeOf(context).width * 0.88,
            decoration: MarketUi.card(context, colors),
          ),
        ),
      );
    }

    if (widget.workshops.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 212,
      child: PageView.builder(
        controller: _pageController,
        padEnds: false,
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: widget.workshops.length > 8 ? 8 : widget.workshops.length,
        itemBuilder: (_, i) {
          final w = widget.workshops[i];
          final hero = w.heroImage;
          final dist = _distanceKm(w);
          final cats = w.categories.take(4).toList();

          return Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? MarketUi.spacingMD : 6,
              right: 6,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: MarketUi.cardRadius,
                onTap: () => context.push(
                  '${RoutesName.workshopDetailScreen}/${w.id}',
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: MarketUi.cardRadius,
                    boxShadow: MarketUi.softElev(context),
                  ),
                  child: ClipRRect(
                    borderRadius: MarketUi.cardRadius,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hero.isNotEmpty)
                          ImageCacheNetwork(url: hero, fit: BoxFit.cover)
                        else
                          ColoredBox(color: colors.surfaceMuted),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: .1),
                                Colors.black.withValues(alpha: .72),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (w.logo.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: ImageCacheNetwork(
                                        url: w.logo,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colors.primary
                                            .withValues(alpha: .25),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(LucideIcons.wrench,
                                          color: colors.primary, size: 22),
                                    ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      w.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (dist != null)
                                    _chip(
                                      LucideIcons.navigation,
                                      dist,
                                      colors,
                                    ),
                                  _chip(
                                    LucideIcons.star,
                                    w.rating.toStringAsFixed(1),
                                    colors,
                                  ),
                                  _chip(
                                    LucideIcons.clock,
                                    w.isOpenNow
                                        ? s.workshopStatusOpen
                                        : s.workshopStatusClosed,
                                    colors,
                                    highlight: w.isOpenNow,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (cats.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  children: cats.map((c) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: .18),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.tonal(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.white
                                            .withValues(alpha: .22),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                      ),
                                      onPressed: w.phone.isEmpty
                                          ? null
                                          : () async {
                                              final uri = Uri.parse(
                                                'tel:${w.phone}',
                                              );
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri);
                                              }
                                            },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(LucideIcons.phone,
                                              size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            s.phone,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filledTonal(
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white
                                          .withValues(alpha: .22),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => context.push(
                                      '${RoutesName.workshopDetailScreen}/${w.id}',
                                    ),
                                    icon: const Icon(LucideIcons.arrowRight,
                                        size: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(IconData icon, String label, AppColors colors,
      {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? colors.success.withValues(alpha: .35)
            : Colors.white.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
