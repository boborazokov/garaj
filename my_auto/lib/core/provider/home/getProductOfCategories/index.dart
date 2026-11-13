import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/home/api/index.dart';

class ProductProvider extends ChangeNotifier {
  /// Called after each successful page fetch (feed, search, favorites).
  void Function(List<Part>)? onProductsLoaded;

  final int limit = 10;
  final TextEditingController searchController = TextEditingController();

  final Map<String, List<Part>> _productsMap = {};
  final Map<String, int> _currentPageMap = {};
  final Map<String, bool> _hasMoreMap = {};
  final Map<String, bool> _isLoadingMap = {};
  final Map<String, bool> _isMoreLoadingMap = {};

  String _key(
    Map<String, dynamic>? filters, {
    String sort = 'RECOMMENDED',
    String? search,
  }) {
    final filterPart = (filters == null || filters.isEmpty)
        ? 'all'
        : filters.entries.map((e) => '${e.key}:${e.value}').join('|');
    final q = (search ?? '').trim();
    return '$filterPart|sort:$sort|q:$q';
  }

  List<Part> getProducts(
    Map<String, dynamic>? filters, {
    String sort = 'RECOMMENDED',
    String? search,
  }) {
    return _productsMap[_key(filters, sort: sort, search: search)] ?? [];
  }

  /// Returns just the promoted-and-currently-active subset for the bucket.
  /// Used to render the "Featured" section at the top of feeds.
  List<Part> promotedFor(Map<String, dynamic>? filters) {
    final now = DateTime.now();
    return getProducts(filters)
        .where((p) =>
            p.isPromoted &&
            (p.promotedUntil == null || p.promotedUntil!.isAfter(now)))
        .toList();
  }

  bool isLoadingFor(
    Map<String, dynamic>? filters, {
    String sort = 'RECOMMENDED',
    String? search,
  }) {
    return _isLoadingMap[_key(filters, sort: sort, search: search)] ?? false;
  }

  bool isMoreLoadingFor(
    Map<String, dynamic>? filters, {
    String sort = 'RECOMMENDED',
    String? search,
  }) {
    return _isMoreLoadingMap[_key(filters, sort: sort, search: search)] ??
        false;
  }

  bool hasMoreFor(
    Map<String, dynamic>? filters, {
    String sort = 'RECOMMENDED',
    String? search,
  }) {
    return _hasMoreMap[_key(filters, sort: sort, search: search)] ?? true;
  }

  /// Loads a page of products.
  ///
  /// When [reset] is true and [keepPrevious] is true (default), existing items
  /// stay on screen until the new page arrives — avoids pull-to-refresh freezes
  /// from wiping the tree into skeletons then rebuilding everything.
  Future<void> loadList({
    Map<String, dynamic>? filters,
    bool reset = true,
    bool keepPrevious = true,
    /// Skip the "loading started" notify (used by [loadMore] to avoid
    /// rebuilding the whole feed mid-fling).
    bool quiet = false,
    String? search,
    String? viewerRegion,
    String sort = 'RECOMMENDED',
  }) async {
    final key = _key(filters, sort: sort, search: search);

    if (_isLoadingMap[key] == true) return;

    final soft =
        reset && keepPrevious && (_productsMap[key]?.isNotEmpty ?? false);

    if (reset) {
      _currentPageMap[key] = 1;
      _hasMoreMap[key] = true;
      if (!soft) {
        _productsMap[key] = [];
      }
    }

    _isLoadingMap[key] = true;
    // Soft refresh / quiet pagination: skip a mid-scroll full-tree rebuild.
    if (!soft && !quiet) {
      notifyListeners();
    }

    try {
      final page = _currentPageMap[key] ?? 1;

      final QueryOptions options = QueryOptions(
        document: gql(GET_ITEMS_BY_CATEGORY),
        variables: {
          'pagination': {'page': page, 'limit': limit},
          'filter': filters ?? const {},
          'search': search,
          'sort': sort,
          if (viewerRegion != null && viewerRegion.isNotEmpty)
            'viewerRegion': viewerRegion,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await GraphQLConfig.client().query(options);

      if (result.hasException) {
        if (kDebugMode) {
          debugPrint('[ProductProvider] getParts error: ${result.exception}');
        }
        return;
      }

      final partsData = result.data?['getParts']?['payload'];
      final totalPages = result.data?['getParts']?['totalPages'];

      if (partsData is List && partsData.isNotEmpty) {
        final parsed = partsData
            .map((e) => Part.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(growable: false);

        if (reset) {
          _productsMap[key] = parsed;
          onProductsLoaded?.call(parsed);
        } else {
          final existingIds = <String>{
            for (final p in _productsMap[key] ?? const <Part>[]) p.id,
          };
          final newProducts =
              parsed.where((p) => !existingIds.contains(p.id)).toList();
          _productsMap[key] = [...?_productsMap[key], ...newProducts];
          onProductsLoaded?.call(newProducts);
        }

        _currentPageMap[key] = page + 1;
        if (_currentPageMap[key]! > (totalPages ?? 1)) {
          _hasMoreMap[key] = false;
        }
      } else {
        if (reset) {
          _productsMap[key] = [];
        }
        _hasMoreMap[key] = false;
      }
    } finally {
      _isLoadingMap[key] = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({
    Map<String, dynamic>? filters,
    String? search,
    String? viewerRegion,
    String sort = 'RECOMMENDED',
  }) async {
    final key = _key(filters, sort: sort, search: search);

    if (_isMoreLoadingMap[key] == true || _hasMoreMap[key] == false) return;

    _isMoreLoadingMap[key] = true;
    // One notify for the footer spinner — avoid a second notify from loadList.
    notifyListeners();

    try {
      await loadList(
        filters: filters,
        reset: false,
        keepPrevious: true,
        quiet: true,
        search: search,
        viewerRegion: viewerRegion,
        sort: sort,
      );
    } finally {
      _isMoreLoadingMap[key] = false;
      notifyListeners();
    }
  }

  void removeProductById(String id) {
    for (var key in _productsMap.keys) {
      _productsMap[key]!.removeWhere((p) => p.id == id);
    }

    notifyListeners();
  }
}
