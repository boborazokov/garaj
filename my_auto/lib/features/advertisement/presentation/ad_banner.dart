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
    /// Bump this (e.g. on pull-to-refresh) to force a network reload.
    this.refreshToken = 0,
  });

  final AdSurface surface;
  final double height;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  final int maxItems;
  final AdvertisementRepository? repository;
  final int refreshToken;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner>
    with AutomaticKeepAliveClientMixin {
  /// Survives scroll dispose/rebuild so returning to top does not flash.
  static final Map<AdSurface, List<Advertisement>> _memoryCache = {};

  late final AdvertisementRepository _repo =
      widget.repository ?? AdvertisementRepository();

  late List<Advertisement> _ads;
  bool _loading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ads = List<Advertisement>.from(_memoryCache[widget.surface] ?? const []);
    _loading = _ads.isEmpty;
    unawaited(_load(forceNetwork: false));
  }

  @override
  void didUpdateWidget(covariant AdBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surface != widget.surface) {
      _ads = List<Advertisement>.from(_memoryCache[widget.surface] ?? const []);
      _loading = _ads.isEmpty;
      unawaited(_load(forceNetwork: false));
      return;
    }
    if (oldWidget.maxItems != widget.maxItems ||
        oldWidget.refreshToken != widget.refreshToken) {
      unawaited(
        _load(forceNetwork: oldWidget.refreshToken != widget.refreshToken),
      );
    }
  }

  Future<void> _load({required bool forceNetwork}) async {
    // Never clear visible ads while refreshing — that causes the flicker
    // when the list rebuilds or the user scrolls back to the top.
    if (_ads.isEmpty && mounted) {
      setState(() => _loading = true);
    }

    try {
      final result = await _repo.list(
        surface: widget.surface,
        forceNetwork: forceNetwork,
      );
      if (!mounted) return;

      if (result.isNotEmpty) {
        _memoryCache[widget.surface] = result;
        setState(() {
          _ads = result;
          _loading = false;
        });
      } else {
        setState(() {
          if (forceNetwork) {
            _memoryCache.remove(widget.surface);
            _ads = const [];
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _onTap(Advertisement ad) async {
    await openAdvertisementLink(context, ad.link);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.appColors;
    final items = _ads.take(widget.maxItems).toList(growable: false);

    if (!_loading && items.isEmpty) {
      return const SizedBox.shrink();
    }

    // While first load has no cache yet, reserve no space — avoids a grey
    // flash that then "suddenly" becomes the real banner.
    if (_loading && items.isEmpty) {
      return const SizedBox.shrink();
    }

    final multiple = items.length > 1;

    return Padding(
      padding: widget.margin,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        clipBehavior: Clip.hardEdge,
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
              autoPlayAnimationDuration: const Duration(milliseconds: 650),
              autoPlayCurve: Curves.easeOutCubic,
              enableInfiniteScroll: multiple,
              pauseAutoPlayOnTouch: true,
              enlargeCenterPage: false,
              scrollPhysics: multiple
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
            ),
            items: [
              for (final ad in items)
                _AdSlide(
                  key: ValueKey(ad.id),
                  ad: ad,
                  colors: colors,
                  borderRadius: widget.borderRadius,
                  onTap: advertisementLinkHasTarget(ad.link)
                      ? () => unawaited(_onTap(ad))
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdSlide extends StatelessWidget {
  const _AdSlide({
    super.key,
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
              LayoutBuilder(
                builder: (context, constraints) {
                  return ImageCacheNetwork(
                    url: ad.bannerImageUrl,
                    fit: BoxFit.cover,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  );
                },
              ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
