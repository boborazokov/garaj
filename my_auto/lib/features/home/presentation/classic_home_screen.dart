import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/model/order/index.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/model/workshop/index.dart';
import 'package:my_auto/core/provider/add/getCotegories.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/core/provider/orders/orders_provider.dart';
import 'package:my_auto/core/provider/workshop/getWorkshop/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/presentation/shimmer_skeletons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';
import 'package:my_auto/features/home/widgets/featuredCarousel/index.dart';
import 'package:my_auto/features/home/widgets/gridCotegory/index.dart';
import 'package:my_auto/features/home/widgets/home_top_bar.dart';
import 'package:my_auto/features/home/widgets/productList/index.dart';
import 'package:my_auto/features/orders/widgets/order_card.dart';
import 'package:my_auto/features/workshop/widgets/workshopCard/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/buttom_navigation_bar/index.dart';
import 'package:provider/provider.dart';

/// Marketplace home — Uzum / Wildberries style:
/// soft grey canvas, white content blocks, plain title + “Hammasi”.
class ClassicHomeScreen extends StatefulWidget {
  const ClassicHomeScreen({super.key});

  @override
  State<ClassicHomeScreen> createState() => _ClassicHomeScreenState();
}

class _ClassicHomeScreenState extends State<ClassicHomeScreen> {
  late final ScrollController _scrollController;
  int _adRefreshToken = 0;
  static const Map<String, dynamic> _workshopFilters = {};
  static const Map<String, dynamic> _promoFilters = {'isPromoted': true};
  static const String _sort = 'NEWEST';
  static const int _productsBeforeServices = 8;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    Future.microtask(() {
      if (!mounted) return;
      context.read<GetCategories>().loadCategories(type.PART.name);
      final products = context.read<ProductProvider>();
      products.loadList(
        filters: _promoFilters,
        reset: true,
        sort: _sort,
      );
      products.loadList(filters: {}, reset: true, sort: _sort);
      context.read<GetWorkshop>().loadList(
            filters: _workshopFilters,
            reset: true,
          );
      context.read<OrdersProvider>().loadList(filters: {}, reset: true);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // Prefetch a bit earlier, but only once near the end — avoids a
    // mid-swipe network+rebuild hitch on old phones.
    if (pos.pixels < pos.maxScrollExtent - 480) return;
    final hub = context.read<ProductProvider>();
    if (!hub.isMoreLoadingFor({}, sort: _sort) &&
        hub.hasMoreFor({}, sort: _sort) &&
        !hub.isLoadingFor({}, sort: _sort)) {
      hub.loadMore(filters: {}, sort: _sort);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Soft refresh keeps current tiles on screen while network runs —
    // avoids the pull-gesture freeze from clearing → skeleton → rebuild.
    await Future.wait([
      context.read<ProductProvider>().loadList(
            filters: _promoFilters,
            reset: true,
            keepPrevious: true,
            sort: _sort,
          ),
      context.read<ProductProvider>().loadList(
            filters: {},
            reset: true,
            keepPrevious: true,
            sort: _sort,
          ),
      context.read<GetCategories>().loadCategories(type.PART.name),
      context.read<GetWorkshop>().loadList(
            filters: _workshopFilters,
            reset: true,
            keepPrevious: true,
          ),
      context.read<OrdersProvider>().loadList(
            filters: {},
            reset: true,
            keepPrevious: true,
          ),
    ]);
    if (!mounted) return;
    // Ads after content — one cheap rebuild instead of mid-gesture setState.
    setState(() => _adRefreshToken++);
  }

  void _openOrdersTab() {
    final shell = context.findAncestorStateOfType<MyBottomNavigationBarState>();
    if (shell != null) {
      shell.changeTab(1);
      return;
    }
    context.push(RoutesName.ordersList);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Do NOT watch all providers here — loadMore would rebuild categories /
    // workshops / ads mid-fling and freeze the scroll. Each section watches
    // only what it needs.
    return Scaffold(
      backgroundColor: colors.background,
      body: AppSafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: ColoredBox(
                  color: colors.surface,
                  child: const HomeTopBar(),
                ),
              ),
              SliverToBoxAdapter(
                child: AdBanner(
                  surface: AdSurface.brand,
                  height: 148,
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  refreshToken: _adRefreshToken,
                ),
              ),
              const _HomeCategoriesSection(),
              const _HomeFeaturedSection(
                promoFilters: _promoFilters,
                sort: _sort,
              ),
              _HomeOrdersSection(onSeeAll: _openOrdersTab),
              // Products + services: only this rebuilds on load-more.
              _HomeFeedBody(
                sort: _sort,
                promoFilters: _promoFilters,
                workshopFilters: _workshopFilters,
                productsBeforeServices: _productsBeforeServices,
                adRefreshToken: _adRefreshToken,
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: listPaddingAboveBottomNav(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Categories only — ignores product pagination notifies.
class _HomeCategoriesSection extends StatelessWidget {
  const _HomeCategoriesSection();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final categories = context.watch<GetCategories>().categories;
    return SliverToBoxAdapter(
      child: _WhiteBlock(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MarketHeader(
              title: s.category,
              onSeeAll: () => context.push(
                RoutesName.categoriesScreen,
                extra: type.PART.name,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: GridCategories(listCategory: categories),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFeaturedSection extends StatelessWidget {
  const _HomeFeaturedSection({
    required this.promoFilters,
    required this.sort,
  });

  final Map<String, dynamic> promoFilters;
  final String sort;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // Fingerprint promoted ids only — main-feed loadMore must not rebuild this.
    final fingerprint = context.select<ProductProvider, int>((p) {
      final promo = p
          .getProducts(promoFilters, sort: sort)
          .where((e) => e.isPromotionActive)
          .map((e) => e.id);
      if (promo.isNotEmpty) return Object.hashAll(promo);
      return Object.hashAll(
        p
            .getProducts({}, sort: sort)
            .where((e) => e.isPromotionActive)
            .map((e) => e.id),
      );
    });
    final products = context.read<ProductProvider>();
    final dedicated = products
        .getProducts(promoFilters, sort: sort)
        .where((p) => p.isPromotionActive)
        .toList(growable: false);
    final topList = dedicated.isNotEmpty
        ? dedicated
        : products
            .getProducts({}, sort: sort)
            .where((p) => p.isPromotionActive)
            .toList(growable: false);
    final promoLoading = products.isLoadingFor(promoFilters, sort: sort) &&
        products.getProducts(promoFilters, sort: sort).isEmpty;

    if (!promoLoading && topList.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      key: ValueKey(fingerprint),
      slivers: [
        const SliverToBoxAdapter(child: _BlockGap()),
        SliverToBoxAdapter(
          child: _WhiteBlock(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MarketHeader(
                  title: s.featured,
                  onSeeAll: () => context.push(
                    RoutesName.search,
                    extra: const {'isAllProduct': true},
                  ),
                ),
                if (promoLoading)
                  const _StripLoading()
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FeaturedCarousel(items: topList),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeOrdersSection extends StatelessWidget {
  const _HomeOrdersSection({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final ordersHub = context.watch<OrdersProvider>();
    final orderList = ordersHub.ordersFor({}).take(12).toList();
    final ordersLoading = ordersHub.isLoadingFor({}) && orderList.isEmpty;

    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(child: _BlockGap()),
        SliverToBoxAdapter(
          child: _WhiteBlock(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MarketHeader(
                  title: s.orders,
                  onSeeAll: onSeeAll,
                ),
                if (ordersLoading)
                  const _StripLoading()
                else if (orderList.isEmpty)
                  _StripEmpty(
                    icon: LucideIcons.clipboardList,
                    message: s.wantToBuyEmptyTitle,
                    colors: colors,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HorizontalOrdersStrip(orders: orderList),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Products + services strip — the only slice that rebuilds on load-more.
class _HomeFeedBody extends StatelessWidget {
  const _HomeFeedBody({
    required this.sort,
    required this.promoFilters,
    required this.workshopFilters,
    required this.productsBeforeServices,
    required this.adRefreshToken,
  });

  final String sort;
  // Kept for API symmetry with other home sections (promo bucket unused here).
  final Map<String, dynamic> promoFilters;
  final Map<String, dynamic> workshopFilters;
  final int productsBeforeServices;
  final int adRefreshToken;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final products = context.watch<ProductProvider>();
    final workshops = context.watch<GetWorkshop>();

    final list = products.getProducts({}, sort: sort);
    final productsLoading =
        products.isLoadingFor({}, sort: sort) && list.isEmpty;
    final head = list.take(productsBeforeServices).toList();
    final tail = list.length > productsBeforeServices
        ? list.sublist(productsBeforeServices)
        : const <Part>[];

    final workshopList =
        workshops.getWorkshops(workshopFilters, null).take(12).toList();
    final workshopsLoading =
        workshops.isLoadingFor(workshopFilters, null) && workshopList.isEmpty;

    return _MultiSliver(
      children: [
        const SliverToBoxAdapter(child: _BlockGap()),
        SliverToBoxAdapter(
          child: _WhiteBlock(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MarketHeader(
                  title: s.allProducts,
                  onSeeAll: () => context.push(
                    RoutesName.search,
                    extra: const {'isAllProduct': true},
                  ),
                ),
                if (productsLoading)
                  const ProductGridSkeleton(
                    count: 4,
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
                  )
                else if (list.isEmpty)
                  _StripEmpty(
                    icon: LucideIcons.package,
                    message: s.noProducts,
                    colors: colors,
                  ),
              ],
            ),
          ),
        ),
        if (!productsLoading && head.isNotEmpty)
          DecoratedSliver(
            decoration: BoxDecoration(color: colors.surface),
            sliver: ProductSliverGrid(
              products: head,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            ),
          ),
        if (workshopsLoading || workshopList.isNotEmpty) ...[
          const SliverToBoxAdapter(child: _BlockGap()),
          SliverToBoxAdapter(
            child: AdBanner(
              surface: AdSurface.service,
              height: 120,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              refreshToken: adRefreshToken,
            ),
          ),
          SliverToBoxAdapter(
            child: _WhiteBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MarketHeader(
                    title: s.services,
                    onSeeAll: () => context.push(RoutesName.servicesHub),
                  ),
                  if (workshopsLoading)
                    const _StripLoading()
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HorizontalWorkshopStrip(workshops: workshopList),
                    ),
                ],
              ),
            ),
          ),
        ],
        if (tail.isNotEmpty) ...[
          const SliverToBoxAdapter(child: _BlockGap()),
          DecoratedSliver(
            decoration: BoxDecoration(color: colors.surface),
            sliver: ProductSliverGrid(
              products: tail,
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            ),
          ),
        ],
        if (products.isMoreLoadingFor({}, sort: sort))
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tiny helper so we can return a flat list of slivers from one widget.
class _MultiSliver extends StatelessWidget {
  const _MultiSliver({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: children);
  }
}

class _BlockGap extends StatelessWidget {
  const _BlockGap();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: ColoredBox(color: context.appColors.background),
    );
  }
}

class _WhiteBlock extends StatelessWidget {
  const _WhiteBlock({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.appColors.surface,
      child: child,
    );
  }
}

/// Plain marketplace header — title + Hammasi › (no icons / stripes).
class _MarketHeader extends StatelessWidget {
  const _MarketHeader({
    required this.title,
    this.onSeeAll,
  });

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                height: 1.15,
                color: colors.textPrimary,
              ),
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.seeAll,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StripLoading extends StatelessWidget {
  const _StripLoading();

  @override
  Widget build(BuildContext context) {
    return const HomeStripSkeleton();
  }
}

class _StripEmpty extends StatelessWidget {
  const _StripEmpty({
    required this.message,
    required this.colors,
    this.icon,
  });

  final String message;
  final AppColors colors;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 28, color: colors.textMuted),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalWorkshopStrip extends StatelessWidget {
  const _HorizontalWorkshopStrip({required this.workshops});

  final List<Workshop> workshops;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = (width * 0.70).clamp(230.0, 280.0);

    return SizedBox(
      height: 188,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: workshops.length,
        addAutomaticKeepAlives: false,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: RepaintBoundary(
              child: WorkshopCard(workshop: workshops[index]),
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalOrdersStrip extends StatelessWidget {
  const _HorizontalOrdersStrip({required this.orders});

  final List<OrderItem> orders;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = (width * 0.68).clamp(220.0, 270.0);

    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: orders.length,
        addAutomaticKeepAlives: false,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: RepaintBoundary(
              child: OrderCard(order: orders[index], compact: true),
            ),
          );
        },
      ),
    );
  }
}
