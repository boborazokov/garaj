import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized access to the support / admin user account.
///
/// The actual ObjectId of the admin user is provisioned on the backend and
/// passed to the client via `.env` as `ADMIN_USER_ID`. Kept in a separate
/// config so the rest of the app can ask `AdminConfig.isConfigured` without
/// caring about how the value is stored.
class AdminConfig {
  AdminConfig._();

  /// Backend-provisioned admin user id, or empty string when not configured.
  static String get userId {
    final raw = dotenv.env['ADMIN_USER_ID']?.trim() ?? '';
    return raw;
  }

  /// `true` when the env supplies a non-empty admin user id.
  static bool get isConfigured => userId.isNotEmpty;
}
