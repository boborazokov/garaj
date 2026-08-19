import 'package:latlong2/latlong.dart';

/// Lightweight lat/lng value returned from the location picker.
class GeoLocation {
  const GeoLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  LatLng get latLng => LatLng(latitude, longitude);

  factory GeoLocation.fromLatLng(LatLng p) =>
      GeoLocation(latitude: p.latitude, longitude: p.longitude);
}
