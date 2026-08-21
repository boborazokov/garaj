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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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
    final list = fromApi.isNotEmpty
        ? fromApi.where((p) => fav.isFavorite(p.id)).toList()
        : fav.cachedFavoriteParts;
    final loading = hub.isLoadingFor(_filters);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(title: s.favorites),
      body: AppSafeArea(
        top: false,
        bottom: true,
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: _load,
          child: loading && list.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : list.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.35,
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
                                style: TextStyle(color: colors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ProductGrid(products: list),
        ),
      ),
    );
  }
}
