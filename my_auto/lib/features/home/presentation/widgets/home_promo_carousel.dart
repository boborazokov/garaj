import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Auto-advancing edge-to-edge promos — products, workshops, services.
class HomePromoSlide {
  HomePromoSlide({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.gradient,
    required this.onTap,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final List<Color> gradient;
  final VoidCallback onTap;
}

class HomePromoCarousel extends StatefulWidget {
  const HomePromoCarousel({super.key, required this.slides});

  final List<HomePromoSlide> slides;

  @override
  State<HomePromoCarousel> createState() => _HomePromoCarouselState();
}

class _HomePromoCarouselState extends State<HomePromoCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (widget.slides.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 176,
            viewportFraction: .92,
            enlargeCenterPage: false,
            autoPlay: widget.slides.length > 1,
            autoPlayInterval: const Duration(seconds: 6),
            autoPlayAnimationDuration: const Duration(milliseconds: 780),
            onPageChanged: (i, _) => setState(() => _page = i),
          ),
          items: widget.slides
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: MarketUi.spacingSM),
                  child: _PromoCard(slide: e, colors: colors),
                ),
              )
              .toList(),
        ),
        if (widget.slides.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.slides.length, (i) {
                final on = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: on ? 18 : 6,
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
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.slide, required this.colors});

  final HomePromoSlide slide;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: MarketUi.cardRadius,
        onTap: slide.onTap,
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
                if (slide.imageUrl.isNotEmpty)
                  ImageCacheNetwork(url: slide.imageUrl, fit: BoxFit.cover)
                else
                  ColoredBox(color: colors.surfaceMuted),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        slide.gradient.first.withValues(alpha: .88),
                        slide.gradient.last.withValues(alpha: .55),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: Colors.white.withValues(alpha: .98),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slide.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          color: Colors.white.withValues(alpha: .88),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              slide.ctaLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(LucideIcons.arrowRight,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
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
