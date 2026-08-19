import 'package:my_auto/core/model/user/index.dart';

/// Persisted session — supports legacy `token` and production access/refresh pair.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshToken,
    this.sessionId,
    this.tokenVersion,
  });

  final String accessToken;
  final String? refreshToken;
  final String? sessionId;
  final int? tokenVersion;
  final User user;

  bool get canRefresh =>
      refreshToken != null && refreshToken!.trim().isNotEmpty;

  factory AuthSession.fromAuthOutput(AuthOutput output) => AuthSession(
        accessToken: output.accessToken,
        refreshToken: output.refreshToken,
        sessionId: output.sessionId,
        tokenVersion: output.tokenVersion,
        user: output.user,
      );

  AuthOutput toAuthOutput() => AuthOutput(
        accessToken: accessToken,
        refreshToken: refreshToken,
        sessionId: sessionId,
        tokenVersion: tokenVersion,
        user: user,
      );

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final access = (json['accessToken'] ?? json['token'] ?? '').toString();
    return AuthSession(
      accessToken: access,
      refreshToken: json['refreshToken'] as String?,
      sessionId: json['sessionId'] as String?,
      tokenVersion: (json['tokenVersion'] as num?)?.toInt(),
      user: json['user'] is Map
          ? User.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : User(phone: '', name: '', id: ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        if (refreshToken != null) 'refreshToken': refreshToken,
        if (sessionId != null) 'sessionId': sessionId,
        if (tokenVersion != null) 'tokenVersion': tokenVersion,
        'user': user.toJson(),
      };

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    String? sessionId,
    int? tokenVersion,
    User? user,
  }) =>
      AuthSession(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        sessionId: sessionId ?? this.sessionId,
        tokenVersion: tokenVersion ?? this.tokenVersion,
        user: user ?? this.user,
      );
}

enum AuthLifecycle {
  unknown,
  bootstrapping,
  authenticated,
  refreshing,
  unauthenticated,
}
