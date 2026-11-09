import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/wallet/data/wallet_models.dart';
import 'package:my_auto/features/wallet/data/wallet_repository.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletBalance? _wallet;
  List<WalletTx> _txs = const [];
  bool _loading = true;
  bool _toppingUp = false;

  static const _topUpAmounts = [10000, 35000, 70000, 120000];

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

  Future<void> _topUp(int amount) async {
    if (_toppingUp) return;
    setState(() => _toppingUp = true);
    try {
      await walletRepository.topUp(amount);
      if (!mounted) return;
      Toaster.success(S.of(context).walletTopUpSuccess, context: context);
      await _reload();
    } catch (_) {
      if (!mounted) return;
      Toaster.error(S.of(context).errorOccurred, context: context);
    } finally {
      if (mounted) setState(() => _toppingUp = false);
    }
  }

  String _format(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
    }
    return '${buf.toString()} UZS';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.walletTitle),
        backgroundColor: colors.surface,
      ),
      body: AppSafeArea(
        top: false,
        child: _loading && _wallet == null
            ? const Center(child: CircularProgressIndicator.adaptive())
            : RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadius.rL,
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.walletAvailable,
                            style: TextStyle(color: colors.textMuted),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _format(_wallet?.availableTotal ?? 0),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _BalanceChip(
                                  label: s.walletMain,
                                  value: _format(_wallet?.mainBalance ?? 0),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _BalanceChip(
                                  label: s.walletBonus,
                                  value: _format(_wallet?.bonusBalance ?? 0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      s.walletTopUp,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.walletTopUpHint,
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _topUpAmounts.map((amount) {
                        return FilledButton.tonal(
                          onPressed: _toppingUp ? null : () => _topUp(amount),
                          child: Text(_format(amount)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      s.walletHistory,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_txs.isEmpty)
                      Text(
                        s.walletEmptyHistory,
                        style: TextStyle(color: colors.textMuted),
                      )
                    else
                      ..._txs.map((tx) {
                        final credit = tx.amount >= 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: AppRadius.rM,
                            border: Border.all(color: colors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                credit
                                    ? LucideIcons.arrowDownLeft
                                    : LucideIcons.arrowUpRight,
                                size: 18,
                                color: credit ? colors.success : colors.danger,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.type,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      tx.note?.isNotEmpty == true
                                          ? tx.note!
                                          : tx.pool,
                                      style: TextStyle(
                                        color: colors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${credit ? '+' : ''}${_format(tx.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color:
                                      credit ? colors.success : colors.danger,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.rM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colors.textMuted, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
