import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_auto/features/map/data/map_discovery_repository.dart';
import 'package:my_auto/features/map/domain/map_geo.dart';
import 'package:my_auto/features/map/models/map_viewport_bounds.dart';
import 'package:my_auto/features/map/services/map_analytics.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';

// ─── Filter chip keys → GraphQL WorkshopFiltersInput ───────────────────────

LinkedHashMap<String, dynamic>? filtersFromChipKeys(Set<String> chips) {
  final m = <String, dynamic>{};
  if (chips.contains('open_now')) m['openNow'] = true;
  if (chips.contains('verified')) m['verified'] = true;
  if (chips.contains('top_rated')) m['topRated'] = true;
  if (chips.contains('premium')) m['premium'] = true;
  if (chips.contains('emergency_only')) m['emergencyOnly'] = true;

  final services = <String>[];
  const serviceMap = {
    'svc_tires': 'tire',
    'svc_engine': 'engine',
    'svc_diagnostics': 'diagnostics',
    'svc_tuning': 'tuning',
    'svc_battery': 'battery',
    'svc_tow': 'tow',
    'svc_wash': 'wash',
    'svc_parts': 'parts-store',
  };
  for (final e in serviceMap.entries) {
    if (chips.contains(e.key)) services.add(e.value);
  }
  if (services.isNotEmpty) m['services'] = services;

  final brands = <String>[];
  const brandKeys = {
    'brand_bmw': 'BMW',
    'brand_mercedes': 'Mercedes',
    'brand_chevrolet': 'Chevrolet',
    'brand_toyota': 'Toyota',
    'brand_kia': 'Kia',
    'brand_hyundai': 'Hyundai',
  };
  for (final e in brandKeys.entries) {
    if (chips.contains(e.key)) brands.add(e.value);
  }
  if (brands.isNotEmpty) m['brands'] = brands;

  if (m.isEmpty) return null;
  final ordered = LinkedHashMap<String, dynamic>.from(m);
  return ordered;
}

// ─── Events ────────────────────────────────────────────────────────────────

sealed class MapDiscoveryEvent extends Equatable {
  const MapDiscoveryEvent();
  @override
  List<Object?> get props => [];
}

final class MapDiscoveryStarted extends MapDiscoveryEvent {
  const MapDiscoveryStarted({
    required this.userLocation,
    required this.initialMapCenter,
  });
  final LatLng userLocation;
  final LatLng initialMapCenter;
  @override
  List<Object?> get props => [userLocation, initialMapCenter];
}

final class MapViewportUpdated extends MapDiscoveryEvent {
  const MapViewportUpdated({
    required this.bounds,
    required this.center,
    this.markAreaStale = false,
  });
  final MapViewportBounds bounds;
  final LatLng center;
  /// True when the map moved due to user gesture (pan / pinch).
  final bool markAreaStale;

  @override
  List<Object?> get props => [bounds, center, markAreaStale];
}

final class MapSearchThisAreaRequested extends MapDiscoveryEvent {
  const MapSearchThisAreaRequested();
}

final class MapDiscoveryReload extends MapDiscoveryEvent {
  const MapDiscoveryReload({this.useBoundsOverride});
  /// When null, use last [MapDiscoveryState.shouldQueryBounds].
  final bool? useBoundsOverride;

  @override
  List<Object?> get props => [useBoundsOverride];
}

final class MapFilterChipPressed extends MapDiscoveryEvent {
  const MapFilterChipPressed(this.key);
  final String key;
  @override
  List<Object?> get props => [key];
}

final class MapRadiusChanged extends MapDiscoveryEvent {
  const MapRadiusChanged(this.radiusKm);
  final double radiusKm;
  @override
  List<Object?> get props => [radiusKm];
}

final class MapLayerToggled extends MapDiscoveryEvent {
  const MapLayerToggled({
    required this.services,
    required this.workshops,
    required this.products,
    required this.orders,
  });
  final bool services;
  final bool workshops;
  final bool products;
  final bool orders;
  @override
  List<Object?> get props => [services, workshops, products, orders];
}

final class MapPinSelected extends MapDiscoveryEvent {
  const MapPinSelected(this.pin);
  final MapPin? pin;
  @override
  List<Object?> get props => [pin];
}

