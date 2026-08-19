import 'package:flutter/animation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_auto/core/theme/tokens.dart';

/// Smooth camera transitions for [MapController] (zoom & pan).
///
/// Pass a dedicated [AnimationController] from the owning [State]
/// (do not share with other widgets).
class MapCameraAnimator {
  MapCameraAnimator._();

  static Future<void> animateTo({
    required MapController controller,
    required AnimationController anim,
    required LatLng center,
    required double zoom,
    Duration duration = const Duration(milliseconds: 450),
    Curve curve = AppMotion.standard,
  }) async {
    final startCenter = controller.camera.center;
    final startZoom = controller.camera.zoom;
    if ((startCenter.latitude - center.latitude).abs() < 1e-6 &&
        (startCenter.longitude - center.longitude).abs() < 1e-6 &&
        (startZoom - zoom).abs() < 0.01) {
      return;
    }

    await _run(
      anim: anim,
      duration: duration,
      curve: curve,
      onTick: (t) {
        final lat = _lerp(startCenter.latitude, center.latitude, t);
        final lng = _lerp(startCenter.longitude, center.longitude, t);
        final z = _lerp(startZoom, zoom, t);
        controller.move(LatLng(lat, lng), z);
      },
    );
  }

  static Future<void> animateZoomTo({
    required MapController controller,
    required AnimationController anim,
    required double zoom,
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = AppMotion.standard,
  }) async {
    final clamped = zoom.clamp(5.0, 18.0);
    final center = controller.camera.center;
    final startZoom = controller.camera.zoom;
    if ((startZoom - clamped).abs() < 0.01) return;

    await _run(
      anim: anim,
      duration: duration,
      curve: curve,
      onTick: (t) {
        final z = _lerp(startZoom, clamped, t);
        controller.move(center, z);
      },
    );
  }

  static Future<void> animateZoomBy({
    required MapController controller,
    required AnimationController anim,
    required double delta,
  }) {
    return animateZoomTo(
      controller: controller,
      anim: anim,
      zoom: controller.camera.zoom + delta,
    );
  }

  static Future<void> _run({
    required AnimationController anim,
    required Duration duration,
    required Curve curve,
    required void Function(double t) onTick,
  }) async {
    anim
      ..stop()
      ..duration = duration
      ..reset();

    final curved = CurvedAnimation(parent: anim, curve: curve);

    void tick() => onTick(curved.value);

    curved.addListener(tick);
    try {
      await anim.forward();
    } finally {
      curved.removeListener(tick);
      curved.dispose();
    }
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
