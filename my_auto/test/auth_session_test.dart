import 'package:flutter_test/flutter_test.dart';
import 'package:my_auto/core/auth/auth_session.dart';
import 'package:my_auto/core/model/user/index.dart';

void main() {
  test('session json keeps the refresh token', () {
    final session = AuthSession.fromJson({
      'token': 'access',
      'refreshToken': 'refresh',
      'sessionId': 'sid',
      'tokenVersion': 1,
      'user': {'_id': '1', 'phone': '+99890', 'name': 'A'},
    });

    expect(session.canRefresh, isTrue);
    expect(session.toJson()['refreshToken'], 'refresh');
    expect(session.toAuthOutput().refreshToken, 'refresh');
  });

  test('auth output reads accessToken or the legacy token field', () {
    final modern = AuthOutput.fromJson({
      'accessToken': 'new',
      'refreshToken': 'r',
      'user': {'_id': '1', 'phone': 'p', 'name': 'n'},
    });
    final legacy = AuthOutput.fromJson({
      'token': 'old',
      'user': {'_id': '1', 'phone': 'p', 'name': 'n'},
    });
    expect(modern.accessToken, 'new');
    expect(modern.refreshToken, 'r');
    expect(legacy.accessToken, 'old');
    expect(legacy.refreshToken, isNull);
  });
}
