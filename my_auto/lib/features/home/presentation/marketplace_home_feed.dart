import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/map/geo_location.dart';
import 'package:my_auto/core/map/user_location_service.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/provider/add/getCotegories.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/utils/geocoder.dart';
import 'package:my_auto/features/chat/chat_di.dart';
import 'package:my_auto/features/chat/domain/entities/conversation.dart';
import 'package:my_auto/features/discovery/presentation/providers/discovery_provider.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/features/home/presentation/widgets/home_product_card.dart';
import 'package:my_auto/features/home/presentation/widgets/home_promo_carousel.dart';
import 'package:my_auto/features/home/presentation/widgets/home_workshops_strip.dart';
import 'package:my_auto/features/notifications/bloc/notifications_bloc.dart';
import 'package:my_auto/features/notifications/bloc/notifications_state.dart';
import 'package:my_auto/main.dart' show pushService;
import 'package:my_auto/features/orders/domain/entities/order.dart';
import 'package:my_auto/features/orders/domain/entities/paginated_orders.dart';
import 'package:my_auto/features/orders/orders_di.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/services/data/services_repository.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:shimmer/shimmer.dart';

/// Automotive marketplace feed: sticky bar → promo → workshops → infinite parts.
class MarketplaceHomeFeed extends StatefulWidget {
  const MarketplaceHomeFeed({super.key});

  @override
  State<MarketplaceHomeFeed> createState() => _MarketplaceHomeFeedState();
}

sealed class _FeedSlot {}

class _SlotProduct extends _FeedSlot {
  _SlotProduct(this.part);
  final Part part;
}

class _SlotOrder extends _FeedSlot {
  _SlotOrder(this.order);
  final Order order;
}

class _SlotWorkshop extends _FeedSlot {
  _SlotWorkshop(this.workshop);
  final WorkshopProfile workshop;
}

