import 'dart:convert';
import 'dart:io';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:my_auto/core/services/graphql/graphql_links.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/services/upload/image_multipart.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/features/advertisement/data/advertisement_api.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/domain/advertisement_plan_price.dart';

/// Thin wrapper around advertisement GraphQL + banner upload REST.
class AdvertisementRepository {
  AdvertisementRepository({GraphQLClient? client})
      : _client = client ?? GraphQLConfig.client();

  final GraphQLClient _client;

  Future<List<Advertisement>> list({
    AdSurface? surface,
    bool forceNetwork = false,
  }) async {
    final filter = <String, dynamic>{};
    if (surface != null) filter['type'] = surface.api;

    final result = await _client.query(
      QueryOptions(
        document: gql(getAdvertisementsQuery),
        variables: {
          'filter': filter.isEmpty ? null : filter,
        },
        fetchPolicy:
            forceNetwork ? FetchPolicy.networkOnly : FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) return const [];

    final raw = result.data?['getAdvertisements'] as List? ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => Advertisement.fromJson(Map<String, dynamic>.from(e)))
        .where((ad) => ad.bannerImageUrl.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<AdvertisementPlanPrice>> planPrices({
    bool forceNetwork = false,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(advertisementPlanPricesQuery),
        fetchPolicy:
            forceNetwork ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst,
      ),
    );
    if (result.hasException) return const [];
    final raw = result.data?['advertisementPlanPrices'] as List? ?? const [];
    return raw
        .whereType<Map>()
        .map(
          (e) => AdvertisementPlanPrice.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList(growable: false);
  }

  Future<AdSlotInfo?> slotInfo(AdSurface surface) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(advertisementSlotInfoQuery),
        variables: {'type': surface.api},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) return null;
    final raw = result.data?['advertisementSlotInfo'];
    if (raw is! Map) return null;
    return AdSlotInfo.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<List<Advertisement>> myAdvertisements() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myAdvertisementsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final raw = result.data?['myAdvertisements'] as List? ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => Advertisement.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<Advertisement> purchase({
    required AdSurface type,
    required AdPlan plan,
    required String title,
    required String link,
    required String bannerImageUrl,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(purchaseAdvertisementMutation),
        variables: {
          'type': type.api,
          'plan': plan.api,
          'title': title,
          'link': link,
          'bannerImageUrl': bannerImageUrl,
        },
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final raw = result.data?['purchaseAdvertisement'];
    if (raw is! Map) throw Exception('Empty purchase response');
    return Advertisement.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> pauseMine(String advertisementId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(pauseMyAdvertisementMutation),
        variables: {'advertisementId': advertisementId},
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Future<void> recordImpression(String advertisementId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(recordAdvertisementImpressionMutation),
          variables: {'advertisementId': advertisementId},
        ),
      );
    } catch (_) {
      /* best-effort analytics */
    }
  }

  Future<void> recordClick(String advertisementId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(recordAdvertisementClickMutation),
          variables: {'advertisementId': advertisementId},
        ),
      );
    } catch (_) {
      /* best-effort analytics */
    }
  }

  /// REST upload → storage key for `purchaseAdvertisement.bannerImageUrl`.
  Future<String> uploadBanner(File file) async {
    final token = await GraphQLLinks.readBearer();
    final uri = Uri.parse('$apiUrl/upload/advertisement-banner');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(mediaRequestHeaders(apiUrl));
    if (token != null) request.headers['Authorization'] = token;
    request.files.add(await multipartImageFromFile(file, fieldName: 'file'));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Banner upload failed (${response.statusCode}): $body');
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map) throw Exception('Invalid upload response');
    final files = decoded['files'];
    if (files is List && files.isNotEmpty) {
      return files.first.toString();
    }
    final url = decoded['url']?.toString();
    if (url != null && url.isNotEmpty) return url;
    throw Exception('Upload returned no file URL');
  }
}

final advertisementRepository = AdvertisementRepository();
