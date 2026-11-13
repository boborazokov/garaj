import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:my_auto/generated/l10n.dart';

/// Delivery availability — two side-by-side toggles (available / not available).
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
        Row(
          children: [
            for (var i = 0; i < _options.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.m),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => onChanged(_options[i]),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: value == _options[i]
                          ? colors.primary.withValues(alpha: 0.08)
                          : colors.surface,
                      foregroundColor: value == _options[i]
                          ? colors.primary
                          : colors.textSecondary,
                      side: BorderSide(
                        color: value == _options[i]
                            ? colors.primary
                            : colors.border,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.rM,
                      ),
                    ),
                    child: Text(
                      _label(s, _options[i]),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
