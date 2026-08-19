import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum UserLocationResult {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  failed,
}

class UserLocationService {
  UserLocationService._();

  static Future<(UserLocationResult, LatLng?)> getCurrentLatLng() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return (UserLocationResult.serviceDisabled, null);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return (UserLocationResult.permissionDenied, null);
    }
    if (permission == LocationPermission.deniedForever) {
      return (UserLocationResult.permissionDeniedForever, null);
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return (
        UserLocationResult.success,
        LatLng(pos.latitude, pos.longitude),
      );
    } catch (_) {
      return (UserLocationResult.failed, null);
    }
  }
}
