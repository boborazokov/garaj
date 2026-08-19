import 'package:my_auto/core/map/geo_location.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/workshop/data/models/workshop_category.dart';

class WorkshopServicePrice {
  const WorkshopServicePrice({
    required this.label,
    this.categorySlug,
    this.priceFrom,
    this.priceTo,
    this.currency,
  });

  final String label;
  final String? categorySlug;
  final double? priceFrom;
  final double? priceTo;
  final String? currency;

  factory WorkshopServicePrice.fromJson(Map<String, dynamic> json) {
    return WorkshopServicePrice(
      label: json['label']?.toString() ?? '',
      categorySlug: json['categorySlug']?.toString(),
      priceFrom: (json['priceFrom'] as num?)?.toDouble(),
      priceTo: (json['priceTo'] as num?)?.toDouble(),
      currency: json['currency']?.toString(),
    );
  }
}

class WorkshopDaySchedule {
  const WorkshopDaySchedule({
    required this.day,
    required this.closed,
    this.openTime,
    this.closeTime,
  });

  final int day;
  final bool closed;
  final String? openTime;
  final String? closeTime;

  factory WorkshopDaySchedule.fromJson(Map<String, dynamic> json) {
    return WorkshopDaySchedule(
      day: (json['day'] as num?)?.toInt() ?? 0,
      closed: json['closed'] == true,
      openTime: json['openTime']?.toString(),
      closeTime: json['closeTime']?.toString(),
    );
  }
}

class WorkshopOwner {
  const WorkshopOwner({required this.id, this.name, this.phone});

  final String id;
  final String? name;
  final String? phone;

