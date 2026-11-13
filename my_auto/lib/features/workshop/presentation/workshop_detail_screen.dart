import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/errors/user_facing_errors.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/map/maptiler_config.dart';
import 'package:my_auto/core/map/open_external_maps.dart';
import 'package:my_auto/core/presentation/shimmer_skeletons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/services/engagement/engagement_repository.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/promotion/presentation/promote_workshop_sheet.dart';
import 'package:my_auto/features/promotion/presentation/promotion_plan_badge.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/features/workshop/presentation/widgets/book_workshop_sheet.dart';
import 'package:my_auto/features/workshop/presentation/widgets/workshop_services_grid.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
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
  int _heroIndex = 0;
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
    unawaited(
      engagementRepository.recordWorkshopPhoneClick(widget.workshopId),
    );
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const AppSafeArea(
          child: DetailPageSkeleton(),
        ),
      );
    }

    final w = _workshop;
    if (w == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(),
        body: AppSafeArea(
          top: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(MarketUi.spacingMD),
              child: Text(
                s.errorWorkshopNotFound,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
          ),
        ),
      );
    }

    final images = w.allImages;
    final isOwner = _isOwnWorkshop(w);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            leading: _GlassBackButton(
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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (images.isEmpty)
                    ColoredBox(
                      color: colors.surfaceMuted,
                      child: Icon(
                        LucideIcons.wrench,
                        size: 56,
                        color: colors.textMuted,
                      ),
                    )
                  else
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 1,
                        autoPlay: images.length > 1,
                        onPageChanged: (i, _) =>
                            setState(() => _heroIndex = i),
                      ),
                      items: images
                          .map(
                            (url) => ImageCacheNetwork(
                              url: url,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                          .toList(),
                    ),
                  if (images.length > 1)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.textPrimary.withValues(alpha: 0.72),
                          borderRadius: AppRadius.rM,
                        ),
                        child: Text(
                          '${_heroIndex + 1}/${images.length}',
                          style: TextStyle(
                            color: colors.background,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ProductSection(
              margin: const EdgeInsets.fromLTRB(
                MarketUi.spacingMD,
                MarketUi.sectionGap,
                MarketUi.spacingMD,
                0,
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Logo(url: w.logo),
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
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: colors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                if (w.isPromotionActive)
                                  PromotionPlanBadge(
                                    plan: w.promotionPlan,
                                    dense: false,
                                  ),
                                if (w.verified)
                                  MarketBadgeChip(label: s.workshopVerified),
                                _StatusChip(
                                  label: w.isOpenNow
                                      ? s.workshopOpenNow
                                      : s.orderStatusClosed,
                                  dotColor: w.isOpenNow
                                      ? colors.success
                                      : colors.textMuted,
                                ),
                                MarketBadgeChip(
                                  label:
                                      '${w.rating.toStringAsFixed(1)} ★ · ${w.reviewCount}',
                                ),
                                if (w.fastResponse)
                                  MarketBadgeChip(
                                    label: s.workshopFastResponse,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (w.description.isNotEmpty)
            SliverToBoxAdapter(
              child: ProductSection(
                title: s.workshopAbout,
                child: Text(
                  w.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                        height: 1.55,
                      ),
                ),
              ),
            ),
          if (w.categories.isNotEmpty || w.servicePricing.isNotEmpty)
            SliverToBoxAdapter(
              child: ProductSection(
                title: s.workshopServiceTypes,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (w.categories.isNotEmpty)
                      WorkshopServicesGrid(categories: w.categories),
                    if (w.servicePricing.isNotEmpty) ...[
                      if (w.categories.isNotEmpty)
                        const SizedBox(height: AppSpacing.l),
                      ...w.servicePricing.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.label,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                p.priceFrom != null
                                    ? s.workshopPriceFrom(
                                        p.priceFrom!.toStringAsFixed(0),
                                        p.currency ?? 'UZS',
                                      )
                                    : s.workshopOnRequest,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (images.length > 1)
            SliverToBoxAdapter(
              child: ProductSection(
                title: s.gallery,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: SizedBox(
                  height: 88,
                  child: ListView.separated(
                    addAutomaticKeepAlives: false,
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
              ),
            ),
          if (w.geo != null)
            SliverToBoxAdapter(
              child: ProductSection(
                title: s.location,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openInMaps(w),
                        borderRadius: MarketUi.cardRadius,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
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
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surface
                                          .withValues(alpha: 0.94),
                                      borderRadius: AppRadius.rM,
                                      border:
                                          Border.all(color: colors.border),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          LucideIcons.externalLink,
                                          size: 14,
                                          color: colors.textPrimary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          s.searchHubOpenMap,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (w.displayAddress.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => _openInMaps(w),
                        borderRadius: AppRadius.rM,
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              size: 16,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                w.displayAddress,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colors.textSecondary,
                                      height: 1.35,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: ProductSection(
              title: _reviewsTotal > 0
                  ? '${s.reviewsTitle} ($_reviewsTotal)'
                  : s.reviewsTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isOwner)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: _myReview != null
                            ? () => _editReview(_myReview!)
                            : _submitReview,
                        icon: Icon(
                          LucideIcons.pencil,
                          size: 16,
                          color: colors.textPrimary,
                        ),
                        label: Text(
                          _myReview != null ? s.editReview : s.writeReview,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  if (_reviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        s.noReviewsYet,
                        style: TextStyle(
                          color: colors.textMuted,
                          height: 1.4,
                        ),
                      ),
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
                        padding: const EdgeInsets.only(top: 4),
                        child: OutlinedButton(
                          onPressed:
                              _reviewsLoadingMore ? null : _loadMoreReviews,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: colors.textPrimary,
                            side: BorderSide(color: colors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.rM,
                            ),
                          ),
                          child: _reviewsLoadingMore
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primary,
                                  ),
                                )
                              : Text(s.loadMoreReviews),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (_similar.isNotEmpty)
            SliverToBoxAdapter(
              child: ProductSection(
                title: s.similarWorkshops,
                padding: const EdgeInsets.fromLTRB(18, 18, 0, 16),
                child: SizedBox(
                  height: 156,
                  child: ListView.separated(
                    addAutomaticKeepAlives: false,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 18),
                    itemCount: _similar.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final item = _similar[i];
                      final cover = item.heroImage;
                      return SizedBox(
                        width: 148,
                        child: MarketCardShell(
                          onTap: () => context.push(
                            '${RoutesName.workshopDetailScreen}/${item.id}',
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  8,
                                  10,
                                  10,
                                ),
                                child: Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: bottomSafeOffset(context, 96)),
          ),
        ],
      ),
      bottomNavigationBar: _BottomDock(
        isOwner: isOwner,
        isPromoted: w.isPromotionActive,
        onCall: () => _call(w.phone.isNotEmpty ? w.phone : w.owner.phone),
        onDirections: w.geo != null ? () => _openInMaps(w) : null,
        onBook: isOwner
            ? null
            : () => BookWorkshopSheet.show(context, w),
        onPromote: () async {
          final promoted =
              await showPromoteWorkshopSheet(context, workshop: w);
          if (promoted == true) await _load();
        },
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: colors.surface.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              LucideIcons.arrowLeft,
              size: 20,
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppRadius.rM,
        child: ImageCacheNetwork(
          url: url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.rM,
        border: Border.all(color: colors.border),
      ),
      child: Icon(LucideIcons.wrench, color: colors.textSecondary),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.dotColor});

  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.userName ?? s.user,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '★ ${review.rating.toStringAsFixed(1)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
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
                    PopupMenuItem(value: 'edit', child: Text(s.editReview)),
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
            Text(
              review.text,
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          if (review.ownerReplyText != null &&
              review.ownerReplyText!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: AppRadius.rM,
                border: Border.all(color: colors.border),
              ),
              child: Text(
                s.workshopOwnerReply(review.ownerReplyText ?? ''),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomDock extends StatelessWidget {
  const _BottomDock({
    required this.onCall,
    required this.onPromote,
    this.onBook,
    this.onDirections,
    this.isOwner = false,
    this.isPromoted = false,
  });

  final VoidCallback onCall;
  final VoidCallback onPromote;
  final VoidCallback? onBook;
  final VoidCallback? onDirections;
  final bool isOwner;
  final bool isPromoted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Material(
      color: colors.background,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          MarketUi.spacingMD,
          AppSpacing.s,
          MarketUi.spacingMD,
          stickyBottomPadding(context, keyboardExtra: 0, homeExtra: 12),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: MarketUi.actionDock(context, colors),
          child: isOwner
              ? SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onPromote,
                    icon: Icon(
                      isPromoted
                          ? LucideIcons.sparkles
                          : LucideIcons.trendingUp,
                      size: 18,
                    ),
                    label: Text(
                      isPromoted
                          ? s.promotedTop
                          : s.promoteWorkshopTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.rM,
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    if (onDirections != null) ...[
                      IconButton.outlined(
                        onPressed: onDirections,
                        tooltip: s.searchHubOpenMap,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(52, 52),
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.rM,
                          ),
                        ),
                        icon: const Icon(LucideIcons.navigation, size: 20),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onBook ?? onCall,
                        icon: Icon(
                          onBook != null
                              ? LucideIcons.calendar
                              : LucideIcons.phone,
                          size: 18,
                        ),
                        label: Text(
                          onBook != null ? s.bookNow : s.callSeller,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.rM,
                          ),
                        ),
                      ),
                    ),
                    if (onBook != null) ...[
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: onCall,
                        tooltip: s.callSeller,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(52, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.rM,
                          ),
                        ),
                        icon: const Icon(LucideIcons.phone, size: 20),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
