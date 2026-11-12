import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/promotion/presentation/promote_plan_sheet.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/generated/l10n.dart';

/// Accent colors per Top plan — higher tiers read warmer / stronger.
Color promotionPlanColor(String? api) {
  switch ((api ?? '').toUpperCase()) {
    case 'BASIC':
      return AppPalette.secondary500;
    case 'STANDARD':
      return AppPalette.primary500;
    case 'PREMIUM':
      return AppPalette.warning600;
    case 'VIP':
      return const Color(0xFF0F766E);
    case 'TOP':
      return AppPalette.error500;
    default:
      return AppPalette.primary500;
  }
}

ServicePromotionPlan? promotionPlanFromApi(String? api) {
  if (api == null || api.isEmpty) return null;
  final normalized = api.toUpperCase();
  for (final plan in ServicePromotionPlan.values) {
    if (plan.api == normalized) return plan;
  }
  return null;
}

/// Corner badge with plan name + plan-matched color.
class PromotionPlanBadge extends StatelessWidget {
  const PromotionPlanBadge({
    super.key,
    required this.plan,
    this.dense = true,
    this.filled = false,
  });

  final String? plan;
  final bool dense;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final color = promotionPlanColor(plan);
    final label =
        promotePlanLabelFromApi(s, plan) ?? s.promotedBadge;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 8,
        vertical: dense ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: filled
            ? null
            : Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.white : color,
          fontSize: dense ? 10 : 11,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
