import 'package:flutter/foundation.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/orders/domain/entities/order.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';

/// Lightweight hit for unified search UI (subset of GraphQL payloads).
@immutable
class UnifiedServiceHit {
  const UnifiedServiceHit({
    required this.id,
    required this.title,
    this.rating,
    this.verified = false,
    this.isEmergency = false,
    this.categoryName,
    this.latitude,
    this.longitude,
    this.coverImage,
  });

  final String id;
  final String title;
  final double? rating;
  final bool verified;
  final bool isEmergency;
  final String? categoryName;
  final double? latitude;
  final double? longitude;
  final String? coverImage;
}

@immutable
class UnifiedSellerHit {
  const UnifiedSellerHit({
    required this.id,
    required this.name,
    this.image,
    this.phone,
    this.productsInSearch = 1,
  });

  final String id;
  final String name;
  final String? image;
  final String? phone;

  /// How many listings from this seller appear in current product hits.
  final int productsInSearch;
}

/// Cross-entity result bag for unified discovery search.
@immutable
class UnifiedSearchSnapshot {
  const UnifiedSearchSnapshot({
    required this.query,
    required this.products,
    required this.workshops,
    required this.orders,
    required this.services,
    required this.sellers,
    this.processingMs,
  });

  final String query;
  final List<Part> products;
  final List<WorkshopProfile> workshops;
  final List<Order> orders;
  final List<UnifiedServiceHit> services;
  final List<UnifiedSellerHit> sellers;
  final int? processingMs;

  bool get hasAnyHits =>
      products.isNotEmpty ||
      workshops.isNotEmpty ||
      orders.isNotEmpty ||
      services.isNotEmpty ||
      sellers.isNotEmpty;

  static UnifiedSearchSnapshot empty(String q) =>
      UnifiedSearchSnapshot(
        query: q,
        products: const [],
        workshops: const [],
        orders: const [],
        services: const [],
        sellers: const [],
      );
}
