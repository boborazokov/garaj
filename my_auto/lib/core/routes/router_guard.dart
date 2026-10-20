import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/auth/pending_action_manager.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';

/// Route-level guest / auth redirect rules for [GoRouter].
class RouterGuard {
  RouterGuard(this._auth);

  final AuthProvider _auth;

  static const _protectedExact = {
    RoutesName.editProfile,
    RoutesName.myProducts,
    RoutesName.myOrders,
    RoutesName.myServices,
    RoutesName.addProduct,
    RoutesName.uploadImage,
    RoutesName.createOrder,
    RoutesName.service,
    RoutesName.createWorkshop,
    RoutesName.editWorkshop,
    RoutesName.map,
    RoutesName.chats,
    RoutesName.inbox,
    RoutesName.notifications,
    RoutesName.storeAnalytics,
  };

  static const _publicAuthRoutes = {
    RoutesName.splash,
    RoutesName.signin,
    RoutesName.signup,
    RoutesName.resetPassword,
    RoutesName.confirmation,
  };

  bool _isAuthenticated() => _auth.auth != null;

  bool _isProtected(String location) {
    if (_publicAuthRoutes.contains(location)) return false;
    if (_protectedExact.contains(location)) return true;
    if (location.startsWith('${RoutesName.chatDetail}/') &&
        location != RoutesName.chats) {
      return true;
    }
    if (location.startsWith('${RoutesName.editWorkshop}/')) {
      return true;
    }
    return false;
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    final authed = _isAuthenticated();

    if (authed &&
        (location == RoutesName.signin || location == RoutesName.signup)) {
      return RoutesName.buttonNavigationBar;
    }

    if (!authed && _isProtected(location)) {
      PendingActionManager.instance.set(
        PendingRoute(path: location, extra: state.extra),
      );
      return RoutesName.signin;
    }

    return null;
  }
}
