import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/services/data/models/service_review.dart';
import 'package:my_auto/features/services/data/services_api.dart';

class ServicesRepository {
  ServicesRepository(this._client);

  final GraphQLClient _client;

  Future<List<ServiceListing>> nearbyServices({
    required double latitude,
    required double longitude,
    double radiusKm = 15,
    int limit = 50,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(nearbyServicesQuery),
        variables: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
          'limit': limit,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return [];
    final list = result.data?['nearbyServices'] as List? ?? [];
    return sortServicesByPromotion(
      list.map(
        (e) => ServiceListing.fromJson(Map<String, dynamic>.from(e as Map)),
      ),
    );
  }

  Future<List<ServiceListing>> topRated() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(topRatedServicesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return [];
    final list = result.data?['topRatedServices'] as List? ?? [];
    return sortServicesByPromotion(
      list.map(
        (e) => ServiceListing.fromJson(Map<String, dynamic>.from(e as Map)),
      ),
    );
  }

  Future<bool> promoteService({
    required String serviceId,
    required ServicePromotionPlan plan,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(promoteServiceMutation),
        variables: {
          'serviceId': serviceId,
          'plan': plan.api,
        },
      ),
    );
    return !result.hasException;
  }

  Future<ServiceListing?> details(String id) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(serviceDetailsQuery),
        variables: {'serviceId': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return null;
    final raw = result.data?['serviceDetails'];
    if (raw == null) return null;
    return ServiceListing.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<List<MapPin>> mapPins({
    required double latitude,
    required double longitude,
    bool showServices = true,
    bool showProducts = true,
    bool showOrders = true,
  }) async {
    final pins = <MapPin>[];
    if (showServices) {
      final services = await nearbyServices(
        latitude: latitude,
        longitude: longitude,
      );
      pins.addAll(
        services.map(
          (s) => MapPin(
            id: s.id,
            title: s.title,
            latitude: s.latitude,
            longitude: s.longitude,
            kind: s.isEmergency ? MapPinKind.emergency : MapPinKind.service,
            subtitle: s.categoryName,
            coverImage: s.images.isNotEmpty ? s.images.first : null,
            verified: s.verified,
            isEmergency: s.isEmergency,
            rating: s.rating,
            phone: s.phone,
            primaryCategorySlug: s.categorySlug,
          ),
        ),
      );
    }
    if (showProducts) {
      final result = await _client.query(
        QueryOptions(
          document: gql(nearbyProductsMapQuery),
          variables: {
            'latitude': latitude,
            'longitude': longitude,
            'radiusKm': 15,
            'limit': 30,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      final list = result.data?['nearbyProducts'] as List? ?? [];
      for (final raw in list) {
        final m = Map<String, dynamic>.from(raw as Map);
        final geo = m['geoLocation'] as Map?;
        if (geo == null) continue;
        final imgs = (m['images'] as List?)?.map((e) => e.toString()).toList() ?? [];
        pins.add(MapPin(
          id: m['_id'].toString(),
          title: (m['name'] ?? 'Part').toString(),
          latitude: (geo['latitude'] as num).toDouble(),
          longitude: (geo['longitude'] as num).toDouble(),
          kind: MapPinKind.product,
          subtitle: '${m['price']} ${m['currency'] ?? ''}',
          coverImage: imgs.isNotEmpty ? imgs.first : null,
          pricePreview: m['price'] != null
              ? '${m['currency'] ?? ''} ${m['price']}'.trim()
              : null,
        ));
      }
    }
    if (showOrders) {
      final result = await _client.query(
        QueryOptions(
          document: gql(nearbyOrdersMapQuery),
          variables: {
            'latitude': latitude,
            'longitude': longitude,
            'radiusKm': 15,
            'limit': 30,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      final list = result.data?['nearbyOrders'] as List? ?? [];
      for (final raw in list) {
        final m = Map<String, dynamic>.from(raw as Map);
        final geo = m['geoLocation'] as Map?;
        if (geo == null) continue;
        pins.add(MapPin(
          id: m['_id'].toString(),
          title: (m['title'] ?? 'Request').toString(),
          latitude: (geo['latitude'] as num).toDouble(),
          longitude: (geo['longitude'] as num).toDouble(),
          kind: MapPinKind.order,
          subtitle: 'Request',
        ));
      }
    }
    return pins;
  }

  Future<List<ServiceReview>> reviews(String serviceId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(serviceReviewsQuery),
        variables: {'serviceId': serviceId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return [];
    final list = result.data?['serviceReviews'] as List? ?? [];
    return list
        .map(
          (e) => ServiceReview.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<void> addReview({
    required String serviceId,
    required double rating,
    String? text,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(addServiceReviewMutation),
        variables: {
          'data': {
            'serviceId': serviceId,
            'rating': rating,
            'text': text ?? '',
          },
        },
      ),
    );
    if (result.hasException) {
      throw result.exception!;
    }
  }

  Future<bool> bookService({
    required String serviceId,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(bookServiceMutation),
        variables: {
          'data': {
            'serviceId': serviceId,
            'scheduledAt': scheduledAt.toIso8601String(),
            if (notes != null) 'notes': notes,
          },
        },
      ),
    );
    return !result.hasException;
  }
}

final ServicesRepository servicesRepository =
    ServicesRepository(GraphQLConfig.client());

void initializeServicesRepository() {
  servicesRepository;
}
