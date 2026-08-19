import 'package:equatable/equatable.dart';

/// Seller's marketplace listing attached to an order offer (optional).
class OrderResponseListing extends Equatable {
  const OrderResponseListing({
    required this.id,
    required this.name,
    this.imageUrl,
    this.price,
    this.currency,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final int? price;
  final String? currency;

  @override
  List<Object?> get props => [id, name, price];
}