class _MarketplaceHomeFeedState extends State<MarketplaceHomeFeed>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;

  List<WorkshopProfile> _nearbyWorkshops = const [];
  bool _workshopsLoading = false;

  List<ServiceListing> _nearbyServices = const [];

  List<Order> _injectOrders = const [];

  List<Conversation> _inboxPreview = const [];

  LatLng? _userLatLng;
  String? _locationLine;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    Future.microtask(() {
      if (!mounted) return;
      context.read<GetCategories>().loadCategories(type.PART.name);
      final p = context.read<ProductProvider>();
      p.loadList(filters: {}, reset: true);
      p.loadList(filters: {'isPromoted': true}, reset: true);
      context.read<DiscoveryProvider>().refreshAll();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapLocation());
      unawaited(_loadSecondary());
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 480) return;
    final hub = context.read<ProductProvider>();
    if (!hub.isMoreLoadingFor({}) &&
        hub.hasMoreFor({}) &&
        !hub.isLoadingFor({})) {
      unawaited(hub.loadMore(filters: {}));
    }
  }

  Future<void> _bootstrapLocation() async {
    final (_, pt) = await UserLocationService.getCurrentLatLng();
    if (!mounted) return;
    if (pt != null) {
      setState(() => _userLatLng = pt);
      try {
        final raw = await GeocodeService.getAddressFromGeo(
          GeoLocation.fromLatLng(pt),
        );
        if (mounted && raw != null && raw.isNotEmpty) {
          final short = raw.split(',').take(2).join(',').trim();
          if (short.length > 42) {
            setState(() => _locationLine = '${short.substring(0, 40)}…');
          } else {
            setState(() => _locationLine = short);
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _loadSecondary() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>().auth;

    setState(() {
      _workshopsLoading = true;
      if (auth == null) _inboxPreview = const [];
    });

    final wfut = workshopsRepository.nearby(limit: 14).catchError((_) {
      return <WorkshopProfile>[];
    });

    final svcFut = Future(() async {
      final (_, ll) = await UserLocationService.getCurrentLatLng();
      double lat = 41.2995;
      double lng = 69.2401;
      if (ll != null) {
        lat = ll.latitude;
        lng = ll.longitude;
      }
      return servicesRepository
          .nearbyServices(latitude: lat, longitude: lng)
          .catchError((_) => <ServiceListing>[]);
    });

    Future<PaginatedOrders> ordersFut =
        ordersRepository.getOrders(page: 1, limit: 16).catchError((_) {
      return const PaginatedOrders(
        items: [],
        page: 1,
        totalPages: 1,
        hasNextPage: false,
        totalDocs: 0,
      );
    });

    Future<void>? inboxFut;
    if (auth != null) {
      inboxFut = chatRepository
          .getConversations(page: 1, limit: 8)
          .then<void>((page) {
        if (!mounted) return;
        setState(() => _inboxPreview = page.items);
      }).catchError((_) {});
    }

    final w = await wfut;
    final svcs = await svcFut;
    final op = await ordersFut;

    if (!mounted) return;
    final openOrders = op.items.where((o) => o.isOpen).take(6).toList();
    setState(() {
      _nearbyWorkshops = w;
      _nearbyServices = svcs;
      _injectOrders = openOrders;
      _workshopsLoading = false;
    });

    if (inboxFut != null) await inboxFut;
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<ProductProvider>().loadList(filters: {}, reset: true),
      context.read<ProductProvider>().loadList(
            filters: {'isPromoted': true},
            reset: true,
          ),
      Future.value(context.read<GetCategories>().loadCategories(type.PART.name)),
      context.read<DiscoveryProvider>().refreshAll(),
      _bootstrapLocation(),
      _loadSecondary(),
    ]);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  int get _messagesUnread =>
      _inboxPreview.fold<int>(0, (s, e) => s + e.unread.clamp(0, 999));

  List<Part> _blendDiscover(List<Part> main, DiscoveryProvider d) {
    if (main.isEmpty) return main;
    final seen = main.map((e) => e.id).toSet();
    final prepend = <Part>[];
    for (final bucket in [
      d.feed(DiscoveryFeed.recommended),
      d.feed(DiscoveryFeed.trending),
      d.feed(DiscoveryFeed.nearby),
    ]) {
      for (final p in bucket) {
        if (prepend.length >= 12) break;
        if (seen.add(p.id)) prepend.add(p);
      }
      if (prepend.length >= 12) break;
    }
    return [...prepend, ...main];
  }

  List<_FeedSlot> _mixSlots(
    List<Part> parts,
    List<Order> orders,
    List<WorkshopProfile> workshopsForInject,
  ) {
    var oi = 0;
    var wi = 0;
    final out = <_FeedSlot>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && i % 10 == 0 && oi < orders.length) {
        out.add(_SlotOrder(orders[oi++]));
      }
      if (i > 0 && i % 16 == 0 && wi < workshopsForInject.length) {
        out.add(_SlotWorkshop(workshopsForInject[wi++]));
      }
      out.add(_SlotProduct(parts[i]));
    }
    return out;
  }

  List<Widget> _rowsFromSlots(BuildContext context, List<_FeedSlot> slots) {
    final rows = <Widget>[];
    for (var i = 0; i < slots.length;) {
      final s = slots[i];
      if (s is _SlotOrder || s is _SlotWorkshop) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: MarketUi.spacingMD),
            child: switch (s) {
              final _SlotOrder o => _InjectorOrderCard(order: o.order),
              final _SlotWorkshop w =>
                _InjectorWorkshopCard(workshop: w.workshop),
              _ => const SizedBox.shrink(),
            },
          ),
        );
        i++;
        continue;
      }
      final left = s as _SlotProduct;
      _SlotProduct? right;
      if (i + 1 < slots.length && slots[i + 1] is _SlotProduct) {
        right = slots[i + 1] as _SlotProduct;
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: MarketUi.spacingMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: HomeProductCard(product: left.part)),
              const SizedBox(width: MarketUi.spacingMD),
              Expanded(
                child: right != null
                    ? HomeProductCard(product: right.part)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      i += right != null ? 2 : 1;
    }
    return rows;
  }

  List<HomePromoSlide> _promoSlides(
    BuildContext context,
    AppColors colors,
    ProductProvider hub,
  ) {
    final s = S.of(context);

    final promoted = hub.promotedFor({'isPromoted': true});
    final promotedAlt = promoted.isEmpty
        ? hub.getProducts({'isPromoted': true})
        : promoted;

    final slides = <HomePromoSlide>[];

    for (final p in promotedAlt.take(3)) {
      final img =
          p.images.isNotEmpty ? p.images.first : '';
      slides.add(
        HomePromoSlide(
          imageUrl: img,
          title: p.name,
          subtitle: '${p.price} ${p.currency} • ${s.searchHubSectionProducts}',
          ctaLabel: s.seeAll,
          gradient: [
            colors.primary.withValues(alpha: .85),
            colors.primaryHover.withValues(alpha: .65),
          ],
          onTap: () =>
              context.push(RoutesName.productDetailScreen, extra: p.id),
        ),
      );
    }

    for (final w in _nearbyWorkshops.where((x) => x.premium || x.verified).take(2)) {
      slides.add(
        HomePromoSlide(
          imageUrl: w.heroImage,
          title: w.name,
          subtitle: '${s.searchHubSectionWorkshops} • ${w.displayAddress}',
          ctaLabel: s.seeAll,
          gradient: [
            colors.info.withValues(alpha: .92),
            colors.primary.withValues(alpha: .5),
          ],
          onTap: () =>
              context.push('${RoutesName.workshopDetailScreen}/${w.id}'),
        ),
      );
    }

    for (final srv in _nearbyServices.where((x) => x.verified || x.rating >= 4.5).take(2)) {
      final img = srv.images.isNotEmpty ? srv.images.first : '';
      slides.add(
        HomePromoSlide(
          imageUrl: img,
          title: srv.title,
          subtitle: '${s.services} • ${srv.categoryName}',
          ctaLabel: s.seeAll,
          gradient: [
            colors.success.withValues(alpha: .75),
            colors.primary.withValues(alpha: .45),
          ],
          onTap: () =>
              context.push('${RoutesName.serviceDetail}/${srv.id}'),
        ),
      );
    }

    if (slides.isEmpty &&
        promotedAlt.isEmpty &&
        _nearbyWorkshops.isNotEmpty) {
      final w = _nearbyWorkshops.first;
      slides.add(
        HomePromoSlide(
          imageUrl: w.heroImage,
          title: w.name,
          subtitle: s.homeNearbyWorkshopsPreview,
          ctaLabel: s.searchHubOpenMap,
          gradient: [
            colors.primary.withValues(alpha: .8),
            colors.surfaceMuted,
          ],
          onTap: () => context.push(RoutesName.nearbyMap),
        ),
      );
    }

    return slides.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.appColors;
    final s = S.of(context);
    final hub = context.watch<ProductProvider>();
    final discovery = context.watch<DiscoveryProvider>();
    final merged = _blendDiscover(hub.getProducts({}), discovery);
    final injectWorkshops = _nearbyWorkshops.length > 3
        ? _nearbyWorkshops.sublist(3)
        : <WorkshopProfile>[];
    final slots =
        _mixSlots(merged, _injectOrders, injectWorkshops.take(8).toList());
    final feedRows = _rowsFromSlots(context, slots);

    final topPad = MediaQuery.paddingOf(context).top;
    final headerExtent = topPad + 58;

    final locationLabel =
        (_locationLine != null && _locationLine!.isNotEmpty)
            ? _locationLine!
            : s.nearYou;

    return Scaffold(
      backgroundColor: colors.background,
      body: AppSafeArea(
        top: false,
        bottom: false,
        child: RefreshIndicator(
          color: colors.primary,
          displacement: headerExtent + 8,
          edgeOffset: headerExtent + 4,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _GlassHomeHeaderDelegate(
                  minExtent: headerExtent,
                  maxExtent: headerExtent,
                  child: SizedBox.expand(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        MarketUi.spacingMD,
                        topPad + 6,
                        MarketUi.spacingMD,
                        8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () =>
                                context.push(RoutesName.nearbyMap),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.mapPin,
                                  size: 20,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 6),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 88),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        s.homeStickyChooseLocation,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textMuted,
                                        ),
                                      ),
                                      Text(
                                        locationLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Spacer(),
                          IconButton(
                            tooltip: s.search,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => context.push(
                              RoutesName.search,
                              extra: const {'unifiedSearch': true},
                            ),
                            icon: Icon(
                              LucideIcons.search,
                              color: colors.primary,
                              size: 24,
                            ),
                          ),
                          if (pushService.operational)
                            BlocBuilder<NotificationsBloc,
                                NotificationsState>(
                              builder: (context, st) {
                                final warn = st.status ==
                                        NotificationsStatus.denied ||
                                    (!st.permissionGranted &&
                                        st.status ==
                                            NotificationsStatus.ready);
                                return IconButton(
                                  tooltip: s.notificationsCenterTitle,
                                  onPressed: () => context.push(
                                      RoutesName.notifications),
                                  visualDensity:
                                      VisualDensity.compact,
                                  icon: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(LucideIcons.bell,
                                          color: colors.textPrimary),
                                      if (warn)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: colors.warning,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: s.messages,
                            visualDensity:
                                VisualDensity.compact,
                            onPressed: () async {
                              final ok = await AuthGuard.requireAuth(
                                context,
                                pending: const PendingRoute(
                                  path: RoutesName.chats,
                                ),
                              );
                              if (context.mounted && ok) {
                                context.push(RoutesName.chats);
                              }
                            },
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(LucideIcons.messageCircle,
                                    color: colors.textPrimary),
                                if (_messagesUnread > 0)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      padding: const EdgeInsets
                                          .symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.primary,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _messagesUnread > 9
                                            ? '9+'
                                            : '$_messagesUnread',
                                        style: TextStyle(
                                          color: colors.onPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: MarketUi.spacingMD),
                  child: HomePromoCarousel(
                    slides: _promoSlides(context, colors, hub),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketUi.spacingMD,
                    0,
                    MarketUi.spacingMD,
                    MarketUi.spacingSM,
                  ),
                  child: Text(
                    s.homeNearbyWorkshopsPreview,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: HomeWorkshopsStrip(
                  workshops: _nearbyWorkshops,
                  loading: _workshopsLoading,
                  userLatLng: _userLatLng,
                ),
              ),
              if (merged.isEmpty && hub.isLoadingFor({})) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MarketUi.spacingMD,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _FeedGridShimmer(colors: colors),
                  ),
                ),
              ] else if (merged.isEmpty && !hub.isLoadingFor({}))
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        s.noProducts,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.textMuted),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      16, 12, 16, MarketUi.spacingMD),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      ...feedRows,
                      if (hub.isMoreLoadingFor({}))
                        _MoreLoadingPlaceholder(colors: colors),
                      SizedBox(
                        height: listPaddingAboveBottomNav(context),
                      ),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedGridShimmer extends StatelessWidget {
  const _FeedGridShimmer({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceMuted,
      highlightColor: colors.surface,
      child: Column(
        children: List.generate(6, (_) {
          return Padding(
            padding: const EdgeInsets.only(bottom: MarketUi.spacingMD),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: MarketUi.cardRadius,
                    ),
                  ),
                ),
                const SizedBox(width: MarketUi.spacingMD),
                Expanded(
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: MarketUi.cardRadius,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _MoreLoadingPlaceholder extends StatelessWidget {
  const _MoreLoadingPlaceholder({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: MarketUi.spacingSM),
      child: Shimmer.fromColors(
        baseColor: colors.surfaceMuted,
        highlightColor: colors.surface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: MarketUi.cardRadius,
                  color: colors.surface,
                ),
              ),
            ),
            const SizedBox(width: MarketUi.spacingMD),
            Expanded(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: MarketUi.cardRadius,
                  color: colors.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassHomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _GlassHomeHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  final double minExtent;

  @override
  final double maxExtent;

  final Widget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final colors = context.appColors;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background.withValues(alpha: .78),
            border: overlaps
                ? Border(
                    bottom: BorderSide(color: colors.border.withValues(alpha: .35)),
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _GlassHomeHeaderDelegate oldDelegate) =>
      oldDelegate.minExtent != minExtent ||
      oldDelegate.maxExtent != maxExtent ||
      oldDelegate.child != child;
}

class _InjectorOrderCard extends StatelessWidget {
  const _InjectorOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: MarketUi.cardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.push('${RoutesName.orderDetail}/${order.id}'),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: MarketUi.cardRadius,
            gradient: LinearGradient(
              colors: [
                colors.warning.withValues(alpha: .22),
                colors.primary.withValues(alpha: .12),
              ],
            ),
            border: Border.all(color: colors.border.withValues(alpha: .25)),
            boxShadow: MarketUi.softElev(context),
          ),
          padding: const EdgeInsets.all(MarketUi.spacingMD),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(LucideIcons.clipboardList,
                    color: colors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.searchHubSectionOrders,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${order.budget} ${order.currency ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(LucideIcons.chevronRight,
                  color: colors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InjectorWorkshopCard extends StatelessWidget {
  const _InjectorWorkshopCard({required this.workshop});

  final WorkshopProfile workshop;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final img =
        workshop.logo.isNotEmpty ? workshop.logo : workshop.heroImage;
    return Material(
      borderRadius: MarketUi.cardRadius,
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          '${RoutesName.workshopDetailScreen}/${workshop.id}',
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: MarketUi.cardRadius,
            boxShadow: MarketUi.softElev(context),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: img.isEmpty
                    ? ColoredBox(
                        color: colors.surfaceMuted,
                        child: Icon(LucideIcons.wrench,
                            color: colors.textMuted))
                    : ImageCacheNetwork(
                        url: img,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.searchHubSectionWorkshops,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colors.info,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workshop.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight,
                  color: colors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
