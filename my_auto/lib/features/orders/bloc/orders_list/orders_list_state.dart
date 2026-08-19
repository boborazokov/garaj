import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_stats.dart';
import '../../domain/entities/orders_tab.dart';
import '../../domain/failures/orders_failure.dart';

enum OrdersListStatus { initial, loading, success, loadingMore, empty, error }

class OrdersListState extends Equatable {
  const OrdersListState({
    this.status = OrdersListStatus.initial,
    this.orders = const [],
    this.visibleOrders = const [],
    this.page = 1,
    this.hasMore = true,
    this.tab = OrdersTab.all,
    this.searchQuery = '',
    this.favoriteIds = const {},
    this.respondedIds = const {},
    this.stats = const OrderStats(),
    this.failure,
    this.authorId,
  });

  final OrdersListStatus status;
  final List<Order> orders;
  final List<Order> visibleOrders;
  final int page;
  final bool hasMore;
  final OrdersTab tab;
  final String searchQuery;
  final Set<String> favoriteIds;
  final Set<String> respondedIds;
  final OrderStats stats;
  final OrdersFailure? failure;
  final String? authorId;

  OrdersListState copyWith({
    OrdersListStatus? status,
    List<Order>? orders,
    List<Order>? visibleOrders,
    int? page,
    bool? hasMore,
    OrdersTab? tab,
    String? searchQuery,
    Set<String>? favoriteIds,
    Set<String>? respondedIds,
    OrderStats? stats,
    OrdersFailure? failure,
    String? authorId,
    bool clearFailure = false,
  }) {
    return OrdersListState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      visibleOrders: visibleOrders ?? this.visibleOrders,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      tab: tab ?? this.tab,
      searchQuery: searchQuery ?? this.searchQuery,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      respondedIds: respondedIds ?? this.respondedIds,
      stats: stats ?? this.stats,
      failure: clearFailure ? null : (failure ?? this.failure),
      authorId: authorId ?? this.authorId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        visibleOrders.length,
        tab,
        searchQuery,
        favoriteIds.length,
        stats,
        failure,
      ];
}
