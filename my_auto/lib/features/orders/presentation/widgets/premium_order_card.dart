import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/card_date_region.dart';

import '../../domain/entities/order.dart';
import 'order_images.dart';

/// Buy-request card. [compact] = 2-per-row grid tile.
class PremiumOrderCard extends StatelessWidget {
  const PremiumOrderCard({
    super.key,
    required this.order,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.onClose,
    this.onDelete,
    this.compact = false,
  });

  final Order order;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onClose;
  final VoidCallback? onDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return compact ? _CompactRequestCard(this) : _FullRequestCard(this);
  }
}

class _CompactRequestCard extends StatelessWidget {
  const _CompactRequestCard(this.parent);
  final PremiumOrderCard parent;

  @override
  Widget build(BuildContext context) {
    final order = parent.order;
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final hasImage = order.primaryImageUrl != null;

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
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('${RoutesName.orderDetail}/${order.id}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 96,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: colors.primary.withValues(alpha: 0.08),
                      child: hasImage
                          ? OrderCardThumbnail(
                              imagePath: order.primaryImageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Center(
                              child: Icon(
                                LucideIcons.imageOff,
                                size: 28,
                                color: colors.primary.withValues(alpha: 0.45),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Pill(
                        label: s.wantToBuyRequestBadge,
                        bg: colors.surface.withValues(alpha: 0.95),
                        fg: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.title.replaceAll('\n', ' ').trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (order.vehicleLabel.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          order.vehicleLabel.replaceAll('\n', ' ').trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _budgetLabel(context, order),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: CardDateRegion(
                              createdAt: order.createdAt,
                              region: order.region,
                              fontSize: 10,
                            ),
                          ),
                          if (order.viewsCount > 0) ...[
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.eye,
                              size: 11,
                              color: colors.textMuted,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${order.viewsCount}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullRequestCard extends StatelessWidget {
  const _FullRequestCard(this.parent);
  final PremiumOrderCard parent;

  @override
  Widget build(BuildContext context) {
    final order = parent.order;
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);

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
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('${RoutesName.orderDetail}/${order.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: AppRadius.rL,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: order.primaryImageUrl != null
                      ? OrderCardThumbnail(
                          imagePath: order.primaryImageUrl!,
                          width: 72,
                          height: 72,
                        )
                      : Icon(
                          LucideIcons.clipboardList,
                          color: colors.primary.withValues(alpha: 0.6),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Pill(
                            label: s.wantToBuyRequestBadge,
                            bg: colors.primary.withValues(alpha: 0.12),
                            fg: colors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.title.replaceAll('\n', ' ').trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      if (order.vehicleLabel.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          order.vehicleLabel.replaceAll('\n', ' ').trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        _budgetLabel(context, order),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CardDateRegion(
                        createdAt: order.createdAt,
                        region: order.region,
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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

String _budgetLabel(BuildContext context, Order order) {
  if (order.budget <= 0) return S.of(context).negotiable;
  final cur = order.currency?.isNotEmpty == true ? order.currency! : 'UZS';
  // Non-breaking spaces so "10 500 000 UZS" never splits mid-number.
  return '${_groupThousands(order.budget)}\u00A0$cur';
}

String _groupThousands(int value) {
  final digits = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    if (i > 0 && fromEnd % 3 == 0) buf.write('\u00A0');
    buf.write(digits[i]);
  }
  return buf.toString();
}
