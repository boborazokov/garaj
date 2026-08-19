import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists unified search queries for Recent / suggestions UI.
final class SearchHistoryStorage {
  SearchHistoryStorage._();

  static const _key = 'autorin_unified_search_history_v1';
  static const int maxItems = 12;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>? ?? [];
      return list.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> remember(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;
    final prefs = await SharedPreferences.getInstance();
    final prev = await load();
    final next = [
      trimmed,
      ...prev.where((e) => e.toLowerCase() != trimmed.toLowerCase()),
    ].take(maxItems).toList();
    await prefs.setString(_key, jsonEncode(next));
  }

  static Future<void> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final prev = await load();
    final next =
        prev.where((e) => e.toLowerCase() != query.toLowerCase()).toList();
    await prefs.setString(_key, jsonEncode(next));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
