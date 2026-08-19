import 'package:equatable/equatable.dart';

import 'order_author.dart';
import 'order_response_listing.dart';

class OrderResponse extends Equatable {
  const OrderResponse({
    required this.id,
    required this.orderId,
    required this.seller,
    required this.text,
    required this.createdAt,
    this.offeredPrice,
    this.deliveryDays,
    this.isAccepted = false,
    this.listing,
  });

  final String id;
  final String orderId;
  final OrderAuthor seller;
  final String text;
  final DateTime createdAt;
  final int? offeredPrice;
  final int? deliveryDays;
  final bool isAccepted;
  final OrderResponseListing? listing;

  @override
  List<Object?> get props => [id, orderId, seller.id, listing?.id];
}
