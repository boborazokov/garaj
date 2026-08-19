import 'package:equatable/equatable.dart';

import 'order.dart';

class PaginatedOrders extends Equatable {
  const PaginatedOrders({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
    required this.totalDocs,
  });

  final List<Order> items;
  final int page;
  final int totalPages;
  final bool hasNextPage;
  final int totalDocs;

  @override
  List<Object?> get props => [items.length, page, hasNextPage];
}
