import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SQLCipher / drift encryption key — never log or persist in SharedPreferences.
class ChatDbKeyService {
  ChatDbKeyService._();

  static const _storage = FlutterSecureStorage();
  static const _keyName = 'chat_db_encryption_key_v1';

  static Future<List<int>> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) {
      return base64Decode(existing);
    }
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    await _storage.write(key: _keyName, value: base64Encode(bytes));
    return bytes;
  }

  static Future<void> destroyKey() async {
    await _storage.delete(key: _keyName);
  }
}
