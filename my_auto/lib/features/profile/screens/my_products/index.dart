import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/features/home/widgets/productList/index.dart';
import 'package:my_auto/features/profile/widgets/my_listings_scaffold.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  final _scrollControllerActive = ScrollController();
  final _scrollControllerInactive = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<ProductProvider>();
      provider.searchController.clear();
      _load(reset: true);

      _scrollControllerActive.addListener(_onScrollActive);
      _scrollControllerInactive.addListener(_onScrollInactive);

      provider.searchController.addListener(() {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 350), () {
          _load(reset: true);
        });
      });
    });
  }

  Map<String, dynamic> get _filters => {
        'seller': context.read<AuthProvider>().auth!.user.id,
      };

  void _load({required bool reset}) {
    context.read<ProductProvider>().loadList(
          filters: _filters,
          reset: reset,
          search: context.read<ProductProvider>().searchController.text.trim(),
        );
  }

  void _onScrollActive() {
    final provider = context.read<ProductProvider>();
    if (_scrollControllerActive.position.pixels >=
            _scrollControllerActive.position.maxScrollExtent - 100 &&
        !provider.isMoreLoadingFor(_filters) &&
        provider.hasMoreFor(_filters)) {
      provider.loadMore(filters: _filters);
    }
  }

  void _onScrollInactive() {
    final provider = context.read<ProductProvider>();
    if (_scrollControllerInactive.position.pixels >=
            _scrollControllerInactive.position.maxScrollExtent - 100 &&
        !provider.isMoreLoadingFor(_filters) &&
        provider.hasMoreFor(_filters)) {
      provider.loadMore(filters: _filters);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollControllerActive.dispose();
    _scrollControllerInactive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final s = S.of(context);
    final myProducts = provider.getProducts(_filters);
    final isLoading = provider.isLoadingFor(_filters) && myProducts.isEmpty;

    final activeProducts =
        myProducts.where((p) => p.status == ItemStatusEnum.active).toList();
    final inactiveProducts =
        myProducts.where((p) => p.status == ItemStatusEnum.archived).toList();

    return MyListingsScaffold(
      title: s.myProducts,
      activeCount: activeProducts.length,
      inactiveCount: inactiveProducts.length,
      searchController: provider.searchController,
      onSearch: (_) {},
      isLoading: isLoading,
      onRefresh: () async => _load(reset: true),
      activeBody: activeProducts.isEmpty
          ? MyListingsEmptyState(
              message: s.myListingsEmptyActive,
              icon: LucideIcons.package,
            )
          : ProductGrid(
              controller: _scrollControllerActive,
              products: activeProducts,
              isMine: true,
            ),
      inactiveBody: inactiveProducts.isEmpty
          ? MyListingsEmptyState(
              message: s.myListingsEmptyInactive,
              icon: LucideIcons.archive,
            )
          : ProductGrid(
              controller: _scrollControllerInactive,
              products: inactiveProducts,
              isMine: true,
              isDepleted: true,
            ),
    );
  }
}
