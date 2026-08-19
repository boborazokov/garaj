import 'dart:io' show Platform;

import 'package:graphql_flutter/graphql_flutter.dart';

import '../api/notifications_api.dart';

/// Talks to the backend `DeviceToken` resolvers.
///
/// Lives in `data/repositories/` (not `provider/`) because the
/// notifications feature uses a clean repository → bloc → UI flow.
/// We can plug a different transport in tests by injecting a custom
/// `GraphQLClient`.
class DeviceTokenRepository {
  DeviceTokenRepository(this._client);

  final GraphQLClient _client;

  /// Maps `Platform` to the server enum (`DevicePlatformEnum`).
  static String detectPlatform() {
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    return 'WEB';
  }

  /// Idempotent. Safe to call after every login and on every token
  /// refresh — the server upserts by `token`.
  Future<void> register({
    required String token,
    required String platform,
    String? locale,
    String? appVersion,
    String? deviceModel,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(REGISTER_DEVICE_TOKEN_MUTATION),
        variables: {
          'data': {
            'token': token,
            'platform': platform,
            if (locale != null) 'locale': locale,
            if (appVersion != null) 'appVersion': appVersion,
            if (deviceModel != null) 'deviceModel': deviceModel,
          },
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }
  }

  /// Called on explicit logout. Server-side this just flips the row's
  /// `isActive` flag so we keep audit history.
  Future<void> remove(String token) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(REMOVE_DEVICE_TOKEN_MUTATION),
        variables: {'token': token},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    if (result.hasException) throw result.exception!;
  }
}
