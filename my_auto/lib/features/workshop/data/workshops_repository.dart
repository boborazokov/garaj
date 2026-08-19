import 'dart:io';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/map/geo_location.dart';
import 'package:my_auto/core/map/user_location_service.dart';
import 'package:my_auto/core/provider/add/uploudImageService.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/workshop/data/models/workshop_category.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/workshop/data/workshops_api.dart';
import 'package:my_auto/features/workshop/domain/create_workshop_draft.dart';

class WorkshopsRepository {
  WorkshopsRepository({
    GraphQLClient? client,
    UploadService? uploadService,
  })  : _client = client ?? GraphQLConfig.client(),
        _upload = uploadService ?? UploadService();

  final GraphQLClient _client;
  final UploadService _upload;

  Future<List<WorkshopCategory>> categories() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(workshopCategoriesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return [];
    final list = result.data?['workshopCategories'] as List? ?? [];
    return list
        .map((e) => WorkshopCategory.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  Future<WorkshopProfile?> details(String id) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(workshopDetailsQuery),
        variables: {'workshopId': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return null;
    final raw = result.data?['workshopDetails'];
    if (raw == null) return null;
    return WorkshopProfile.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<List<WorkshopProfile>> list({
    String? search,
    String? categoryId,
    String? city,
    bool openNow = false,
    int page = 1,
    int limit = 20,
  }) async {
    final filter = <String, dynamic>{};
    if (categoryId != null) filter['categoryId'] = categoryId;
    if (city != null && city.isNotEmpty) filter['city'] = city;
    if (openNow) filter['openNow'] = true;

    final result = await _client.query(
      QueryOptions(
        document: gql(getWorkshopsQuery),
        variables: {
          'search': search,
          'filter': filter.isEmpty ? null : filter,
          'pagination': {'page': page, 'limit': limit},
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return [];
    final payload = result.data?['getWorkshops']?['payload'] as List? ?? [];
    return payload
        .map((e) => WorkshopProfile.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  static bool hasValidMapGeo(GeoLocation? geo) {
    if (geo == null) return false;
    if (geo.latitude.abs() < 0.01 && geo.longitude.abs() < 0.01) {
      return false;
    }
    return geo.latitude.abs() <= 90 && geo.longitude.abs() <= 180;
  }

  Future<List<MapPin>> mapPins({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    int limit = 80,
  }) async {
    var list = await nearby(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      limit: limit,
    );

    if (list.isEmpty) {
      list = await this.list(limit: limit);
    }

    return list
        .where((w) => hasValidMapGeo(w.geo))
        .map(
          (w) => MapPin(
            id: w.id,
            title: w.name,
            latitude: w.geo!.latitude,
            longitude: w.geo!.longitude,
            kind: MapPinKind.workshop,
            subtitle: w.displayAddress,
            coverImage: w.heroImage.isNotEmpty ? w.heroImage : null,
            verified: w.verified,
            premium: w.premium,
            open24Hours: w.open24Hours,
            isEmergency: w.isEmergency,
            isOpenNow: w.isOpenNow,
            fastResponse: w.fastResponse,
            rating: w.rating,
            phone: w.phone.isNotEmpty ? w.phone : null,
            primaryCategorySlug:
                w.categories.isNotEmpty ? w.categories.first.slug : null,
            categoryNames: w.categories.map((c) => c.name).toList(),
          ),
        )
        .toList();
  }

  /// Advanced map viewport query (Mongo bounds / geoNear + Redis server cache).
  Future<List<WorkshopProfile>> workshopsMapDiscovery({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    Map<String, dynamic>? bounds,
    Map<String, dynamic>? filters,
    int limit = 120,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(workshopsMapDiscoveryQuery),
        variables: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
          'bounds': bounds,
          'filters': filters,
          'limit': limit,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      assert(() {
        // ignore: avoid_print
        print('workshopsMapDiscovery error: ${result.exception}');
        return true;
      }());
      return [];
    }
    final list = result.data?['workshopsMapDiscovery'] as List? ?? [];
    return list
        .map((e) => WorkshopProfile.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  /// Cross-entity text search with coordinates for placing pins after a search.
  Future<Map<String, dynamic>?> rawSearchMapEntities({
    required String query,
    int limit = 24,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(searchMapEntitiesQuery),
        variables: {'query': query, 'limit': limit},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return null;
    final raw = result.data?['searchMapEntities'];
    if (raw is! Map) return null;
    return Map<String, dynamic>.from(raw);
  }

  Future<List<WorkshopProfile>> nearby({
    double? latitude,
    double? longitude,
    double radiusKm = 20,
    int limit = 40,
  }) async {
    var lat = latitude;
    var lng = longitude;
    if (lat == null || lng == null) {
      final (_, point) = await UserLocationService.getCurrentLatLng();
      if (point == null) return [];
      lat = point.latitude;
      lng = point.longitude;
    }

    final result = await _client.query(
      QueryOptions(
        document: gql(nearbyWorkshopsQuery),
        variables: {
          'latitude': lat,
          'longitude': lng,
          'radiusKm': radiusKm,
          'limit': limit,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      assert(() {
        // ignore: avoid_print
        print('nearbyWorkshops error: ${result.exception}');
        return true;
      }());
      return [];
    }
    final list = result.data?['nearbyWorkshops'] as List? ?? [];
    return list
        .map((e) => WorkshopProfile.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  Future<List<WorkshopProfile>> recommended() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(recommendedWorkshopsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return [];
    final list = result.data?['recommendedWorkshops'] as List? ?? [];
    return list
        .map((e) => WorkshopProfile.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  Future<List<WorkshopProfile>> openNow() async {
    final (_, point) = await UserLocationService.getCurrentLatLng();
    if (point == null) return [];
    final result = await _client.query(
      QueryOptions(
        document: gql(openNowWorkshopsQuery),
        variables: {
          'latitude': point.latitude,
          'longitude': point.longitude,
          'limit': 30,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return [];
    final list = result.data?['openNowWorkshops'] as List? ?? [];
    return list
        .map((e) => WorkshopProfile.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  Future<List<WorkshopProfile>> smartSearch({
    required String query,
    String? categoryId,
    String? city,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(searchWorkshopsQuery),
        variables: {
          'search': query,
          'categoryId': categoryId,
          'city': city,
          'limit': 40,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return [];
    final list = result.data?['searchWorkshops'] as List? ?? [];
    return list
        .map((e) => WorkshopProfile.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  static const int _reviewsPageSize = 10;

  Future<PaginatedWorkshopReviewsPage> reviewsPage({
    required String workshopId,
    int page = 1,
    int limit = _reviewsPageSize,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(workshopReviewsPaginatedQuery),
        variables: {
          'workshopId': workshopId,
          'pagination': {'page': page, 'limit': limit},
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      throw result.exception!;
    }
    final raw = result.data?['workshopReviewsPaginated'] as Map?;
    if (raw == null) {
      return const PaginatedWorkshopReviewsPage(
        items: [],
        hasNextPage: false,
        page: 1,
        totalDocs: 0,
      );
    }
    final list = raw['payload'] as List? ?? [];
    return PaginatedWorkshopReviewsPage(
      items: list
          .map((e) => WorkshopReview.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
      hasNextPage: raw['hasNextPage'] == true,
      page: (raw['page'] as num?)?.toInt() ?? page,
      totalDocs: (raw['totalDocs'] as num?)?.toInt() ?? 0,
    );
  }

  Future<String> createWorkshop(CreateWorkshopDraft draft) async {
    final data = draft.toGraphQLInput();
    final result = await _client.mutate(
      MutationOptions(
        document: gql(createWorkshopMutation),
        variables: {'data': data},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final id = result.data?['createWorkshop']?['_id']?.toString();
    if (id == null) throw Exception('Failed to create workshop');

    if (draft.galleryFiles.isNotEmpty) {
      await _uploadGallery(id, draft.galleryFiles);
    }
    return id;
  }

  Future<void> _uploadGallery(String workshopId, List<File> files) async {
    final urls = await _upload.uploadFilesWithProgress(
      files: files,
      targetId: workshopId,
      targetType: 'workshop',
      onProgress: (_) {},
    );
    if (urls.isEmpty) return;
    await _client.mutate(
      MutationOptions(
        document: gql(updateWorkshopMutation),
        variables: {
          'workshopId': workshopId,
          'data': <String, dynamic>{'gallery': urls},
        },
      ),
    );
  }

  Future<void> updateWorkshop(
    String workshopId,
    Map<String, dynamic> data,
  ) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(updateWorkshopMutation),
        variables: {
          'workshopId': workshopId,
          'data': data,
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Future<void> updateWorkshopProfile({
    required String workshopId,
    required Map<String, dynamic> data,
    List<String> retainedGalleryUrls = const [],
    List<File> newGalleryFiles = const [],
  }) async {
    final updateData = Map<String, dynamic>.from(data);
    var gallery = List<String>.from(retainedGalleryUrls);

    if (newGalleryFiles.isNotEmpty) {
      final urls = await _upload.uploadFilesWithProgress(
        files: newGalleryFiles,
        targetId: workshopId,
        targetType: 'workshop',
        onProgress: (_) {},
      );
      gallery.addAll(urls);
    }

    updateData['gallery'] = gallery;
    await updateWorkshop(workshopId, updateData);
  }

  Future<void> deleteWorkshop(String workshopId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(deleteWorkshopMutation),
        variables: {'workshopId': workshopId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Future<void> bookWorkshop({
    required String workshopId,
    required DateTime scheduledAt,
    String? notes,
    String? serviceLabel,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(bookWorkshopMutation),
        variables: {
          'data': {
            'workshopId': workshopId,
            'scheduledAt': scheduledAt.toUtc().toIso8601String(),
            'notes': notes ?? '',
            'serviceLabel': serviceLabel ?? '',
          },
        },
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Future<void> addReview({
    required String workshopId,
    required double rating,
    String? text,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(addWorkshopReviewMutation),
        variables: {
          'data': {
            'workshopId': workshopId,
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

  Future<void> updateReview({
    required String reviewId,
    required double rating,
    String? text,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(updateWorkshopReviewMutation),
        variables: {
          'data': {
            'reviewId': reviewId,
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

  Future<void> deleteReview(String reviewId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(deleteWorkshopReviewMutation),
        variables: {'reviewId': reviewId},
      ),
    );
    if (result.hasException) {
      throw result.exception!;
    }
  }

  Future<bool> promoteWorkshop({
    required String workshopId,
    required ServicePromotionPlan plan,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(promoteWorkshopMutation),
        variables: {
          'workshopId': workshopId,
          'plan': plan.api,
        },
      ),
    );
    return !result.hasException;
  }
}

final workshopsRepository = WorkshopsRepository();
