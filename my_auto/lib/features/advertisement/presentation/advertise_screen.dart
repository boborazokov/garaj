import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/advertisement/data/advertisement_repository.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/domain/advertisement_plan_price.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

String _formatUzs(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    buf.write(s[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
  }
  return buf.toString();
}

/// Self-serve hub: tariffs, buy CTA, and advertiser stats for own banners.
class AdvertiseScreen extends StatefulWidget {
  const AdvertiseScreen({super.key, this.highlightSurface});

  final AdSurface? highlightSurface;

  @override
  State<AdvertiseScreen> createState() => _AdvertiseScreenState();
}

class _AdvertiseScreenState extends State<AdvertiseScreen>
    with SingleTickerProviderStateMixin {
  final _repo = AdvertisementRepository();
  List<AdvertisementPlanPrice> _prices = const [];
  List<Advertisement> _mine = const [];
  bool _loading = true;
  bool _loadingMine = false;
  AdSurface? _expanded;
  late final TabController _tabs;

  static const _order = [
    AdSurface.brand,
    AdSurface.part,
    AdSurface.service,
    AdSurface.announcement,
    AdSurface.tuning,
    AdSurface.model,
  ];

  @override
  void initState() {
    super.initState();
    _expanded = widget.highlightSurface;
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prices = await _repo.planPrices();
    if (!mounted) return;
    setState(() {
      _prices = prices;
      _loading = false;
    });
    if (AuthGuard.isAuthenticated(context)) {
      await _loadMine();
    }
  }

  Future<void> _loadMine() async {
    setState(() => _loadingMine = true);
    try {
      final mine = await _repo.myAdvertisements();
      if (!mounted) return;
      setState(() => _mine = mine);
    } catch (_) {
      if (!mounted) return;
      setState(() => _mine = const []);
    } finally {
      if (mounted) setState(() => _loadingMine = false);
    }
  }

  String _placementLabel(S s, AdSurface surface) {
    return switch (surface) {
      AdSurface.brand => s.advertisePlacementBrand,
      AdSurface.part => s.advertisePlacementPart,
      AdSurface.service => s.advertisePlacementService,
      AdSurface.announcement => s.advertisePlacementAnnouncement,
      AdSurface.tuning => s.advertisePlacementTuning,
      AdSurface.model => s.advertisePlacementModel,
    };
  }

  String _planLabel(S s, AdPlan plan) {
    return switch (plan) {
      AdPlan.day => s.advertisePlanDay,
      AdPlan.week => s.advertisePlanWeek,
      AdPlan.month => s.advertisePlanMonth,
      AdPlan.quarter => s.advertisePlanQuarter,
    };
  }

  String _statusLabel(S s, AdCampaignStatus status) {
    return switch (status) {
      AdCampaignStatus.active => s.adStatusActive,
      AdCampaignStatus.paused => s.adStatusPaused,
      AdCampaignStatus.expired => s.adStatusExpired,
      AdCampaignStatus.queued => s.adStatusQueued,
    };
  }

  int? _weekPrice(AdSurface surface) {
    for (final row in _prices) {
      if (row.placement == surface && row.plan == AdPlan.week) {
        return row.amount;
      }
    }
    return null;
  }

  List<AdvertisementPlanPrice> _rowsFor(AdSurface surface) {
    final rows = _prices.where((p) => p.placement == surface).toList()
      ..sort((a, b) => a.days.compareTo(b.days));
    return rows;
  }

  Future<void> _openPurchase() async {
    final already = AuthGuard.isAuthenticated(context);
    final ok = await AuthGuard.requireAuth(
      context,
      pending: PendingRoute(
        path: RoutesName.purchaseAdvertisement,
        extra: widget.highlightSurface?.api,
      ),
    );
    if (!ok || !mounted) return;
    if (!already) return;
    final bought = await context.push<bool>(
      RoutesName.purchaseAdvertisement,
      extra: widget.highlightSurface?.api,
    );
    if (bought == true && mounted) {
      _tabs.index = 1;
      await _loadMine();
    }
  }

  Future<void> _pause(Advertisement ad) async {
    try {
      await _repo.pauseMine(ad.id);
      if (!mounted) return;
      await _loadMine();
    } catch (_) {
      /* toaster optional */
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.advertiseTitle),
        backgroundColor: colors.surface,
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: s.advertiseTariffsTitle),
            Tab(text: s.adMyBannersTitle),
          ],
        ),
      ),
      bottomNavigationBar: Material(
        color: colors.surface,
        elevation: 8,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openPurchase,
                icon: const Icon(LucideIcons.megaphone, size: 18),
                label: Text(s.adPurchaseFab),
              ),
            ),
          ),
        ),
      ),
      body: AppSafeArea(
        top: false,
        child: TabBarView(
          controller: _tabs,
          children: [
            RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(
                    s.advertiseSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: AppRadius.rL,
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.info, size: 18, color: colors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.advertiseHowTitle,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.advertiseHowBody,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.textMuted,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    s.advertiseTariffsHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    )
                  else
                    ..._order.map((surface) {
                      final week = _weekPrice(surface);
                      final open = _expanded == surface;
                      final rows = _rowsFor(surface);
                      final highlighted =
                          widget.highlightSurface == surface;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: colors.surface,
                          borderRadius: AppRadius.rL,
                          child: InkWell(
                            borderRadius: AppRadius.rL,
                            onTap: () => setState(
                              () => _expanded = open ? null : surface,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: AppRadius.rL,
                                border: Border.all(
                                  color: highlighted
                                      ? colors.primary
                                      : colors.border,
                                  width: highlighted ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      12,
                                      10,
                                      12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _placementLabel(s, surface),
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              if (week != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  s.advertiseFromWeek(
                                                    _formatUzs(week),
                                                  ),
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: colors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          open
                                              ? LucideIcons.chevronUp
                                              : LucideIcons.chevronDown,
                                          size: 18,
                                          color: colors.textMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (open && rows.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        14,
                                        0,
                                        14,
                                        12,
                                      ),
                                      child: Column(
                                        children: [
                                          for (final row in rows)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _planLabel(s, row.plan),
                                                      style: theme
                                                          .textTheme.bodyMedium,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${_formatUzs(row.amount)} UZS',
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: AppSpacing.m),
                  OutlinedButton.icon(
                    onPressed: () => context.push(RoutesName.wallet),
                    icon: const Icon(LucideIcons.wallet, size: 18),
                    label: Text(s.advertiseWalletCta),
                  ),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: _loadMine,
              child: _loadingMine
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        Center(child: CircularProgressIndicator.adaptive()),
                      ],
                    )
                  : _mine.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              LucideIcons.megaphone,
                              size: 40,
                              color: colors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.adMyBannersEmpty,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: _mine.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final ad = _mine[i];
                            final surface = ad.surface;
                            return Container(
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: AppRadius.rL,
                                border: Border.all(color: colors.border),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (ad.bannerImageUrl.isNotEmpty)
                                    SizedBox(
                                      height: 110,
                                      child: ImageCacheNetwork(
                                        url: ad.bannerImageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 110,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ad.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          [
                                            if (surface != null)
                                              _placementLabel(s, surface),
                                            _statusLabel(s, ad.status),
                                            if (ad.status ==
                                                AdCampaignStatus.queued)
                                              s.adQueuePosition(
                                                '${ad.queuePosition}',
                                              ),
                                          ].join(' · '),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colors.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _StatChip(
                                              label: s.adStatImpressions,
                                              value: '${ad.impressionCount}',
                                            ),
                                            const SizedBox(width: 8),
                                            _StatChip(
                                              label: s.adStatClicks,
                                              value: '${ad.clickCount}',
                                            ),
                                            const SizedBox(width: 8),
                                            _StatChip(
                                              label: s.adStatCtr,
                                              value:
                                                  '${ad.ctr.toStringAsFixed(1)}%',
                                            ),
                                          ],
                                        ),
                                        if (ad.status ==
                                            AdCampaignStatus.active) ...[
                                          const SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () => _pause(ad),
                                              child: Text(s.adPauseCta),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceMuted.withValues(alpha: 0.6),
          borderRadius: AppRadius.rM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: colors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
