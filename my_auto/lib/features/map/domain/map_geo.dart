import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Great-circle distance between two coordinates (km).
double haversineKm(LatLng a, LatLng b) {
  const r = 6371.0088;
  final dLat = _rad(b.latitude - a.latitude);
  final dLon = _rad(b.longitude - a.longitude);
  final lat1 = _rad(a.latitude);
  final lat2 = _rad(b.latitude);
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  return 2 * r * math.asin(math.sqrt(h.clamp(0, 1)));
}

double _rad(double deg) => deg * math.pi / 180;

/// Very rough drive ETA (urban mix); for lightweight UI preview only.
Duration roughDriveEta(double distanceKm) {
  const avgKmh = 32.0;
  final hours = distanceKm / avgKmh;
  return Duration(minutes: (hours * 60).round().clamp(1, 999));
}

String formatDistanceKm(double km) {
  if (km < 1) {
    return '${(km * 1000).round()} m';
  }
  return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
}
