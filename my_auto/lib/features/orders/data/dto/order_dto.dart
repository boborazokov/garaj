import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_author.dart';
import '../../domain/entities/order_category_ref.dart';

class OrderDto {
  OrderDto({
    required this.id,
    required this.title,
    required this.description,
    required this.phone,
    required this.budget,
    required this.status,
    required this.isPromoted,
    required this.createdAt,
    this.location,
    this.region,
    this.currency,
    this.author,
    this.brand,
    this.carModel,
    this.partCategory,
    this.images = const [],
    this.urgency,
    this.year,
    this.condition,
    this.viewsCount = 0,
    this.responseCount = 0,
  });

  final String id;
  final String title;
  final String description;
  final String phone;
  final String? location;
  final String? region;
  final int budget;
  final String? currency;
  final String status;
  final bool isPromoted;
  final DateTime createdAt;
  final OrderAuthor? author;
  final OrderCategoryRef? brand;
  final OrderCategoryRef? carModel;
  final OrderCategoryRef? partCategory;
  final List<String> images;
  final String? urgency;
  final int? year;
  final String? condition;
  final int viewsCount;
  final int responseCount;

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['_id'].toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      location: json['location']?.toString(),
      region: json['region']?.toString(),
      budget: _toInt(json['budget']),
      currency: json['currency']?.toString(),
      status: (json['status'] ?? 'ACTIVE').toString(),
      isPromoted: json['isPromoted'] == true,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      author: _author(json['author']),
      brand: _category(json['brand']),
      carModel: _category(json['carModel']),
      partCategory: _category(json['partCategory']),
      images: _normalizeImages(json['images']),
      urgency: json['urgency']?.toString(),
      year: _toIntOrNull(json['year']),
      condition: json['condition']?.toString(),
      viewsCount: _toInt(json['viewsCount']),
      responseCount: _toInt(json['responseCount']),
    );
  }

  Order toEntity({List<String> responderPreview = const []}) => Order(
        id: id,
        title: title,
        description: description,
        phone: phone,
        location: location,
        region: region,
        budget: budget,
        currency: currency,
        status: OrderStatusX.fromApi(status),
        isPromoted: isPromoted,
        createdAt: createdAt,
        author: author,
        brand: brand,
        carModel: carModel,
        partCategory: partCategory,
        images: images,
        urgency: OrderUrgencyX.fromApi(urgency?.trim().isEmpty == true ? null : urgency),
        year: year,
        condition: condition,
        viewsCount: viewsCount,
        responseCount: responseCount,
        responderPreview: responderPreview,
      );

  static OrderAuthor? _author(dynamic raw) {
    if (raw == null) return null;
    if (raw is! Map) return null;
    final id = raw['_id']?.toString();
    if (id == null || id.isEmpty) return null;
    return OrderAuthor(
      id: id,
      name: (raw['name'] ?? 'User').toString().trim().isEmpty
          ? 'User'
          : (raw['name'] ?? 'User').toString(),
      phone: raw['phone']?.toString(),
    );
  }

  static OrderCategoryRef? _category(dynamic raw) {
    if (raw is! Map) return null;
    return OrderCategoryRef(
      id: raw['_id'].toString(),
      name: (raw['name'] ?? '').toString(),
      iconUrl: raw['iconUrl']?.toString(),
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  static List<String> _normalizeImages(dynamic raw) {
    return _stringList(raw)
        .map((e) => normalizeStoragePath(e, mediaBase: fileUrl))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    final n = _toInt(v);
    return n == 0 && v != 0 ? null : n;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {}
    }
    return null;
  }
}
