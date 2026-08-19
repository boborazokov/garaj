import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';

List<String> _parseImages(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .map((e) => normalizeStoragePath(e.toString(), mediaBase: fileUrl))
      .where((s) => s.isNotEmpty)
      .toList();
}

/// Paid boost tiers — must match backend `ServicePromotionPlanEnum`.
enum ServicePromotionPlan {
  basic('BASIC', 1),
  standard('STANDARD', 2),
  premium('PREMIUM', 3),
  vip('VIP', 4);

  const ServicePromotionPlan(this.api, this.weight);
  final String api;
  final int weight;
}

class ServiceListing {
  ServiceListing({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.verified,
    required this.isEmergency,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.features,
    required this.categoryName,
    this.categorySlug,
    this.phone,
    this.ownerName,
    this.ownerId,
    this.isPromoted = false,
    this.promotedUntil,
    this.promotionPlan,
    this.promotionPriority = 0,
  });

  final String id;
  final String title;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final bool verified;
  final bool isEmergency;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> features;
  final String categoryName;
  final String? categorySlug;
  final String? phone;
  final String? ownerName;
  final String? ownerId;
  final bool isPromoted;
  final DateTime? promotedUntil;
  final String? promotionPlan;
  final int promotionPriority;

  bool get isPromotionActive {
    if (!isPromoted) return false;
    final until = promotedUntil;
    if (until == null) return false;
    return until.isAfter(DateTime.now());
  }

  int get effectivePromotionWeight {
    if (!isPromotionActive) return 0;
    if (promotionPriority > 0) return promotionPriority;
    final plan = promotionPlan;
    if (plan == null) return 1;
    for (final p in ServicePromotionPlan.values) {
      if (p.api == plan) return p.weight;
    }
    return 1;
  }

  factory ServiceListing.fromJson(Map<String, dynamic> json) {
    final geo = json['geoLocation'] as Map?;
    DateTime? promotedUntil;
    final rawUntil = json['promotedUntil']?.toString();
    if (rawUntil != null && rawUntil.isNotEmpty) {
      promotedUntil = DateTime.tryParse(rawUntil);
    }
    return ServiceListing(
      id: json['_id'].toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: (geo?['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (geo?['longitude'] as num?)?.toDouble() ?? 0,
      verified: json['verified'] == true,
      isEmergency: json['isEmergency'] == true,
      isPromoted: json['isPromoted'] == true,
      promotedUntil: promotedUntil,
      promotionPlan: json['promotionPlan']?.toString(),
      promotionPriority: (json['promotionPriority'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      images: _parseImages(json['images']),
      features: (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      categoryName: (json['category'] as Map?)?['name']?.toString() ?? '',
      categorySlug: (json['category'] as Map?)?['slug']?.toString(),
      phone: json['phone']?.toString(),
      ownerName: (json['owner'] as Map?)?['name']?.toString(),
      ownerId: (json['owner'] as Map?)?['_id']?.toString(),
    );
  }
}

/// Promoted (paid) services first, then by plan weight, then organic order.
List<ServiceListing> sortServicesByPromotion(Iterable<ServiceListing> items) {
  final list = items.toList(growable: true);
  list.sort((a, b) {
    final boost = b.effectivePromotionWeight - a.effectivePromotionWeight;
    if (boost != 0) return boost;
    final rating = b.rating.compareTo(a.rating);
    if (rating != 0) return rating;
    return b.reviewCount.compareTo(a.reviewCount);
  });
  return list;
}

class MapPin {
  MapPin({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.kind,
    this.subtitle,
    this.coverImage,
    this.pricePreview,
    this.verified = false,
    this.premium = false,
    this.open24Hours = false,
    this.isEmergency = false,
    this.isOpenNow = false,
    this.fastResponse = false,
    this.rating = 0,
    this.phone,
    this.primaryCategorySlug,
    this.categoryNames = const [],
    this.distanceKm,
  });

  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final MapPinKind kind;
  final String? subtitle;
  /// Hero image for preview cards (workshops / some services).
  final String? coverImage;
  /// Short price line e.g. "from \$25" or workshop offer.
  final String? pricePreview;
  final bool verified;
  final bool premium;
  final bool open24Hours;
  final bool isEmergency;
  final bool isOpenNow;
  final bool fastResponse;
  final double rating;
  final String? phone;
  final String? primaryCategorySlug;
  final List<String> categoryNames;
  final double? distanceKm;

  MapPin copyWith({
    String? id,
    String? title,
    double? latitude,
    double? longitude,
    MapPinKind? kind,
    String? subtitle,
    String? coverImage,
    String? pricePreview,
    bool? verified,
    bool? premium,
    bool? open24Hours,
    bool? isEmergency,
    bool? isOpenNow,
    bool? fastResponse,
    double? rating,
    String? phone,
    String? primaryCategorySlug,
    List<String>? categoryNames,
    double? distanceKm,
  }) {
    return MapPin(
      id: id ?? this.id,
      title: title ?? this.title,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      kind: kind ?? this.kind,
      subtitle: subtitle ?? this.subtitle,
      coverImage: coverImage ?? this.coverImage,
      pricePreview: pricePreview ?? this.pricePreview,
      verified: verified ?? this.verified,
      premium: premium ?? this.premium,
      open24Hours: open24Hours ?? this.open24Hours,
      isEmergency: isEmergency ?? this.isEmergency,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      fastResponse: fastResponse ?? this.fastResponse,
      rating: rating ?? this.rating,
      phone: phone ?? this.phone,
      primaryCategorySlug: primaryCategorySlug ?? this.primaryCategorySlug,
      categoryNames: categoryNames ?? this.categoryNames,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

enum MapPinKind { service, product, order, emergency, workshop }
