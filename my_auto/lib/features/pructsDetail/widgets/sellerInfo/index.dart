import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/features/sellerProfile/repository/seller_profile_repository.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

class SellerInfo extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final String? sellerImage;
  final int? productCount;
  final int? followersCount;

  const SellerInfo({
    super.key,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    this.sellerImage,
    this.productCount,
    this.followersCount,
  });

  @override
  State<SellerInfo> createState() => _SellerInfoState();
}

class _SellerInfoState extends State<SellerInfo> {
  bool? _isFollowing;
  bool _isOwnProfile = false;
  bool _followLoading = false;
  int? _followers;
  int? _products;

  @override
  void initState() {
    super.initState();
    _followers = widget.followersCount;
    _products = widget.productCount;
    _loadMiniProfile();
  }

  Future<void> _loadMiniProfile() async {
    try {
      final p = await sellerProfileRepository.fetchProfile(widget.sellerId);
      if (!mounted) return;
      setState(() {
        _isFollowing = p.isFollowing;
        _isOwnProfile = p.isOwnProfile;
        _followers = p.stats.followersCount;
        _products = p.stats.totalProducts;
      });
    } catch (_) {}
  }

  Future<void> _toggleFollow() async {
    final authed = await AuthGuard.requireAuth(context);
    if (!authed || !mounted) return;
    setState(() => _followLoading = true);
    try {
      final wasFollowing = _isFollowing == true;
      if (wasFollowing) {
        await sellerProfileRepository.unfollow(widget.sellerId);
      } else {
        await sellerProfileRepository.follow(widget.sellerId);
      }
      if (!mounted) return;
      setState(() {
        _isFollowing = !wasFollowing;
        _followers = ((_followers ?? 0) + (wasFollowing ? -1 : 1)).clamp(0, 999999999);
      });
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final avatarUrl =
        resolveMediaUrl(widget.sellerImage, mediaBase: fileUrl);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                s.sellerInformation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(color: colors.border),
                borderRadius: AppRadius.rL,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: avatarUrl != null
                            ? ImageCacheNetwork(
                                url: avatarUrl, width: 52, height: 52)
                            : Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colors.primary,
                                      colors.primaryHover
                                    ],
                                  ),
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
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.sellerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_followers != null || _products != null)
                              Text(
                                [
                                  if (_followers != null)
                                    '${_followers!} ${s.sellerStatFollowers.toLowerCase()}',
                                  if (_products != null)
                                    '${_products!} ${s.sellerStatProducts.toLowerCase()}',
                                ].join(' • '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isOwnProfile)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.push(
                          RoutesName.sellerProfile,
                          extra: widget.sellerId,
                        ),
                        child: Text(s.editStore),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push(
                              RoutesName.sellerProfile,
                              extra: widget.sellerId,
                            ),
                            child: Text(s.viewProfile),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed:
                                _followLoading ? null : _toggleFollow,
                            child: _followLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isFollowing == true
                                        ? s.following
                                        : s.follow,
                                  ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
