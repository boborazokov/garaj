import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/features/chat/admin/admin_chat.dart';
import 'package:my_auto/features/sellerProfile/models/seller_store_profile.dart';
import 'package:my_auto/features/sellerProfile/utils/format_count.dart';
import 'package:my_auto/features/sellerProfile/utils/profile_completion.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

class StoreBannerHeader extends StatelessWidget {
  final SellerStoreProfile profile;
  final bool isOwner;
  final VoidCallback? onChangeBanner;

  const StoreBannerHeader({
    super.key,
    required this.profile,
    required this.isOwner,
    this.onChangeBanner,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bannerUrl = resolveMediaUrl(profile.banner, mediaBase: fileUrl);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: AppRadius.rL,
            child: SizedBox(
              height: 128,
              width: double.infinity,
              child: bannerUrl != null
                  ? ImageCacheNetwork(
                      url: bannerUrl,
                      height: 128,
                      width: double.infinity,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.primaryHover],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
            ),
          ),
          if (isOwner)
            Positioned(
              right: 10,
              bottom: 10,
              child: FilledButton.tonal(
                onPressed: onChangeBanner,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(S.of(context).changeBanner),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact owner header: identity + stat chips. No action buttons (see AppBar).
class OwnerStoreIdentity extends StatelessWidget {
  final SellerStoreProfile profile;
  final String initials;
  final VoidCallback onOpenFollowers;

  const OwnerStoreIdentity({
    super.key,
    required this.profile,
    required this.initials,
    required this.onOpenFollowers,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final avatarUrl = resolveMediaUrl(profile.image, mediaBase: fileUrl);
    final stats = profile.stats;

    final chips = [
      (s.sellerStatProducts, formatCompactCount(stats.totalProducts)),
      (s.sellerStatFollowers, formatCompactCount(stats.followersCount)),
      (s.sellerStatProfileViews, formatCompactCount(stats.profileViews)),
      (s.sellerStatCategories, '${stats.categoriesCount}'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.rL,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: avatarUrl != null
                      ? ImageCacheNetwork(url: avatarUrl, width: 64, height: 64)
                      : Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colors.primary, colors.primaryHover],
                            ),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          if (profile.verified) ...[
                            const SizedBox(width: 6),
                            Icon(LucideIcons.badgeCheck,
                                size: 18, color: colors.primary),
                          ],
                        ],
                      ),
                      if (profile.username?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          s.sellerAtUsername(profile.username!),
                          style: TextStyle(color: colors.textMuted, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = chips[i];
                  final isFollowers = i == 1;
                  final chip = Container(
                    width: 88,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: AppRadius.rM,
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          c.$2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          c.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                  if (!isFollowers) return chip;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: AppRadius.rM,
                      onTap: onOpenFollowers,
                      child: chip,
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

/// Thin completion hint — no duplicate "Complete profile" button (use AppBar edit).
class ProfileCompletionStrip extends StatelessWidget {
  final SellerStoreProfile profile;
  final VoidCallback onTap;

  const ProfileCompletionStrip({
    super.key,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final result = computeProfileCompletion(profile, s);
    if (result.percent >= 100) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Material(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.rM,
        child: InkWell(
          borderRadius: AppRadius.rM,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.storeProfileCompletion,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: result.percent / 100,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${result.percent}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
                Icon(LucideIcons.chevronRight,
                    size: 18, color: colors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Single stats panel — tap opens analytics (replaces dashboard + duplicate buttons).
class OwnerStatsPanel extends StatelessWidget {
  final SellerStoreProfile profile;
  final VoidCallback onOpenAnalytics;

  const OwnerStatsPanel({
    super.key,
    required this.profile,
    required this.onOpenAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final stats = profile.stats;

    final items = [
      (s.sellerStatProfileViews, formatCompactCount(stats.profileViews)),
      (s.dashboardProductViews, '—'),
      (s.sellerStatFollowers, formatCompactCount(stats.followersCount)),
      (s.sellerStatActiveProducts, '${stats.activeProducts}'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpenAnalytics,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: AppRadius.rL,
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.quickSellerDashboard,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      s.openAnalytics,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Icon(LucideIcons.chevronRight,
                        size: 16, color: colors.primary),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map(
                        (e) => SizedBox(
                          width: (MediaQuery.sizeOf(context).width - 56) / 2,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.$1,
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                e.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal quick actions — each destination appears only once.
class OwnerQuickActionsRow extends StatelessWidget {
  final VoidCallback onOpenAnalytics;

  const OwnerQuickActionsRow({
    super.key,
    required this.onOpenAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;

    final actions = <(IconData, String, VoidCallback)>[
      (LucideIcons.plus, s.addProduct, () => context.push(RoutesName.addProduct)),
      (
        LucideIcons.package,
        s.manageProducts,
        () => context.push(RoutesName.myProducts),
      ),
      (LucideIcons.messageSquare, s.chats, () => context.push(RoutesName.chats)),
      (
        LucideIcons.clipboardList,
        s.myOrders,
        () => context.push(RoutesName.ordersList),
      ),
      (LucideIcons.barChart3, s.storeAnalytics, onOpenAnalytics),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.quickActions,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: actions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final a = actions[i];
                return SizedBox(
                  width: 88,
                  child: Material(
                    color: colors.surface,
                    borderRadius: AppRadius.rM,
                    child: InkWell(
                      borderRadius: AppRadius.rM,
                      onTap: a.$3,
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.rM,
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(a.$1, size: 22, color: colors.primary),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                a.$2,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Explains what the verified badge means — shown on the seller profile when
/// the store has been approved by the admin team.
class VerifiedAccountInfoCard extends StatelessWidget {
  const VerifiedAccountInfoCard({
    super.key,
    required this.isOwner,
  });

  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;
    const accent = Color(0xFF0EA5E9);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: AppRadius.rL,
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    LucideIcons.badgeCheck,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.verifiedAccountTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOwner
                            ? s.verifiedAccountOwnerInfo
                            : s.verifiedAccountVisitorInfo,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _VerifiedPoint(
              text: s.verifiedAccountPointIdentity,
              colors: colors,
              accent: accent,
            ),
            const SizedBox(height: 4),
            _VerifiedPoint(
              text: s.verifiedAccountPointTrusted,
              colors: colors,
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedPoint extends StatelessWidget {
  const _VerifiedPoint({
    required this.text,
    required this.colors,
    required this.accent,
  });

  final String text;
  final AppColors colors;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(LucideIcons.checkCircle2, size: 14, color: accent),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Owner-facing call-to-action that opens the admin support chat with a
/// pre-typed verification request. Hidden once the seller is verified.
class VerificationRequestCard extends StatelessWidget {
  const VerificationRequestCard({
    super.key,
    required this.profile,
  });

  final SellerStoreProfile profile;

  @override
  Widget build(BuildContext context) {
    if (profile.verified) return const SizedBox.shrink();
    if (!AdminChat.isAvailable) return const SizedBox.shrink();

    final s = S.of(context);
    final colors = context.appColors;
    final adminStrings = AdminChatStrings.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.rL,
        child: InkWell(
          borderRadius: AppRadius.rL,
          onTap: () => AdminChat.open(
            context,
            prefillText:
                adminStrings.verificationRequestPrefill(profile.name),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.primaryHover],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.shieldCheck,
                    color: colors.onPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminStrings.requestVerification,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        adminStrings.requestVerificationHint,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.verificationWhatIsIt,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight,
                    size: 18, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
