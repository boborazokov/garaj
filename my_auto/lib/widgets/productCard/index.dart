import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/card_date_region.dart';
import 'package:my_auto/widgets/favorite_heart_button.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Clear marketplace product card.
/// Hierarchy: photo → price → title → place · time.
class ProductCardGrid extends StatelessWidget {
  final Part product;
  final bool isMine;

  const ProductCardGrid({
    super.key,
    required this.product,
    this.isMine = false,
  });

  String _formatPrice(int price, String currency) {
    final raw = price.toString();
    final parts = <String>[];
    for (var i = raw.length; i > 0; i -= 3) {
      final start = i - 3 < 0 ? 0 : i - 3;
      parts.add(raw.substring(start, i));
    }
    return '${parts.reversed.join(' ')} $currency';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    final showPrice =
        !(product.negotiable == true && product.price <= 0);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.rL,
        boxShadow: MarketUi.softElev(context),
      ),
      child: Material(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.push(RoutesName.productDetailScreen, extra: product.id),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bounded = constraints.maxHeight.isFinite;

              final image = _ProductCardImage(
                imageUrl: imageUrl,
                product: product,
                colors: colors,
              );

              final body = Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showPrice
                          ? _formatPrice(product.price, product.currency)
                          : s.negotiable,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                        fontSize: 15,
                        height: 1.1,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (product.negotiable == true && showPrice) ...[
                      const SizedBox(height: 1),
                      Text(
                        s.negotiable,
                        maxLines: 1,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      product.name,
                      maxLines: bounded ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CardDateRegion(
                      createdAt: product.createdAt,
                      region: product.region,
                    ),
                  ],
                ),
              );

              if (bounded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: image),
                    body,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(aspectRatio: 1, child: image),
                  body,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProductCardImage extends StatelessWidget {
  const _ProductCardImage({
    required this.imageUrl,
    required this.product,
    required this.colors,
  });

  final String? imageUrl;
  final Part product;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final hasImage = url.isNotEmpty;
    final s = S.of(context);
    final isNew = product.condition == true;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: colors.surfaceMuted,
          child: hasImage
              ? ImageCacheNetwork(url: url, fit: BoxFit.cover)
              : Icon(LucideIcons.imageOff, size: 36, color: colors.textMuted),
        ),
        Positioned(
          left: 8,
          top: 8,
          child: product.isPromotionActive
              ? _Chip(
                  label: s.promotedBadge,
                  icon: LucideIcons.flame,
                  background: colors.primary,
                  foreground: colors.onPrimary,
                )
              : const SizedBox.shrink(),
        ),
        if (isNew)
          Positioned(
            left: 8,
            bottom: 8,
            child: _Chip(
              label: s.newPart,
              background: colors.success,
              foreground: Colors.white,
            ),
          ),
        Positioned(
          right: 6,
          top: 6,
          child: FavoriteHeartButton(
            partId: product.id,
            onLightImage: true,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
