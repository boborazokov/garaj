import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/advertisement/data/advertisement_api.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';

/// Thin wrapper around the public `getAdvertisements` GraphQL query. Each
/// surface (Home / Product / Workshop / Store / List) requests its own
/// `AdSurface` so the network payload stays small.
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
}
