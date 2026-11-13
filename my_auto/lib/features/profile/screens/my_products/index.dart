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
  final _scrollController = ScrollController();
  Timer? _debounce;
  MyListingsStatusFilter _status = MyListingsStatusFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<ProductProvider>();
      provider.searchController.clear();
      _load(reset: true);

      _scrollController.addListener(_onScroll);

      provider.searchController.addListener(() {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 280), () {
          if (!mounted) return;
          setState(() {});
          _load(reset: true);
        });
      });
    });
  }

  Map<String, dynamic> get _filters => {
        'seller': context.read<AuthProvider>().auth!.user.id,
      };

  String get _query =>
      context.read<ProductProvider>().searchController.text.trim();

  Future<void> _load({required bool reset}) {
    return context.read<ProductProvider>().loadList(
          filters: _filters,
          reset: reset,
          keepPrevious: true,
          search: _query,
          sort: 'NEWEST',
        );
  }

  void _onScroll() {
    final provider = context.read<ProductProvider>();
    final query = _query;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !provider.isMoreLoadingFor(_filters, search: query, sort: 'NEWEST') &&
        provider.hasMoreFor(_filters, search: query, sort: 'NEWEST')) {
      provider.loadMore(filters: _filters, search: query, sort: 'NEWEST');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  List<Part> _applyStatus(List<Part> products) {
    switch (_status) {
      case MyListingsStatusFilter.all:
        return products;
      case MyListingsStatusFilter.active:
        return products
            .where((p) => p.status.countsAsActiveListing)
            .toList();
      case MyListingsStatusFilter.inactive:
        return products.where((p) => p.status.isInactive).toList();
    }
  }

  String _emptyMessage(S s, String query) {
    if (query.isNotEmpty) return s.searchHubNoGroupedHits;
    switch (_status) {
      case MyListingsStatusFilter.all:
        return s.myListingsEmptyActive;
      case MyListingsStatusFilter.active:
        return s.myListingsEmptyActive;
      case MyListingsStatusFilter.inactive:
        return s.myListingsEmptyInactive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final s = S.of(context);
    final query = provider.searchController.text.trim();
    final myProducts =
        provider.getProducts(_filters, search: query, sort: 'NEWEST');
    final isLoading = provider.isLoadingFor(
          _filters,
          search: query,
          sort: 'NEWEST',
        ) &&
        myProducts.isEmpty;

    final activeCount =
        myProducts.where((p) => p.status.countsAsActiveListing).length;
    final inactiveCount =
        myProducts.where((p) => p.status.isInactive).length;
    final visible = _applyStatus(myProducts);

    return MyListingsScaffold(
      title: s.myProducts,
      activeCount: activeCount,
      inactiveCount: inactiveCount,
      searchController: provider.searchController,
      searchHint: s.searchSellerProducts,
      onSearch: (_) {},
      showSummary: false,
      isLoading: isLoading,
      onRefresh: () => _load(reset: true),
      belowSearch: MyListingsStatusFilters(
        selected: _status,
        allCount: myProducts.length,
        activeCount: activeCount,
        inactiveCount: inactiveCount,
        onSelected: (value) => setState(() => _status = value),
      ),
      body: visible.isEmpty
          ? MyListingsEmptyState(
              message: _emptyMessage(s, query),
              icon: query.isNotEmpty
                  ? LucideIcons.searchX
                  : LucideIcons.package,
            )
          : ProductGrid(
              controller: _scrollController,
              products: visible,
              isMine: true,
            ),
    );
  }
}
