import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:url_launcher/url_launcher.dart';

/// Returns true when the admin provided a non-empty tap target.
bool advertisementLinkHasTarget(String rawLink) {
  return rawLink.trim().isNotEmpty;
}

/// Known first path segments that map to in-app screens.
const _kInAppHeads = {
  'chat',
  'chats',
  'inbox',
  'notifications',
  'product',
  'part',
  'productDetailScreen',
  'workshop',
  'workshopDetailScreen',
  'service',
  'services',
  'serviceDetail',
  'servicesHub',
  'seller',
  'store',
  'sellerProfile',
  'search',
  'favorites',
  'map',
  'nearbyMap',
  'categoriesScreen',
  'listOfItems',
  'orders',
  'orderDetail',
  'ordersList',
  'createOrder',
  'myProducts',
  'myOrders',
  'myServices',
  'editProfile',
  'edit_profile',
  'addProduct',
  'contactUs',
  'privacyPolicy',
  'storeAnalytics',
};

/// Hosts whose paths may be resolved as in-app deep links.
/// Everything else on http(s) opens in the browser / external app.
const _kAppHosts = {
  'garage.uz',
  'www.garage.uz',
  'autorin.uz',
  'www.autorin.uz',
  'app.garage.uz',
  'app.autorin.uz',
};

/// Opens any advertisement link format used in admin:
/// - in-app routes: `/chat/ID`, `/product/ID`, `/favorites`
/// - app deep links: `autorin://product/ID`
/// - websites: `https://instagram.com/…`, `https://t.me/…`, `www.example.com`
/// - other apps: `tg://…`, `whatsapp://…`, `mailto:`, `tel:`
///
/// Unknown http(s) paths are **never** pushed into GoRouter — they open externally.
Future<void> openAdvertisementLink(BuildContext context, String rawLink) async {
  final normalized = _normalizeLink(rawLink);
  if (normalized == null) return;
  if (!context.mounted) return;

  // Pure in-app relative path: `/favorites`, `/product/abc`
  if (normalized.startsWith('/')) {
    if (_isKnownInAppPath(normalized) &&
        _openInAppPath(context, normalized, const {})) {
      return;
    }
    // Unknown `/…` — do not route inside the app.
    if (kDebugMode) {
      debugPrint('[AdLink] unknown in-app path, ignored: $normalized');
    }
    return;
  }

  final uri = _parseUri(normalized);
  if (uri == null) return;

  final scheme = uri.scheme.toLowerCase();

  // Custom app scheme for this product.
  if (scheme == 'autorin') {
    if (!context.mounted) return;
    final path = uri.path.isNotEmpty ? uri.path : '/${uri.host}';
    _openInAppPath(context, path.startsWith('/') ? path : '/$path', uri.queryParameters);
    return;
  }

  // Direct OS handlers / other apps.
  if (scheme == 'mailto' ||
      scheme == 'tel' ||
      scheme == 'sms' ||
      scheme == 'tg' ||
      scheme == 'telegram' ||
      scheme == 'whatsapp' ||
      scheme == 'viber' ||
      scheme == 'instagram' ||
      scheme == 'fb' ||
      scheme == 'facebook' ||
      scheme == 'market' ||
      scheme == 'intent' ||
      scheme == 'geo') {
    await _launchExternal(uri);
    return;
  }

  if (scheme == 'http' || scheme == 'https') {
    // Only try in-app navigation for our own hosts + known route paths.
    // External sites (Instagram, Telegram web, Google, partner shops, …)
    // always open in the browser / external app.
    final tryInApp = _isAppHost(uri.host) && _isKnownInAppPath(uri.path);
    if (tryInApp) {
      if (!context.mounted) return;
      if (_openInAppPath(context, uri.path, uri.queryParameters)) return;
    }
    await _launchExternal(uri);
    return;
  }

  // Empty / unknown scheme that still looks like a URL → https.
  if (scheme.isEmpty) {
    await _launchExternal(Uri.parse('https://$normalized'));
    return;
  }

  // Any other custom scheme (third-party apps).
  await _launchExternal(uri);
}

String? _normalizeLink(String raw) {
  var link = raw.trim();
  if (link.isEmpty) return null;

  // `chat/abc` → `/chat/abc` (in-app shorthand only)
  if (!link.contains('://') &&
      !link.startsWith('/') &&
      _looksLikeInAppShorthand(link)) {
    link = '/$link';
  }

  return link;
}

bool _looksLikeInAppShorthand(String link) {
  if (link.contains(' ') || link.contains('.')) return false;
  final head = link.split('/').firstWhere((s) => s.isNotEmpty, orElse: () => '');
  return _kInAppHeads.contains(head);
}

bool _isAppHost(String host) {
  final h = host.trim().toLowerCase();
  if (h.isEmpty) return false;
  if (_kAppHosts.contains(h)) return true;
  // localhost / LAN during QA
  if (h == 'localhost' || h.startsWith('192.168.') || h.startsWith('10.')) {
    return true;
  }
  return false;
}

