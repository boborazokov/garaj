import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/discovery/data/discovery_api.dart';

enum DiscoveryFeed {
  recommended,
  trending,
  nearby,
  recentlyViewed,
  similar,
  newArrivals,
}

class DiscoveryProvider extends ChangeNotifier {
  final Map<DiscoveryFeed, List<Part>> _feeds = {};
  final Map<DiscoveryFeed, bool> _loading = {};
  final Map<DiscoveryFeed, String?> _errors = {};

  List<Part> feed(DiscoveryFeed key) => _feeds[key] ?? const [];

  bool isLoading(DiscoveryFeed key) => _loading[key] ?? false;

  String? errorFor(DiscoveryFeed key) => _errors[key];

  Future<void> loadRecommended({int limit = 12, String? city}) =>
      _loadFeed(
        DiscoveryFeed.recommended,
        recommendedProductsQuery,
        {'limit': limit, if (city != null) 'city': city},
      );

  Future<void> loadTrending({int limit = 12, String? city}) => _loadFeed(
        DiscoveryFeed.trending,
        trendingProductsQuery,
        {'limit': limit, if (city != null) 'city': city},
      );

  Future<void> loadNearby({int limit = 12, String? region}) => _loadFeed(
        DiscoveryFeed.nearby,
        nearbyProductsQuery,
        {'limit': limit, if (region != null) 'region': region},
      );

  Future<void> loadRecentlyViewed({int limit = 12}) => _loadFeed(
        DiscoveryFeed.recentlyViewed,
        recentlyViewedProductsQuery,
        {'limit': limit},
      );

  Future<void> loadNewArrivals({int limit = 12}) => _loadFeed(
        DiscoveryFeed.newArrivals,
        newArrivalsQuery,
        {'limit': limit},
      );

  Future<void> loadSimilar(String productId, {int limit = 10}) => _loadFeed(
        DiscoveryFeed.similar,
        similarProductsQuery,
        {'productId': productId, 'limit': limit},
      );

  Future<void> refreshAll({String? city, String? region}) async {
    await Future.wait([
      loadRecommended(city: city),
      loadTrending(city: city),
      loadNearby(region: region),
      loadRecentlyViewed(),
      loadNewArrivals(),
    ]);
  }

  Future<List<Part>> search({
    required String query,
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await GraphQLConfig.client().query(
      QueryOptions(
        document: gql(searchProductsQuery),
        variables: {
          'query': query,
          if (category != null) 'category': category,
          if (city != null) 'city': city,
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
          'limit': limit,
          'offset': offset,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final list = result.data?['searchProducts']?['payload'] as List? ?? [];
    return list
        .map((e) => Part.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _loadFeed(
    DiscoveryFeed key,
    String document, [
    Map<String, dynamic> variables = const {},
    String? rootKey,
  ]) async {
    _loading[key] = true;
    _errors[key] = null;
    notifyListeners();

    final field = rootKey ?? _rootFieldFor(key);

    try {
      final result = await GraphQLConfig.client().query(
        QueryOptions(
          document: gql(document),
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _errors[key] = result.exception.toString();
        _feeds[key] = [];
      } else {
        final list = result.data?[field] as List? ?? [];
        _feeds[key] = list
            .map((e) => Part.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (e) {
      _errors[key] = e.toString();
      _feeds[key] = [];
    } finally {
      _loading[key] = false;
      notifyListeners();
    }
  }

  String _rootFieldFor(DiscoveryFeed key) {
    switch (key) {
      case DiscoveryFeed.recommended:
        return 'recommendedProducts';
      case DiscoveryFeed.trending:
        return 'trendingProducts';
      case DiscoveryFeed.nearby:
        return 'nearbyProducts';
      case DiscoveryFeed.recentlyViewed:
        return 'recentlyViewedProducts';
      case DiscoveryFeed.similar:
        return 'similarProducts';
      case DiscoveryFeed.newArrivals:
        return 'newArrivals';
    }
  }
}
