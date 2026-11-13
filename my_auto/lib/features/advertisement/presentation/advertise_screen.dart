import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/presentation/shimmer_skeletons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/advertisement/data/advertisement_repository.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Biznes hub: contact-admin info and advertiser stats for own banners.
class AdvertiseScreen extends StatefulWidget {
  const AdvertiseScreen({super.key, this.highlightSurface});

  final AdSurface? highlightSurface;

  @override
  State<AdvertiseScreen> createState() => _AdvertiseScreenState();
}

class _AdvertiseScreenState extends State<AdvertiseScreen>
    with SingleTickerProviderStateMixin {
  final _repo = AdvertisementRepository();
  List<Advertisement> _mine = const [];
  bool _loadingMine = false;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _refreshMine();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _refreshMine() async {
    if (!AuthGuard.isAuthenticated(context)) return;
    final soft = _mine.isNotEmpty;
    if (!soft) {
      setState(() => _loadingMine = true);
    }
    try {
      final mine = await _repo.myAdvertisements();
      if (!mounted) return;
      setState(() => _mine = mine);
    } catch (_) {
      if (!mounted) return;
      if (!soft) {
        setState(() => _mine = const []);
      }
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

  String _statusLabel(S s, AdCampaignStatus status) {
    return switch (status) {
      AdCampaignStatus.active => s.adStatusActive,
      AdCampaignStatus.paused => s.adStatusPaused,
      AdCampaignStatus.expired => s.adStatusExpired,
      AdCampaignStatus.queued => s.adStatusQueued,
    };
  }

  Future<void> _pause(Advertisement ad) async {
    try {
      await _repo.pauseMine(ad.id);
      if (!mounted) return;
      await _refreshMine();
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
            Tab(text: s.advertiseHowTitle),
            Tab(text: s.adMyBannersTitle),
          ],
        ),
      ),
      body: AppSafeArea(
        top: false,
        child: TabBarView(
          controller: _tabs,
          children: [
            ListView(
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
                const SizedBox(height: AppSpacing.m),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.06),
                    borderRadius: AppRadius.rL,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.headphones,
                        size: 18,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.advertiseContactHint,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textPrimary,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                OutlinedButton.icon(
                  onPressed: () => context.push(RoutesName.wallet),
                  icon: const Icon(LucideIcons.wallet, size: 18),
                  label: Text(s.advertiseWalletCta),
                ),
              ],
            ),
            RefreshIndicator(
              onRefresh: _refreshMine,
              child: !AuthGuard.isAuthenticated(context)
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 48),
                        Icon(
                          LucideIcons.lock,
                          size: 36,
                          color: colors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.signInToContinue,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : _loadingMine && _mine.isEmpty
                      ? const CardListSkeleton(count: 4, cardHeight: 120)
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
                              addAutomaticKeepAlives: false,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                                alignment:
                                                    Alignment.centerRight,
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
