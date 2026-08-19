import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';
import 'package:my_auto/features/chat/chat_di.dart';
import 'package:my_auto/features/chat/domain/failures/chat_failure.dart';
import 'package:my_auto/features/sellerProfile/models/seller_store_profile.dart';
import 'package:my_auto/features/sellerProfile/repository/seller_profile_repository.dart';
import 'package:my_auto/features/sellerProfile/utils/format_count.dart';
import 'package:my_auto/features/sellerProfile/utils/store_share_link.dart';
import 'package:my_auto/features/sellerProfile/widgets/owner_mode_sections.dart';
import 'package:my_auto/features/sellerProfile/widgets/seller_product_list_tile.dart';
import 'package:my_auto/features/sellerProfile/widgets/seller_profile_error.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/widgets/productCard/index.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

enum _ProductTab { all, latest, popular }

class SellerProfile extends StatefulWidget {
  final String sellerId;
  const SellerProfile({super.key, required this.sellerId});

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  SellerStoreProfile? _profile;
  Object? _profileError;
  bool _profileLoading = true;
  bool _followLoading = false;
  bool _openingChat = false;
  _ProductTab _tab = _ProductTab.all;
  String _sort = 'RECOMMENDED';
  String? _categoryId;
  bool _gridView = true;

  Map<String, dynamic> get _filters {
    final f = <String, dynamic>{'seller': widget.sellerId};
    if (_categoryId != null) f['category'] = _categoryId!;
    return f;
  }

  String get _sortForTab {
    switch (_tab) {
      case _ProductTab.latest:
        return 'NEWEST';
      case _ProductTab.popular:
      case _ProductTab.all:
        return _sort;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts(reset: true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _profileLoading = true;
      _profileError = null;
    });
    try {
      final p = await sellerProfileRepository.fetchProfile(widget.sellerId);
      if (!mounted) return;
      setState(() {
        _profile = p;
        _profileLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileError = e;
        _profileLoading = false;
      });
    }
  }

  void _loadProducts({bool reset = false}) {
    final search = _searchController.text.trim();
    context.read<ProductProvider>().loadList(
          filters: _filters,
          reset: reset,
          search: search.isEmpty ? null : search,
          sort: _sortForTab,
        );
  }

