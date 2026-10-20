import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/name.dart';
import '../notifications_constants.dart';

/// Maps an incoming push payload to an in-app route.
///
/// Decoupled from `PushService` so unit-testing the routing rules
/// doesn't require FCM at all — feed it a `Map<String, dynamic>` and
/// assert the navigator call.
///
/// Deep links are resolved against the global `navigatorKey` instead
/// of an in-tree `BuildContext`: pushes arrive from terminated-state
/// taps where there is no widget tree yet.
class PushRouter {
  PushRouter({required this.navigatorKey, required this.isAuthenticated});

  final GlobalKey<NavigatorState> navigatorKey;

  /// Resolved at routing time so we always see the current auth state.
  /// `() => bool` rather than a value: the router is constructed once
  /// at startup, but auth state changes throughout the session.
  final bool Function() isAuthenticated;

  /// Pending deep link captured when the user taps a push but is not
  /// yet authenticated. Consumed by the splash / auth flow after a
  /// successful sign-in.
  String? _pendingDeepLink;
  String? get pendingDeepLink => _pendingDeepLink;
  void clearPendingDeepLink() => _pendingDeepLink = null;

  /// Entry point invoked from `PushService` for every taken push.
  /// Safe to call before the widget tree exists — we queue the link.
  /// Returns `true` when a navigation was attempted.
  bool route(Map<String, dynamic> data) {
    final normalized = <String, dynamic>{
      for (final e in data.entries)
        if (e.value != null) e.key: e.value.toString(),
    };
    final link = _resolveLink(normalized);
    if (link == null) return false;

    if (!isAuthenticated()) {
      _pendingDeepLink = link;
      return true;
    }

    return _navigate(link);
  }

  /// Replay the queued deep link after a successful login. Returns
  /// `true` if a navigation happened so the caller can skip its own
  /// default redirect.
  bool consumePendingDeepLink() {
    final link = _pendingDeepLink;
    if (link == null) return false;
    _pendingDeepLink = null;
    return _navigate(link);
  }

  // ------------------- internals -------------------

  String? _resolveLink(Map<String, dynamic> data) {
    final deepLink = data[PushDataKeys.deepLink]?.toString().trim();
    if (deepLink != null && deepLink.isNotEmpty) return deepLink;

    // Backward-compatible fallback: derive a path from `type` + ids.
    final type = data[PushDataKeys.type]?.toString();
    switch (type) {
      case PushEventTypes.chat:
        final id = data[PushDataKeys.conversationId]?.toString();
        return (id != null && id.isNotEmpty)
            ? '${RoutesName.chatDetail}/$id'
            : RoutesName.chats;
      case PushEventTypes.orderReply:
        final id = data[PushDataKeys.orderId]?.toString();
        return (id != null && id.isNotEmpty)
            ? '${RoutesName.orderDetail}/$id'
            : RoutesName.ordersList;
      case PushEventTypes.orderMatched:
        final id = data[PushDataKeys.orderId]?.toString();
        return (id != null && id.isNotEmpty)
            ? '${RoutesName.orderDetail}/$id'
            : RoutesName.sellerMatchingOrders;
      case PushEventTypes.favoriteMatched:
      case PushEventTypes.sellerResponse:
      case PushEventTypes.promotedExpired:
        final id = data[PushDataKeys.partId]?.toString();
        return (id != null && id.isNotEmpty)
            ? '${RoutesName.productDetailScreen}?id=$id'
            : null;
      default:
        return null;
    }
  }

  bool _navigate(String link) {
    // Defer until the navigator has finished laying itself out — this
    // handles the cold-start case where the splash hasn't built yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null) {
        // No tree yet — re-queue and try after the next frame.
        _pendingDeepLink = link;
        return;
      }
      try {
        final router = GoRouter.of(context);
        final uri = _parseLink(link);
        final path = uri.path;
        final params = uri.queryParameters;

        if (path == RoutesName.productDetailScreen) {
          final id = params['id'] ?? params['partId'];
          if (id != null && id.isNotEmpty) {
            router.push(RoutesName.productDetailScreen, extra: id);
          }
          return;
        }

        if (path == RoutesName.sellerProfile) {
          final sellerId = params['sellerId'] ?? params['id'];
          if (sellerId != null && sellerId.isNotEmpty) {
            router.push(RoutesName.sellerProfile, extra: sellerId);
          }
          return;
        }

        if (path.startsWith(RoutesName.chatDetail) ||
            path.startsWith(RoutesName.orderDetail) ||
            path.startsWith(RoutesName.workshopDetailScreen) ||
            path.startsWith(RoutesName.serviceDetail)) {
          router.push(path);
          return;
        }

        router.push(path);
      } catch (e) {
        assert(() {
          debugPrint('[PushRouter] navigate failed: $e link=$link');
          return true;
        }());
      }
    });
    return true;
  }

  Uri _parseLink(String link) {
    final trimmed = link.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Uri.parse(trimmed);
    }
    if (trimmed.startsWith('/')) {
      return Uri.parse(trimmed);
    }
    return Uri.parse('/$trimmed');
  }
}
