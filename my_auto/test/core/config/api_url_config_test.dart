import 'package:flutter_test/flutter_test.dart';

/// Documents expected API URL shapes for local / emulator / device.
/// Real values come from dotenv at runtime (see `my_auto/.env.example`).
bool looksLikeLocalApiBase(String url) {
  final u = url.trim();
  if (u.isEmpty) return false;
  final uri = Uri.tryParse(u);
  if (uri == null || !uri.hasScheme) return false;
  if (uri.scheme != 'http' && uri.scheme != 'https') return false;
  return true;
}

bool isLanOrLoopbackHost(String url) {
  final host = Uri.tryParse(url)?.host ?? '';
  return host == '127.0.0.1' ||
      host == 'localhost' ||
      host == '10.0.2.2' ||
      host.startsWith('192.168.') ||
      host.startsWith('10.');
}

void main() {
  test('example local URLs are valid', () {
    expect(looksLikeLocalApiBase('http://127.0.0.1:7007'), isTrue);
    expect(looksLikeLocalApiBase('http://10.0.2.2:7007'), isTrue);
    expect(looksLikeLocalApiBase(''), isFalse);
    expect(looksLikeLocalApiBase('not-a-url'), isFalse);
  });

  test('loopback and emulator hosts are recognized', () {
    expect(isLanOrLoopbackHost('http://127.0.0.1:7007'), isTrue);
    expect(isLanOrLoopbackHost('http://10.0.2.2:7007'), isTrue);
  });
}