final class MapSearchSubmitted extends MapDiscoveryEvent {
  const MapSearchSubmitted(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class MapHeatmapToggled extends MapDiscoveryEvent {
  const MapHeatmapToggled(this.enabled);
  final bool enabled;
  @override
  List<Object?> get props => [enabled];
}

// ─── State ─────────────────────────────────────────────────────────────────

final class MapDiscoveryState extends Equatable {
  const MapDiscoveryState({
    required this.userLocation,
    required this.mapCenter,
    this.viewportBounds,
    required this.radiusKm,
    required this.filters,
    this.showServicesLayer = true,
    this.showWorkshopsLayer = true,
    this.showProductsLayer = true,
    this.showOrdersLayer = true,
    required this.loading,
    this.initializing = false,
    this.areaStale = false,
    required this.shouldQueryBounds,
    this.pins = const [],
    this.workshopsById = const {},
    this.selectedPin,
    this.activeSearchQuery,
    this.heatmapEnabled = false,
  });

  factory MapDiscoveryState.initial(LatLng user, LatLng mapCenter) {
    return MapDiscoveryState(
      userLocation: user,
      mapCenter: mapCenter,
      radiusKm: 25,
      filters: LinkedHashSet<String>(),
      loading: true,
      initializing: true,
      shouldQueryBounds: false,
    );
  }

  final LatLng userLocation;
  final LatLng mapCenter;
  final MapViewportBounds? viewportBounds;
  final double radiusKm;
  final LinkedHashSet<String> filters;
  final bool showServicesLayer;
  final bool showWorkshopsLayer;
  final bool showProductsLayer;
  final bool showOrdersLayer;
  final bool loading;
  final bool initializing;
  final bool areaStale;
  /// When true and [viewportBounds] is set, call API with geographic bounds.
  final bool shouldQueryBounds;
  final List<MapPin> pins;
  final Map<String, WorkshopProfile> workshopsById;
  final MapPin? selectedPin;
  final String? activeSearchQuery;
  final bool heatmapEnabled;

  double get effectiveRadiusKm {
    var r = radiusKm;
    if (filters.contains('nearby')) {
      r = r.clamp(1, 5);
    }
    return r;
  }

  MapDiscoveryState copyWith({
    LatLng? userLocation,
    LatLng? mapCenter,
    MapViewportBounds? viewportBounds,
    double? radiusKm,
    LinkedHashSet<String>? filters,
    bool? showServicesLayer,
    bool? showWorkshopsLayer,
    bool? showProductsLayer,
    bool? showOrdersLayer,
    bool? loading,
    bool? initializing,
    bool? areaStale,
    bool? shouldQueryBounds,
    List<MapPin>? pins,
    Map<String, WorkshopProfile>? workshopsById,
    MapPin? selectedPin,
    String? activeSearchQuery,
    bool? heatmapEnabled,
    bool clearSelectedPin = false,
    bool clearSearch = false,
    bool clearViewport = false,
  }) {
    return MapDiscoveryState(
      userLocation: userLocation ?? this.userLocation,
      mapCenter: mapCenter ?? this.mapCenter,
      viewportBounds:
          clearViewport ? null : viewportBounds ?? this.viewportBounds,
      radiusKm: radiusKm ?? this.radiusKm,
      filters: filters ?? this.filters,
      showServicesLayer: showServicesLayer ?? this.showServicesLayer,
      showWorkshopsLayer: showWorkshopsLayer ?? this.showWorkshopsLayer,
      showProductsLayer: showProductsLayer ?? this.showProductsLayer,
      showOrdersLayer: showOrdersLayer ?? this.showOrdersLayer,
      loading: loading ?? this.loading,
      initializing: initializing ?? this.initializing,
      areaStale: areaStale ?? this.areaStale,
      shouldQueryBounds: shouldQueryBounds ?? this.shouldQueryBounds,
      pins: pins ?? this.pins,
      workshopsById: workshopsById ?? this.workshopsById,
      selectedPin:
          clearSelectedPin ? null : selectedPin ?? this.selectedPin,
      activeSearchQuery:
          clearSearch ? null : activeSearchQuery ?? this.activeSearchQuery,
      heatmapEnabled: heatmapEnabled ?? this.heatmapEnabled,
    );
  }

  @override
  List<Object?> get props => [
        userLocation,
        mapCenter,
        viewportBounds,
        radiusKm,
        filters,
        showServicesLayer,
        showWorkshopsLayer,
        showProductsLayer,
        showOrdersLayer,
        loading,
        initializing,
        areaStale,
        shouldQueryBounds,
        pins,
        workshopsById,
        selectedPin,
        activeSearchQuery,
        heatmapEnabled,
      ];

  Iterable<MapPin> get workshopPins =>
      pins.where((p) => p.kind == MapPinKind.workshop);


  Iterable<MapPin> workshopPinsNearest(LatLng from) {
    final sorted = [...workshopPins];
    sorted.sort((a, b) {
      final da = haversineKm(from, LatLng(a.latitude, a.longitude));
      final db = haversineKm(from, LatLng(b.latitude, b.longitude));
      return da.compareTo(db);
    });
    return sorted;
  }

  List<String> recommendedWorkshopIds() {
    final entries = [...workshopsById.entries];
    entries.sort((a, b) => b.value.rating.compareTo(a.value.rating));
    return entries.take(10).map((e) => e.key).toList();
  }

  List<String> trendingWorkshopIds() {
    final entries = [...workshopsById.entries];
    entries.sort((a, b) => b.value.reviewCount.compareTo(a.value.reviewCount));
    return entries.take(10).map((e) => e.key).toList();
  }

  MapPin? pinForId(String id) {
    try {
      return pins.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

class MapDiscoveryBloc extends Bloc<MapDiscoveryEvent, MapDiscoveryState> {
  MapDiscoveryBloc(this._repo)
      : super(
          MapDiscoveryState(
            userLocation: const LatLng(0, 0),
            mapCenter: const LatLng(0, 0),
            radiusKm: 25,
            filters: LinkedHashSet<String>(),
            loading: false,
            shouldQueryBounds: false,
          ),
        ) {
    on<MapDiscoveryStarted>(_onStarted);
    on<MapViewportUpdated>(_onViewportUpdated);
    on<MapSearchThisAreaRequested>(_onSearchArea);
    on<MapDiscoveryReload>(_onReload);
    on<MapFilterChipPressed>(_onFilterChip);
    on<MapRadiusChanged>(_onRadiusChanged);
    on<MapLayerToggled>(_onLayers);
    on<MapPinSelected>(_onPinSelected);
    on<MapSearchSubmitted>(_onSearch);
    on<MapHeatmapToggled>(_onHeatmap);
  }

  final MapDiscoveryRepository _repo;

  Future<void> _onStarted(
    MapDiscoveryStarted e,
    Emitter<MapDiscoveryState> emit,
  ) async {
    emit(
      MapDiscoveryState.initial(e.userLocation, e.initialMapCenter).copyWith(
        mapCenter: e.initialMapCenter,
        userLocation: e.userLocation,
      ),
    );
    await _loadDiscovery(
      emit,
      distanceFrom: e.userLocation,
      mapCenter: e.initialMapCenter,
      useBounds: false,
      clearSearch: true,
      filterFingerprint: {...state.filters},
    );
    emit(state.copyWith(initializing: false, loading: false, areaStale: false));
  }

  Future<void> _onViewportUpdated(
    MapViewportUpdated event,
    Emitter<MapDiscoveryState> emit,
  ) async {
    emit(
      state.copyWith(
        viewportBounds: event.bounds,
        mapCenter: event.center,
        areaStale: event.markAreaStale ? true : state.areaStale,
      ),
    );
  }

  Future<void> _onSearchArea(
    MapSearchThisAreaRequested event,
    Emitter<MapDiscoveryState> emit,
  ) async {
    if (state.viewportBounds == null) return;
    MapAnalytics.areaSearch();
    emit(state.copyWith(shouldQueryBounds: true));
    await _loadDiscovery(
      emit,
      distanceFrom: state.userLocation,
      mapCenter: state.viewportBounds!.center,
      useBounds: true,
      clearSearch: true,
      filterFingerprint: {...state.filters},
    );
    emit(state.copyWith(loading: false, areaStale: false));
  }

  Future<void> _onReload(
    MapDiscoveryReload event,
    Emitter<MapDiscoveryState> emit,
  ) async {
    if (state.activeSearchQuery != null && state.activeSearchQuery!.isNotEmpty) {
      await _onSearch(
        MapSearchSubmitted(state.activeSearchQuery!),
        emit,
      );
      return;
    }
    final ub = event.useBoundsOverride ?? state.shouldQueryBounds;
    final center = ub && state.viewportBounds != null
        ? state.viewportBounds!.center
        : state.mapCenter;
    await _loadDiscovery(
      emit,
      distanceFrom: state.userLocation,
      mapCenter: center,
      useBounds: ub && state.viewportBounds != null,
      filterFingerprint: {...state.filters},
    );
    emit(state.copyWith(loading: false, areaStale: false));
  }

  void _onFilterChip(
    MapFilterChipPressed event,
    Emitter<MapDiscoveryState> emit,
  ) {
    final next = LinkedHashSet<String>.from(state.filters);
    if (next.contains(event.key)) {
      next.remove(event.key);
    } else {
      next.add(event.key);
    }
    emit(state.copyWith(filters: next));
    add(const MapDiscoveryReload());
  }

  Future<void> _onRadiusChanged(
    MapRadiusChanged event,
    Emitter<MapDiscoveryState> emit,
  ) async {
    emit(state.copyWith(radiusKm: event.radiusKm));
    add(const MapDiscoveryReload());
  }

  void _onLayers(
    MapLayerToggled event,
    Emitter<MapDiscoveryState> emit,
  ) {
    emit(
      state.copyWith(
        showServicesLayer: event.services,
        showWorkshopsLayer: event.workshops,
        showProductsLayer: event.products,
        showOrdersLayer: event.orders,
      ),
    );
    add(const MapDiscoveryReload());
  }

  void _onPinSelected(
    MapPinSelected event,
    Emitter<MapDiscoveryState> emit,
  ) {
    emit(state.copyWith(selectedPin: event.pin, clearSelectedPin: event.pin == null));
  }

  Future<void> _onSearch(
    MapSearchSubmitted event,
    Emitter<MapDiscoveryState> emit,
  ) async {
    final q = event.query.trim();
    if (q.isEmpty) {
      emit(state.copyWith(clearSearch: true));
      add(const MapDiscoveryReload());
      return;
    }
    emit(state.copyWith(loading: true, activeSearchQuery: q));
    final res = await _repo.searchEntities(
      query: q,
      distanceFrom: state.userLocation,
    );
    if (res == null) {
      emit(state.copyWith(loading: false));
      return;
    }
    MapAnalytics.mapSearch(query: q, hits: res.pins.length);
    emit(
      state.copyWith(
        loading: false,
        pins: res.pins,
        workshopsById: res.workshopsById,
        areaStale: false,
        shouldQueryBounds: false,
      ),
    );
  }

  void _onHeatmap(
    MapHeatmapToggled event,
    Emitter<MapDiscoveryState> emit,
  ) {
    emit(state.copyWith(heatmapEnabled: event.enabled));
  }

  Future<void> _loadDiscovery(
    Emitter<MapDiscoveryState> emit, {
    required LatLng distanceFrom,
    required LatLng mapCenter,
    required bool useBounds,
    bool clearSearch = false,
    Set<String>? filterFingerprint,
  }) async {
    emit(
      state.copyWith(
        loading: true,
        clearSearch: clearSearch,
      ),
    );
    final fg = filterFingerprint ?? state.filters;
    final res = await _repo.loadViewport(
      mapCenter: mapCenter,
      distanceFrom: distanceFrom,
      radiusKm: state.effectiveRadiusKm,
      viewportBounds: state.viewportBounds,
      queryByBounds: useBounds,
      filters: filtersFromChipKeys(fg),
      showServices: state.showServicesLayer,
      showProducts: state.showProductsLayer,
      showOrders: state.showOrdersLayer,
      showWorkshops: state.showWorkshopsLayer,
    );

    emit(
      state.copyWith(
        pins: res.pins,
        workshopsById: res.workshopsById,
        mapCenter: mapCenter,
        loading: false,
      ),
    );
  }
}