bool _isKnownInAppPath(String path) {
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return false;
  return _kInAppHeads.contains(segments.first);
}

Uri? _parseUri(String link) {
  var uri = Uri.tryParse(link);
  if (uri != null && uri.scheme.isNotEmpty) return uri;

  if (!link.contains('://')) {
    uri = Uri.tryParse('https://$link');
  }
  return uri;
}

Future<void> _launchExternal(Uri uri) async {
  try {
    final ok = await canLaunchUrl(uri);
    if (!ok) {
      if (kDebugMode) debugPrint('[AdLink] cannot launch: $uri');
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    if (kDebugMode) debugPrint('[AdLink] launch failed: $e');
  }
}

String? _resolveId(String? pathId, Map<String, String> query) {
  if (pathId != null && pathId.trim().isNotEmpty) return pathId.trim();
  for (final key in ['id', 'partId', 'sellerId', 'workshopId', 'orderId', 'serviceId']) {
    final v = query[key]?.trim();
    if (v != null && v.isNotEmpty) return v;
  }
  return null;
}

/// Returns `true` only when navigation inside the Flutter app succeeded.
bool _openInAppPath(
  BuildContext context,
  String path,
  Map<String, String> query,
) {
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return false;

  final head = segments.first;
  final pathId = segments.length > 1 ? segments[1] : null;
  final id = _resolveId(pathId, query);

  switch (head) {
    case 'chat':
      if (id != null) {
        context.push('${RoutesName.chatDetail}/$id');
        return true;
      }
      context.push(RoutesName.chats);
      return true;
    case 'chats':
      context.push(RoutesName.chats);
      return true;
    case 'inbox':
      context.push(RoutesName.inbox, extra: query.isEmpty ? null : query);
      return true;
    case 'notifications':
      context.push(RoutesName.notifications);
      return true;
    case 'product':
    case 'part':
    case 'productDetailScreen':
      if (id == null) return false;
      context.push(RoutesName.productDetailScreen, extra: id);
      return true;
    case 'workshop':
    case 'workshopDetailScreen':
      if (id == null) return false;
      context.push('${RoutesName.workshopDetailScreen}/$id');
      return true;
    case 'service':
    case 'services':
    case 'serviceDetail':
      if (id != null) {
        context.push('${RoutesName.serviceDetail}/$id');
        return true;
      }
      context.push(RoutesName.servicesHub);
      return true;
    case 'servicesHub':
      context.push(RoutesName.servicesHub);
      return true;
    case 'seller':
    case 'store':
      if (id == null) return false;
      context.push(RoutesName.sellerProfile, extra: id);
      return true;
    case 'sellerProfile':
      if (id != null) {
        context.push(RoutesName.sellerProfile, extra: id);
        return true;
      }
      context.push(RoutesName.sellerProfile);
      return true;
    case 'search':
      context.push(RoutesName.search, extra: query.isEmpty ? null : query);
      return true;
    case 'favorites':
      context.push(RoutesName.favorites);
      return true;
    case 'map':
      context.push(RoutesName.map);
      return true;
    case 'nearbyMap':
      context.push(RoutesName.nearbyMap);
      return true;
    case 'categoriesScreen':
      context.push(
        RoutesName.categoriesScreen,
        extra: id ?? query['type'],
      );
      return true;
    case 'listOfItems':
      context.push(RoutesName.listOfItems, extra: query.isEmpty ? null : query);
      return true;
    case 'orders':
    case 'orderDetail':
      if (id != null) {
        context.push('${RoutesName.orderDetail}/$id');
        return true;
      }
      context.push(RoutesName.ordersList);
      return true;
    case 'ordersList':
      context.push(RoutesName.ordersList);
      return true;
    case 'createOrder':
      context.push(RoutesName.createOrder, extra: query.isEmpty ? null : query);
      return true;
    case 'myProducts':
      context.push(RoutesName.myProducts);
      return true;
    case 'myOrders':
      context.push(RoutesName.myOrders);
      return true;
    case 'myServices':
      context.push(RoutesName.myServices);
      return true;
    case 'editProfile':
    case 'edit_profile':
      context.push(RoutesName.editProfile);
      return true;
    case 'addProduct':
      context.push(RoutesName.addProduct);
      return true;
    case 'contactUs':
      context.push(RoutesName.contactUs);
      return true;
    case 'privacyPolicy':
      context.push(RoutesName.privacyPolicy);
      return true;
    case 'storeAnalytics':
      if (id != null) {
        context.push(RoutesName.storeAnalytics, extra: id);
        return true;
      }
      context.push(RoutesName.storeAnalytics);
      return true;
    default:
      // Never push unknown paths into GoRouter — that caused the banner errors.
      return false;
  }
}
