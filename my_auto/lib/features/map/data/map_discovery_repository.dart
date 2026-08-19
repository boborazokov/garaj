import 'package:latlong2/latlong.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/services/data/services_repository.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';

import '../domain/map_pin_factory.dart';
import '../models/map_viewport_bounds.dart';

/// Result of a viewport fetch: merged pins + workshop cache for rich UI.
class MapDiscoveryLoadResult {
  const MapDiscoveryLoadResult({
    required this.pins,
    required this.workshopsById,
  });

  final List<MapPin> pins;
  final Map<String, WorkshopProfile> workshopsById;
}

class MapDiscoveryRepository {
  MapDiscoveryRepository(
    this._workshops,
    this._services,
  );

  final WorkshopsRepository _workshops;
  final ServicesRepository _services;

  Future<MapDiscoveryLoadResult> loadViewport({
    required LatLng mapCenter,
    required LatLng distanceFrom,
    required double radiusKm,
    MapViewportBounds? viewportBounds,
    required bool queryByBounds,
    Map<String, dynamic>? filters,
    required bool showServices,
    required bool showProducts,
    required bool showOrders,
    required bool showWorkshops,
  }) async {
    final workshopsById = <String, WorkshopProfile>{};
    final pins = <MapPin>[];

    if (showWorkshops) {
      final lat = mapCenter.latitude;
      final lng = mapCenter.longitude;
      if (!lat.isFinite ||
          !lng.isFinite ||
          (lat == 0 && lng == 0)) {
        return MapDiscoveryLoadResult(
          pins: pins,
          workshopsById: workshopsById,
        );
      }
      var list = await _workshops.workshopsMapDiscovery(
        latitude: lat,
        longitude: lng,
        radiusKm: radiusKm,
        bounds: queryByBounds && viewportBounds != null
            ? viewportBounds.toGraphQLInput()
            : null,
        filters: filters,
      );
      if (list.isEmpty && !queryByBounds) {
        list = await _workshops.nearby(
          latitude: lat,
          longitude: lng,
          radiusKm: radiusKm < 80 ? 80 : radiusKm,
          limit: 120,
        );
      }
      if (list.isEmpty && !queryByBounds) {
        list = await _workshops.list(limit: 120);
      }
      for (final w in list) {
        if (!WorkshopsRepository.hasValidMapGeo(w.geo)) continue;
        workshopsById[w.id] = w;
        pins.add(mapPinFromWorkshop(w, distanceFrom: distanceFrom));
      }
    }

    if (showServices || showProducts || showOrders) {
      final extra = await _services.mapPins(
        latitude: mapCenter.latitude,
        longitude: mapCenter.longitude,
        showServices: showServices,
        showProducts: showProducts,
        showOrders: showOrders,
      );
      pins.addAll(extra);
    }

    return MapDiscoveryLoadResult(
      pins: pins,
      workshopsById: workshopsById,
    );
  }

  /// Build pins from global text search (coordinates may be sparse).
  Future<MapDiscoveryLoadResult?> searchEntities({
    required String query,
    required LatLng distanceFrom,
  }) async {
    final raw = await _workshops.rawSearchMapEntities(query: query);
    if (raw == null) return null;

    final workshopsById = <String, WorkshopProfile>{};
    final pins = <MapPin>[];

    final wl = raw['workshops'] as List? ?? [];
    for (final e in wl) {
      final w =
          WorkshopProfile.fromJson(Map<String, dynamic>.from(e as Map));
      if (!WorkshopsRepository.hasValidMapGeo(w.geo)) continue;
      workshopsById[w.id] = w;
      pins.add(mapPinFromWorkshop(w, distanceFrom: distanceFrom));
    }

    final sl = raw['services'] as List? ?? [];
    for (final e in sl) {
      final m = Map<String, dynamic>.from(e as Map);
      final geo = m['geoLocation'] as Map?;
      if (geo == null) continue;
      final cat = m['category'] as Map?;
      final isEmergency = m['isEmergency'] == true;
      final imgs = (m['images'] as List?)?.map((x) => x.toString()).toList() ?? [];
      pins.add(MapPin(
        id: m['_id'].toString(),
        title: (m['title'] ?? 'Service').toString(),
        latitude: (geo['latitude'] as num).toDouble(),
        longitude: (geo['longitude'] as num).toDouble(),
        kind: isEmergency ? MapPinKind.emergency : MapPinKind.service,
        subtitle: cat?['name']?.toString(),
        verified: m['verified'] == true,
        isEmergency: isEmergency,
        rating: (m['rating'] as num?)?.toDouble() ?? 0,
        coverImage: imgs.isNotEmpty ? imgs.first : null,
        primaryCategorySlug: cat?['slug']?.toString(),
      ));
    }

    final pl = raw['parts'] as List? ?? [];
    for (final e in pl) {
      final m = Map<String, dynamic>.from(e as Map);
      final geo = m['geoLocation'] as Map?;
      if (geo == null) continue;
      final imgs = (m['images'] as List?)?.map((x) => x.toString()).toList() ?? [];
      pins.add(MapPin(
        id: m['_id'].toString(),
        title: (m['name'] ?? 'Part').toString(),
        latitude: (geo['latitude'] as num).toDouble(),
        longitude: (geo['longitude'] as num).toDouble(),
        kind: MapPinKind.product,
        subtitle: '${m['price']} ${m['currency'] ?? ''}',
        coverImage: imgs.isNotEmpty ? imgs.first : null,
        pricePreview: m['price'] != null
            ? '${m['currency'] ?? ''} ${m['price']}'.trim()
            : null,
      ));
    }

    return MapDiscoveryLoadResult(
      pins: pins,
      workshopsById: workshopsById,
    );
  }
}

final mapDiscoveryRepository =
    MapDiscoveryRepository(workshopsRepository, servicesRepository);
