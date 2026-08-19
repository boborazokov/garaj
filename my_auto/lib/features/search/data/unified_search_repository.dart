import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/discovery/data/discovery_api.dart';
import 'package:my_auto/features/orders/domain/entities/paginated_orders.dart';
import 'package:my_auto/features/orders/orders_di.dart';
import 'package:my_auto/features/search/domain/unified_search_snapshot.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';

/// Aggregates catalog + geographic search APIs behind one call.
///
/// Backend team can replace internals with single `globalSearch(query)` resolver
/// without changing call sites (`GlobalSearchHubScreen`).
class UnifiedSearchRepository {
  UnifiedSearchRepository({
    GraphQLClient? client,
    WorkshopsRepository? workshops,
  })  : _client = client ?? GraphQLConfig.client(),
        _workshops = workshops ?? workshopsRepository;

  final GraphQLClient _client;
  final WorkshopsRepository _workshops;

  Future<UnifiedSearchSnapshot> search({
    required String query,
    int productLimit = 24,
    int workshopLimit = 16,
    int orderLimit = 12,
    int mapEntityLimit = 16,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return UnifiedSearchSnapshot.empty(q);

    final productsFut = _searchProducts(q, productLimit);
    final workshopsFut = _workshops.smartSearch(query: q);
    final ordersFut = ordersRepository.getOrders(
      page: 1,
      limit: orderLimit,
      search: q,
    );
    final rawFut = _workshops.rawSearchMapEntities(query: q, limit: mapEntityLimit);

    final bag = await Future.wait([
      productsFut,
      workshopsFut,
      ordersFut,
      rawFut,
    ]);

    final products = bag[0] as List<Part>;
    var workshops = bag[1] as List<WorkshopProfile>;
    final ordersPage = bag[2] as PaginatedOrders;
    final raw = bag[3] as Map<String, dynamic>?;

    var mergedProducts = [...products];

    final orders = ordersPage.items;

    final services = <UnifiedServiceHit>[];
    final mapWorkshops = <WorkshopProfile>[];

    if (raw != null) {
      final wl = raw['workshops'] as List? ?? [];
      for (final e in wl) {
        try {
          mapWorkshops.add(
            WorkshopProfile.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          );
        } catch (_) {}
      }
      final sl = raw['services'] as List? ?? [];
      for (final e in sl) {
        try {
          final m = Map<String, dynamic>.from(e as Map);
          final geo = m['geoLocation'] as Map?;
          final imgs = (m['images'] as List?) ?? const [];
          services.add(UnifiedServiceHit(
            id: m['_id']?.toString() ?? '',
            title: (m['title'] ?? '').toString(),
            rating: (m['rating'] as num?)?.toDouble(),
            verified: m['verified'] == true,
            isEmergency: m['isEmergency'] == true,
            categoryName: (m['category'] as Map?)?['name']?.toString(),
            latitude: geo != null ? (geo['latitude'] as num?)?.toDouble() : null,
            longitude: geo != null ? (geo['longitude'] as num?)?.toDouble() : null,
            coverImage: imgs.isNotEmpty ? imgs.first.toString() : null,
          ));
        } catch (_) {}
      }
      if (products.isEmpty) {
        final pl = raw['parts'] as List? ?? [];
        for (final e in pl) {
          try {
            mergedProducts.add(
              Part.fromJson(Map<String, dynamic>.from(e as Map)),
            );
          } catch (_) {}
        }
      }
    }

    workshops = _mergeWorkshops(workshops, mapWorkshops, workshopLimit);

    final sellers = _deriveSellers(mergedProducts);

    return UnifiedSearchSnapshot(
      query: q,
      products: mergedProducts.take(productLimit).toList(),
      workshops: workshops,
      orders: orders,
      services: services,
      sellers: sellers,
    );
  }

  List<WorkshopProfile> _mergeWorkshops(
    List<WorkshopProfile> primary,
    List<WorkshopProfile> secondary,
    int cap,
  ) {
    final byId = <String, WorkshopProfile>{};
    for (final w in primary) {
      if (w.id.isEmpty) continue;
      byId[w.id] = w;
    }
    for (final w in secondary) {
      if (w.id.isEmpty) continue;
      byId.putIfAbsent(w.id, () => w);
    }
    return byId.values.take(cap).toList();
  }

  List<UnifiedSellerHit> _deriveSellers(List<Part> products) {
    final counts = <String, int>{};
    final reps = <String, Seller>{};
    for (final p in products) {
      final s = p.seller;
      if (s == null || s.id.isEmpty) continue;
      counts[s.id] = (counts[s.id] ?? 0) + 1;
      reps.putIfAbsent(s.id, () => s);
    }
    final hits = counts.entries.map((e) {
      final s = reps[e.key]!;
      return UnifiedSellerHit(
        id: s.id,
        name: s.name,
        image: s.image.isNotEmpty ? s.image : null,
        phone: s.phone.isNotEmpty ? s.phone : null,
        productsInSearch: e.value,
      );
    }).toList()
      ..sort((a, b) => b.productsInSearch.compareTo(a.productsInSearch));
    return hits.take(12).toList();
  }

  Future<List<Part>> _searchProducts(String query, int limit) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(searchProductsQuery),
          variables: {
            'query': query,
            'limit': limit,
            'offset': 0,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException) return [];
      final list =
          result.data?['searchProducts']?['payload'] as List<dynamic>? ?? [];
      final out = <Part>[];
      for (final e in list) {
        try {
          out.add(
            Part.fromJson(Map<String, dynamic>.from(e as Map)),
          );
        } catch (_) {}
      }
      return out;
    } catch (_) {
      return [];
    }
  }
}

final unifiedSearchRepository = UnifiedSearchRepository();
