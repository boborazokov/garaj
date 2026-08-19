import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/orders/bloc/order_detail/order_detail_bloc.dart';
import 'package:my_auto/features/orders/bloc/order_detail/order_detail_event.dart';
import 'package:my_auto/features/orders/domain/entities/order.dart';
import 'package:my_auto/generated/l10n.dart';

/// Owner-only status banner and close / reopen actions.
class OrderOwnerActions extends StatelessWidget {
  const OrderOwnerActions({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;
    final isClosed = order.status == OrderStatus.closed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isClosed
                ? colors.textMuted.withValues(alpha: 0.12)
                : colors.success.withValues(alpha: 0.12),
            borderRadius: AppRadius.rL,
            border: Border.all(
              color: isClosed
                  ? colors.textMuted.withValues(alpha: 0.35)
                  : colors.success.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isClosed ? LucideIcons.archive : LucideIcons.circleDot,
                size: 20,
                color: isClosed ? colors.textMuted : colors.success,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isClosed ? s.orderStatusClosed : s.orderStatusActive,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isClosed ? colors.textMuted : colors.success,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isClosed)
          FilledButton.icon(
            onPressed: () => _confirmReopen(context),
            icon: const Icon(LucideIcons.rotateCcw),
            label: Text(s.reopenOrder),
          )
        else
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              foregroundColor: colors.danger,
              backgroundColor: colors.danger.withValues(alpha: 0.12),
            ),
            onPressed: () => _confirmClose(context),
            icon: const Icon(LucideIcons.archive),
            label: Text(s.closeOrder),
          ),
      ],
    );
  }

  Future<void> _confirmClose(BuildContext context) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.closeOrder),
        content: Text(s.closeOrderConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.yes),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<OrderDetailBloc>().add(const OrderDetailCloseRequested());
    }
  }

  Future<void> _confirmReopen(BuildContext context) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.reopenOrder),
        content: Text(s.reopenOrderConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.yes),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<OrderDetailBloc>().add(const OrderDetailReopenRequested());
    }
  }
}
