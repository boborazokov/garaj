import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';

import '../../domain/entities/order_author.dart';
import '../../domain/entities/order_response.dart';
import '../../domain/entities/order_response_listing.dart';

class OrderResponseDto {
  OrderResponseDto({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.seller,
    this.offeredPrice,
    this.deliveryDays,
    this.isAccepted = false,
    this.listing,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final OrderAuthor seller;
  final int? offeredPrice;
  final int? deliveryDays;
  final bool isAccepted;
  final OrderResponseListing? listing;

  factory OrderResponseDto.fromJson(
    Map<String, dynamic> json, {
    required String orderId,
  }) {
    final sellerRaw = json['seller'];
    OrderAuthor seller = const OrderAuthor(id: '', name: 'Seller');
    if (sellerRaw is Map) {
      seller = OrderAuthor(
        id: sellerRaw['_id'].toString(),
        name: (sellerRaw['name'] ?? 'Seller').toString(),
        phone: sellerRaw['phone']?.toString(),
      );
    }

    return OrderResponseDto(
      id: json['_id'].toString(),
      text: (json['text'] ?? '').toString(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      seller: seller,
      offeredPrice: _toIntOrNull(json['offeredPrice']),
      deliveryDays: _toIntOrNull(json['deliveryDays']),
      isAccepted: json['isAccepted'] == true,
      listing: _parseListing(json['part']),
    );
  }

  static OrderResponseListing? _parseListing(dynamic raw) {
    if (raw is! Map) return null;
    final id = raw['_id']?.toString();
    if (id == null || id.isEmpty) return null;
    final name = (raw['name'] ?? '').toString();
    if (name.isEmpty) return null;

    String? imageUrl;
    final images = raw['images'];
    if (images is List && images.isNotEmpty) {
      imageUrl = normalizeStoragePath(
        images.first.toString(),
        mediaBase: fileUrl,
      );
    }

    return OrderResponseListing(
      id: id,
      name: name,
      imageUrl: imageUrl,
      price: _toIntOrNull(raw['price']),
      currency: raw['currency']?.toString(),
    );
  }

  OrderResponse toEntity(String orderId) => OrderResponse(
        id: id,
        orderId: orderId,
        seller: seller,
        text: text,
        createdAt: createdAt,
        offeredPrice: offeredPrice,
        deliveryDays: deliveryDays,
        isAccepted: isAccepted,
        listing: listing,
      );

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
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
