import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/map/map_camera_animator.dart';
import 'package:my_auto/core/map/maptiler_config.dart';
import 'package:my_auto/core/map/user_location_service.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/map/bloc/map_discovery_bloc.dart';
import 'package:my_auto/features/map/data/map_discovery_repository.dart';
import 'package:my_auto/features/map/models/map_viewport_bounds.dart';
import 'package:my_auto/features/map/services/map_analytics.dart';
import 'package:my_auto/features/map/widgets/map_bottom_preview_card.dart';
import 'package:my_auto/features/map/widgets/map_cluster_widget.dart';
import 'package:my_auto/features/map/widgets/map_filter_chips.dart';
import 'package:my_auto/features/map/widgets/map_floating_actions.dart';
import 'package:my_auto/features/map/widgets/map_heatmap_layer.dart';
import 'package:my_auto/features/map/widgets/map_radius_selector.dart';
import 'package:my_auto/features/map/widgets/map_search_area_button.dart';
import 'package:my_auto/features/map/widgets/map_workshop_marker.dart';
import 'package:my_auto/features/map/widgets/map_workshop_mini_card.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:url_launcher/url_launcher.dart';

const double kMapDefaultZoom = 13.5;
const double kUserLocationZoom = 16;

/// Bottom list panel: fixed peek height; can only expand upward, not collapse below peek.
const double kMapSheetPeek = 0.34;
const double kMapSheetMax = 0.72;

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({super.key, this.embedded = false});

  /// True when shown as a bottom-nav tab (no back affordance).
  final bool embedded;

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  MapDiscoveryBloc? _bloc;
  LatLng? _userLocation;
  bool _locatingUser = false;
  bool _booting = true;

  late final AnimationController _sheetCtrl;
  late final AnimationController _cameraAnimCtrl;
  late final Animation<double> _sheetSlide;
  final DraggableScrollableController _listSheetCtrl =
      DraggableScrollableController();
  double _listSheetSize = kMapSheetPeek;

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(vsync: this, duration: AppMotion.base);
    _cameraAnimCtrl = AnimationController(vsync: this);
    _sheetSlide = CurvedAnimation(
      parent: _sheetCtrl,
      curve: AppMotion.standard,
      reverseCurve: Curves.easeInCubic,
    );
    _listSheetCtrl.addListener(_onListSheetSizeChanged);
    _bootstrap();
  }

  void _onListSheetSizeChanged() {
    if (!_listSheetCtrl.isAttached) return;
    var next = _listSheetCtrl.size;
    if (next < kMapSheetPeek - 0.01) {
      _listSheetCtrl.jumpTo(kMapSheetPeek);
      next = kMapSheetPeek;
    }
    if ((next - _listSheetSize).abs() < 0.001) return;
    setState(() => _listSheetSize = next);
  }

  Future<void> _snapListSheetToPeek() async {
    if (!_listSheetCtrl.isAttached) return;
    if (_listSheetCtrl.size >= kMapSheetPeek - 0.02) return;
    await _listSheetCtrl.animateTo(
      kMapSheetPeek,
      duration: AppMotion.base,
      curve: AppMotion.standard,
    );
  }

  Future<void> _bootstrap() async {
    final (result, point) = await UserLocationService.getCurrentLatLng();
    if (!mounted) return;
    final center = point ?? MapTilerConfig.defaultCenter;
    final user = point ?? center;
    setState(() {
      _userLocation = user;
    });
    final bloc = MapDiscoveryBloc(mapDiscoveryRepository);
    bloc.add(MapDiscoveryStarted(
      userLocation: user,
      initialMapCenter: center,
    ));
    if (!mounted) {
      await bloc.close();
      return;
    }
    setState(() {
      _bloc = bloc;
      _booting = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(
        center,
        point == null ? kMapDefaultZoom : kUserLocationZoom,
      );
    });
    if (result != UserLocationResult.success && point == null && mounted) {
      Toaster.error(S.of(context).mapLocationDefaultArea);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cameraAnimCtrl.dispose();
    _listSheetCtrl.removeListener(_onListSheetSizeChanged);
    _listSheetCtrl.dispose();
    _sheetCtrl.dispose();
    _bloc?.close();
    super.dispose();
  }

  Future<void> _goToMyLocation() async {
    if (_locatingUser || _bloc == null) return;
    setState(() => _locatingUser = true);
    final (result, point) = await UserLocationService.getCurrentLatLng();
    if (!mounted) return;
    if (result != UserLocationResult.success || point == null) {
      setState(() => _locatingUser = false);
      _showLocationError(result);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _userLocation = point;
      _locatingUser = false;
    });
    _bloc!.add(MapViewportUpdated(
      bounds: MapViewportBounds.fromCamera(_mapController.camera),
      center: point,
      markAreaStale: false,
    ));
    _mapController.move(point, kUserLocationZoom);
    await MapCameraAnimator.animateTo(
      controller: _mapController,
      anim: _cameraAnimCtrl,
      center: point,
      zoom: kUserLocationZoom,
    );
    _bloc!.add(const MapDiscoveryReload());
  }

  void _showLocationError(UserLocationResult result) {
    final message = switch (result) {
      UserLocationResult.serviceDisabled =>
        S.of(context).mapLocationGpsDisabled,
      UserLocationResult.permissionDenied =>
        S.of(context).mapLocationPermissionRequired,
      UserLocationResult.permissionDeniedForever =>
        S.of(context).mapLocationPermissionForever,
      UserLocationResult.failed => S.of(context).mapLocationFailed,
      UserLocationResult.success => '',
    };
    if (message.isEmpty) return;
    Toaster.error(message);
    if (result == UserLocationResult.permissionDeniedForever) {
      Geolocator.openAppSettings();
    }
  }

  void _openWorkshopFromSheet(MapDiscoveryBloc bloc, MapPin pin) {
    bloc.add(MapPinSelected(pin));
    _openPin(pin);
  }

  void _openPin(MapPin pin) {
    if (pin.kind == MapPinKind.workshop) {
      MapAnalytics.workshopView(workshopId: pin.id);
      context.push('${RoutesName.workshopDetailScreen}/${pin.id}');
    } else if (pin.kind == MapPinKind.service || pin.kind == MapPinKind.emergency) {
      context.push('${RoutesName.serviceDetail}/${pin.id}');
    } else if (pin.kind == MapPinKind.product) {
      context.push(RoutesName.productDetailScreen, extra: pin.id);
    } else {
      context.push('${RoutesName.orderDetail}/${pin.id}');
    }
  }

  void _openNavigation(MapPin pin) {
    MapAnalytics.openedRoute(entityType: pin.kind.name, entityId: pin.id);
    launchUrl(
      Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${pin.latitude},${pin.longitude}',
      ),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openMapControlsSheet(MapDiscoveryBloc bloc) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: systemBottomInset(sheetCtx) + 8,
            ),
            child: SingleChildScrollView(
              child: BlocBuilder<MapDiscoveryBloc, MapDiscoveryState>(
                builder: (_, state) {
                  final tc = Theme.of(sheetCtx);
                  final ac = sheetCtx.appColors;

                  int countKind(MapPinKind k) =>
                      state.pins.where((p) => p.kind == k).length;
                  final serviceCount = state.pins
                      .where(
                        (p) =>
                            p.kind == MapPinKind.service ||
                            p.kind == MapPinKind.emergency,
                      )
                      .length;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                        child: Text(
                          S.of(context).mapFiltersTitle,
                          style: tc.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SwitchListTile.adaptive(
                        title: Text(S.of(context).mapHeatmapTitle),
                        subtitle: Text(
                          S.of(context).mapHeatmapSubtitle,
                        ),
                        value: state.heatmapEnabled,
                        onChanged: (v) => bloc.add(MapHeatmapToggled(v)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          S.of(context).mapShownOnMap,
                          style: TextStyle(
                            color: ac.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SwitchListTile.adaptive(
                        title: Text(S.of(context).services),
                        subtitle: Text('$serviceCount on map'),
                        value: state.showServicesLayer,
                        onChanged: (_) => bloc.add(
                          MapLayerToggled(
                            services: !state.showServicesLayer,
                            workshops: state.showWorkshopsLayer,
                            products: state.showProductsLayer,
                            orders: state.showOrdersLayer,
                          ),
                        ),
                      ),
                      SwitchListTile.adaptive(
                        title: Text(S.of(context).mapLayerWorkshops),
                        subtitle: Text(
                          '${countKind(MapPinKind.workshop)} on map',
                        ),
                        value: state.showWorkshopsLayer,
                        onChanged: (_) => bloc.add(
                          MapLayerToggled(
                            services: state.showServicesLayer,
                            workshops: !state.showWorkshopsLayer,
                            products: state.showProductsLayer,
                            orders: state.showOrdersLayer,
                          ),
                        ),
                      ),
                      SwitchListTile.adaptive(
                        title: Text(S.of(context).parts),
                        subtitle: Text(
                          '${countKind(MapPinKind.product)} on map',
                        ),
                        value: state.showProductsLayer,
                        onChanged: (_) => bloc.add(
                          MapLayerToggled(
                            services: state.showServicesLayer,
                            workshops: state.showWorkshopsLayer,
                            products: !state.showProductsLayer,
                            orders: state.showOrdersLayer,
                          ),
                        ),
                      ),
                      SwitchListTile.adaptive(
                        title: Text(S.of(context).mapLayerRequests),
                        subtitle: Text(
                          '${countKind(MapPinKind.order)} on map',
                        ),
                        value: state.showOrdersLayer,
                        onChanged: (_) => bloc.add(
                          MapLayerToggled(
                            services: state.showServicesLayer,
                            workshops: state.showWorkshopsLayer,
                            products: state.showProductsLayer,
                            orders: !state.showOrdersLayer,
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                        child: Text(
                          'Quick filters',
                          style: TextStyle(
                            color: ac.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 44,
                        child: MapFilterChips(
                          colors: ac,
                          activeKeys: state.filters,
                          onChipToggle: (k) => bloc.add(MapFilterChipPressed(k)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _nearbyListChildren(
    MapDiscoveryBloc bloc,
    MapDiscoveryState state,
    LatLng? user,
    AppColors colors,
  ) {
    return [
      Text(
        'Recommended',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: colors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      ...state.recommendedWorkshopIds().map((id) {
        final p = state.pinForId(id);
        if (p == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MapWorkshopMiniCard(
            pin: p,
            workshop: state.workshopsById[id],
            colors: colors,
            highlight: true,
            onTap: () => _openWorkshopFromSheet(bloc, p),
          ),
        );
      }),
      const SizedBox(height: 12),
      Text(
        'All workshops',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: colors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      ...state.workshopPinsNearest(user ?? state.mapCenter).map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MapWorkshopMiniCard(
                pin: p,
                workshop: state.workshopsById[p.id],
                colors: colors,
                onTap: () => _openWorkshopFromSheet(bloc, p),
              ),
            ),
          ),
      if (state.trendingWorkshopIds().isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(
          'Trending',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...state.trendingWorkshopIds().map((id) {
          final p = state.pinForId(id);
          if (p == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MapWorkshopMiniCard(
              pin: p,
              workshop: state.workshopsById[id],
              colors: colors,
              onTap: () => _openWorkshopFromSheet(bloc, p),
            ),
          );
        }),
      ],
    ];
  }

  void _showRadiusSheet(MapDiscoveryBloc bloc, MapDiscoveryState state) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return MapRadiusSelector(
          colors: ctx.appColors,
          valueKm: state.radiusKm,
          onPick: (km) {
            bloc.add(MapRadiusChanged(km));
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = systemTopInset(context);
    final bottomPad = systemBottomInset(context);

    if (_booting || _bloc == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    return BlocProvider<MapDiscoveryBloc>.value(
      value: _bloc!,
      child: BlocConsumer<MapDiscoveryBloc, MapDiscoveryState>(
        listenWhen: (a, b) => a.selectedPin != b.selectedPin,
        listener: (context, state) {
          if (state.selectedPin != null) {
            _sheetCtrl.forward();
          } else {
            _sheetCtrl.reverse();
            _snapListSheetToPeek();
          }
        },
        builder: (context, state) {
          final bloc = context.read<MapDiscoveryBloc>();
          final user = _userLocation;
          final selected = state.selectedPin;

          return Scaffold(
            backgroundColor: colors.background,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final screenH = MediaQuery.sizeOf(context).height;
                final sheetPeekH = screenH * _listSheetSize;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: state.mapCenter,
                          initialZoom: kMapDefaultZoom,
                          minZoom: 5,
                          maxZoom: 18,
                          onTap: (_, __) {
                            bloc.add(const MapPinSelected(null));
                          },
                          onPositionChanged: (camera, hasGesture) {
                            bloc.add(MapViewportUpdated(
                              bounds: MapViewportBounds.fromCamera(camera),
                              center: camera.center,
                              markAreaStale: hasGesture,
                            ));
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: MapTilerConfig.tileUrl(isDark: isDark),
                            userAgentPackageName: 'garaj.uz',
                          ),
                          if (state.heatmapEnabled)
                            MapHeatmapLayer(
                              enabled: true,
                              colors: colors,
                              points: state.workshopPins
                                  .map(
                                    (p) => LatLng(p.latitude, p.longitude),
                                  )
                                  .toList(),
                            ),
                          if (user != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: user,
                                  width: 72,
                                  height: 72,
                                  alignment: Alignment.center,
                                  child: _UserLocationPulse(
                                    colors: colors,
                                    locating: _locatingUser,
                                  ),
                                ),
                              ],
                            ),
                          MarkerClusterLayerWidget(
                            options: MarkerClusterLayerOptions(
                              maxClusterRadius: 56,
                              size: const Size(48, 48),
                              alignment: Alignment.center,
                              markers: state.pins
                                  .map(
                                    (p) => Marker(
                                      point: LatLng(p.latitude, p.longitude),
                                      width: 52,
                                      height: 68,
                                      alignment: Alignment.topCenter,
                                      child: GestureDetector(
                                        onTap: () {
                                          MapAnalytics.markerTapped(
                                            entityType: p.kind.name,
                                            entityId: p.id,
                                          );
                                          bloc.add(MapPinSelected(p));
                                          MapCameraAnimator.animateTo(
                                            controller: _mapController,
                                            anim: _cameraAnimCtrl,
                                            center: LatLng(
                                              p.latitude,
                                              p.longitude,
                                            ),
                                            zoom: _mapController.camera.zoom
                                                .clamp(13, 16)
                                                .toDouble(),
                                          );
                                        },
                                        child: MapWorkshopMarker(
                                          pin: p,
                                          selected: selected?.id == p.id,
                                          colors: colors,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              builder: (context, markers) => MapClusterWidget(
                                count: markers.length,
                                colors: colors,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: topPad + 104,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colors.background
                                      .withValues(alpha: isDark ? 0.72 : 0.55),
                                  colors.background.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: topPad + 8,
                        left: AppSpacing.screenPadding,
                        right: AppSpacing.screenPadding,
                        child: _GlassBar(
                          child: Row(
                            children: [
                              if (!widget.embedded) ...[
                                _iconBtn(
                                  LucideIcons.arrowLeft,
                                  () => context.pop(),
                                  colors,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  textCapitalization: TextCapitalization.none,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search workshops, parts, services…',
                                    hintStyle: TextStyle(color: colors.textMuted),
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 10),
                                    prefixIcon: Icon(
                                      LucideIcons.search,
                                      color: colors.primary,
                                      size: 20,
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        _openMapControlsSheet(bloc);
                                      },
                                      borderRadius: AppRadius.rM,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Icon(
                                          LucideIcons.slidersHorizontal,
                                          color: colors.primary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    suffixIconConstraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                  ),
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (v) {
                                    bloc.add(MapSearchSubmitted(v));
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.areaStale && !state.loading)
                        Positioned(
                          top: topPad + 78,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: MapSearchAreaButton(
                              colors: colors,
                              busy: state.loading,
                              onPressed: () => bloc
                                  .add(const MapSearchThisAreaRequested()),
                            ),
                          ),
                        ),
                      Positioned(
                        right: AppSpacing.screenPadding,
                        bottom: bottomPad +
                            sheetPeekH +
                            (selected != null ? 210 : 16),
                        child: MapFloatingActions(
                          colors: colors,
                          onZoomIn: () {
                            MapCameraAnimator.animateZoomBy(
                              controller: _mapController,
                              anim: _cameraAnimCtrl,
                              delta: 1,
                            );
                          },
                          onZoomOut: () {
                            MapCameraAnimator.animateZoomBy(
                              controller: _mapController,
                              anim: _cameraAnimCtrl,
                              delta: -1,
                            );
                          },
                          onMyLocation: _goToMyLocation,
                          locating: _locatingUser,
                          onRadius: () => _showRadiusSheet(bloc, state),
                        ),
                      ),
                      if (state.initializing)
                        Positioned.fill(
                          child: Container(
                            color:
                                colors.background.withValues(alpha: 0.35),
                            child: const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                        ),
                      if (selected != null)
                        Positioned(
                          left: AppSpacing.screenPadding,
                          right: AppSpacing.screenPadding,
                          bottom: bottomPad + sheetPeekH + 10,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(_sheetSlide),
                            child: FadeTransition(
                              opacity: _sheetSlide,
                              child: MapBottomPreviewCard(
                                pin: selected,
                                workshop:
                                    state.workshopsById[selected.id],
                                colors: colors,
                                userLocation: user,
                                onClose: () {
                                  bloc.add(const MapPinSelected(null));
                                  _snapListSheetToPeek();
                                },
                                onOpen: () => _openPin(selected),
                                onNavigate: () => _openNavigation(selected),
                                onCall: () {
                                  MapAnalytics.callTap(
                                    entityType: selected.kind.name,
                                    entityId: selected.id,
                                  );
                                  launchPhone(selected.phone);
                                },
                                onShare: () {
                                  MapAnalytics.shareTap(
                                    entityType: selected.kind.name,
                                    entityId: selected.id,
                                  );
                                  sharePin(selected);
                                },
                              ),
                            ),
                          ),
                        ),
                    DraggableScrollableSheet(
                      controller: _listSheetCtrl,
                      minChildSize: kMapSheetPeek,
                      initialChildSize: kMapSheetPeek,
                      maxChildSize: kMapSheetMax,
                      snap: true,
                      snapSizes: const [kMapSheetPeek, kMapSheetMax],
                      snapAnimationDuration: AppMotion.base,
                      builder: (ctx, scrollController) {
                        return Material(
                          color: colors.surface,
                          elevation: 10,
                          shadowColor: Colors.black26,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    AppSpacing.screenPadding,
                                    4,
                                    AppSpacing.screenPadding,
                                    0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: colors.border
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Nearby',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (state.loading)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.primary,
                                      ),
                                    )
                                  else
                                    Text(
                                      '${state.pins.length}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  AppSpacing.screenPadding,
                                  0,
                                  AppSpacing.screenPadding,
                                  bottomPad + 24,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate(
                                    _nearbyListChildren(
                                      bloc,
                                      state,
                                      user,
                                      colors,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, AppColors colors) {
    return Material(
      color: colors.primary.withValues(alpha: 0.1),
      borderRadius: AppRadius.rM,
      child: InkWell(
        borderRadius: AppRadius.rM,
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: colors.primary),
        ),
      ),
    );
  }
}

class _GlassBar extends StatelessWidget {
  const _GlassBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark
                ? colors.surface.withValues(alpha: 0.78)
                : colors.surface.withValues(alpha: 0.88),
            border: Border.all(
              color: colors.border.withValues(alpha: isDark ? 0.25 : 0.45),
            ),
            boxShadow: AppShadows.floating(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _UserLocationPulse extends StatefulWidget {
  const _UserLocationPulse({required this.colors, required this.locating});

  final AppColors colors;
  final bool locating;

  @override
  State<_UserLocationPulse> createState() => _UserLocationPulseState();
}

class _UserLocationPulseState extends State<_UserLocationPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dot = Color(0xFF2F80ED);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final t = widget.locating ? _pulse.value : 0.35;
        final scale = 1.0 + t * 0.45;
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dot.withValues(alpha: (1.0 - t) * 0.35),
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x552F80ED),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 2,
              child: Icon(
                LucideIcons.navigation,
                size: 11,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
