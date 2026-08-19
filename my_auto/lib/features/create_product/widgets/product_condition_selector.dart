import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:my_auto/generated/l10n.dart';

/// Localized New / Used picker for the create-listing flow.
class ProductConditionSelector extends StatelessWidget {
  const ProductConditionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ProductCondition value;
  final ValueChanged<ProductCondition> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Row(
      children: [
        Expanded(
          child: _ConditionCard(
            selected: value == ProductCondition.newPart,
            icon: LucideIcons.sparkles,
            label: s.newPart,
            hint: s.createProductConditionNewHint,
            accent: colors.success,
            onTap: () => onChanged(ProductCondition.newPart),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ConditionCard(
            selected: value == ProductCondition.used,
            icon: LucideIcons.recycle,
            label: s.used,
            hint: s.createProductConditionUsedHint,
            accent: colors.warning,
            onTap: () => onChanged(ProductCondition.used),
          ),
        ),
      ],
    );
  }
}

class _ConditionCard extends StatelessWidget {
  const _ConditionCard({
    required this.selected,
    required this.icon,
    required this.label,
    required this.hint,
    required this.accent,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final String hint;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final borderColor = selected ? accent : colors.border;
    final bg = selected ? accent.withValues(alpha: 0.12) : colors.surfaceMuted;

    return Material(
      color: bg,
      borderRadius: AppRadius.rL,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rL,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rL,
            border: Border.all(
              color: borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: selected ? accent : colors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(LucideIcons.checkCircle2, size: 18, color: accent),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                hint,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
