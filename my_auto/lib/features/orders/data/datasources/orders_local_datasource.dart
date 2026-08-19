import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for favorites and "responded" order ids until
/// dedicated backend fields are wired for every user.
class OrdersLocalDataSource {
  static const _favoritesKey = 'orders_favorite_ids';
  static const _respondedKey = 'orders_responded_ids';

  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? [];
    return raw.toSet();
  }

  Future<void> saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids.toList());
  }

  Future<Set<String>> getRespondedOrderIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_respondedKey) ?? [];
    return raw.toSet();
  }

  Future<void> saveRespondedOrderIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_respondedKey, ids.toList());
  }

  Future<void> saveDraft(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('orders_create_draft', json);
  }

  Future<Map<String, dynamic>?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('orders_create_draft');
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orders_create_draft');
  }
}
