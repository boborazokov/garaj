import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';

class _PromoSlide {
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final List<Color> gradient;

  const _PromoSlide({
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.gradient,
  });
}

class SliderHome extends StatefulWidget {
  const SliderHome({super.key, this.horizontalPadding = 8});

  /// Side inset on home feed — keep small so slides are ~full width.
  final double horizontalPadding;

  @override
  State<SliderHome> createState() => _SliderState();
}

class _SliderState extends State<SliderHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    final slides = <_PromoSlide>[
      _PromoSlide(
        titleKey: s.parts,
        subtitleKey: s.topDeals,
        icon: LucideIcons.wrench,
        gradient: [colors.primary, colors.primaryHover],
      ),
      _PromoSlide(
        titleKey: s.services,
        subtitleKey: s.search,
        icon: LucideIcons.settings,
        gradient: const [Color(0xFF1F2937), Color(0xFF0B0F14)],
      ),
      _PromoSlide(
        titleKey: s.announcements,
        subtitleKey: s.allProducts,
        icon: LucideIcons.megaphone,
        gradient: const [Color(0xFFB45309), Color(0xFFF59E0B)],
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: slides.length,
            options: CarouselOptions(
              height: 160,
              viewportFraction: 1,
              padEnds: false,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 600),
              autoPlayCurve: Curves.easeOutCubic,
              onPageChanged: (index, _) {
                if (mounted) setState(() => _currentIndex = index);
              },
            ),
            itemBuilder: (context, index, _) {
              return _PromoCard(slide: slides[index]);
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: AppMotion.fast,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? colors.primary : colors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final _PromoSlide slide;
  const _PromoCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: slide.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.rXl,
        boxShadow: AppShadows.glow(slide.gradient.first),
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              slide.icon,
              size: 160,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(slide.icon, size: 12, color: Colors.white),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        slide.subtitleKey,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                slide.titleKey,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                S.of(context).appMarketplaceTagline,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
