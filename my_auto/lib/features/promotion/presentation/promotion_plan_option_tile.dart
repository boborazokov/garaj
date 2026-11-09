import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

/// Selectable plan row used by promote sheet and create-flow boost step.
class PromotionPlanOptionTile extends StatelessWidget {
  const PromotionPlanOptionTile({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.enabled = true,
    this.recommended = false,
    this.recommendedLabel,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool recommended;
  final String? recommendedLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '$title. $subtitle. $trailing',
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.08)
            : colors.surfaceMuted.withValues(alpha: 0.55),
        borderRadius: AppRadius.rL,
        child: InkWell(
          borderRadius: AppRadius.rL,
          onTap: enabled ? onTap : null,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: AppRadius.rL,
              border: Border.all(
                color: selected ? colors.primary : colors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                  vertical: AppSpacing.m,
                ),
                child: Row(
                  children: [
                    Icon(
                      selected ? LucideIcons.circleDot : LucideIcons.circle,
                      size: 22,
                      color: selected
                          ? colors.primary
                          : colors.textMuted.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              if (recommended &&
                                  recommendedLabel != null &&
                                  recommendedLabel!.isNotEmpty) ...[
                                const SizedBox(width: AppSpacing.s),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.pill,
                                    ),
                                  ),
                                  child: Text(
                                    recommendedLabel!,
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textMuted,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      trailing,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? colors.primary
                            : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
