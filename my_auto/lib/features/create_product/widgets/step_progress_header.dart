import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final idx = _steps.indexOf(current);
    final progress = _steps.isEmpty ? 0.0 : (idx + 1) / _steps.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.rXl,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.surfaceMuted,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                s.createProductStepProgress(idx + 1, _steps.length),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colors.textMuted,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (draftSavedAt != null)
                Text(
                  s.createProductDraftSaved,
                  style: TextStyle(fontSize: 11, color: colors.success),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
