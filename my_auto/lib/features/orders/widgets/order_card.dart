import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/model/order/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// Compact card representation of an [OrderItem]. Used in the public
/// announcements feed and in "My requests".
class OrderCard extends StatelessWidget {
  final OrderItem order;

  const OrderCard({super.key, required this.order});

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: order.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatWhen(DateTime dt) {
    final local = dt.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy, HH:mm').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);

    final tags = <String>[
      if (order.brand?.name != null) order.brand!.name,
      if (order.carModel?.name != null) order.carModel!.name,
      if (order.partCategory?.name != null) order.partCategory!.name,
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(
          color: order.isPromoted
              ? colors.primary.withOpacity(0.6)
              : colors.border,
          width: order.isPromoted ? 1.4 : 1,
        ),
        boxShadow: order.isPromoted
            ? AppShadows.glow(colors.primary)
            : AppShadows.card(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (order.isPromoted) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.primaryHover],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.flame,
                            size: 11, color: colors.onPrimary),
                        const SizedBox(width: 3),
                        Text(
                          s.promotedBadge,
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    order.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (order.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                order.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colors.border),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(LucideIcons.clock, size: 13, color: colors.textMuted),
                const SizedBox(width: 4),
                Text(
                  _formatWhen(order.createdAt),
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(LucideIcons.mapPin, size: 13, color: colors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    (order.location?.isNotEmpty ?? false)
                        ? order.location!
                        : (order.region ?? '—'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (order.budget > 0) ...[
                  Icon(LucideIcons.wallet, size: 13, color: colors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${order.budget} ${order.currency ?? ''}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _call,
                    icon: const Icon(LucideIcons.phone, size: 16),
                    label: Text(s.callAuthor),
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
