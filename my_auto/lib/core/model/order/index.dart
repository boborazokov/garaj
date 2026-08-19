import 'package:my_auto/core/model/categoryCar/index.dart';
import 'package:my_auto/core/model/user/index.dart';

/// Mirrors the backend `OrderStatusEnum`.
enum OrderStatusEnum { active, closed, cancelled }

extension OrderStatusEnumX on OrderStatusEnum {
  String toApiString() {
    switch (this) {
      case OrderStatusEnum.active:
        return 'ACTIVE';
      case OrderStatusEnum.closed:
        return 'CLOSED';
      case OrderStatusEnum.cancelled:
        return 'CANCELLED';
    }
  }

  static OrderStatusEnum fromApi(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'ACTIVE':
        return OrderStatusEnum.active;
      case 'CLOSED':
        return OrderStatusEnum.closed;
      case 'CANCELLED':
        return OrderStatusEnum.cancelled;
      default:
        return OrderStatusEnum.active;
    }
  }
}

/// User announcement / buy request. Created from "Didn't find what you
/// need? → Create Request" or from the dedicated CreateOrder screen.
class OrderItem {
  final String id;
  final String title;
  final String description;
  final String phone;
  final String? location;
  final String? region;
  final int budget;
  final String? currency;
  final OrderStatusEnum status;
  final bool isPromoted;
  final DateTime createdAt;
  final User? author;
  final CategoryCar? brand;
  final CategoryCar? carModel;
  final CategoryCar? partCategory;

  OrderItem({
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
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      location: json['location']?.toString(),
      region: json['region']?.toString(),
      budget: _toInt(json['budget']),
      currency: json['currency']?.toString(),
      status: OrderStatusEnumX.fromApi(json['status']?.toString()),
      isPromoted: json['isPromoted'] == true,
      createdAt: _parseDate(json['createdAt']),
      author:
          json['author'] is Map ? User.fromJson(json['author']) : null,
      brand: _category(json['brand']),
      carModel: _category(json['carModel']),
      partCategory: _category(json['partCategory']),
    );
  }

  static CategoryCar? _category(dynamic raw) {
    if (raw is Map) {
      return CategoryCar.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime _parseDate(dynamic v) {
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {}
    }
    return DateTime.now();
  }
}
