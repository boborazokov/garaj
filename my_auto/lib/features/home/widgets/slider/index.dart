import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';

class _PromoSlide {
  final String titleKey;
  final String subtitleKey;
  final IconData icon;

  const _PromoSlide({
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
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
      ),
      _PromoSlide(
        titleKey: s.services,
        subtitleKey: s.search,
        icon: LucideIcons.settings,
      ),
      _PromoSlide(
        titleKey: s.announcements,
        subtitleKey: s.allProducts,
        icon: LucideIcons.megaphone,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: slides.length,
            options: CarouselOptions(
              height: 148,
              viewportFraction: 1,
              padEnds: false,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 500),
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
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.rL,
          border: Border.all(color: colors.border),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: AppRadius.rM,
                border: Border.all(color: colors.border),
              ),
              child: Icon(slide.icon, size: 18, color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              slide.titleKey,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              slide.subtitleKey,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
