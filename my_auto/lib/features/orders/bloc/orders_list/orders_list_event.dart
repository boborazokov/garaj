import 'package:equatable/equatable.dart';

import '../../domain/entities/orders_tab.dart';

sealed class OrdersListEvent extends Equatable {
  const OrdersListEvent();
  @override
  List<Object?> get props => const [];
}

final class OrdersListStarted extends OrdersListEvent {
  const OrdersListStarted({
    this.authorId,
    this.partCategoryId,
    this.matchSellerCategories = false,
  });
  final String? authorId;
  final String? partCategoryId;
  final bool matchSellerCategories;
  @override
  List<Object?> get props => [authorId, partCategoryId, matchSellerCategories];
}

final class OrdersListRefreshed extends OrdersListEvent {
  const OrdersListRefreshed();
}

final class OrdersListLoadMore extends OrdersListEvent {
  const OrdersListLoadMore();
}

final class OrdersListSearchChanged extends OrdersListEvent {
  const OrdersListSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class OrdersListTabChanged extends OrdersListEvent {
  const OrdersListTabChanged(this.tab);
  final OrdersTab tab;
  @override
  List<Object?> get props => [tab];
}

final class OrdersListFavoriteToggled extends OrdersListEvent {
  const OrdersListFavoriteToggled(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

final class OrdersListDeleteRequested extends OrdersListEvent {
  const OrdersListDeleteRequested(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

final class OrdersListCloseRequested extends OrdersListEvent {
  const OrdersListCloseRequested(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}
