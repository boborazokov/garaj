import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Normalized viewport for `workshopsMapDiscovery` bounds (matches backend MapBoundsInput).
class MapViewportBounds {
  const MapViewportBounds({
    required this.southWestLat,
    required this.southWestLng,
    required this.northEastLat,
    required this.northEastLng,
  });

  factory MapViewportBounds.fromCamera(MapCamera camera) {
    final b = camera.visibleBounds;
    return MapViewportBounds(
      southWestLat: b.southWest.latitude,
      southWestLng: b.southWest.longitude,
      northEastLat: b.northEast.latitude,
      northEastLng: b.northEast.longitude,
    );
  }

  final double southWestLat;
  final double southWestLng;
  final double northEastLat;
  final double northEastLng;

  LatLng get center => LatLng(
        (southWestLat + northEastLat) / 2,
        (southWestLng + northEastLng) / 2,
      );

  Map<String, dynamic> toGraphQLInput() => {
        'southWestLat': southWestLat,
        'southWestLng': southWestLng,
        'northEastLat': northEastLat,
        'northEastLng': northEastLng,
      };
}
