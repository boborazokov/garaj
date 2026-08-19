import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_auto/core/model/categoryCar/index.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';
import 'package:my_auto/features/home/widgets/productList/index.dart';
import 'package:my_auto/core/utils/category_locale.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/searchInput/index.dart';
import 'package:provider/provider.dart';

class ListOfItems extends StatefulWidget {
  final CategoryCar category;
  const ListOfItems({super.key, required this.category});

  @override
  State<ListOfItems> createState() => _ListOfItemsState();
}

class _ListOfItemsState extends State<ListOfItems> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  ProductProvider? _productProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider ??= context.read<ProductProvider>();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      _productProvider ??= context.read<ProductProvider>();
      _productProvider!.searchController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = _productProvider ?? context.read<ProductProvider>();
      p.loadList(
        filters: {"category": widget.category.id},
        reset: true,
        search: p.searchController.text,
      );
    });

    _scrollController.addListener(() {
      final provider = _productProvider ?? context.read<ProductProvider>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !provider.isMoreLoadingFor({"category": widget.category.id}) &&
          provider.hasMoreFor({"category": widget.category.id})) {
        provider.loadMore(filters: {"category": widget.category.id});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = _productProvider ?? context.read<ProductProvider>();
      p.searchController.addListener(_onSearchChanged);
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (!mounted) return;
    final p = _productProvider;
    if (p == null) return;
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      p.loadList(
        filters: {"category": widget.category.id},
        reset: true,
        search: p.searchController.text,
      );
    });
  }

  @override
  void dispose() {
    _productProvider?.searchController.removeListener(_onSearchChanged);
    _productProvider?.searchController.clear();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    final products = provider.getProducts({"category": widget.category.id});
    final isLoading = provider.isLoadingFor({"category": widget.category.id});
    final isMoreLoading =
        provider.isMoreLoadingFor({"category": widget.category.id});

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.localizedName(categoryLanguageCode(context))),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: CustomSearchInput(
                  controller: provider.searchController,
                  hintText: S.of(context).search,
                )),
            const AdBanner(
              surface: AdSurface.part,
              height: 120,
              margin: EdgeInsets.only(bottom: 8),
            ),
            Expanded(
              child: isLoading && products.isEmpty
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : products.isEmpty
                      ? Center(child: Text(S.of(context).noProducts))
                      : ProductGrid(
                          controller: _scrollController,
                          products: products,
                          physics: const AlwaysScrollableScrollPhysics(),
                          inlineAdSurface: AdSurface.part,
                        ),
            ),
            if (isMoreLoading)
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
