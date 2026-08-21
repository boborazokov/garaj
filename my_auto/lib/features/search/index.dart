import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';
import 'package:my_auto/features/home/widgets/productList/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/app_bar.dart';
import 'package:my_auto/widgets/searchInput/index.dart';
import 'package:provider/provider.dart';

enum _ConditionFilter { any, isNew, used }

/// Catalog search with the "Didn't find what you need? → Create request"
/// CTA that turns empty / sparse results into actionable buy-requests.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.categoryId, required this.isAll});

  final String? categoryId;
  final bool isAll;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  _ConditionFilter _condition = _ConditionFilter.any;
  bool? _negotiable;
  ProductProvider? _productProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider ??= context.read<ProductProvider>();
  }

  /// Below this count we surface the small inline "Create request" tip
  /// even though there *are* some results.
  static const int _sparseThreshold = 3;

  Map<String, dynamic> _buildFilters() {
    final filters = <String, dynamic>{};
    if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
      filters['category'] = widget.categoryId;
    }
    switch (_condition) {
      case _ConditionFilter.isNew:
        filters['isNew'] = true;
        break;
      case _ConditionFilter.used:
        filters['isNew'] = false;
        break;
      case _ConditionFilter.any:
        break;
    }
    if (_negotiable == true) {
      filters['isNegotiable'] = true;
    }
    return filters;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final p = _productProvider ?? context.read<ProductProvider>();
      p.searchController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = _productProvider ?? context.read<ProductProvider>();
      p.loadList(
        filters: _buildFilters(),
        reset: true,
        search: p.searchController.text,
      );
      p.searchController.addListener(_onSearchChanged);
    });

    _scrollController.addListener(() {
      final provider = _productProvider;
      if (provider == null) return;
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !provider.isMoreLoadingFor(_buildFilters()) &&
          provider.hasMoreFor(_buildFilters())) {
        provider.loadMore(
          filters: _buildFilters(),
          search: provider.searchController.text,
        );
      }
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
        filters: _buildFilters(),
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

  void _refresh() {
    final provider = context.read<ProductProvider>();
    provider.loadList(
      filters: _buildFilters(),
      reset: true,
      search: provider.searchController.text,
    );
  }

  void _openCreateRequest() {
    final query = context.read<ProductProvider>().searchController.text.trim();
    context.push(RoutesName.createOrder, extra: query.isEmpty ? null : query);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final provider = context.watch<ProductProvider>();
    final filters = _buildFilters();
    final products = provider.getProducts(filters);
    final isLoading = provider.isLoadingFor(filters);
    final isMoreLoading = provider.isMoreLoadingFor(filters);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final hasQuery = provider.searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: canPop
          ? AppTopBar(
              title: widget.isAll ? s.allProducts : s.search,
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: CustomSearchInput(
                      controller: provider.searchController,
                      hintText: s.search,
                      autoFocus: false,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    icon: LucideIcons.sparkles,
                    label: s.newPart,
                    isActive: _condition == _ConditionFilter.isNew,
                    onTap: () {
                      setState(() {
                        _condition = _condition == _ConditionFilter.isNew
                            ? _ConditionFilter.any
                            : _ConditionFilter.isNew;
                      });
                      _refresh();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    icon: LucideIcons.recycle,
                    label: s.used,
                    isActive: _condition == _ConditionFilter.used,
                    onTap: () {
                      setState(() {
                        _condition = _condition == _ConditionFilter.used
                            ? _ConditionFilter.any
                            : _ConditionFilter.used;
                      });
                      _refresh();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    icon: LucideIcons.percent,
                    label: s.negotiable,
                    isActive: _negotiable == true,
                    onTap: () {
                      setState(() {
                        _negotiable = _negotiable == true ? null : true;
                      });
                      _refresh();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading && products.isEmpty
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : products.isEmpty
                      ? _EmptyWithCTA(
                          query: provider.searchController.text,
                          onCreate: _openCreateRequest,
                        )
                      : RefreshIndicator(
                          color: colors.primary,
                          onRefresh: () async => _refresh(),
                          child: ListView(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const AdBanner(
                                surface: AdSurface.part,
                                height: 120,
                                margin: EdgeInsets.fromLTRB(8, 0, 8, 12),
                              ),
                              ProductGrid(
                                products: products,
                                inlineAdSurface: AdSurface.part,
                              ),
                              if (hasQuery && products.length <= _sparseThreshold)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8, 12, 8, 8),
                                  child: _InlineRequestCta(
                                    onTap: _openCreateRequest,
                                  ),
                                ),
                              if (isMoreLoading)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                      child: CircularProgressIndicator
                                          .adaptive()),
                                ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: isActive ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? colors.primary : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14,
                  color: isActive ? colors.onPrimary : colors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? colors.onPrimary : colors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big, friendly empty state shown when the catalog has zero results.
/// Doubles as the entry point to the "create request" flow — this is the
/// single most important UX moment of the app.
class _EmptyWithCTA extends StatelessWidget {
  final String query;
  final VoidCallback onCreate;

  const _EmptyWithCTA({required this.query, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.rXl,
            ),
            child: Icon(LucideIcons.searchX, size: 40, color: colors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            s.noProducts,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            s.tryAnotherSearch,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primaryHover],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.rL,
              boxShadow: AppShadows.glow(colors.primary),
            ),
            child: Column(
              children: [
                Icon(LucideIcons.megaphone,
                    color: colors.onPrimary, size: 32),
                const SizedBox(height: 12),
                Text(
                  s.didntFindWhatYouNeed,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.createRequestSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimary.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.onPrimary,
                      foregroundColor: colors.primary,
                    ),
                    onPressed: onCreate,
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: Text(
                      s.createRequest,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Slim banner shown at the bottom of a sparse result list to nudge the
/// user into creating a buy-request.
class _InlineRequestCta extends StatelessWidget {
  final VoidCallback onTap;
  const _InlineRequestCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Material(
      color: colors.surfaceMuted,
      borderRadius: AppRadius.rL,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rL,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.15),
                  borderRadius: AppRadius.rM,
                ),
                child: Icon(LucideIcons.megaphone,
                    color: colors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.didntFindWhatYouNeed,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.createRequestSubtitle,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight,
                  size: 18, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
