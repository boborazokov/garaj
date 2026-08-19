import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/provider/home/setFavorite/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:provider/provider.dart';

/// Modern marketplace-style product card. Used in grids on the home screen,
/// search results and seller pages. Designed around the Amber & Carbon palette.
class ProductCardGrid extends StatelessWidget {
  final Part product;
  final bool isMine;

  const ProductCardGrid({
    super.key,
    required this.product,
    this.isMine = false,
  });

  String _formatPrice(int price, String currency) {
    final formatter = NumberFormat('#,###', 'ru');
    final normalized = formatter.format(price).replaceAll(',', ' ');
    return '$normalized $currency';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;

    void open() {
      context.push(RoutesName.productDetailScreen, extra: product.id);
    }

    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rL,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: open,
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.rL,
            border: Border.all(color: colors.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boundedHeight = constraints.maxHeight.isFinite;

              Widget imageBlock = AspectRatio(
                aspectRatio: 1.05,
                child: _ProductCardImage(
                  imageUrl: imageUrl,
                  product: product,
                  colors: colors,
                ),
              );

              final textBlock = Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatPrice(product.price, product.currency),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: boundedHeight ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.tag,
                            size: 11, color: colors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.category?.name ?? "—",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              if (boundedHeight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: imageBlock),
                    textBlock,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [imageBlock, textBlock],
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

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: colors.surfaceMuted,
          child: hasImage
              ? ImageCacheNetwork(url: url)
              : Icon(LucideIcons.imageOff, size: 36, color: colors.textMuted),
        ),
        Positioned(
          left: 8,
          top: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product.isPromotionActive) ...[
                _PromotedBadge(),
                const SizedBox(width: 6),
              ],
              _ConditionBadge(isNew: product.condition),
            ],
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: Consumer<SetFavoriteProvider>(
            builder: (context, provider, _) {
              final isFav = provider.isFavorite(product.id);
              return _RoundIcon(
                icon: LucideIcons.heart,
                filled: isFav,
                onTap: () async {
                  final ok = await AuthGuard.requireAuth(
                    context,
                    pending: PendingToggleFavorite(partId: product.id),
                  );
                  if (!ok || !context.mounted) return;
                  if (!AuthGuard.isAuthenticated(context)) return;
                  provider.toggleFavoriteDebounced(null, product.id);
                },
              );
            },
          ),
        ),
        if (product.negotiable == true)
          Positioned(
            left: 8,
            bottom: 8,
            child: _SoftBadge(
              icon: LucideIcons.percent,
              label: S.of(context).negotiable,
              background: colors.primary,
              foreground: colors.onPrimary,
            ),
          ),
      ],
    );
  }
}

class _PromotedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryHover],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.flame, size: 10, color: colors.onPrimary),
          const SizedBox(width: 3),
          Text(
            S.of(context).promotedBadge,
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionBadge extends StatelessWidget {
  final bool? isNew;

  const _ConditionBadge({required this.isNew});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isNewPart = isNew == true;
    final bg = isNewPart ? colors.success : colors.warning;
    final fg = colors.onDark;
    final label =
        isNewPart ? S.of(context).newPart : S.of(context).used;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isNewPart ? fg : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _SoftBadge({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _RoundIcon({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            icon,
            size: 18,
            color: filled ? colors.danger : colors.textPrimary,
            fill: filled ? 1.0 : 0.0,
          ),
        ),
      ),
    );
  }
}
