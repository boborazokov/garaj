import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/features/sellerProfile/repository/seller_profile_repository.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

class SellerInfo extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final String? sellerImage;
  final int? productCount;

  const SellerInfo({
    super.key,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    this.sellerImage,
    this.productCount,
  });

  @override
  State<SellerInfo> createState() => _SellerInfoState();
}

class _SellerInfoState extends State<SellerInfo> {
  bool _isOwnProfile = false;
  int? _products;

  @override
  void initState() {
    super.initState();
    _products = widget.productCount;
    _loadMiniProfile();
  }

  Future<void> _loadMiniProfile() async {
    try {
      final p = await sellerProfileRepository.fetchProfile(widget.sellerId);
      if (!mounted) return;
      setState(() {
        _isOwnProfile = p.isOwnProfile;
        _products = p.stats.totalProducts;
      });
    } catch (_) {}
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final avatarUrl =
        resolveMediaUrl(widget.sellerImage, mediaBase: fileUrl);

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        color: colors.surface,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.sellerInformation,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.push(
                  RoutesName.sellerProfile,
                  extra: widget.sellerId,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipOval(
                        child: avatarUrl != null
                            ? ImageCacheNetwork(
                                url: avatarUrl,
                                width: 48,
                                height: 48,
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _initials(widget.sellerName),
                                  style: TextStyle(
                                    color: colors.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.sellerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _products != null
                                  ? '$_products ${s.sellerStatProducts.toLowerCase()}'
                                  : (_isOwnProfile
                                      ? s.editStore
                                      : s.viewProfile),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: colors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