  void _onSearchChanged() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _loadProducts(reset: true);
    });
  }

  void _onScroll() {
    if (!mounted) return;
    final p = context.read<ProductProvider>();
    final search = _searchController.text.trim();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !p.isMoreLoadingFor(_filters, sort: _sortForTab, search: search) &&
        p.hasMoreFor(_filters, sort: _sortForTab, search: search)) {
      p.loadMore(
        filters: _filters,
        search: search.isEmpty ? null : search,
        sort: _sortForTab,
      );
    }
  }

  Future<void> _confirmUnfollow() async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.unfollow),
        content: Text(s.unfollowConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.close),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.unfollow),
          ),
        ],
      ),
    );
    if (ok == true) await _toggleFollow(forceUnfollow: true);
  }

  Future<void> _toggleFollow({bool forceUnfollow = false}) async {
    if (_profile == null || _profile!.isOwnProfile) return;
    if (_profile!.isFollowing && !forceUnfollow) {
      await _confirmUnfollow();
      return;
    }
    final authed = await AuthGuard.requireAuth(context);
    if (!authed || !mounted) return;

    setState(() => _followLoading = true);
    try {
      if (_profile!.isFollowing) {
        await sellerProfileRepository.unfollow(widget.sellerId);
      } else {
        await sellerProfileRepository.follow(widget.sellerId);
      }
      if (!mounted) return;
      final delta = _profile!.isFollowing ? -1 : 1;
      setState(() {
        _profile = _profile!.copyWith(
          isFollowing: !_profile!.isFollowing,
          stats: SellerStoreStats(
            totalProducts: _profile!.stats.totalProducts,
            activeProducts: _profile!.stats.activeProducts,
            categoriesCount: _profile!.stats.categoriesCount,
            followersCount:
                (_profile!.stats.followersCount + delta).clamp(0, 999999999),
            profileViews: _profile!.stats.profileViews,
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  Future<void> _writeSeller() async {
    if (_openingChat || _profile == null) return;
    final authed = await AuthGuard.requireAuth(
      context,
      pending: PendingWriteSeller(
        recipientId: widget.sellerId,
        partId: '',
        sellerName: _profile!.name,
      ),
    );
    if (!authed || !mounted) return;

    final auth = context.read<AuthProvider>().auth!;
    if (auth.user.id == widget.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).errorCannotMessageSelf)),
      );
      return;
    }
    setState(() => _openingChat = true);
    try {
      final conversation = await chatRepository.createConversation(
        recipientId: widget.sellerId,
      );
      if (!mounted) return;
      context.push(
        '${RoutesName.chatDetail}/${conversation.id}',
        extra: _profile!.name,
      );
    } on ChatFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  void _shareProfile() {
    final p = _profile;
    if (p == null) return;
    final link = buildStoreShareLink(sellerId: p.id, username: p.username);
    final handle = p.username?.isNotEmpty == true ? '@${p.username}' : p.name;
    SharePlus.instance.share(
      ShareParams(text: '${p.name} ($handle)\n$link'),
    );
  }

  void _openEditStore() => context.push(RoutesName.editProfile);

  void _openAnalytics() {
    final p = _profile;
    if (p == null) return;
    context.push(RoutesName.storeAnalytics, extra: p);
  }

  void _openFollowers() {
    final p = _profile;
    if (p == null) return;
    context.push(RoutesName.sellerFollowers, extra: p.id);
  }

  void _openAddProduct() => context.push(RoutesName.addProduct);

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Future<void> _openUrl(String url) async {
    var u = url.trim();
    if (!u.startsWith('http')) u = 'https://$u';
    final uri = Uri.tryParse(u);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final localeCode = context.watch<LocaleNotifier>().locale?.languageCode;
    final productProvider = context.watch<ProductProvider>();
    final search = _searchController.text.trim();
    final parts = productProvider.getProducts(
      _filters,
      sort: _sortForTab,
      search: search,
    );
    final isLoading = productProvider.isLoadingFor(
      _filters,
      sort: _sortForTab,
      search: search,
    );
    final isMoreLoading = productProvider.isMoreLoadingFor(
      _filters,
      sort: _sortForTab,
      search: search,
    );
    final profile = _profile;

    final isOwner = profile?.isOwnProfile == true;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(isOwner ? s.myStore : s.sellerProfile),
        centerTitle: false,
        actions: isOwner
            ? [
                IconButton(
                  onPressed: _shareProfile,
                  icon: const Icon(LucideIcons.share2, size: 20),
                  tooltip: s.shareProfile,
                ),
                IconButton(
                  onPressed: _openEditStore,
                  icon: const Icon(LucideIcons.pencil, size: 20),
                  tooltip: s.editStore,
                ),
              ]
            : null,
      ),
      bottomNavigationBar: profile != null &&
              !profile.isOwnProfile &&
              MediaQuery.sizeOf(context).width < 600
          ? _StickyFollowBar(
              isFollowing: profile.isFollowing,
              loading: _followLoading,
              onFollow: _toggleFollow,
            )
          : null,
      body: _profileLoading && profile == null
          ? const _ProfileSkeleton()
          : _profileError != null && profile == null
              ? SellerProfileError(
                  error: _profileError,
                  onRetry: _loadProfile,
                )
              : RefreshIndicator(
                  color: colors.primary,
                  onRefresh: () async {
                    await _loadProfile();
                    _loadProducts(reset: true);
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      if (profile != null &&
                          (profile.banner?.trim().isNotEmpty == true ||
                              profile.isOwnProfile))
                        SliverToBoxAdapter(
                          child: StoreBannerHeader(
                            profile: profile,
                            isOwner: profile.isOwnProfile,
                            onChangeBanner: _openEditStore,
                          ),
                        ),
                      if (profile != null && profile.isOwnProfile)
                        SliverToBoxAdapter(
                          child: OwnerStoreIdentity(
                            profile: profile,
                            initials: _initials(profile.name),
                            onOpenFollowers: _openFollowers,
                          ),
                        ),
                      if (profile != null && !profile.isOwnProfile)
                        SliverToBoxAdapter(
                          child: _VisitorProfileHeader(
                            profile: profile,
                            localeCode: localeCode,
                            initials: _initials(profile.name),
                            onFollow: _toggleFollow,
                            onMessage: _writeSeller,
                            onShare: _shareProfile,
                            followLoading: _followLoading,
                            messageLoading: _openingChat,
                          ),
                        ),
                      if (profile != null && profile.isOwnProfile)
                        SliverToBoxAdapter(
                          child: VerificationRequestCard(profile: profile),
                        ),
                      if (profile != null && profile.verified)
                        SliverToBoxAdapter(
                          child: VerifiedAccountInfoCard(
                            isOwner: profile.isOwnProfile,
                          ),
                        ),
                      if (profile != null)
                        const SliverToBoxAdapter(
                          child: AdBanner(
                            surface: AdSurface.model,
                            height: 120,
                            margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
                          ),
                        ),
                      if (profile != null && profile.isOwnProfile)
                        SliverToBoxAdapter(
                          child: ProfileCompletionStrip(
                            profile: profile,
                            onTap: _openEditStore,
                          ),
                        ),
                      if (profile != null && profile.isOwnProfile)
                        SliverToBoxAdapter(
                          child: OwnerStatsPanel(
                            profile: profile,
                            onOpenAnalytics: _openAnalytics,
                          ),
                        ),
                      if (profile != null && profile.isOwnProfile)
                        SliverToBoxAdapter(
                          child: OwnerQuickActionsRow(
                            onOpenAnalytics: _openAnalytics,
                          ),
                        ),
                      if (profile != null && !profile.isOwnProfile)
                        SliverToBoxAdapter(
                          child: _StatsRow(stats: profile.stats),
                        ),
                      if (!isOwner && profile?.bio?.trim().isNotEmpty == true)
                        SliverToBoxAdapter(
                          child: _SectionCard(
                            title: s.sellerBioSection,
                            child: Text(
                              profile!.bio!.trim(),
                              style: TextStyle(
                                color: colors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                      if (!isOwner &&
                          profile?.description?.trim().isNotEmpty == true)
                        SliverToBoxAdapter(
                          child: _SectionCard(
                            title: s.sellerDescriptionSection,
                            child: Text(
                              profile!.description!.trim(),
                              style: TextStyle(
                                color: colors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      if (!isOwner && profile?.locationLabel != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Row(
                              children: [
                                Icon(LucideIcons.mapPin,
                                    size: 16, color: colors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    profile!.locationLabel!,
                                    style: TextStyle(color: colors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!isOwner && profile?.socialLinks?.hasAny == true)
                        SliverToBoxAdapter(
                          child: _SocialLinksRow(
                            links: profile!.socialLinks!,
                            onTap: _openUrl,
                          ),
                        ),
                      if (profile != null && profile.categories.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _CategoriesSection(
                            categories: profile.categories,
                            selectedId: _categoryId,
                            onSelect: (id) {
                              setState(() {
                                _categoryId =
                                    _categoryId == id ? null : id;
                              });
                              _loadProducts(reset: true);
                            },
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: _ProductsToolbar(
                          isOwner: isOwner,
                          tab: _tab,
                          gridView: _gridView,
                          searchController: _searchController,
                          sort: _sort,
                          onAddProduct: _openAddProduct,
                          onTab: (t) {
                            setState(() => _tab = t);
                            _loadProducts(reset: true);
                          },
                          onSort: (v) {
                            setState(() => _sort = v);
                            _loadProducts(reset: true);
                          },
                          onToggleView: () =>
                              setState(() => _gridView = !_gridView),
                        ),
                      ),
                      if (isLoading && parts.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        )
                      else if (parts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.store,
                                    size: 48, color: colors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  profile?.isOwnProfile == true
                                      ? s.ownerStoreEmpty
                                      : s.sellerStoreEmpty,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  profile?.isOwnProfile == true
                                      ? s.addFirstProduct
                                      : s.sellerStoreEmptyHint,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: colors.textMuted),
                                ),
                                if (profile?.isOwnProfile == true) ...[
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: _openAddProduct,
                                    icon: const Icon(LucideIcons.plus, size: 18),
                                    label: Text(s.addFirstProduct),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      else if (_gridView)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.72,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => ProductCardGrid(
                                product: parts[index],
                                key: ValueKey(parts[index].id),
                              ),
                              childCount: parts.length,
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                              child: SellerProductListTile(
                                product: parts[index],
                              ),
                            ),
                            childCount: parts.length,
                          ),
                        ),
                      if (isMoreLoading)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
    );
  }
}

class _VisitorProfileHeader extends StatelessWidget {
  final SellerStoreProfile profile;
  final String? localeCode;
  final String initials;
  final VoidCallback onFollow;
  final VoidCallback onMessage;
  final VoidCallback onShare;
  final bool followLoading;
  final bool messageLoading;

  const _VisitorProfileHeader({
    required this.profile,
    required this.localeCode,
    required this.initials,
    required this.onFollow,
    required this.onMessage,
    required this.onShare,
    required this.followLoading,
    required this.messageLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final joined = DateFormat('MMM yyyy', localeCode).format(profile.createdAt);
    final avatarUrl = resolveMediaUrl(profile.image, mediaBase: fileUrl);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: AppRadius.rL,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: avatarUrl != null
                      ? ImageCacheNetwork(url: avatarUrl, width: 72, height: 72)
                      : Container(
                          width: 72,
                          height: 72,
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
                              fontSize: 26,
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
                      const SizedBox(height: 8),
                      Text(
                        s.sellerFollowersProducts(
                          formatCompactCount(profile.stats.followersCount),
                          formatCompactCount(profile.stats.totalProducts),
                          joined,
                        ),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: followLoading ? null : onFollow,
                      icon: followLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              profile.isFollowing
                                  ? LucideIcons.check
                                  : LucideIcons.userPlus,
                              size: 18,
                            ),
                      label: Text(
                        profile.isFollowing ? s.following : s.follow,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: profile.isFollowing
                            ? colors.textPrimary
                            : null,
                      ),
                    ),
                  ),
                  if (profile.allowMessages) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: messageLoading ? null : onMessage,
                        icon: messageLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              )
                            : const Icon(LucideIcons.messageSquare, size: 18),
                        label: Text(s.writeSeller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: onShare,
                    icon: const Icon(LucideIcons.share2, size: 18),
                    tooltip: s.shareProfile,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final SellerStoreStats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;
    final items = [
      (s.sellerStatProducts, formatCompactCount(stats.totalProducts)),
      (s.sellerStatCategories, '${stats.categoriesCount}'),
      (s.sellerStatFollowers, formatCompactCount(stats.followersCount)),
      (s.sellerStatProfileViews, formatCompactCount(stats.profileViews)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map(
              (e) => Container(
                width: (MediaQuery.sizeOf(context).width - 48) / 2,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadius.rM,
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.$2,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.$1,
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.rL,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _SocialLinksRow extends StatelessWidget {
  final SellerSocialLinks links;
  final void Function(String url) onTap;
  const _SocialLinksRow({required this.links, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final entries = <(IconData, String?)>[
      (LucideIcons.send, links.telegram),
      (LucideIcons.instagram, links.instagram),
      (LucideIcons.globe, links.website),
      (LucideIcons.youtube, links.youtube),
      (LucideIcons.facebook, links.facebook),
    ].where((e) => e.$2 != null && e.$2!.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.sellerSocialLinks,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: entries
                .map(
                  (e) => IconButton.filledTonal(
                    onPressed: () => onTap(e.$2!),
                    icon: Icon(e.$1, size: 20),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final List<SellerCategoryStat> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _CategoriesSection({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.sellerCategories,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = categories[i];
                final selected = selectedId == c.categoryId;
                return FilterChip(
                  label: Text('${c.name} (${c.productCount})'),
                  selected: selected,
                  onSelected: (_) => onSelect(c.categoryId),
                  selectedColor: colors.primary.withValues(alpha: 0.15),
                  checkmarkColor: colors.primary,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsToolbar extends StatelessWidget {
  final bool isOwner;
  final _ProductTab tab;
  final bool gridView;
  final TextEditingController searchController;
  final String sort;
  final VoidCallback onAddProduct;
  final ValueChanged<_ProductTab> onTab;
  final ValueChanged<String> onSort;
  final VoidCallback onToggleView;

  const _ProductsToolbar({
    required this.isOwner,
    required this.tab,
    required this.gridView,
    required this.searchController,
    required this.sort,
    required this.onAddProduct,
    required this.onTab,
    required this.onSort,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isOwner ? s.ownerMyListings : s.allProducts,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isOwner)
                FilledButton.tonalIcon(
                  onPressed: onAddProduct,
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: Text(s.addProduct),
                ),
            ],
          ),
          if (!isOwner) ...[
            const SizedBox(height: 10),
            SegmentedButton<_ProductTab>(
              segments: [
                ButtonSegment(value: _ProductTab.all, label: Text(s.allProducts)),
                ButtonSegment(
                    value: _ProductTab.latest, label: Text(s.latestProducts)),
                ButtonSegment(
                    value: _ProductTab.popular, label: Text(s.popularProducts)),
              ],
              selected: {tab},
              onSelectionChanged: (v) => onTab(v.first),
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: s.searchSellerProducts,
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(borderRadius: AppRadius.rM),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: sort,
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: AppRadius.rM),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'RECOMMENDED', child: Text(s.popularProducts)),
                    DropdownMenuItem(
                        value: 'NEWEST', child: Text(s.sortNewest)),
                    DropdownMenuItem(
                        value: 'PRICE_ASC', child: Text(s.sortPriceLowHigh)),
                    DropdownMenuItem(
                        value: 'PRICE_DESC', child: Text(s.sortPriceHighLow)),
                  ],
                  onChanged: (v) {
                    if (v != null) onSort(v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: onToggleView,
                icon: Icon(gridView ? LucideIcons.list : LucideIcons.layoutGrid),
                tooltip: gridView ? s.listView : s.gridView,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StickyFollowBar extends StatelessWidget {
  final bool isFollowing;
  final bool loading;
  final VoidCallback onFollow;

  const _StickyFollowBar({
    required this.isFollowing,
    required this.loading,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: loading ? null : onFollow,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isFollowing ? LucideIcons.check : LucideIcons.userPlus,
                      size: 18,
                    ),
              label: Text(isFollowing ? s.following : s.follow),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isFollowing ? colors.surface : colors.primary,
                foregroundColor:
                    isFollowing ? colors.textPrimary : colors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: base.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: base,
                borderRadius: AppRadius.rL,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                4,
                (_) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 64,
                    color: base,
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
