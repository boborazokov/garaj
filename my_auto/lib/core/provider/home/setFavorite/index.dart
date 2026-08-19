import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/home/api/index.dart';
import 'package:my_auto/main.dart';
import 'package:my_auto/widgets/toaster/index.dart';

class SetFavoriteProvider extends ChangeNotifier {
  final Map<String, bool> _favorites = {};
  final Map<String, Timer?> _debouncers = {};

  bool isFavorite(String productId) => _favorites[productId] ?? false;

  /// Apply server flags from part payloads (feed / detail).
  void applyFromParts(Iterable<Part> parts) {
    var changed = false;
    for (final p in parts) {
      if (p.isFavorite && _favorites[p.id] != true) {
        _favorites[p.id] = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void setFavorite(String productId, bool value) {
    if (_favorites[productId] == value) return;
    _favorites[productId] = value;
    notifyListeners();
  }

  /// Replace local map with authoritative id list from API.
  void syncFavoriteIds(Iterable<String> partIds) {
    _favorites.clear();
    for (final id in partIds) {
      if (id.isNotEmpty) _favorites[id] = true;
    }
    notifyListeners();
  }

  void clear() {
    _favorites.clear();
    _cachedFavoriteParts.clear();
    for (final t in _debouncers.values) {
      t?.cancel();
    }
    _debouncers.clear();
    notifyListeners();
  }

  Future<void> loadFavoritesFromServer() async {
    try {
      final result = await GraphQLConfig.client().query(
        QueryOptions(
          document: gql(GET_FAVORITE_PARTS),
          variables: {
            'pagination': {'page': 1, 'limit': 200},
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException) {
        if (kDebugMode) {
          debugPrint('[SetFavoriteProvider] loadFavorites: ${result.exception}');
        }
        return;
      }

      final payload = result.data?['getParts']?['payload'] as List?;
      if (payload == null) return;

      final ids = <String>[];
      final parts = <Part>[];
      for (final raw in payload) {
        final map = Map<String, dynamic>.from(raw as Map);
        final id = map['_id']?.toString() ?? '';
        if (id.isNotEmpty) ids.add(id);
        parts.add(Part.fromJson(map));
      }
      syncFavoriteIds(ids);
      _cachedFavoriteParts
        ..clear()
        ..addAll(parts);
    } catch (e) {
      if (kDebugMode) debugPrint('[SetFavoriteProvider] loadFavorites: $e');
    }
  }

  final List<Part> _cachedFavoriteParts = [];

  List<Part> get cachedFavoriteParts => List.unmodifiable(_cachedFavoriteParts);

  void toggleFavoriteDebounced(String? serviceId, String productId) {
    final next = !isFavorite(productId);
    setFavorite(productId, next);

    _debouncers[productId]?.cancel();
    _debouncers[productId] = Timer(const Duration(milliseconds: 400), () async {
      await _persistFavorite(
        serviceId: serviceId,
        productId: productId,
        add: next,
      );
    });
  }

  Future<void> _persistFavorite({
    required String? serviceId,
    required String productId,
    required bool add,
  }) async {
    final input = <String, dynamic>{
      'partId': productId,
      if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
    };

    try {
      final result = await GraphQLConfig.client().mutate(
        MutationOptions(
          document: gql(add ? SET_FAVORITE : REMOVE_FAVORITE),
          variables: {'favorite': input},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        setFavorite(productId, !add);
        _toastError();
        return;
      }

      final root = result.data;
      final mutationKey =
          add ? 'addToFavorites' : 'removeFromFavorites';
      final data = root == null ? null : root[mutationKey];
      final ids = (data?['partsIds'] as List?)
          ?.map((e) => e.toString())
          .where((id) => id.isNotEmpty)
          .toList();
      if (ids != null && ids.isNotEmpty) {
        syncFavoriteIds(ids);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[SetFavoriteProvider] persist: $e');
      setFavorite(productId, !add);
      _toastError();
    }
  }

  void _toastError() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    Toaster.error('Could not update favorites');
  }
}
