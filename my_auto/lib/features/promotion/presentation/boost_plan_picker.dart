import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/promotion/presentation/promote_plan_sheet.dart';
import 'package:my_auto/features/promotion/presentation/promotion_plan_option_tile.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/wallet/data/wallet_repository.dart';
import 'package:my_auto/generated/l10n.dart';

String _formatUzs(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    buf.write(s[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
  }
  return '${buf.toString()} UZS';
}

/// Move-to-Top picker used as the last create-flow step.
/// [selected] null = publish free (no promotion).
class BoostPlanPicker extends StatefulWidget {
  const BoostPlanPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.compact = false,
  });

  final ServicePromotionPlan? selected;
  final ValueChanged<ServicePromotionPlan?> onChanged;
  final String? title;
  final String? subtitle;
  final bool compact;

  @override
  State<BoostPlanPicker> createState() => _BoostPlanPickerState();
}

class _BoostPlanPickerState extends State<BoostPlanPicker> {
  Map<ServicePromotionPlan, PromotionPlanPrice> _prices = const {};
  int? _walletTotal;
  bool _loading = true;

  static const _plans = ServicePromotionPlan.values;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prices = await walletRepository.fetchPlanPrices();
    final wallet = await walletRepository.fetchWallet();
    if (!mounted) return;
    setState(() {
      _prices = prices;
      _walletTotal = wallet?.availableTotal;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);

    return ListView(
      shrinkWrap: widget.compact,
      physics:
          widget.compact ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.fromLTRB(
        widget.compact ? 0 : AppSpacing.screenPadding,
        widget.compact ? 0 : AppSpacing.s,
        widget.compact ? 0 : AppSpacing.screenPadding,
        widget.compact ? 0 : 120,
      ),
      children: [
        Text(
          widget.title ?? s.createProductBoostTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          widget.subtitle ?? s.createProductBoostSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textMuted,
            height: 1.35,
          ),
        ),
        if (_walletTotal != null) ...[
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceMuted.withValues(alpha: 0.7),
              borderRadius: AppRadius.rL,
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.wallet,
                  size: 18,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    s.walletPromoteBalance(_formatUzs(_walletTotal!)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else ...[
          PromotionPlanOptionTile(
            selected: widget.selected == null,
            title: s.createProductBoostFree,
            subtitle: s.createProductBoostFreeHint,
            trailing: s.createProductBoostFree,
            onTap: () => widget.onChanged(null),
          ),
          const SizedBox(height: AppSpacing.s),
          ..._plans.map((plan) {
            final price = _prices[plan];
            final amount = price?.amount;
            final days = price?.days ?? _fallbackDays(plan);
            final isFreePlan = amount != null && amount <= 0;
            final isTop = plan == ServicePromotionPlan.top;
            final trailing = amount == null
                ? '—'
                : isFreePlan
                    ? s.createProductBoostFree
                    : _formatUzs(amount);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: PromotionPlanOptionTile(
                selected: widget.selected == plan,
                title: promotePlanLabel(s, plan),
                subtitle: s.promotePlanDuration(days, plan.weight),
                trailing: trailing,
                recommended: isTop,
                recommendedLabel: isTop ? s.popularProducts : null,
                onTap: () => widget.onChanged(plan),
              ),
            );
          }),
        ],
      ],
    );
  }

  int _fallbackDays(ServicePromotionPlan plan) {
    switch (plan) {
      case ServicePromotionPlan.basic:
        return 3;
      case ServicePromotionPlan.standard:
        return 7;
      case ServicePromotionPlan.premium:
        return 14;
      case ServicePromotionPlan.vip:
        return 30;
      case ServicePromotionPlan.top:
        return 45;
    }
  }
}
