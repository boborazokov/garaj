import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/core/provider/profile/removePartsById/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/promotion/presentation/promote_product_sheet.dart';
import 'package:my_auto/features/profile/widgets/my_listing_card_helpers.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:provider/provider.dart';

class MyProductCard extends StatelessWidget {
  final bool isMine;
  final Part product;
  final bool isDepleted;

  const MyProductCard({
    super.key,
    required this.product,
    this.isMine = false,
    this.isDepleted = false,
  });

  String _formatPrice(int price, String currency) {
    final formatter = NumberFormat('#,###', 'ru');
    return '${formatter.format(price).replaceAll(',', ' ')} $currency';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final provider = context.watch<ProductProvider>();
    final providerRemove = context.watch<RemovePartsByIdProvider>();
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;

    final statusLabel = isDepleted
        ? s.depleted
        : s.availableUntil(DateFormat('d MMMM').format(product.activeUntil));

    void openDetail() =>
        context.push(RoutesName.productDetailScreen, extra: product.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.s,
        AppSpacing.screenPadding,
        0,
      ),
      child: Material(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: openDetail,
          child: Ink(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.rL,
              border: Border.all(color: colors.border),
              boxShadow: AppShadows.card(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.rM,
                        child: SizedBox(
                          width: 92,
                          height: 92,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                color: colors.surfaceMuted,
                                child: imageUrl != null
                                    ? ImageCacheNetwork(url: imageUrl)
                                    : Icon(
                                        LucideIcons.imageOff,
                                        size: 28,
                                        color: colors.textMuted,
                                      ),
                              ),
                              if (product.isPromotionActive)
                                Positioned(
                                  left: 6,
                                  top: 6,
                                  child: _PromotedRibbon(
                                    colors: colors,
                                    label: s.promotedBadge,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatPrice(product.price, product.currency),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.primary,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            MyListingStatusChip(
                              label: statusLabel,
                              isActive: !isDepleted,
                            ),
                            if (product.category?.name != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                product.category!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.divider),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isMine && !isDepleted) ...[
                        MyListingPromoteButton(
                          label: product.isPromotionActive
                              ? s.promotedTop
                              : s.promoteToTop,
                          isActive: product.isPromotionActive,
                          onTap: () async {
                            final ok = await showPromoteProductSheet(
                              context,
                              product: product,
                            );
                            if (ok != true || !context.mounted) return;
                            final sellerId = product.seller?.id;
                            if (sellerId == null || sellerId.isEmpty) return;
                            await context.read<ProductProvider>().loadList(
                                  filters: {'seller': sellerId},
                                  reset: true,
                                  sort: 'NEWEST',
                                );
                          },
                        ),
                        const SizedBox(height: AppSpacing.s),
                      ],
                      Row(
                        children: [
                          MyListingActionButton(
                            icon: LucideIcons.pencil,
                            label: s.edit,
                            color: colors.primary,
                            onTap: () => context.push(
                              RoutesName.addProduct,
                              extra: product,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          MyListingActionButton(
                            icon: LucideIcons.trash2,
                            label: s.delete,
                            color: colors.danger,
                            onTap: () => _showDeleteDialog(
                              context,
                              provider,
                              providerRemove,
                            ),
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
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProductProvider provider,
    RemovePartsByIdProvider providerRemove,
  ) {
    final colors = context.appColors;
    final s = S.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.trash2, color: colors.danger),
            const SizedBox(width: 12),
            Expanded(child: Text(s.deleteProductTitle)),
          ],
        ),
        content: Text(s.areYouSureToDeleteProduct),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.danger),
            onPressed: () {
              provider.removeProductById(product.id);
              providerRemove.removePartsById(product.id, context);
              context.pop(true);
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }
}

class _PromotedRibbon extends StatelessWidget {
  const _PromotedRibbon({
    required this.colors,
    required this.label,
  });

  final AppColors colors;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryHover],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.flame, size: 9, color: colors.onPrimary),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
