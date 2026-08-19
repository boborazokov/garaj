import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:url_launcher/url_launcher.dart';

/// Returns true when the admin provided a non-empty tap target.
bool advertisementLinkHasTarget(String rawLink) {
  return rawLink.trim().isNotEmpty;
}

/// Opens any advertisement link format used in admin:
/// - in-app routes: `/chat/ID`, `/productDetailScreen`, `/favorites`
/// - site paths: `https://garage.uz/store/handle`, `/seller/ID`
/// - deep links: `autorin://product/ID`
/// - external: `https://…`, `www.…`, `mailto:`, `tel:`
///
/// Used by every [AdBanner] in the app — one handler for all surfaces.
Future<void> openAdvertisementLink(BuildContext context, String rawLink) async {
  final normalized = _normalizeLink(rawLink);
  if (normalized == null) return;

  if (!context.mounted) return;

  // Pure in-app path.
  if (normalized.startsWith('/')) {
    if (_openInAppPath(context, normalized, const {})) return;
    context.push(normalized);
    return;
  }

  final uri = _parseUri(normalized);
  if (uri == null) return;

  if (uri.scheme == 'autorin') {
    if (!context.mounted) return;
    _openAutorinUri(context, uri);
    return;
  }

  if (uri.scheme == 'mailto' || uri.scheme == 'tel') {
    await _launchExternal(uri);
    return;
  }

  if (uri.scheme == 'http' || uri.scheme == 'https') {
    final path = uri.path;
    if (path.isNotEmpty && path != '/') {
      if (!context.mounted) return;
      if (_openInAppPath(context, path, uri.queryParameters)) return;
    }
    await _launchExternal(uri);
    return;
  }

  await _launchExternal(uri);
}

String? _normalizeLink(String raw) {
  var link = raw.trim();
  if (link.isEmpty) return null;

  // `chat/abc` → `/chat/abc`
  if (!link.contains('://') &&
      !link.startsWith('/') &&
      _looksLikeRelativePath(link)) {
    link = '/$link';
  }

  return link;
}

bool _looksLikeRelativePath(String link) {
  if (link.contains(' ')) return false;
  return link.contains('/') ||
      link.startsWith('chat') ||
      link.startsWith('product') ||
      link.startsWith('seller') ||
      link.startsWith('store') ||
      link.startsWith('workshop') ||
      link.startsWith('service') ||
      link.startsWith('orders');
}

Uri? _parseUri(String link) {
  var uri = Uri.tryParse(link);
  if (uri != null) return uri;

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

void _openAutorinUri(BuildContext context, Uri uri) {
  final path = uri.path.isNotEmpty ? uri.path : '/${uri.host}';
  _openInAppPath(context, path, uri.queryParameters);
}

bool _openInAppPath(
  BuildContext context,
  String path,
  Map<String, String> query,
) {
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return false;

  final head = segments.first;
  final id = segments.length > 1 ? segments[1] : null;
  final subId = segments.length > 2 ? segments[2] : null;

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
      if (id != null) {
        context.push(RoutesName.productDetailScreen, extra: id);
        return true;
      }
      return false;
    case 'productDetailScreen':
      if (id != null) {
        context.push(RoutesName.productDetailScreen, extra: id);
        return true;
      }
      context.push(RoutesName.productDetailScreen);
      return true;
    case 'workshop':
    case 'workshopDetailScreen':
      if (id != null) {
        context.push('${RoutesName.workshopDetailScreen}/$id');
        return true;
      }
      return false;
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
      if (id != null) {
        context.push(RoutesName.sellerProfile, extra: id);
        return true;
      }
      return false;
    case 'store':
      if (id != null) {
        context.push(RoutesName.sellerProfile, extra: id);
        return true;
      }
      return false;
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
      if (path.startsWith('/')) {
        context.push(path);
        return true;
      }
      if (subId != null) {
        context.push('/$head/$id/$subId');
        return true;
      }
      return false;
  }
}
