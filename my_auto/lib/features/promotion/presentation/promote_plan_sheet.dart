import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/promotion/presentation/promotion_plan_option_tile.dart';
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

class _PlanOption {
  const _PlanOption(this.plan, this.fallbackDays, this.fallbackAmount);
  final ServicePromotionPlan plan;
  final int fallbackDays;
  final int fallbackAmount;
}

typedef PromotePlanCallback = Future<bool> Function(ServicePromotionPlan plan);
typedef CancelPromotionCallback = Future<bool> Function();

Future<bool?> showPromotePlanSheet(
  BuildContext context, {
  required String listingTitle,
  required PromotePlanCallback onPromote,
  CancelPromotionCallback? onCancelPromotion,
  bool isPromotionActive = false,
  String? activePlan,
  DateTime? promotedUntil,
  String? sheetTitle,
}) {
  final resolvedTitle = sheetTitle ?? S.of(context).promoteListingTitle;
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PromotePlanSheet(
      listingTitle: listingTitle,
      onPromote: onPromote,
      onCancelPromotion: onCancelPromotion,
      isPromotionActive: isPromotionActive,
      activePlan: activePlan,
      promotedUntil: promotedUntil,
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
    this.onCancelPromotion,
    this.activePlan,
    this.promotedUntil,
  });

  final String listingTitle;
  final PromotePlanCallback onPromote;
  final CancelPromotionCallback? onCancelPromotion;
  final bool isPromotionActive;
  final String? activePlan;
  final DateTime? promotedUntil;
  final String sheetTitle;

  @override
  State<_PromotePlanSheet> createState() => _PromotePlanSheetState();
}

class _PromotePlanSheetState extends State<_PromotePlanSheet> {
  ServicePromotionPlan? _selected;
  bool _submitting = false;
  bool _cancelling = false;
  bool _loading = true;
  Map<ServicePromotionPlan, PromotionPlanPrice> _prices = const {};
  int? _walletTotal;

  static const _plans = [
    _PlanOption(ServicePromotionPlan.basic, 1, 1000),
    _PlanOption(ServicePromotionPlan.standard, 7, 5000),
    _PlanOption(ServicePromotionPlan.premium, 14, 10000),
    _PlanOption(ServicePromotionPlan.vip, 30, 20000),
    _PlanOption(ServicePromotionPlan.top, 45, 30000),
  ];

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    final prices = await walletRepository.fetchPlanPrices();
    final wallet = await walletRepository.fetchWallet();
    if (!mounted) return;
    setState(() {
      _prices = prices;
      _walletTotal = wallet?.availableTotal;
      _loading = false;
      _selected ??= ServicePromotionPlan.top;
    });
  }

  Future<void> _submit() async {
    final plan = _selected;
    if (plan == null || _submitting || _cancelling) return;

    setState(() => _submitting = true);
    try {
      final ok = await widget.onPromote(plan);
      if (!mounted) return;
      setState(() => _submitting = false);

      if (ok) {
        Toaster.success(
          widget.isPromotionActive
              ? S.of(context).promotionExtendedSuccess
              : S.of(context).promotionActivatedSuccess,
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final msg = e.toString();
      if (msg.contains('INSUFFICIENT_WALLET_BALANCE')) {
        Toaster.error(S.of(context).walletInsufficientFunds, context: context);
        Navigator.pop(context, false);
        context.push(RoutesName.wallet);
        return;
      }
      Toaster.error(S.of(context).errorOccurred, context: context);
    }
  }

  Future<void> _cancel() async {
    final cancel = widget.onCancelPromotion;
    if (cancel == null || _cancelling || _submitting) return;

    final colors = context.appColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final s = S.of(ctx);
        return AlertDialog(
          title: Text(s.promotionCancelTitle),
          content: Text(s.promotionCancelBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.danger,
                foregroundColor: colors.onPrimary,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.promotionTurnOff),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      final ok = await cancel();
      if (!mounted) return;
      setState(() => _cancelling = false);
      if (ok) {
        Toaster.success(
          S.of(context).promotionCancelledSuccess,
          context: context,
        );
        Navigator.pop(context, true);
      } else {
        Toaster.error(S.of(context).errorOccurred, context: context);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _cancelling = false);
      Toaster.error(S.of(context).errorOccurred, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    final busy = _submitting || _cancelling;
    final activePlanLabel = promotePlanLabelFromApi(s, widget.activePlan);
    final until = widget.promotedUntil;
    final untilLabel = until != null
        ? DateFormat('d MMM yyyy', Localizations.localeOf(context).toString())
            .format(until.toLocal())
        : null;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Material(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.m,
                  AppSpacing.s,
                  0,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: AppRadius.rM,
                          ),
                          child: Icon(
                            LucideIcons.arrowUpToLine,
                            color: colors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.sheetTitle,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.listingTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.textMuted,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                          onPressed: busy ? null : () => Navigator.pop(context),
                          icon: Icon(
                            LucideIcons.x,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.l,
                    AppSpacing.screenPadding,
                    AppSpacing.m,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_walletTotal != null)
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
                                  s.walletPromoteBalance(
                                    _formatUzs(_walletTotal!),
                                  ),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: busy
                                    ? null
                                    : () {
                                        Navigator.pop(context, false);
                                        context.push(RoutesName.wallet);
                                      },
                                child: Text(s.walletTopUp),
                              ),
                            ],
                          ),
                        ),
                      if (widget.isPromotionActive) ...[
                        const SizedBox(height: AppSpacing.m),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.l),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.08),
                            borderRadius: AppRadius.rL,
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                size: 20,
                                color: colors.primary,
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activePlanLabel != null
                                          ? '${s.promotedTop} · $activePlanLabel'
                                          : s.promotedTop,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colors.primary,
                                      ),
                                    ),
                                    if (untilLabel != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        s.promotionActiveUntil(untilLabel),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: colors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      s.promotionExtendHint,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colors.textMuted,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.l),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        )
                      else
                        ..._plans.map((p) {
                          final selected = _selected == p.plan;
                          final price = _prices[p.plan];
                          final days = price?.days ?? p.fallbackDays;
                          final amount = price?.amount ?? p.fallbackAmount;
                          final isTop = p.plan == ServicePromotionPlan.top;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.s),
                            child: PromotionPlanOptionTile(
                              selected: selected,
                              enabled: !busy,
                              title: promotePlanLabel(s, p.plan),
                              subtitle:
                                  s.promotePlanDuration(days, p.plan.weight),
                              trailing: _formatUzs(amount),
                              recommended: isTop,
                              recommendedLabel:
                                  isTop ? s.popularProducts : null,
                              onTap: () =>
                                  setState(() => _selected = p.plan),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.s,
                    AppSpacing.screenPadding,
                    AppSpacing.l,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed:
                              _selected == null || busy || _loading
                                  ? null
                                  : _submit,
                          child: _submitting
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      colors.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  widget.isPromotionActive
                                      ? s.promotionExtend
                                      : s.activatePromotion,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      if (widget.isPromotionActive &&
                          widget.onCancelPromotion != null) ...[
                        const SizedBox(height: AppSpacing.s),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: busy ? null : _cancel,
                            child: _cancelling
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(s.promotionTurnOff),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
