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
import 'package:my_auto/core/theme/colors/index.dart';
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
    if (pos.pixels < pos.maxScrollExtent - 200) return;
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
    await Future.wait([
      context.read<ProductProvider>().loadList(
            filters: _promoFilters,
            reset: true,
            sort: _sort,
          ),
      context
          .read<ProductProvider>()
          .loadList(filters: {}, reset: true, sort: _sort),
      context.read<GetCategories>().loadCategories(type.PART.name),
      context.read<GetWorkshop>().loadList(
            filters: _workshopFilters,
            reset: true,
          ),
      context.read<OrdersProvider>().loadList(filters: {}, reset: true),
    ]);
  }

  List<Part> _topProducts(ProductProvider products) {
    final dedicated = products
        .getProducts(_promoFilters, sort: _sort)
        .where((p) => p.isPromotionActive)
        .toList(growable: false);
    if (dedicated.isNotEmpty) return dedicated;
    return products
        .getProducts({}, sort: _sort)
        .where((p) => p.isPromotionActive)
        .toList(growable: false);
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
    final s = S.of(context);
    final categories = context.watch<GetCategories>();
    final products = context.watch<ProductProvider>();
    final workshops = context.watch<GetWorkshop>();
    final ordersHub = context.watch<OrdersProvider>();

    final list = products.getProducts({}, sort: _sort);
    final topList = _topProducts(products);
    final workshopList =
        workshops.getWorkshops(_workshopFilters, null).take(12).toList();
    final orderList = ordersHub.ordersFor({}).take(12).toList();

    final promoBucketEmpty =
        products.getProducts(_promoFilters, sort: _sort).isEmpty;
    final promoLoading =
        products.isLoadingFor(_promoFilters, sort: _sort) && promoBucketEmpty;
    final productsLoading =
        products.isLoadingFor({}, sort: _sort) && list.isEmpty;
    final workshopsLoading =
        workshops.isLoadingFor(_workshopFilters, null) && workshopList.isEmpty;
    final ordersLoading = ordersHub.isLoadingFor({}) && orderList.isEmpty;

    final head = list.take(_productsBeforeServices).toList();
    final tail = list.length > _productsBeforeServices
        ? list.sublist(_productsBeforeServices)
        : const <Part>[];

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
              // Kategoriya
              SliverToBoxAdapter(
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
                        child: GridCategories(
                          listCategory: categories.categories,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tavsiya / hits
              if (promoLoading || topList.isNotEmpty) ...[
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

              // Buyurtmalar
              const SliverToBoxAdapter(child: _BlockGap()),
              SliverToBoxAdapter(
                child: _WhiteBlock(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MarketHeader(
                        title: s.orders,
                        onSeeAll: _openOrdersTab,
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

              // Barcha mahsulotlar
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
                        const _StripLoading()
                      else if (list.isEmpty)
                        _StripEmpty(
                          icon: LucideIcons.package,
                          message: s.noProducts,
                          colors: colors,
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ProductGrid(
                            products: head,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Avtoservis
              if (workshopsLoading || workshopList.isNotEmpty) ...[
                const SliverToBoxAdapter(child: _BlockGap()),
                SliverToBoxAdapter(
                  child: _WhiteBlock(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _MarketHeader(
                          title: s.services,
                          onSeeAll: () =>
                              context.push(RoutesName.servicesHub),
                        ),
                        if (workshopsLoading)
                          const _StripLoading()
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HorizontalWorkshopStrip(
                              workshops: workshopList,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              if (tail.isNotEmpty) ...[
                const SliverToBoxAdapter(child: _BlockGap()),
                SliverToBoxAdapter(
                  child: _WhiteBlock(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: ProductGrid(
                        products: tail,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                    ),
                  ),
                ),
              ],

              if (products.isMoreLoadingFor({}, sort: _sort))
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
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
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.seeAll,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: colors.primary,
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
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
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: WorkshopCard(workshop: workshops[index]),
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
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: OrderCard(order: orders[index], compact: true),
          );
        },
      ),
    );
  }
}
