import 'package:flutter/material.dart';
import 'package:my_auto/core/auth/auth_coordinator.dart';
import 'package:my_auto/core/auth/auth_token_store.dart';
import 'package:my_auto/core/model/user/index.dart';
import 'package:my_auto/core/services/graphql/graphql_links.dart';

typedef AuthSessionHook = Future<void> Function();

/// UI-facing auth notifier — delegates token lifecycle to [AuthCoordinator].
class AuthProvider extends ChangeNotifier {
  AuthOutput? _auth;
  AuthOutput? get auth => _auth;
  bool get isAuthenticated => AuthCoordinator.instance.isAuthenticated;
  bool get isGuest => !isAuthenticated;

  static AuthSessionHook? onSignedInHook;
  static AuthSessionHook? onSignedOutHook;

  Future<void> setAuth(AuthOutput authData) async {
    await AuthCoordinator.instance.establishFromAuthOutput(authData);
    _auth = authData;
    notifyListeners();
    await onSignedInHook?.call();
  }

  /// After [loadAuth] restores a session (e.g. splash), register FCM if hooks
  /// were not run yet.
  Future<void> notifySessionRestored() async {
    if (_auth == null) return;
    await onSignedInHook?.call();
  }

  void setUser(User user) {
    if (_auth == null) return;
    _auth = AuthOutput(
      accessToken: _auth!.accessToken,
      refreshToken: _auth!.refreshToken,
      sessionId: _auth!.sessionId,
      tokenVersion: _auth!.tokenVersion,
      user: user,
    );
    AuthCoordinator.instance.updateUser(user);
    notifyListeners();
  }

  Future<void> loadAuth() async {
    final ok = await AuthCoordinator.instance.bootstrap();
    _auth = ok ? AuthCoordinator.instance.session?.toAuthOutput() : null;
    if (!ok) await clearOrphanBearerIfGuest();
    notifyListeners();
  }

  Future<void> clearOrphanBearerIfGuest() async {
    if (isAuthenticated) return;
    await AuthTokenStore.clearOrphanBearer();
    GraphQLLinks.setMemoryAccessToken(null);
    await GraphQLLinks.refreshWebSocketAuth();
  }

  Future<bool> tryAutoLogin() async {
    await loadAuth();
    return isAuthenticated;
  }

  Future<void> revokeSession() async {
    await onSignedOutHook?.call();
    await AuthCoordinator.instance.clearSession();
    _auth = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await onSignedOutHook?.call();
    await AuthCoordinator.instance.logoutCurrentDevice();
    _auth = null;
    notifyListeners();
  }

  Future<void> logoutAllDevices() async {
    await onSignedOutHook?.call();
    await AuthCoordinator.instance.logoutAllDevices();
    _auth = null;
    notifyListeners();
  }
}
