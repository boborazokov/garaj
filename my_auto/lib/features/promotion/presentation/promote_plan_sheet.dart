import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';

String promotePlanLabel(S s, ServicePromotionPlan plan) {
  switch (plan) {
    case ServicePromotionPlan.basic:
      return s.promotePlanBasic;
    case ServicePromotionPlan.standard:
      return s.promotePlanStandard;
    case ServicePromotionPlan.premium:
      return s.promotePlanPremium;
    case ServicePromotionPlan.vip:
      return s.promotePlanVip;
  }
}

String? promotePlanLabelFromApi(S s, String? api) {
  if (api == null || api.isEmpty) return null;
  final normalized = api.toUpperCase();
  for (final plan in ServicePromotionPlan.values) {
    if (plan.api == normalized) return promotePlanLabel(s, plan);
  }
  return api;
}

class _PlanOption {
  const _PlanOption(this.plan, this.days);
  final ServicePromotionPlan plan;
  final int days;
}

typedef PromotePlanCallback = Future<bool> Function(ServicePromotionPlan plan);

Future<bool?> showPromotePlanSheet(
  BuildContext context, {
  required String listingTitle,
  required PromotePlanCallback onPromote,
  bool isPromotionActive = false,
  String? activePlan,
  String? sheetTitle,
}) {
  final resolvedTitle = sheetTitle ?? S.of(context).promoteListingTitle;
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _PromotePlanSheet(
      listingTitle: listingTitle,
      onPromote: onPromote,
      isPromotionActive: isPromotionActive,
      activePlan: activePlan,
      sheetTitle: resolvedTitle,
    ),
  );
}

class _PromotePlanSheet extends StatefulWidget {
  const _PromotePlanSheet({
    required this.listingTitle,
    required this.onPromote,
    required this.isPromotionActive,
    required this.sheetTitle,
    this.activePlan,
  });

  final String listingTitle;
  final PromotePlanCallback onPromote;
  final bool isPromotionActive;
  final String? activePlan;
  final String sheetTitle;

  @override
  State<_PromotePlanSheet> createState() => _PromotePlanSheetState();
}

class _PromotePlanSheetState extends State<_PromotePlanSheet> {
  ServicePromotionPlan? _selected;
  bool _submitting = false;

  static const _plans = [
    _PlanOption(ServicePromotionPlan.basic, 3),
    _PlanOption(ServicePromotionPlan.standard, 7),
    _PlanOption(ServicePromotionPlan.premium, 14),
    _PlanOption(ServicePromotionPlan.vip, 30),
  ];

  Future<void> _submit() async {
    final plan = _selected;
    if (plan == null || _submitting) return;

    setState(() => _submitting = true);
    final ok = await widget.onPromote(plan);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Toaster.success(S.of(context).promotionActivatedSuccess, context: context);
      Navigator.pop(context, true);
    } else {
      Toaster.error(S.of(context).errorOccurred, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final activePlanLabel = promotePlanLabelFromApi(s, widget.activePlan);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.sheetTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.listingTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textMuted),
          ),
          if (widget.isPromotionActive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.12),
                borderRadius: AppRadius.rM,
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.sparkles, size: 18, color: colors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activePlanLabel != null
                          ? '${s.promotedTop} · $activePlanLabel'
                          : s.promotedTop,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ..._plans.map((p) {
            final selected = _selected == p.plan;
            final label = promotePlanLabel(s, p.plan);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected
                    ? colors.primary.withValues(alpha: 0.1)
                    : colors.surface,
                borderRadius: AppRadius.rL,
                child: InkWell(
                  borderRadius: AppRadius.rL,
                  onTap:
                      _submitting ? null : () => setState(() => _selected = p.plan),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.rL,
                      border: Border.all(
                        color: selected ? colors.primary : colors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? LucideIcons.circleDot
                                : LucideIcons.circle,
                            size: 20,
                            color: selected ? colors.primary : colors.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  s.promotePlanDuration(p.days, p.plan.weight),
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (p.plan == ServicePromotionPlan.vip)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                s.promotedBadge,
                                style: TextStyle(
                                  color: colors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _selected == null || _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : Text(s.activatePromotion),
          ),
        ],
      ),
    );
  }
}
