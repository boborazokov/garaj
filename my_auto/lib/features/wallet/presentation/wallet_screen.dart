import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/place_label.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/wallet/data/wallet_models.dart';
import 'package:my_auto/features/wallet/data/wallet_repository.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/app_bar.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletBalance? _wallet;
  List<WalletTx> _txs = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final wallet = await walletRepository.fetchWallet();
    final txs = await walletRepository.fetchTransactions();
    if (!mounted) return;
    setState(() {
      _wallet = wallet;
      _txs = txs;
      _loading = false;
    });
  }

  String _format(int value, {String? currency}) {
    final s = value.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
    }
    final cur = currency ?? _wallet?.currency ?? 'UZS';
    return '${buf.toString()} $cur';
  }

  String _txTitle(S s, WalletTx tx) {
    final type = tx.type.toUpperCase();
    if (type.contains('TOPUP') || type.contains('CREDIT')) {
      return s.walletTxTopUp;
    }
    if (type.contains('PROMOTION')) {
      return s.notificationWalletReasonPromotionGeneric;
    }
    if (type.contains('BOOKING')) {
      return s.notificationWalletReasonBooking;
    }
    if (type.contains('ADVERTISEMENT') || type.contains('ADVERT')) {
      return s.advertiseTitle;
    }
    if (type.contains('SPEND') ||
        type.contains('DEBIT') ||
        type.contains('CHARGE') ||
        type.contains('PURCHASE')) {
      return s.walletTxSpend;
    }
    if (tx.note != null && tx.note!.trim().isNotEmpty) {
      return tx.note!.trim();
    }
    return tx.type.replaceAll('_', ' ');
  }

  String? _relatedRoute(WalletTx tx) {
    switch ((tx.referenceType ?? '').toUpperCase()) {
      case 'ADVERTISEMENT':
        return RoutesName.advertise;
      case 'PROMOTION_PAYMENT':
        final target = tx.meta['targetType']?.toString().toUpperCase() ?? '';
        if (target.contains('WORKSHOP') || target.contains('SERVICE')) {
          return RoutesName.myServices;
        }
        return RoutesName.myProducts;
      case 'SERVICE_BOOKING':
        return RoutesName.myServices;
      default:
        return null;
    }
  }

  Future<void> _openTxDetails(WalletTx tx) async {
    final s = S.of(context);
    final colors = context.appColors;
    final credit = tx.amount >= 0;
    final related = _relatedRoute(tx);
    final lang = Localizations.localeOf(context).languageCode;
    final created = tx.createdAt?.toLocal();
    final dateLabel = created == null
        ? '—'
        : '${cardPostedLabel(created, languageCode: lang)} · '
            '${created.hour.toString().padLeft(2, '0')}:'
            '${created.minute.toString().padLeft(2, '0')}';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              stickyBottomPadding(ctx, homeExtra: 12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  s.walletTxDetails,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txTitle(s, tx),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '${credit ? '+' : '−'}${_format(tx.amount, currency: tx.currency)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: credit ? colors.success : colors.danger,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _TxDetailRow(
                  label: s.walletTxReason,
                  value: (tx.note?.trim().isNotEmpty == true)
                      ? tx.note!.trim()
                      : _txTitle(s, tx),
                ),
                _TxDetailRow(
                  label: s.walletTxStatus,
                  value: tx.status.replaceAll('_', ' '),
                ),
                _TxDetailRow(
                  label: s.walletTxDate,
                  value: dateLabel,
                ),
                _TxDetailRow(
                  label: s.walletTxId,
                  value: tx.id,
                  trailing: IconButton(
                    tooltip: s.walletTxCopyId,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: tx.id));
                      if (!ctx.mounted) return;
                      Toaster.success(s.chatCopied, context: ctx);
                    },
                    icon: Icon(
                      LucideIcons.copy,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                if (tx.referenceId != null &&
                    tx.referenceId!.trim().isNotEmpty)
                  _TxDetailRow(
                    label: s.walletTxReference,
                    value:
                        '${(tx.referenceType ?? 'REF').replaceAll('_', ' ')} · ${tx.referenceId}',
                    trailing: IconButton(
                      tooltip: s.walletTxCopyId,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: tx.referenceId!),
                        );
                        if (!ctx.mounted) return;
                        Toaster.success(s.chatCopied, context: ctx);
                      },
                      icon: Icon(
                        LucideIcons.copy,
                        size: 18,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                if (related != null) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push(related);
                    },
                    icon: const Icon(LucideIcons.externalLink, size: 18),
                    label: Text(s.walletTxOpenRelated),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.rM,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComingSoon(String method) {
    final s = S.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.walletPaymentComingSoonBody(method)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openTelegram() async {
    final s = S.of(context);
    final raw = (dotenv.env['TELEGRAM_WALLET_URL'] ?? '').trim();
    if (raw.isEmpty || raw == 'https://t.me/' || raw == 'https://t.me') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.walletTelegramHint),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final uri = Uri.tryParse(raw);
    if (uri == null) {
      Toaster.error(s.errorOccurred, context: context);
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      Toaster.error(s.errorOccurred, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final balance = _wallet?.availableTotal ?? 0;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(title: s.walletTitle),
      body: AppSafeArea(
        top: false,
        child: _loading && _wallet == null
            ? const Center(child: CircularProgressIndicator.adaptive())
            : RefreshIndicator(
                color: colors.primary,
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  children: [
                    ProductSection(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.walletAvailable,
                            style: TextStyle(
                              color: colors.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _format(balance),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: colors.textPrimary,
                                  height: 1.1,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.walletSubtitle,
                            style: TextStyle(
                              color: colors.textSecondary,
                              height: 1.3,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ProductSection(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      title: s.walletPaymentMethods,
                      subtitle: s.walletTopUpHint,
                      child: Column(
                        children: [
                          _PaymentMethodTile(
                            title: 'Payme',
                            subtitle: s.comingSoon,
                            logoAsset: 'assets/svg/payments/payme.svg',
                            enabled: false,
                            onTap: () => _showComingSoon('Payme'),
                          ),
                          const SizedBox(height: 6),
                          _PaymentMethodTile(
                            title: 'Click',
                            subtitle: s.comingSoon,
                            logoAsset: 'assets/svg/payments/click.svg',
                            enabled: false,
                            onTap: () => _showComingSoon('Click'),
                          ),
                          const SizedBox(height: 6),
                          _PaymentMethodTile(
                            title: 'Paynet',
                            subtitle: s.comingSoon,
                            logoAsset: 'assets/svg/payments/paynet.svg',
                            enabled: false,
                            onTap: () => _showComingSoon('Paynet'),
                          ),
                          const SizedBox(height: 6),
                          _PaymentMethodTile(
                            title: 'Telegram',
                            subtitle: s.walletTelegramOpen,
                            logoAsset: 'assets/svg/payments/telegram.svg',
                            enabled: true,
                            emphasized: true,
                            onTap: _openTelegram,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ProductSection(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      title: s.walletHistory,
                      child: _txs.isEmpty
                          ? Text(
                              s.walletEmptyHistory,
                              style: TextStyle(
                                color: colors.textMuted,
                                height: 1.35,
                              ),
                            )
                          : Column(
                              children: [
                                for (var i = 0; i < _txs.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 6),
                                  _TxTile(
                                    title: _txTitle(s, _txs[i]),
                                    subtitle: _txs[i].note?.trim().isNotEmpty ==
                                            true
                                        ? _txs[i].note!.trim()
                                        : null,
                                    amountLabel:
                                        '${_txs[i].amount >= 0 ? '+' : '−'}${_format(_txs[i].amount)}',
                                    credit: _txs[i].amount >= 0,
                                    onTap: () => _openTxDetails(_txs[i]),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.logoAsset,
    required this.onTap,
    this.enabled = true,
    this.emphasized = false,
  });

  final String title;
  final String subtitle;
  final String logoAsset;
  final VoidCallback onTap;
  final bool enabled;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: emphasized
          ? colors.primary.withValues(alpha: 0.08)
          : colors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: emphasized
                  ? colors.primary.withValues(alpha: 0.35)
                  : colors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.rS,
                  child: SvgPicture.asset(
                    logoAsset,
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: emphasized
                              ? colors.primary
                              : colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  enabled ? LucideIcons.chevronRight : LucideIcons.clock,
                  size: 18,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({
    required this.title,
    required this.amountLabel,
    required this.credit,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String amountLabel;
  final bool credit;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border.withValues(alpha: 0.85)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (credit ? colors.success : colors.danger)
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    credit
                        ? LucideIcons.arrowDownLeft
                        : LucideIcons.arrowUpRight,
                    size: 16,
                    color: credit ? colors.success : colors.danger,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  amountLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: credit ? colors.success : colors.danger,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TxDetailRow extends StatelessWidget {
  const _TxDetailRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border.withValues(alpha: 0.85)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
