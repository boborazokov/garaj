import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/promotion/presentation/promotion_plan_badge.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/card_date_region.dart';
import 'package:my_auto/widgets/favorite_heart_button.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Marketplace product card — photo, price, title, place · time, views.
class ProductCardGrid extends StatelessWidget {
  final Part product;
  final bool isMine;

  /// Parent already gave a fixed height (feed grid) — use [Expanded] image.
  final bool expandImage;

  /// Logical px hint for decode size (halves GPU work on fling).
  final double? imageCacheWidth;

  const ProductCardGrid({
    super.key,
    required this.product,
    this.isMine = false,
    this.expandImage = false,
    this.imageCacheWidth,
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

    final image = _ProductCardImage(
      imageUrl: imageUrl,
      product: product,
      colors: colors,
      cacheWidth: imageCacheWidth ?? 180,
    );

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              fontSize: 15,
              height: 1.15,
              letterSpacing: -0.2,
            ),
          ),
          if (product.negotiable == true && showPrice) ...[
            const SizedBox(height: 2),
            Text(
              s.negotiable,
              maxLines: 1,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textPrimary.withValues(alpha: 0.82),
              fontWeight: FontWeight.w500,
              height: 1.25,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CardDateRegion(
                  createdAt: product.createdAt,
                  region: product.region,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                LucideIcons.eye,
                size: 12,
                color: colors.textMuted,
              ),
              const SizedBox(width: 3),
              Text(
                '${product.viewsCount}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final column = expandImage
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: image),
              body,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(aspectRatio: 1, child: image),
              body,
            ],
          );

    return RepaintBoundary(
      child: MarketCardShell(
        lite: true,
        onTap: () =>
            context.push(RoutesName.productDetailScreen, extra: product.id),
        child: column,
      ),
    );
  }
}

class _ProductCardImage extends StatelessWidget {
  const _ProductCardImage({
    required this.imageUrl,
    required this.product,
    required this.colors,
    required this.cacheWidth,
  });

  final String? imageUrl;
  final Part product;
  final AppColors colors;
  final double cacheWidth;

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
              ? ImageCacheNetwork(
                  url: url,
                  fit: BoxFit.cover,
                  cacheWidth: cacheWidth,
                )
              : Icon(LucideIcons.imageOff, size: 36, color: colors.textMuted),
        ),
        if (product.isPromotionActive)
          Positioned(
            left: 8,
            top: 8,
            child: PromotionPlanBadge(plan: product.promotionPlan),
          ),
        if (isNew)
          Positioned(
            left: 8,
            bottom: 8,
            child: MarketBadgeChip(label: s.newPart, dense: true),
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
