import 'package:equatable/equatable.dart';

class OrderAuthor extends Equatable {
  const OrderAuthor({
    required this.id,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.rating,
  });

  final String id;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final double? rating;

  @override
  List<Object?> get props => [id, name];
}
