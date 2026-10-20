import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/place_label.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/services/data/models/service_review.dart';
import 'package:my_auto/features/services/data/services_repository.dart';
import 'package:my_auto/features/services/presentation/book_service_sheet.dart';
import 'package:my_auto/features/services/presentation/promote_service_sheet.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/errors/user_facing_errors.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/widgets/reviews/submit_review_sheet.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  ServiceListing? _service;
  List<ServiceReview> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await servicesRepository.details(widget.serviceId);
    final reviews = await servicesRepository.reviews(widget.serviceId);
    if (!mounted) return;
    setState(() {
      _service = s;
      _reviews = reviews;
      _loading = false;
    });
  }

  bool _isOwnService(ServiceListing s) {
    final myId = context.read<AuthProvider>().auth?.user.id;
    final ownerId = s.ownerId;
    return myId != null &&
        myId.isNotEmpty &&
        ownerId != null &&
        ownerId.isNotEmpty &&
        myId == ownerId;
  }

  Future<void> _submitReview() async {
    await SubmitReviewSheet.show(
      context,
      onSubmit: ({required rating, required text}) async {
        try {
          await servicesRepository.addReview(
            serviceId: widget.serviceId,
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final s = _service;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(S.of(context).errorServiceNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              background: s.images.isEmpty
                  ? ColoredBox(color: colors.primary.withValues(alpha: 0.2))
                  : CarouselSlider(
                      options: CarouselOptions(
                        height: 240,
                        viewportFraction: 1,
                        autoPlay: s.images.length > 1,
                      ),
                      items: s.images
                          .map(
                            (url) => CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              width: double.infinity,
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (s.verified) _Badge('Verified', colors.primary),
                      if (s.isPromotionActive)
                        _Badge(S.of(context).promotedBadge, colors.warning),
                      _Badge(s.categoryName, colors.textMuted),
                      _Badge(
                        '${s.rating.toStringAsFixed(1)} ★ (${s.reviewCount})',
                        colors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(s.description),
                  const SizedBox(height: 12),
                  if (humanPlaceLabel(address: s.address, fallback: '').isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(LucideIcons.mapPin, color: colors.primary),
                      title: Text(humanPlaceLabel(address: s.address)),
                      trailing: IconButton(
                        icon: const Icon(LucideIcons.navigation),
                        onPressed: () {
                          final uri = Uri.parse(
                            'https://www.google.com/maps/dir/?api=1&destination=${s.latitude},${s.longitude}',
                          );
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                      ),
                    ),
                  if (s.features.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(S.of(context).serviceFeatures,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: s.features
                          .map((f) => Chip(label: Text(f)))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          S.of(context).reviewsTitle,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      if (!_isOwnService(s))
                        TextButton.icon(
                          onPressed: _submitReview,
                          icon: Icon(
                            LucideIcons.pencil,
                            size: 18,
                            color: colors.primary,
                          ),
                          label: Text(S.of(context).writeReview),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_reviews.isEmpty)
                    Text(
                      S.of(context).noReviewsYet,
                      style: TextStyle(color: colors.textMuted),
                    )
                  else
                    ..._reviews.take(8).map(
                          (r) => _ServiceReviewTile(review: r),
                        ),
                  SizedBox(height: bottomSafeOffset(context, 64)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          stickyBottomPadding(context, homeExtra: 16),
        ),
        child: Row(
          children: [
            if (_isOwnService(s))
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final promoted = await showPromoteServiceSheet(
                      context,
                      service: s,
                    );
                    if (promoted == true) await _load();
                  },
                  icon: const Icon(LucideIcons.sparkles),
                  label: Text(S.of(context).promotedTop),
                ),
              )
            else ...[
              if (s.phone != null && s.phone!.isNotEmpty)
                IconButton.filledTonal(
                  onPressed: () => launchUrl(Uri.parse('tel:${s.phone}')),
                  icon: const Icon(LucideIcons.phone),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    await showBookServiceSheet(
                      context,
                      serviceId: s.id,
                      serviceTitle: s.title,
                    );
                  },
                  icon: const Icon(LucideIcons.calendar),
                  label: Text(S.of(context).bookNow),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => context.push(RoutesName.nearbyMap),
                icon: const Icon(LucideIcons.map),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.rM,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ServiceReviewTile extends StatelessWidget {
  const _ServiceReviewTile({required this.review});

  final ServiceReview review;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
              Text(
                review.userName ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text('★ ${review.rating.toStringAsFixed(1)}'),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.text),
          ],
        ],
      ),
    );
  }
}
