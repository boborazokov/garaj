import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_auto/core/map/geo_location.dart';
import 'package:my_auto/core/map/map_camera_animator.dart';
import 'package:my_auto/core/map/maptiler_config.dart';
import 'package:my_auto/core/map/user_location_service.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/button/index.dart';
import 'package:geolocator/geolocator.dart';

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key, this.initialPoint});

  final GeoLocation? initialPoint;

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _cameraAnimCtrl;
  LatLng? _selected;
  LatLng? _userLocation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cameraAnimCtrl = AnimationController(vsync: this);
    if (widget.initialPoint != null) {
      _selected = widget.initialPoint!.latLng;
      _loading = false;
    } else {
      _determinePosition();
    }
  }

  Future<void> _determinePosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _selected = MapTilerConfig.defaultCenter;
        _loading = false;
      });
      return;
    }

    final (_, point) = await UserLocationService.getCurrentLatLng();
    setState(() {
      _userLocation = point;
      _selected = point ?? MapTilerConfig.defaultCenter;
      _loading = false;
    });
    _mapController.move(_selected!, MapTilerConfig.defaultZoom);
    await MapCameraAnimator.animateTo(
      controller: _mapController,
      anim: _cameraAnimCtrl,
      center: _selected!,
      zoom: MapTilerConfig.defaultZoom,
    );
  }

  @override
  void dispose() {
    _cameraAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _centerOnUser() async {
    final (_, point) = await UserLocationService.getCurrentLatLng();
    if (point == null || !mounted) return;
    setState(() {
      _userLocation = point;
      _selected = point;
    });
    _mapController.move(point, 16);
    await MapCameraAnimator.animateTo(
      controller: _mapController,
      anim: _cameraAnimCtrl,
      center: point,
      zoom: 16,
    );
  }

  void _zoomBy(double delta) {
    MapCameraAnimator.animateZoomBy(
      controller: _mapController,
      anim: _cameraAnimCtrl,
      delta: delta,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).chooseLocationOnMap),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnUser,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selected ?? MapTilerConfig.defaultCenter,
                    initialZoom: MapTilerConfig.defaultZoom,
                    onPositionChanged: (pos, _) {
                      setState(() => _selected = pos.center);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapTilerConfig.tileUrl(isDark: isDark),
                      userAgentPackageName: 'garaj.uz',
                    ),
                    if (_userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _userLocation!,
                            width: 24,
                            height: 24,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F80ED),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const Center(
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: bottomSafeOffset(context, 100),
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: () => _zoomBy(1),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () => _zoomBy(-1),
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: bottomSafeOffset(context, 16),
                  child: Button(
                    title: S.of(context).chooseLocation,
                    onTap: () {
                      if (_selected == null) return;
                      context.pop(GeoLocation.fromLatLng(_selected!));
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
