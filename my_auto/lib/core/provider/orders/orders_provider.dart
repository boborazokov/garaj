import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/model/order/index.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/orders/api/index.dart';

/// Multi-bucket provider for the announcements (Orders) feed.
///
/// Buckets are keyed by serialized filters/search so the home feed,
/// "my orders", and search-filtered views can coexist in one provider —
/// the same pattern `ProductProvider` uses.
class OrdersProvider extends ChangeNotifier {
  static const int _limit = 10;

  final TextEditingController searchController = TextEditingController();

  final Map<String, List<OrderItem>> _ordersMap = {};
  final Map<String, int> _pageMap = {};
  final Map<String, bool> _hasMoreMap = {};
  final Map<String, bool> _loadingMap = {};
  final Map<String, bool> _moreLoadingMap = {};

  bool isCreating = false;

  String _key(Map<String, dynamic>? filters, String? search) {
    final f = filters ?? const {};
    final filterPart =
        f.entries.map((e) => '${e.key}:${e.value}').join('|');
    return '$filterPart::${search ?? ''}';
  }

  List<OrderItem> ordersFor(Map<String, dynamic>? filters, {String? search}) =>
      _ordersMap[_key(filters, search)] ?? const [];

  bool isLoadingFor(Map<String, dynamic>? filters, {String? search}) =>
      _loadingMap[_key(filters, search)] ?? false;

  bool isMoreLoadingFor(Map<String, dynamic>? filters, {String? search}) =>
      _moreLoadingMap[_key(filters, search)] ?? false;

  bool hasMoreFor(Map<String, dynamic>? filters, {String? search}) =>
      _hasMoreMap[_key(filters, search)] ?? true;

  Future<void> loadList({
    Map<String, dynamic>? filters,
    String? search,
    String? viewerRegion,
    bool reset = true,
  }) async {
    final key = _key(filters, search);
    if (_loadingMap[key] == true) return;

    if (reset) {
      _pageMap[key] = 1;
      _hasMoreMap[key] = true;
      _ordersMap[key] = [];
    }

    _loadingMap[key] = true;
    notifyListeners();

    try {
      final page = _pageMap[key] ?? 1;
      final result = await GraphQLConfig.client().query(
        QueryOptions(
          document: gql(GET_ORDERS),
          variables: {
            'pagination': {'page': page, 'limit': _limit},
            'filter': filters ?? const {},
            'search': search,
            'sort': 'NEWEST',
            if (viewerRegion != null && viewerRegion.isNotEmpty)
              'viewerRegion': viewerRegion,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      final raw = result.data?['getOrders']?['payload'];
      final totalPages =
          (result.data?['getOrders']?['totalPages'] as num?)?.toInt() ?? 1;

      if (raw is List && raw.isNotEmpty) {
        final fresh = raw
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((o) =>
                !(_ordersMap[key]?.any((x) => x.id == o.id) ?? false))
            .toList();

        _ordersMap[key] = [...?_ordersMap[key], ...fresh];
        _pageMap[key] = page + 1;
        if (_pageMap[key]! > totalPages) _hasMoreMap[key] = false;
      } else {
        _hasMoreMap[key] = false;
      }
    } finally {
      _loadingMap[key] = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({
    Map<String, dynamic>? filters,
    String? search,
    String? viewerRegion,
  }) async {
    final key = _key(filters, search);
    if (_moreLoadingMap[key] == true || _hasMoreMap[key] == false) return;

    _moreLoadingMap[key] = true;
    notifyListeners();

    await loadList(
      filters: filters,
      search: search,
      viewerRegion: viewerRegion,
      reset: false,
    );

    _moreLoadingMap[key] = false;
    notifyListeners();
  }

  /// Returns the freshly created order id on success, throws on failure.
  Future<String> createOrder(Map<String, dynamic> data) async {
    isCreating = true;
    notifyListeners();
    try {
      final result = await GraphQLConfig.client().mutate(
        MutationOptions(
          document: gql(CREATE_ORDER),
          variables: {'data': data},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );
      if (result.hasException) {
        throw result.exception ?? Exception('Failed to create order');
      }
      final id = result.data?['createOrder']?['_id']?.toString();
      if (id == null) throw Exception('Empty response');

      // Invalidate cache so the new order shows up everywhere.
      _ordersMap.clear();
      _pageMap.clear();
      _hasMoreMap.clear();
      return id;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  Future<void> closeOrder(String orderId) async {
    await GraphQLConfig.client().mutate(
      MutationOptions(
        document: gql(CLOSE_ORDER),
        variables: {'orderId': orderId},
      ),
    );

    for (final key in _ordersMap.keys) {
      final list = _ordersMap[key];
      if (list == null) continue;
      _ordersMap[key] = list
          .map((o) => o.id == orderId
              ? OrderItem(
                  id: o.id,
                  title: o.title,
                  description: o.description,
                  phone: o.phone,
                  location: o.location,
                  region: o.region,
                  budget: o.budget,
                  currency: o.currency,
                  status: OrderStatusEnum.closed,
                  isPromoted: o.isPromoted,
                  createdAt: o.createdAt,
                  author: o.author,
                  brand: o.brand,
                  carModel: o.carModel,
                  partCategory: o.partCategory,
                  images: o.images,
                )
              : o)
          .toList();
    }
    notifyListeners();
  }

  Future<void> deleteOrder(String orderId) async {
    await GraphQLConfig.client().mutate(
      MutationOptions(
        document: gql(DELETE_ORDER),
        variables: {'orderId': orderId},
      ),
    );
    for (final key in _ordersMap.keys) {
      _ordersMap[key]?.removeWhere((o) => o.id == orderId);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
