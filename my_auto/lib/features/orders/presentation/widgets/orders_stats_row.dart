import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

import '../../domain/entities/order_stats.dart';

class OrdersStatsRow extends StatelessWidget {
  const OrdersStatsRow({super.key, required this.stats});

  final OrderStats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: LucideIcons.zap,
              label: 'Active',
              value: stats.activeRequests.toString(),
              accent: context.appColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: LucideIcons.messageCircle,
              label: 'Responses',
              value: stats.totalResponses.toString(),
              accent: context.appColors.info,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: LucideIcons.checkCircle2,
              label: 'Closed',
              value: stats.closedRequests.toString(),
              accent: context.appColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
