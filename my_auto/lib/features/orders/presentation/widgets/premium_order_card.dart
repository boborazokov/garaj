import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/order.dart';
import '../utils/order_author_chat.dart';
import 'order_images.dart';

class PremiumOrderCard extends StatelessWidget {
  const PremiumOrderCard({
    super.key,
    required this.order,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.onClose,
    this.onDelete,
  });

  final Order order;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onClose;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
        color: colors.surface,
        borderRadius: AppRadius.rXl,
        elevation: 0,
        shadowColor: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.rXl,
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('${RoutesName.orderDetail}/${order.id}');
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: AppRadius.rXl,
              border: Border.all(
                color: order.isPromoted
                    ? colors.primary.withValues(alpha: 0.35)
                    : colors.border.withValues(alpha: 0.5),
              ),
              boxShadow: AppShadows.card(context),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.primaryImageUrl != null) ...[
                        OrderCardThumbnail(imagePath: order.primaryImageUrl!),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.vehicleLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusChip(status: order.displayStatus),
                    ],
                  ),
                  if (order.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      order.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textMuted, height: 1.35),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: LucideIcons.wallet,
                        label: _budgetLabel(order),
                      ),
                      if ((order.location ?? '').isNotEmpty)
                        _MetaChip(
                          icon: LucideIcons.mapPin,
                          label: order.location!,
                        ),
                      if (order.urgency != null &&
                          order.urgency != OrderUrgency.medium)
                        _UrgencyChip(urgency: order.urgency!),
                      if (order.responseCount > 0)
                        _MetaChip(
                          icon: LucideIcons.users,
                          label: '${order.responseCount} responses',
                          highlight: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        _timeAgo(order.createdAt),
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                      const Spacer(),
                      if (order.isPromoted)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: AppRadius.rM,
                          ),
                          child: Text(
                            'BOOSTED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      _IconAction(
                        icon: isFavorite
                            ? LucideIcons.heart
                            : LucideIcons.heart,
                        filled: isFavorite,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onFavoriteToggle();
                        },
                      ),
                      _IconAction(
                        icon: LucideIcons.messageSquare,
                        onTap: () => openOrderAuthorChat(context, order),
                      ),
                      _IconAction(
                        icon: LucideIcons.phone,
                        onTap: () => launchUrl(Uri.parse('tel:${order.phone}')),
                      ),
                      _IconAction(
                        icon: LucideIcons.share2,
                        onTap: () => Share.share(
                          '${order.title}\n${order.description}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  String _budgetLabel(Order order) {
    if (order.budget <= 0) return 'Budget: negotiable';
    final cur = order.currency?.isNotEmpty == true ? order.currency! : 'UZS';
    return '$cur ${order.budget}';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OrderDisplayStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (label, bg, fg) = switch (status) {
      OrderDisplayStatus.open => ('OPEN', colors.success.withValues(alpha: 0.15), colors.success),
      OrderDisplayStatus.inProgress => ('ACTIVE', colors.info.withValues(alpha: 0.15), colors.info),
      OrderDisplayStatus.closed => ('CLOSED', colors.surfaceMuted, colors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rM),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? colors.primary.withValues(alpha: 0.1)
            : colors.surfaceMuted,
        borderRadius: AppRadius.rM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: highlight ? colors.primary : colors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight ? colors.primary : colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgencyChip extends StatelessWidget {
  const _UrgencyChip({required this.urgency});
  final OrderUrgency urgency;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (label, icon, highlight) = switch (urgency) {
      OrderUrgency.urgent => (s.orderUrgencyUrgent, LucideIcons.flame, true),
      OrderUrgency.medium => (s.orderUrgencyNormal, LucideIcons.clock, false),
      OrderUrgency.low => (s.orderUrgencyLow, LucideIcons.minus, false),
    };
    return _MetaChip(icon: icon, label: label, highlight: highlight);
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
        color: filled ? colors.danger : colors.textMuted,
        fill: filled ? 1.0 : 0.0,
      ),
    );
  }
}
