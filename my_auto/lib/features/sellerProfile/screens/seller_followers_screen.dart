import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/features/sellerProfile/models/seller_follower.dart';
import 'package:my_auto/features/sellerProfile/repository/seller_profile_repository.dart';
import 'package:my_auto/features/sellerProfile/widgets/seller_profile_error.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

class SellerFollowersScreen extends StatefulWidget {
  const SellerFollowersScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  State<SellerFollowersScreen> createState() => _SellerFollowersScreenState();
}

class _SellerFollowersScreenState extends State<SellerFollowersScreen> {
  final _scrollController = ScrollController();
  final _followers = <SellerFollower>[];
  Object? _error;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    try {
      final result = await sellerProfileRepository.fetchFollowers(
        widget.sellerId,
        page: reset ? 1 : _page + 1,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _followers
            ..clear()
            ..addAll(result.items);
          _page = 1;
        } else {
          _followers.addAll(result.items);
          _page += 1;
        }
        _hasMore = result.hasNextPage;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore) {
      _load(reset: false);
    }
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
    final s = S.of(context);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.sellerStatFollowers),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _error != null && _followers.isEmpty
              ? SellerProfileError(
                  error: _error,
                  onRetry: () => _load(reset: true),
                )
              : RefreshIndicator(
                  color: colors.primary,
                  onRefresh: () => _load(reset: true),
                  child: _followers.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.users,
                                      size: 48,
                                      color: colors.textMuted,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      s.noFollowersYet,
                                      style: TextStyle(color: colors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              _followers.length + (_loadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (index >= _followers.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              );
                            }

                            final follower = _followers[index];
                            final avatarUrl = resolveMediaUrl(
                              follower.image,
                              mediaBase: fileUrl,
                            );
                            final date = DateFormat.yMMMd().format(
                              follower.followedAt.toLocal(),
                            );

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: AppRadius.rL,
                                border: Border.all(color: colors.border),
                              ),
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: avatarUrl != null
                                        ? ImageCacheNetwork(
                                            url: avatarUrl,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 48,
                                            height: 48,
                                            color: colors.primary
                                                .withValues(alpha: 0.12),
                                            alignment: Alignment.center,
                                            child: Text(
                                              _initials(follower.name),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: colors.primary,
                                              ),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          follower.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (follower.username?.isNotEmpty ==
                                            true)
                                          Text(
                                            s.sellerAtUsername(
                                              follower.username!,
                                            ),
                                            style: TextStyle(
                                              color: colors.textMuted,
                                              fontSize: 13,
                                            ),
                                          ),
                                        Text(
                                          s.followedOn(date),
                                          style: TextStyle(
                                            color: colors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
