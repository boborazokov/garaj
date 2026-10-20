import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/map/maptiler_config.dart';
import 'package:my_auto/core/map/open_external_maps.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/features/promotion/presentation/promote_workshop_sheet.dart';
import 'package:my_auto/features/workshop/presentation/widgets/workshop_services_grid.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/errors/user_facing_errors.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/widgets/reviews/submit_review_sheet.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkshopDetailScreen extends StatefulWidget {
  const WorkshopDetailScreen({super.key, required this.workshopId});

  final String workshopId;

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> {
  WorkshopProfile? _workshop;
  List<WorkshopReview> _reviews = [];
  List<WorkshopProfile> _similar = [];
  bool _loading = true;
  bool _reviewsLoadingMore = false;
  bool _reviewsHasMore = false;
  int _reviewsPage = 1;
  int _reviewsTotal = 0;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_reviewsHasMore || _reviewsLoadingMore) return;
    if (_scrollCtrl.position.pixels <
        _scrollCtrl.position.maxScrollExtent - 280) {
      return;
    }
    _loadMoreReviews();
  }

  WorkshopReview? get _myReview {
    final myId = context.read<AuthProvider>().auth?.user.id;
    if (myId == null || myId.isEmpty) return null;
    for (final r in _reviews) {
      if (r.userId == myId) return r;
    }
    return null;
  }

  Future<void> _load() async {
    final w = await workshopsRepository.details(widget.workshopId);
    if (!mounted) return;
    setState(() {
      _workshop = w;
      _loading = false;
    });
    await _loadReviews(reset: true);
    if (w == null) return;
    final nearby = await workshopsRepository.nearby(
      latitude: w.geo?.latitude,
      longitude: w.geo?.longitude,
      limit: 12,
    );
    if (!mounted) return;
    setState(() {
      _similar = nearby
          .where((e) => e.id != widget.workshopId)
          .take(8)
          .toList(growable: false);
    });
  }

  Future<void> _loadReviews({required bool reset}) async {
    final pageToFetch = reset ? 1 : _reviewsPage;
    try {
      final page = await workshopsRepository.reviewsPage(
        workshopId: widget.workshopId,
        page: pageToFetch,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _reviews = page.items;
          _reviewsPage = 2;
        } else {
          _reviews = [..._reviews, ...page.items];
          _reviewsPage = pageToFetch + 1;
        }
        _reviewsHasMore = page.hasNextPage;
        _reviewsTotal = page.totalDocs;
        _reviewsLoadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _reviewsLoadingMore = false);
    }
  }

  Future<void> _loadMoreReviews() async {
    if (_reviewsLoadingMore || !_reviewsHasMore) return;
    setState(() => _reviewsLoadingMore = true);
    await _loadReviews(reset: false);
  }

  Future<void> _call(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openInMaps(WorkshopProfile w) async {
    final geo = w.geo;
    if (geo == null) return;
    final opened = await openLocationInExternalMaps(
      latitude: geo.latitude,
      longitude: geo.longitude,
      label: w.displayAddress.isNotEmpty ? w.displayAddress : w.name,
    );
    if (!opened && mounted) {
      Toaster.error(S.of(context).errorGeneric, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const AppSafeArea(
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
      );
    }

    final w = _workshop;
    if (w == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppSafeArea(
          top: false,
          child: Center(child: Text(S.of(context).errorWorkshopNotFound)),
        ),
      );
    }

    final s = S.of(context);
    final images = w.allImages;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutesName.buttonNavigationBar);
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: images.isEmpty
                  ? ColoredBox(
                      color: colors.primary.withValues(alpha: 0.15),
                      child: Icon(LucideIcons.wrench,
                          size: 64, color: colors.primary),
                    )
                  : CarouselSlider(
                      options: CarouselOptions(
                        height: 280,
                        viewportFraction: 1,
                        autoPlay: images.length > 1,
                      ),
                      items: images
                          .map(
                            (url) => ImageCacheNetwork(
                              url: url,
                              height: 280,
                              fit: BoxFit.cover,
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (w.logo.isNotEmpty)
                        ClipRRect(
                          borderRadius: AppRadius.rM,
                          child: ImageCacheNetwork(
                            url: w.logo,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: AppRadius.rM,
                          ),
                          child: Icon(LucideIcons.wrench, color: colors.primary),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                if (w.isPromotionActive)
                                  _chip(s.promotedBadge, colors.warning),
                                if (w.verified) _chip(s.workshopVerified, colors.primary),
                                _chip(
                                  w.isOpenNow ? s.workshopOpenNow : s.orderStatusClosed,
                                  w.isOpenNow
                                      ? const Color(0xFF16A34A)
                                      : colors.danger,
                                ),
                                _chip(
                                  '★ ${w.rating.toStringAsFixed(1)} (${w.reviewCount})',
                                  colors.warning,
                                ),
                                if (w.fastResponse)
                                  _chip(s.workshopFastResponse, colors.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (w.description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted.withValues(alpha: 0.65),
                        borderRadius: AppRadius.rL,
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.info,
                                size: 18,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                s.workshopAbout,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            w.description,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: colors.textSecondary,
                                      height: 1.55,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (w.categories.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      s.workshopServiceTypes,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    WorkshopServicesGrid(categories: w.categories),
                  ],
                  if (w.servicePricing.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...w.servicePricing.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(p.label)),
                            Text(
                              p.priceFrom != null
                                  ? s.workshopPriceFrom(
                                      p.priceFrom!.toStringAsFixed(0),
                                      p.currency ?? 'UZS',
                                    )
                                  : s.workshopOnRequest,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (images.length > 1) ...[
                    const SizedBox(height: 20),
                    Text(
                      s.gallery,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: AppRadius.rM,
                          child: ImageCacheNetwork(
                            url: images[i],
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (w.geo != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      s.location,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openInMaps(w),
                        borderRadius: AppRadius.rL,
                        child: ClipRRect(
                          borderRadius: AppRadius.rL,
                          child: SizedBox(
                            height: 160,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                FlutterMap(
                                  options: MapOptions(
                                    initialCenter: LatLng(
                                      w.geo!.latitude,
                                      w.geo!.longitude,
                                    ),
                                    initialZoom: 14,
                                    interactionOptions:
                                        const InteractionOptions(
                                      flags: InteractiveFlag.none,
                                    ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          MapTilerConfig.streetsTileUrl,
                                      userAgentPackageName: 'garaj.uz',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(
                                            w.geo!.latitude,
                                            w.geo!.longitude,
                                          ),
                                          width: 40,
                                          height: 40,
                                          child: Icon(
                                            LucideIcons.mapPin,
                                            color: colors.primary,
                                            size: 32,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: colors.surface
                                          .withValues(alpha: 0.92),
                                      borderRadius: AppRadius.rM,
                                      border: Border.all(color: colors.border),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LucideIcons.externalLink,
                                            size: 16,
                                            color: colors.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            S.of(context).searchHubOpenMap,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: colors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _openInMaps(w),
                      borderRadius: AppRadius.rM,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          w.displayAddress,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.primary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: colors.primary
                                        .withValues(alpha: 0.4),
                                  ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _reviewsTotal > 0
                              ? '${S.of(context).reviewsTitle} ($_reviewsTotal)'
                              : S.of(context).reviewsTitle,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      if (!_isOwnWorkshop(w))
                        TextButton.icon(
                          onPressed: _myReview != null
                              ? () => _editReview(_myReview!)
                              : _submitReview,
                          icon: Icon(
                            LucideIcons.pencil,
                            size: 18,
                            color: colors.primary,
                          ),
                          label: Text(
                            _myReview != null
                                ? S.of(context).editReview
                                : S.of(context).writeReview,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_reviews.isEmpty)
                    Text(
                      S.of(context).noReviewsYet,
                      style: TextStyle(color: colors.textMuted),
                    )
                  else ...[
                    ..._reviews.map(
                      (r) => _ReviewTile(
                        review: r,
                        isMine: r.userId != null &&
                            r.userId ==
                                context.read<AuthProvider>().auth?.user.id,
                        onEdit: () => _editReview(r),
                        onDelete: () => _deleteReview(r),
                      ),
                    ),
                    if (_reviewsHasMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: OutlinedButton(
                          onPressed:
                              _reviewsLoadingMore ? null : _loadMoreReviews,
                          child: _reviewsLoadingMore
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(S.of(context).loadMoreReviews),
                        ),
                      ),
                  ],
                  if (_similar.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      S.of(context).similarWorkshops,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 148,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _similar.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final item = _similar[i];
                          final cover = item.heroImage;
                          return SizedBox(
                            width: 148,
                            child: Material(
                              color: colors.surface,
                              borderRadius: AppRadius.rL,
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => context.push(
                                  '${RoutesName.workshopDetailScreen}/${item.id}',
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: cover.isEmpty
                                          ? ColoredBox(
                                              color: colors.surfaceMuted,
                                              child: Icon(
                                                LucideIcons.wrench,
                                                color: colors.textMuted,
                                              ),
                                            )
                                          : ImageCacheNetwork(
                                              url: cover,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        item.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: bottomSafeOffset(context, 76)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        isOwner: _isOwnWorkshop(w),
        isPromoted: w.isPromotionActive,
        onCall: () => _call(w.phone.isNotEmpty ? w.phone : w.owner.phone),
        onPromote: () async {
          final promoted = await showPromoteWorkshopSheet(context, workshop: w);
          if (promoted == true) await _load();
        },
      ),
    );
  }

  bool _isOwnWorkshop(WorkshopProfile w) {
    final myId = context.read<AuthProvider>().auth?.user.id;
    return myId != null && myId.isNotEmpty && myId == w.owner.id;
  }

  Future<void> _submitReview() async {
    final workshopId = widget.workshopId;
    await SubmitReviewSheet.show(
      context,
      onSubmit: ({required rating, required text}) async {
        try {
          await workshopsRepository.addReview(
            workshopId: workshopId,
            rating: rating,
            text: text,
          );
          if (!mounted) return;
          Toaster.success(S.of(context).reviewSubmitted, context: context);
          await _load();
        } on OperationException catch (e) {
          if (!mounted) return;
          UserFacingErrors.show(
            context,
            presentation: ErrorPresentation.userAction,
            exception: e,
          );
        }
      },
    );
  }

  Future<void> _editReview(WorkshopReview review) async {
    await SubmitReviewSheet.show(
      context,
      initialRating: review.rating,
      initialText: review.text,
      title: S.of(context).editReview,
      onSubmit: ({required rating, required text}) async {
        try {
          await workshopsRepository.updateReview(
            reviewId: review.id,
            rating: rating,
            text: text,
          );
          if (!mounted) return;
          Toaster.success(S.of(context).reviewUpdated, context: context);
          await _load();
        } on OperationException catch (e) {
          if (!mounted) return;
          UserFacingErrors.show(
            context,
            presentation: ErrorPresentation.userAction,
            exception: e,
          );
        }
      },
    );
  }

  Future<void> _deleteReview(WorkshopReview review) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteReview),
        content: Text(s.deleteReviewConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.deleteReview),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await workshopsRepository.deleteReview(review.id);
      if (!mounted) return;
      Toaster.success(s.reviewDeleted, context: context);
      await _load();
    } on OperationException catch (e) {
      if (!mounted) return;
      UserFacingErrors.show(
        context,
        presentation: ErrorPresentation.userAction,
        exception: e,
      );
    }
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    this.isMine = false,
    this.onEdit,
    this.onDelete,
  });

  final WorkshopReview review;
  final bool isMine;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.userName ?? S.of(context).user,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('★ ${review.rating.toStringAsFixed(1)}'),
              if (isMine)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(s.editReview),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        s.deleteReview,
                        style: TextStyle(color: colors.danger),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.text),
          ],
          if (review.ownerReplyText != null &&
              review.ownerReplyText!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.06),
                borderRadius: AppRadius.rM,
              ),
              child: Text(
                S.of(context).workshopOwnerReply(review.ownerReplyText ?? ''),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.onCall,
    required this.onPromote,
    this.isOwner = false,
    this.isPromoted = false,
  });

  final VoidCallback onCall;
  final VoidCallback onPromote;
  final bool isOwner;
  final bool isPromoted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            stickyBottomPadding(context, keyboardExtra: 0, homeExtra: 12),
          ),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.92),
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: isOwner
              ? FilledButton.icon(
                  onPressed: onPromote,
                  icon: Icon(
                    isPromoted ? LucideIcons.sparkles : LucideIcons.trendingUp,
                  ),
                  label: Text(
                    isPromoted ? '${s.promotedTop} · plan' : 'Choose promotion plan',
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onCall,
                    icon: const Icon(LucideIcons.phone),
                    label: Text(s.callSeller),
                  ),
                ),
        ),
      ),
    );
  }
}
