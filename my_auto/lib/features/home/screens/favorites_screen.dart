import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/core/provider/home/setFavorite/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/widgets/productList/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/app_bar.dart';
import 'package:provider/provider.dart';

/// Saved / liked parts for the signed-in user.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const _filters = {'onlyFavorites': true};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;

    await context.read<SetFavoriteProvider>().loadFavoritesFromServer();
    if (!mounted) return;

    await context.read<ProductProvider>().loadList(
          filters: _filters,
          reset: true,
        );
    if (!mounted) return;
    context.read<SetFavoriteProvider>().applyFromParts(
          context.read<ProductProvider>().getProducts(_filters),
        );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final hub = context.read<ProductProvider>();
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    if (hub.isMoreLoadingFor(_filters) ||
        hub.isLoadingFor(_filters) ||
        !hub.hasMoreFor(_filters)) {
      return;
    }
    hub.loadMore(filters: _filters).then((_) {
      if (!mounted) return;
      context.read<SetFavoriteProvider>().applyFromParts(
            hub.getProducts(_filters),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final auth = context.watch<AuthProvider>();

    if (auth.isGuest) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppTopBar(title: s.favorites),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              s.signInToContinueHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
        ),
      );
    }

    final hub = context.watch<ProductProvider>();
    final fav = context.watch<SetFavoriteProvider>();
    final fromApi = hub.getProducts(_filters);
    // Prefer API pages (paginated). Keep locally unfavorited items out of the
    // grid; still accept server `isFavorite` so pages beyond the ID prefetch
    // are not stripped.
    final list = fromApi.isNotEmpty
        ? fromApi
            .where((p) => p.isFavorite || fav.isFavorite(p.id))
            .toList()
        : fav.cachedFavoriteParts;
    final loading = hub.isLoadingFor(_filters);
    final loadingMore = hub.isMoreLoadingFor(_filters);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(title: s.favorites),
      body: AppSafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: colors.primary,
                onRefresh: _load,
                child: loading && list.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 240,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ],
                      )
                    : list.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.35,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.heart,
                                      size: 48,
                                      color: colors.textMuted,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      s.favoritesEmpty,
                                      style:
                                          TextStyle(color: colors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ProductGrid(
                            controller: _scrollController,
                            products: list,
                            physics: const AlwaysScrollableScrollPhysics(),
                          ),
              ),
            ),
            if (loadingMore)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator.adaptive(),
              ),
          ],
        ),
      ),
    );
  }
}
