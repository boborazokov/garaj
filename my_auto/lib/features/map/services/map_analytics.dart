import 'package:flutter/foundation.dart';

/// Lightweight client-side map analytics (swap for Firebase / backend).
class MapAnalytics {
  static void markerTapped({
    required String entityType,
    required String entityId,
  }) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('map.marker_tap entity=$entityType id=$entityId');
    }
  }

  static void mapSearch({
    required String query,
    required int hits,
  }) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('map.search q="$query" hits=$hits');
    }
  }

  static void areaSearch() {
    if (kDebugMode) {
      // ignore: avoid_print
      print('map.area_search');
    }
  }

  static void openedRoute({
    required String entityType,
    required String entityId,
  }) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('map.route entity=$entityType id=$entityId');
    }
  }

  static void callTap({
    required String entityType,
    required String entityId,
  }) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('map.call entity=$entityType id=$entityId');
    }
  }

  static void shareTap({
    required String entityType,
    required String entityId,
  }) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('map.share entity=$entityType id=$entityId');
    }
  }

  static void workshopView({
    required String workshopId,
  }) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('map.workshop_view id=$workshopId');
    }
  }
}
