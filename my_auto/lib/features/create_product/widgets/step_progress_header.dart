import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';

class StepProgressHeader extends StatelessWidget {
  const StepProgressHeader({
    super.key,
    required this.current,
    this.draftSavedAt,
  });

  final CreateProductStep current;
  final DateTime? draftSavedAt;

  static const _steps = CreateProductStep.values;

  String _stepLabel(S s, CreateProductStep step) {
    switch (step) {
      case CreateProductStep.photos:
        return s.createProductStepPhotos;
      case CreateProductStep.vehicle:
        return s.createProductStepVehicle;
      case CreateProductStep.info:
        return s.createProductStepInfo;
      case CreateProductStep.price:
        return s.createProductStepPrice;
      case CreateProductStep.preview:
        return s.createProductStepPreview;
      case CreateProductStep.boost:
        return s.createProductStepBoost;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final idx = _steps.indexOf(current);
    final progress = _steps.isEmpty ? 0.0 : (idx + 1) / _steps.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MarketUi.spacingMD,
        AppSpacing.s,
        MarketUi.spacingMD,
        AppSpacing.m,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: MarketUi.productSection(context, colors),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: s.createProductStepProgress(
                            idx + 1,
                            _steps.length,
                          ),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' · ${_stepLabel(s, current)}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (draftSavedAt != null)
                  Text(
                    s.createProductDraftSaved,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                for (var i = 0; i < _steps.length; i++) ...[
                  Expanded(
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= idx ? colors.primary : colors.surfaceMuted,
                        borderRadius: AppRadius.rXl,
                        border: i <= idx
                            ? null
                            : Border.all(color: colors.border),
                      ),
                    ),
                  ),
                  if (i != _steps.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            ClipRRect(
              borderRadius: AppRadius.rXl,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: colors.surfaceMuted,
                color: colors.primary.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
