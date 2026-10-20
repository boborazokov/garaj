import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/order/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/card_date_region.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:url_launcher/url_launcher.dart';

/// Buy-request card for home strip / lists.
class OrderCard extends StatelessWidget {
  final OrderItem order;
  final bool compact;

  const OrderCard({
    super.key,
    required this.order,
    this.compact = false,
  });

  Future<void> _call() async {
    final phone = order.phone.trim();
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _budget(BuildContext context) {
    final s = S.of(context);
    if (order.budget <= 0) return s.negotiable;
    final cur = (order.currency?.trim().isNotEmpty == true)
        ? order.currency!.trim()
        : 'UZS';
    return '${_groupThousands(order.budget)}\u00A0$cur';
  }

  static String _groupThousands(int value) {
    final digits = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final fromEnd = digits.length - i;
      if (i > 0 && fromEnd % 3 == 0) buf.write('\u00A0');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return compact ? _CompactCard(this) : _FullCard(this);
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard(this.parent);
  final OrderCard parent;

  @override
  Widget build(BuildContext context) {
    final order = parent.order;
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final vehicle = order.vehicleLabel;
    final image = order.primaryImageUrl;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.rL,
        boxShadow: MarketUi.softElev(context),
        border: Border.all(color: colors.border.withValues(alpha: 0.45)),
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
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: colors.primary.withValues(alpha: 0.08),
                      child: image != null
                          ? ImageCacheNetwork(url: image, fit: BoxFit.cover)
                          : Center(
                              child: Icon(
                                LucideIcons.clipboardList,
                                size: 28,
                                color: colors.primary.withValues(alpha: 0.55),
                              ),
                            ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.wantToBuyRequestBadge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      parent._budget(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.title.replaceAll('\n', ' ').trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        fontSize: 13,
                      ),
                    ),
                    if (vehicle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        vehicle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
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
    );
  }
}

class _FullCard extends StatelessWidget {
  const _FullCard(this.parent);
  final OrderCard parent;

  @override
  Widget build(BuildContext context) {
    final order = parent.order;
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final vehicle = order.vehicleLabel;
    final part = OrderItem.isMeaningfulLabel(order.partCategory?.name)
        ? order.partCategory!.name
        : '';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.rL,
        boxShadow: MarketUi.softElev(context),
        border: Border.all(color: colors.border.withValues(alpha: 0.45)),
      ),
      child: Material(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.push('${RoutesName.orderDetail}/${order.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        parent._budget(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    if (order.isPromoted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          s.promotedBadge,
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  order.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (vehicle.isNotEmpty || part.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    [if (part.isNotEmpty) part, if (vehicle.isNotEmpty) vehicle]
                        .join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                CardDateRegion(
                  createdAt: order.createdAt,
                  region: order.region,
                  fontSize: 12,
                ),
                if (order.phone.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: parent._call,
                      icon: const Icon(LucideIcons.phone, size: 16),
                      label: Text(s.callAuthor),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.border),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
