import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/generated/l10n.dart';

/// Compact facts row under the title — delivery + quantity/negotiable.
class ProductInfo extends StatelessWidget {
  final String delivery;
  final bool condition;
  final bool negotiable;
  final int? quantity;

  const ProductInfo({
    super.key,
    required this.condition,
    required this.delivery,
    required this.negotiable,
    this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final deliveryText = delivery.trim().isEmpty ? '—' : delivery.trim();

    final rows = <_Fact>[
      _Fact(
        icon: LucideIcons.truck,
        label: s.delivery,
        value: deliveryText,
      ),
      _Fact(
        icon: LucideIcons.percent,
        label: s.negotiable,
        value: negotiable ? s.yes : s.no,
      ),
      if (quantity != null && quantity! > 0)
        _Fact(
          icon: LucideIcons.boxes,
          label: s.quantity,
          value: '$quantity',
        ),
    ];

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        color: colors.surface,
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              _FactRow(fact: rows[i]),
              if (i != rows.length - 1)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colors.border.withValues(alpha: 0.6),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Fact {
  const _Fact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.fact});

  final _Fact fact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Icon(fact.icon, size: 18, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fact.label,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Text(
              fact.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
