import 'package:flutter_test/flutter_test.dart';
import 'package:my_auto/core/auth/auth_session.dart';
import 'package:my_auto/core/model/user/index.dart';

void main() {
  group('AuthSession', () {
    test('fromJson supports legacy token field', () {
      final session = AuthSession.fromJson({
        'token': 'access-legacy',
        'user': {'phone': '+998', 'name': 'Test', '_id': 'abc'},
      });
      expect(session.accessToken, 'access-legacy');
    });

    test('fromJson supports production fields', () {
      final session = AuthSession.fromJson({
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'sessionId': 'sid',
        'tokenVersion': 2,
        'user': {'phone': '+998', 'name': 'Test', '_id': 'abc'},
      });
      expect(session.refreshToken, 'refresh');
      expect(session.tokenVersion, 2);
    });
  });

  group('AuthOutput', () {
    test('fromJson maps accessToken and legacy token', () {
      final out = AuthOutput.fromJson({
        'token': 'legacy',
        'user': {'phone': '1', 'name': 'n', '_id': 'id'},
      });
      expect(out.accessToken, 'legacy');
      expect(out.token, 'legacy');
    });
  });
}