  factory WorkshopOwner.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WorkshopOwner(id: '');
    return WorkshopOwner(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

class WorkshopReview {
  const WorkshopReview({
    required this.id,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.images = const [],
    this.userId,
    this.userName,
    this.ownerReplyText,
    this.ownerReplyAt,
  });

  final String id;
  final double rating;
  final String text;
  final DateTime createdAt;
  final List<String> images;
  final String? userId;
  final String? userName;
  final String? ownerReplyText;
  final DateTime? ownerReplyAt;

  factory WorkshopReview.fromJson(Map<String, dynamic> json) {
    final reply = json['ownerReply'] as Map?;
    final user = json['user'] as Map?;
    return WorkshopReview(
      id: json['_id']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      text: json['text']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      userId: user?['_id']?.toString(),
      userName: user?['name']?.toString(),
      ownerReplyText: reply?['text']?.toString(),
      ownerReplyAt: DateTime.tryParse(reply?['repliedAt']?.toString() ?? ''),
    );
  }
}

class PaginatedWorkshopReviewsPage {
  const PaginatedWorkshopReviewsPage({
    required this.items,
    required this.hasNextPage,
    required this.page,
    required this.totalDocs,
  });

  final List<WorkshopReview> items;
  final bool hasNextPage;
  final int page;
  final int totalDocs;
}

class WorkshopProfile {
  const WorkshopProfile({
    required this.id,
    required this.name,
    this.description = '',
    this.address = '',
    this.city = '',
    this.location = '',
    this.coverImage = '',
    this.logo = '',
    this.gallery = const [],
    this.phone = '',
    this.telegram = '',
    this.verified = false,
    this.premium = false,
    this.isPromoted = false,
    this.promotedUntil,
    this.promotionPlan,
    this.promotionPriority = 0,
    this.hasPickupService = false,
    this.open24Hours = false,
    this.isEmergency = false,
    this.supportedCarBrands = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.fastResponse = false,
    this.responseTimeMinutes,
    this.serviceRadiusKm = 15,
    this.isOpenNow = false,
    this.geo,
    this.categories = const [],
    this.servicePricing = const [],
    this.weeklySchedule = const [],
    this.owner = const WorkshopOwner(id: ''),
    this.openFrom,
    this.openUntil,
  });

  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String location;
  final String coverImage;
  final String logo;
  final List<String> gallery;
  final String phone;
  final String telegram;
  final bool verified;
  final bool premium;
  final bool isPromoted;
  final DateTime? promotedUntil;
  final String? promotionPlan;
  final int promotionPriority;
  final bool hasPickupService;
  final bool open24Hours;
  final bool isEmergency;
  final List<String> supportedCarBrands;
  final double rating;
  final int reviewCount;
  final bool fastResponse;
  final int? responseTimeMinutes;
  final double serviceRadiusKm;
  final bool isOpenNow;
  final GeoLocation? geo;
  final List<WorkshopCategory> categories;
  final List<WorkshopServicePrice> servicePricing;
  final List<WorkshopDaySchedule> weeklySchedule;
  final WorkshopOwner owner;
  final DateTime? openFrom;
  final DateTime? openUntil;

  String get heroImage {
    if (coverImage.isNotEmpty) return coverImage;
    if (gallery.isNotEmpty) return gallery.first;
    return '';
  }

  List<String> get allImages {
    final seen = <String>{};
    final out = <String>[];
    for (final u in [coverImage, ...gallery]) {
      if (u.isNotEmpty && seen.add(u)) out.add(u);
    }
    return out;
  }

  String get displayAddress {
    if (address.isNotEmpty) return address;
    if (city.isNotEmpty) return city;
    return location;
  }

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

  static bool scheduleLooks24x7(List<WorkshopDaySchedule> schedule) {
    if (schedule.length < 7) return false;
    for (final d in schedule) {
      if (d.closed) return false;
      if (d.openTime != '00:00') return false;
      final close = d.closeTime;
      if (close != '23:59' && close != '24:00') return false;
    }
    return true;
  }

  factory WorkshopProfile.fromJson(Map<String, dynamic> json) {
    final geoRaw = json['geoLocation'] as Map?;
    final weeklySchedule = (json['weeklySchedule'] as List?)
            ?.map((e) => WorkshopDaySchedule.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList() ??
        const [];
    return WorkshopProfile(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      coverImage: _normImage(json['coverImage']?.toString() ?? ''),
      logo: _normImage(json['logo']?.toString() ?? ''),
      gallery: _imageList(json['gallery'] ?? json['images']),
      phone: json['phone']?.toString() ?? '',
      telegram: json['telegram']?.toString() ?? '',
      verified: json['verified'] == true,
      premium: json['premium'] == true,
      isPromoted: json['isPromoted'] == true,
      promotedUntil: DateTime.tryParse(json['promotedUntil']?.toString() ?? ''),
      promotionPlan: json['promotionPlan']?.toString(),
      promotionPriority: (json['promotionPriority'] as num?)?.toInt() ?? 0,
      hasPickupService: json['hasPickupService'] == true,
      open24Hours:
          json['open24Hours'] == true || scheduleLooks24x7(weeklySchedule),
      isEmergency: json['isEmergency'] == true,
      supportedCarBrands: (json['supportedCarBrands'] as List?)
              ?.map((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      fastResponse: json['fastResponse'] == true,
      responseTimeMinutes: (json['responseTimeMinutes'] as num?)?.toInt(),
      serviceRadiusKm: (json['serviceRadiusKm'] as num?)?.toDouble() ?? 15,
      isOpenNow: json['isOpenNow'] == true,
      geo: geoRaw != null
          ? GeoLocation(
              latitude: (geoRaw['latitude'] as num).toDouble(),
              longitude: (geoRaw['longitude'] as num).toDouble(),
            )
          : null,
      categories: (json['categories'] as List?)
              ?.map((e) => WorkshopCategory.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList() ??
          const [],
      servicePricing: (json['servicePricing'] as List?)
              ?.map((e) => WorkshopServicePrice.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList() ??
          const [],
      weeklySchedule: weeklySchedule,
      owner: WorkshopOwner.fromJson(
        json['owner'] != null
            ? Map<String, dynamic>.from(json['owner'] as Map)
            : null,
      ),
      openFrom: DateTime.tryParse(json['openFrom']?.toString() ?? ''),
      openUntil: DateTime.tryParse(json['openUntil']?.toString() ?? ''),
    );
  }

  static String _normImage(String path) {
    if (path.isEmpty) return '';
    return normalizeStoragePath(path, mediaBase: fileUrl);
  }

  static List<String> _imageList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => _normImage(e.toString()))
        .where((u) => u.isNotEmpty)
        .toList();
  }
}
