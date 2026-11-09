import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/promotion/data/promotion_repository.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/wallet/data/wallet_repository.dart';
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
    case ServicePromotionPlan.top:
      return s.promotePlanTop;
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

String formatPromotionPrice(int amount, String currency) {
  final digits = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    if (i > 0 && fromEnd % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  return '${buf.toString()} $currency';
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
  bool _loadingPrices = true;
  List<PromotionPlanPrice> _prices = const [];

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final prices = await promotionRepository.fetchPlanPrices();
    if (!mounted) return;
    setState(() {
      _prices = prices;
      _loadingPrices = false;
    });
  }

  PromotionPlanPrice? _priceFor(ServicePromotionPlan plan) {
    for (final p in _prices) {
      if (p.plan == plan) return p;
    }
    return null;
  }

  Future<void> _submit() async {
    final plan = _selected;
    if (plan == null || _submitting) return;

    setState(() => _submitting = true);
    try {
      final ok = await widget.onPromote(plan);
      if (!mounted) return;
      setState(() => _submitting = false);

      if (ok) {
        Toaster.success(
          S.of(context).promotionActivatedSuccess,
          context: context,
        );
        Navigator.pop(context, true);
      } else {
        Toaster.error(S.of(context).errorOccurred, context: context);
      }
    } on WalletInsufficientFundsException {
      if (!mounted) return;
      setState(() => _submitting = false);
      Toaster.error(S.of(context).walletInsufficientFunds, context: context);
      Navigator.pop(context, false);
      context.push(RoutesName.wallet);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      Toaster.error(S.of(context).errorOccurred, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final activePlanLabel = promotePlanLabelFromApi(s, widget.activePlan);
    final selectedPrice = _selected == null ? null : _priceFor(_selected!);

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
          if (_loadingPrices)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              ),
            )
          else
            ...ServicePromotionPlan.values.map((plan) {
              final price = _priceFor(plan);
              final days = price?.days ?? _fallbackDays(plan);
              final priority = price?.priority ?? plan.weight;
              final selected = _selected == plan;
              final label = promotePlanLabel(s, plan);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: selected
                      ? colors.primary.withValues(alpha: 0.1)
                      : colors.surface,
                  borderRadius: AppRadius.rL,
                  child: InkWell(
                    borderRadius: AppRadius.rL,
                    onTap: _submitting
                        ? null
                        : () => setState(() => _selected = plan),
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
                              color:
                                  selected ? colors.primary : colors.textMuted,
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
                                    s.promotePlanDuration(days, priority),
                                    style: TextStyle(
                                      color: colors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (price != null)
                              Text(
                                formatPromotionPrice(
                                  price.amount,
                                  price.currency,
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: selected
                                      ? colors.primary
                                      : colors.textPrimary,
                                ),
                              )
                            else if (plan == ServicePromotionPlan.top)
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
                : Text(
                    selectedPrice == null
                        ? s.activatePromotion
                        : '${s.activatePromotion} · ${formatPromotionPrice(selectedPrice.amount, selectedPrice.currency)}',
                  ),
          ),
        ],
      ),
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
