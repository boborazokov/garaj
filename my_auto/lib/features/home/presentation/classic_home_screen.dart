import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/provider/add/getCotegories.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';
import 'package:my_auto/features/home/widgets/gridCotegory/index.dart';
import 'package:my_auto/features/home/widgets/home_top_bar.dart';
import 'package:my_auto/features/home/widgets/productList/index.dart';
import 'package:my_auto/features/home/widgets/sectionHeader/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

/// Classic marketplace home (search, promo, categories, product grid).
class ClassicHomeScreen extends StatefulWidget {
  const ClassicHomeScreen({super.key});

  @override
  State<ClassicHomeScreen> createState() => _ClassicHomeScreenState();
}

class _ClassicHomeScreenState extends State<ClassicHomeScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    Future.microtask(() {
      if (!mounted) return;
      context.read<GetCategories>().loadCategories(type.PART.name);
      context.read<ProductProvider>().loadList(filters: {}, reset: true);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 200) return;
    final hub = context.read<ProductProvider>();
    if (!hub.isMoreLoadingFor({}) &&
        hub.hasMoreFor({}) &&
        !hub.isLoadingFor({})) {
      hub.loadMore(filters: {});
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final categories = context.watch<GetCategories>();
    final products = context.watch<ProductProvider>();
    final list = products.getProducts({});

    return Scaffold(
      backgroundColor: colors.background,
      body: AppSafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () async {
            await products.loadList(filters: {}, reset: true);
            await categories.loadCategories(type.PART.name);
          },
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: listPaddingAboveBottomNav(context),
            ),
            children: [
              const HomeTopBar(),
              const SizedBox(height: 16),
              const AdBanner(
                surface: AdSurface.brand,
                height: 160,
                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridCategories(
                  listCategory: categories.categories,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(
                  title: s.topDeals,
                  onSeeAll: () => context.push(
                    RoutesName.search,
                    extra: const {'isAllProduct': true},
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (products.isLoadingFor({}) && list.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                )
              else if (list.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Text(
                    s.noProducts,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textMuted),
                  ),
                )
              else
                ProductGrid(products: list),
              if (products.isMoreLoadingFor({}))
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(
                  title: s.service,
                  onSeeAll: () => context.push(
                    RoutesName.search,
                    extra: const {'isAllProduct': true},
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(
                  title: s.announcements,
                  onSeeAll: () => context.push(
                    RoutesName.search,
                    extra: const {'isAllProduct': true},
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
