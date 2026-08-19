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

  Future<void> loadList({
    Map<String, dynamic>? filters,
    bool reset = true,
    String? search,
    String? viewerRegion,
    String sort = 'RECOMMENDED',
  }) async {
    final key = _key(filters, sort: sort, search: search);

    if (_isLoadingMap[key] == true) return;

    if (reset) {
      _currentPageMap[key] = 1;
      _hasMoreMap[key] = true;
      _productsMap[key] = [];
    }

    _isLoadingMap[key] = true;
    notifyListeners();

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
        final newProducts = partsData
            .map((e) => Part.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((p) =>
                !(_productsMap[key]?.any((existing) => existing.id == p.id) ??
                    false))
            .toList();

        _productsMap[key] = [...?_productsMap[key], ...newProducts];
        onProductsLoaded?.call(newProducts);

        _currentPageMap[key] = page + 1;
        if (_currentPageMap[key]! > (totalPages ?? 1)) {
          _hasMoreMap[key] = false;
        }
      } else {
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
    notifyListeners();

    await loadList(
      filters: filters,
      reset: false,
      search: search,
      viewerRegion: viewerRegion,
      sort: sort,
    );

    _isMoreLoadingMap[key] = false;
    notifyListeners();
  }

  void removeProductById(String id) {
    for (var key in _productsMap.keys) {
      _productsMap[key]!.removeWhere((p) => p.id == id);
    }

    notifyListeners();
  }
}
