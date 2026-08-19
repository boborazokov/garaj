import 'package:latlong2/latlong.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';

import 'map_geo.dart';

String? workshopPricePreview(WorkshopProfile w) {
  for (final s in w.servicePricing) {
    if (s.label.isEmpty) continue;
    if (s.priceFrom != null) {
      final c = s.currency ?? '';
      final p = s.priceFrom!.toStringAsFixed(
        s.priceFrom! == s.priceFrom!.truncateToDouble() ? 0 : 1,
      );
      return 'from ${r"$"}$p${c.isNotEmpty ? ' $c' : ''} · ${s.label}';
    }
    return s.label;
  }
  return null;
}

MapPin mapPinFromWorkshop(
  WorkshopProfile w, {
  LatLng? distanceFrom,
}) {
  final geo = w.geo;
  if (geo == null) {
    return MapPin(
      id: w.id,
      title: w.name,
      latitude: 0,
      longitude: 0,
      kind: MapPinKind.workshop,
      subtitle: w.displayAddress,
    );
  }

  double? km;
  if (distanceFrom != null) {
    km = haversineKm(distanceFrom, LatLng(geo.latitude, geo.longitude));
  }

  return MapPin(
    id: w.id,
    title: w.name,
    latitude: geo.latitude,
    longitude: geo.longitude,
    kind: MapPinKind.workshop,
    subtitle: w.displayAddress,
    coverImage: w.heroImage.isNotEmpty ? w.heroImage : null,
    pricePreview: workshopPricePreview(w),
    verified: w.verified,
    premium: w.premium,
    open24Hours: w.open24Hours,
    isEmergency: w.isEmergency,
    isOpenNow: w.isOpenNow,
    fastResponse: w.fastResponse,
    rating: w.rating,
    phone: w.phone.isNotEmpty ? w.phone : null,
    primaryCategorySlug:
        w.categories.isNotEmpty ? w.categories.first.slug : null,
    categoryNames: w.categories.map((c) => c.name).toList(),
    distanceKm: km,
  );
}
