import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_auto/core/auth/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure persistence for tokens and session metadata.
class AuthTokenStore {
  AuthTokenStore._();

  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'authToken';
  static const _refreshKey = 'authRefreshToken';
  static const _sessionKey = 'authSessionId';
  static const _deviceKey = 'authDeviceId';
  static const _prefsSessionKey = 'auth';

  static String? _memoryAccess;
  static String? _memoryRefresh;

  static String? get memoryAccess => _memoryAccess;
  static String? get memoryRefresh => _memoryRefresh;

  static Future<String> deviceId() async {
    final existing = await _storage.read(key: _deviceKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _generateDeviceId();
    await _storage.write(key: _deviceKey, value: id);
    return id;
  }

  static String _generateDeviceId() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Future<void> persistSession(AuthSession session) async {
    _memoryAccess = session.accessToken;
    _memoryRefresh = session.refreshToken;

    await _storage.write(key: _accessKey, value: session.accessToken);
    if (session.refreshToken != null) {
      await _storage.write(key: _refreshKey, value: session.refreshToken);
    } else {
      await _storage.delete(key: _refreshKey);
    }
    if (session.sessionId != null) {
      await _storage.write(key: _sessionKey, value: session.sessionId);
    } else {
      await _storage.delete(key: _sessionKey);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsSessionKey, jsonEncode(session.toJson()));
  }

  static Future<AuthSession?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsSessionKey);
    if (raw == null) return null;
    try {
      final session =
          AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (session.accessToken.isEmpty) return null;
      _memoryAccess = session.accessToken;
      _memoryRefresh = session.refreshToken;
      final storedAccess = await _storage.read(key: _accessKey);
      if (storedAccess != null && storedAccess.isNotEmpty) {
        _memoryAccess = storedAccess;
      }
      final storedRefresh = await _storage.read(key: _refreshKey);
      if (storedRefresh != null && storedRefresh.isNotEmpty) {
        _memoryRefresh = storedRefresh;
      }
      return session.copyWith(
        accessToken: _memoryAccess!,
        refreshToken: _memoryRefresh,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AuthTokenStore] corrupt session: $e\n$st');
      }
      return null;
    }
  }

  static Future<String?> readRefreshToken() async =>
      _memoryRefresh ?? await _storage.read(key: _refreshKey);

  static Future<String?> readSessionId() async =>
      await _storage.read(key: _sessionKey);

  static Future<void> clear({bool wipeDeviceId = false}) async {
    _memoryAccess = null;
    _memoryRefresh = null;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _sessionKey);
    if (wipeDeviceId) await _storage.delete(key: _deviceKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsSessionKey);
  }

  static Future<void> clearOrphanBearer() async {
    if (_memoryAccess != null) return;
    final bearer = await _storage.read(key: _accessKey);
    if (bearer == null || bearer.isEmpty) return;
    await _storage.delete(key: _accessKey);
  }
}
