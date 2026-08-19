import 'package:flutter/foundation.dart';

/// Structured logging — wire to Sentry/Crashlytics in production builds.
abstract final class AppLogger {
  static void auth(String message, {Map<String, Object?>? fields}) {
    _log('auth', message, fields);
  }

  static void websocket(String message, {Map<String, Object?>? fields}) {
    _log('ws', message, fields);
  }

  static void security(String message, {Map<String, Object?>? fields}) {
    _log('security', message, fields);
  }

  static void _log(String channel, String message, Map<String, Object?>? fields) {
    if (kReleaseMode) {
      // TODO: Sentry.captureMessage with scope tags
      return;
    }
    final extra = fields == null || fields.isEmpty
        ? ''
        : ' ${fields.entries.map((e) => '${e.key}=${e.value}').join(' ')}';
    debugPrint('[$channel] $message$extra');
  }

  /// Never pass tokens, OTP, or passwords.
  static Map<String, Object?> safe({String? userId, String? sessionId}) => {
        if (userId != null) 'userId': userId,
        if (sessionId != null) 'sessionId': sessionId,
      };
}
