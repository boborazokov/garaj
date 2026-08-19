import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/advertisement/data/advertisement_repository.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/utils/ad_link_launcher.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Reusable banner slot. Fetches ads for [surface], auto-rotates when there
/// are 2+ banners, and opens [Advertisement.link] on tap when a link exists.
class AdBanner extends StatefulWidget {
  const AdBanner({
    super.key,
    required this.surface,
    this.height = 140,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.maxItems = 5,
    this.repository,
  });

  final AdSurface surface;
  final double height;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  final int maxItems;
  final AdvertisementRepository? repository;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  late final AdvertisementRepository _repo =
      widget.repository ?? AdvertisementRepository();
  Future<List<Advertisement>>? _future;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = _repo.list(surface: widget.surface);
  }

  @override
  void didUpdateWidget(covariant AdBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surface != widget.surface ||
        oldWidget.maxItems != widget.maxItems) {
      _future = _repo.list(surface: widget.surface);
      _page = 0;
    }
  }

  Future<void> _onTap(Advertisement ad) async {
    await openAdvertisementLink(context, ad.link);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Advertisement>>(
      future: _future,
      builder: (context, snapshot) {
        final ads = snapshot.data ?? const <Advertisement>[];
        if (ads.isEmpty) return const SizedBox.shrink();

        final items = ads.take(widget.maxItems).toList(growable: false);
        final colors = context.appColors;
        final multiple = items.length > 1;

        return Padding(
          padding: widget.margin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: widget.borderRadius,
                child: SizedBox(
                  height: widget.height,
                  width: double.infinity,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: widget.height,
                      viewportFraction: 1,
                      padEnds: false,
                      autoPlay: multiple,
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 650),
                      autoPlayCurve: Curves.easeOutCubic,
                      enableInfiniteScroll: multiple,
                      pauseAutoPlayOnTouch: true,
                      onPageChanged: (i, _) => setState(() => _page = i),
                    ),
                    items: items.map((ad) {
                      return _AdSlide(
                        ad: ad,
                        colors: colors,
                        borderRadius: widget.borderRadius,
                        onTap: advertisementLinkHasTarget(ad.link)
                            ? () => unawaited(_onTap(ad))
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (multiple)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(items.length, (i) {
                      final on = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: on ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: on ? colors.primary : colors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AdSlide extends StatelessWidget {
  const _AdSlide({
    required this.ad,
    required this.colors,
    required this.borderRadius,
    this.onTap,
  });

  final Advertisement ad;
  final AppColors colors;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  bool get _hasLink => advertisementLinkHasTarget(ad.link);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surfaceMuted,
      child: MouseRegion(
        cursor: _hasLink ? SystemMouseCursors.click : MouseCursor.defer,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
            ImageCacheNetwork(url: ad.bannerImageUrl, fit: BoxFit.cover),
            if (_hasLink)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'AD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (ad.title.isNotEmpty)
                    Expanded(
                      child: Text(
                        ad.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
