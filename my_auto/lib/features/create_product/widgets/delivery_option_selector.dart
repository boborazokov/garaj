import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:my_auto/generated/l10n.dart';

/// Delivery chips aligned with legacy add-product form and [deliveryCondition] API.
class DeliveryOptionSelector extends StatelessWidget {
  const DeliveryOptionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DeliveryOption value;
  final ValueChanged<DeliveryOption> onChanged;

  static const _options = [
    DeliveryOption.included,
    DeliveryOption.notIncluded,
    DeliveryOption.byAgreement,
  ];

  String _label(S s, DeliveryOption option) {
    switch (option) {
      case DeliveryOption.included:
        return s.available;
      case DeliveryOption.notIncluded:
        return s.noAvailable;
      case DeliveryOption.byAgreement:
        return s.byAgreement;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.delivery,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _options.map((option) {
            final selected = value == option;
            return ChoiceChip(
              label: Text(_label(s, option)),
              selected: selected,
              onSelected: (_) => onChanged(option),
              selectedColor: colors.primary.withValues(alpha: 0.18),
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? colors.primary : colors.textPrimary,
              ),
              side: BorderSide(
                color: selected ? colors.primary : colors.border,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
            );
          }).toList(),
        ),
      ],
    );
  }
}
