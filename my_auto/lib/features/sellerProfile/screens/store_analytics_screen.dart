import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/sellerProfile/models/seller_store_profile.dart';
import 'package:my_auto/features/sellerProfile/repository/seller_profile_repository.dart';
import 'package:my_auto/features/sellerProfile/utils/format_count.dart';
import 'package:my_auto/features/sellerProfile/widgets/seller_profile_error.dart';
import 'package:my_auto/generated/l10n.dart';

class StoreAnalyticsScreen extends StatefulWidget {
  final SellerStoreProfile? profile;
  final String? sellerId;

  const StoreAnalyticsScreen({
    super.key,
    this.profile,
    this.sellerId,
  });

  @override
  State<StoreAnalyticsScreen> createState() => _StoreAnalyticsScreenState();
}

class _StoreAnalyticsScreenState extends State<StoreAnalyticsScreen> {
  int _rangeDays = 7;
  SellerStoreProfile? _profile;
  Object? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    if (_profile == null && widget.sellerId != null) {
      _loadProfile(widget.sellerId!);
    }
  }

  Future<void> _loadProfile(String sellerId) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await sellerProfileRepository.fetchProfile(sellerId);
      if (!mounted) return;
      setState(() {
        _profile = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final profile = _profile;

    return Scaffold(
      appBar: AppBar(title: Text(s.storeAnalytics)),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _error != null
              ? SellerProfileError(
                  error: _error,
                  onRetry: () {
                    final id = widget.sellerId ?? profile?.id;
                    if (id != null) _loadProfile(id);
                  },
                )
              : profile == null
                  ? Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text(s.close),
                      ),
                    )
                  : _AnalyticsBody(
                      profile: profile,
                      rangeDays: _rangeDays,
                      onRangeChanged: (v) => setState(() => _rangeDays = v),
                    ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  final SellerStoreProfile profile;
  final int rangeDays;
  final ValueChanged<int> onRangeChanged;

  const _AnalyticsBody({
    required this.profile,
    required this.rangeDays,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final stats = profile.stats;

    final metrics = [
      (s.sellerStatProfileViews, formatCompactCount(stats.profileViews)),
      (s.dashboardProductViews, '—'),
      (s.sellerStatFollowers, formatCompactCount(stats.followersCount)),
      (s.dashboardMessages, '—'),
      (s.dashboardLeads, '—'),
      (s.productClicks, '—'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<int>(
          segments: [
            ButtonSegment(value: 7, label: Text(s.range7Days)),
            ButtonSegment(value: 30, label: Text(s.range30Days)),
            ButtonSegment(value: 90, label: Text(s.range90Days)),
          ],
          selected: {rangeDays},
          onSelectionChanged: (v) => onRangeChanged(v.first),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: metrics
              .map(
                (m) => Container(
                  width: (MediaQuery.sizeOf(context).width - 48) / 2,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadius.rM,
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.$1,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        Text(s.topProducts,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        _placeholderCard(context, s.comingSoon),
        const SizedBox(height: 16),
        Text(s.topCategories,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (profile.categories.isEmpty)
          _placeholderCard(context, s.sellerStoreEmpty)
        else
          ...profile.categories.take(5).map(
                (c) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c.name),
                  trailing: Text('${c.productCount}'),
                ),
              ),
      ],
    );
  }

  Widget _placeholderCard(BuildContext context, String text) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rM,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.barChart2, color: colors.textMuted),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: colors.textMuted))),
        ],
      ),
    );
  }
}
