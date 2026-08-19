import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';

class DraftStorage {
  static const _draftKey = 'create_product_draft_v2';
  static const _recentVehiclesKey = 'create_product_recent_vehicles';

  Future<CreateProductDraft?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return CreateProductDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDraft(CreateProductDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _draftKey,
      jsonEncode(draft.copyWith(updatedAt: DateTime.now()).toJson()),
    );
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  Future<List<VehicleSelection>> loadRecentVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_recentVehiclesKey) ?? [];
    return raw
        .map((s) {
          try {
            return VehicleSelection.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<VehicleSelection>()
        .toList();
  }

  Future<void> pushRecentVehicle(VehicleSelection vehicle) async {
    if (vehicle.brandId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadRecentVehicles();
    final encoded = jsonEncode(vehicle.toJson());
    final list = [
      encoded,
      ...existing
          .map((v) => jsonEncode(v.toJson()))
          .where((e) => e != encoded),
    ].take(5).toList();
    await prefs.setStringList(_recentVehiclesKey, list);
  }
}
