import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

/// MapTiler raster tiles for [flutter_map].
class MapTilerConfig {
  MapTilerConfig._();

  static String get apiKey => dotenv.env['MAPTILER_API_KEY'] ?? '';

  static String get streetsTileUrl =>
      'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$apiKey';

  static String get darkTileUrl =>
      'https://api.maptiler.com/maps/streets-v2-dark/{z}/{x}/{y}.png?key=$apiKey';

  static String tileUrl({required bool isDark}) =>
      isDark ? darkTileUrl : streetsTileUrl;

  /// Default map center — Tashkent.
  static const LatLng defaultCenter = LatLng(41.2995, 69.2401);
  static const double defaultZoom = 12;
}
