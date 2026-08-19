import 'package:equatable/equatable.dart';

class OrderCategoryRef extends Equatable {
  const OrderCategoryRef({
    required this.id,
    required this.name,
    this.iconUrl,
  });

  final String id;
  final String name;
  final String? iconUrl;

  @override
  List<Object?> get props => [id, name];
}
