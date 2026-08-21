import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/provider/home/setFavorite/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:provider/provider.dart';

class ProductImagesSlider extends StatefulWidget {
  final List<String> images;
  final String partId;
  final String? serviceId;
  final bool initialIsFavorite;

  const ProductImagesSlider({
    super.key,
    required this.images,
    required this.partId,
    this.serviceId,
    this.initialIsFavorite = false,
  });

  @override
  State<ProductImagesSlider> createState() => _ProductImagesSliderState();
}

class _ProductImagesSliderState extends State<ProductImagesSlider> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialIsFavorite) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SetFavoriteProvider>().setFavorite(widget.partId, true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasImages = widget.images.isNotEmpty;
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.42,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: colors.surfaceMuted,
              child: hasImages
                  ? CarouselSlider(
                      options: CarouselOptions(
                        height: double.infinity,
                        viewportFraction: 1,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, _) {
                          if (mounted) {
                            setState(() => _currentIndex = index);
                          }
                        },
                      ),
                      items: widget.images.map((img) {
                        return GestureDetector(
                          onTap: () {
                            context.push(
                              RoutesName.fullScreenGallery,
                              extra: {
                                'images': widget.images,
                                'initialIndex': _currentIndex,
                              },
                            );
                          },
                          child: ImageCacheNetwork(url: img),
                        );
                      }).toList(),
                    )
                  : Center(
                      child: Icon(
                        LucideIcons.imageOff,
                        size: 56,
                        color: colors.textMuted,
                      ),
                    ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                      Colors.transparent,
                      colors.background.withOpacity(0.6),
                    ],
                    stops: const [0, 0.18, 0.65, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _RoundButton(
              icon: LucideIcons.arrowLeft,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Row(
              children: [
                Consumer<SetFavoriteProvider>(
                  builder: (context, fav, _) {
                    final isFav = fav.isFavorite(widget.partId);
                    return _RoundButton(
                      icon: LucideIcons.heart,
                      filled: isFav,
                      onTap: () async {
                        final ok = await AuthGuard.requireAuth(
                          context,
                          pending: PendingToggleFavorite(partId: widget.partId),
                        );
                        if (!ok || !context.mounted) return;
                        if (!AuthGuard.isAuthenticated(context)) return;
                        fav.toggleFavoriteDebounced(
                          widget.serviceId,
                          widget.partId,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                _RoundButton(icon: LucideIcons.share2, onTap: () {}),
              ],
            ),
          ),
          if (hasImages && widget.images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (i) {
                  final isActive = _currentIndex == i;
                  return AnimatedContainer(
                    duration: AppMotion.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _RoundButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: filled ? Colors.red : Colors.black87,
            size: 18,
            fill: filled ? 1.0 : 0.0,
          ),
        ),
      ),
    );
  }
}
