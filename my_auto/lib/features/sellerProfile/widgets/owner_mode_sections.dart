import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/features/sellerProfile/models/seller_store_profile.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

class StoreBannerHeader extends StatelessWidget {
  final SellerStoreProfile profile;

  const StoreBannerHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bannerUrl = resolveMediaUrl(profile.banner, mediaBase: fileUrl);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
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
                    color: colors.surfaceMuted,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Explains what the verified badge means — shown when the store is verified.
class VerifiedAccountInfoCard extends StatelessWidget {
  const VerifiedAccountInfoCard({super.key});

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
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.verifiedAccountVisitorInfo,
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
