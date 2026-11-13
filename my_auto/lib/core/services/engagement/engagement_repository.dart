import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/auth/auth_token_store.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/home/api/index.dart';
import 'package:my_auto/features/orders/data/api/orders_api.dart';
import 'package:my_auto/features/workshop/data/workshops_api.dart';

final engagementRepository = EngagementRepository();

/// Fire-and-forget engagement counters (phone clicks, shares).
class EngagementRepository {
  EngagementRepository({GraphQLClient? client})
      : _client = client ?? GraphQLConfig.client();

  final GraphQLClient _client;

  Future<void> recordPartPhoneClick(String partId) async {
    try {
      final deviceId = await AuthTokenStore.deviceId();
      await _client.mutate(
        MutationOptions(
          document: gql(recordPartPhoneClickMutation),
          variables: {'partId': partId, 'deviceId': deviceId},
        ),
      );
    } catch (_) {
      /* best-effort analytics */
    }
  }

  Future<void> recordPartShare(String partId) async {
    try {
      final deviceId = await AuthTokenStore.deviceId();
      await _client.mutate(
        MutationOptions(
          document: gql(recordPartShareMutation),
          variables: {'partId': partId, 'deviceId': deviceId},
        ),
      );
    } catch (_) {
      /* best-effort analytics */
    }
  }

  Future<void> recordOrderPhoneClick(String orderId) async {
    try {
      final deviceId = await AuthTokenStore.deviceId();
      await _client.mutate(
        MutationOptions(
          document: gql(recordOrderPhoneClickMutation),
          variables: {'orderId': orderId, 'deviceId': deviceId},
        ),
      );
    } catch (_) {
      /* best-effort analytics */
    }
  }

  Future<void> recordOrderShare(String orderId) async {
    try {
      final deviceId = await AuthTokenStore.deviceId();
      await _client.mutate(
        MutationOptions(
          document: gql(recordOrderShareMutation),
          variables: {'orderId': orderId, 'deviceId': deviceId},
        ),
      );
    } catch (_) {
      /* best-effort analytics */
    }
  }

  Future<void> recordWorkshopPhoneClick(String workshopId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(recordWorkshopPhoneClickMutation),
          variables: {'workshopId': workshopId},
        ),
      );
    } catch (_) {
      /* best-effort analytics */
    }
  }
}
