import 'package:equatable/equatable.dart';

import 'order_author.dart';
import 'order_category_ref.dart';

enum OrderStatus { active, closed, cancelled }

enum OrderUrgency { low, medium, urgent }

enum OrderDisplayStatus { open, inProgress, closed }

extension OrderStatusX on OrderStatus {
  String toApi() {
    switch (this) {
      case OrderStatus.active:
        return 'ACTIVE';
      case OrderStatus.closed:
        return 'CLOSED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static OrderStatus fromApi(String? v) {
    switch ((v ?? '').toUpperCase()) {
      case 'CLOSED':
        return OrderStatus.closed;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.active;
    }
  }
}

extension OrderUrgencyX on OrderUrgency {
  String toApi() {
    switch (this) {
      case OrderUrgency.low:
        return 'LOW';
      case OrderUrgency.medium:
        return 'MEDIUM';
      case OrderUrgency.urgent:
        return 'URGENT';
    }
  }

  static OrderUrgency? fromApi(String? v) {
    switch ((v ?? '').trim().toUpperCase()) {
      case 'URGENT':
        return OrderUrgency.urgent;
      case 'MEDIUM':
        return OrderUrgency.medium;
      case 'LOW':
        return OrderUrgency.low;
      default:
        return null;
    }
  }
}

class Order extends Equatable {
  const Order({
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
    this.newResponsesCount = 0,
    this.responderPreview = const [],
  });

  final String id;
  final String title;
  final String description;
  final String phone;
  final String? location;
  final String? region;
  final int budget;
  final String? currency;
  final OrderStatus status;
  final bool isPromoted;
  final DateTime createdAt;
  final OrderAuthor? author;
  final OrderCategoryRef? brand;
  final OrderCategoryRef? carModel;
  final OrderCategoryRef? partCategory;
  final List<String> images;
  final OrderUrgency? urgency;
  final int? year;
  final String? condition;
  final int viewsCount;
  final int responseCount;
  final int newResponsesCount;
  final List<String> responderPreview;

  String? get primaryImageUrl => images.isNotEmpty ? images.first : null;

  String get vehicleLabel {
    final parts = <String>[
      if (_meaningfulName(brand?.name)) brand!.name,
      if (_meaningfulName(carModel?.name)) carModel!.name,
      if (year != null) year.toString(),
    ];
    return parts.join(' · ');
  }

  static bool _meaningfulName(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return false;
    if (RegExp(r'^[-–—._\s]+$').hasMatch(t)) return false;
    return true;
  }

  /// Part + vehicle context for the buyer request (not seller listings).
  String get requestContextLabel {
    final parts = <String>[
      if (partCategory?.name.isNotEmpty == true) partCategory!.name,
      if (brand?.name.isNotEmpty == true) brand!.name,
      if (carModel?.name.isNotEmpty == true) carModel!.name,
      if (year != null) year.toString(),
    ];
    return parts.join(' · ');
  }

  OrderDisplayStatus get displayStatus {
    if (status == OrderStatus.closed) return OrderDisplayStatus.closed;
    if (responseCount > 0) return OrderDisplayStatus.inProgress;
    return OrderDisplayStatus.open;
  }

  bool get isOpen => status == OrderStatus.active;

  Order copyWith({
    int? responseCount,
    int? newResponsesCount,
    int? viewsCount,
    OrderStatus? status,
    List<String>? responderPreview,
  }) {
    return Order(
      id: id,
      title: title,
      description: description,
      phone: phone,
      budget: budget,
      status: status ?? this.status,
      isPromoted: isPromoted,
      createdAt: createdAt,
      location: location,
      region: region,
      currency: currency,
      author: author,
      brand: brand,
      carModel: carModel,
      partCategory: partCategory,
      images: images,
      urgency: urgency,
      year: year,
      condition: condition,
      viewsCount: viewsCount ?? this.viewsCount,
      responseCount: responseCount ?? this.responseCount,
      newResponsesCount: newResponsesCount ?? this.newResponsesCount,
      responderPreview: responderPreview ?? this.responderPreview,
    );
  }

  @override
  List<Object?> get props => [id, title, status, responseCount, createdAt];
}
