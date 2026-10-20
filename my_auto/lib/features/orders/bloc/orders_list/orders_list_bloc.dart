import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_stats.dart';
import '../../domain/entities/orders_tab.dart';
import '../../domain/failures/orders_failure.dart';
import '../../domain/repositories/orders_repository.dart';
import 'orders_list_event.dart';
import 'orders_list_state.dart';

class OrdersListBloc extends Bloc<OrdersListEvent, OrdersListState> {
  OrdersListBloc({
    required OrdersRepository repository,
    required String? currentUserId,
  })  : _repository = repository,
        _currentUserId = currentUserId,
        super(const OrdersListState()) {
    on<OrdersListStarted>(_onStarted);
    on<OrdersListRefreshed>(_onRefreshed, transformer: droppable());
    on<OrdersListLoadMore>(_onLoadMore, transformer: droppable());
    on<OrdersListSearchChanged>(_onSearchChanged, transformer: restartable());
    on<OrdersListTabChanged>(_onTabChanged);
    on<OrdersListFavoriteToggled>(_onFavoriteToggled);
    on<OrdersListDeleteRequested>(_onDelete);
    on<OrdersListCloseRequested>(_onClose);
  }

  final OrdersRepository _repository;
  final String? _currentUserId;

  Future<void> _onStarted(
    OrdersListStarted event,
    Emitter<OrdersListState> emit,
  ) async {
    emit(state.copyWith(
      authorId: event.authorId,
      partCategoryId: event.partCategoryId,
      matchSellerCategories: event.matchSellerCategories,
    ));
    final favorites = await _repository.getFavoriteIds();
    final responded = await _repository.getRespondedOrderIds();
    emit(state.copyWith(favoriteIds: favorites, respondedIds: responded));
    await _load(emit, reset: true);
  }

  Future<void> _onRefreshed(
    OrdersListRefreshed event,
    Emitter<OrdersListState> emit,
  ) =>
      _load(emit, reset: true);

  Future<void> _onLoadMore(
    OrdersListLoadMore event,
    Emitter<OrdersListState> emit,
  ) async {
    if (!state.hasMore || state.status == OrdersListStatus.loadingMore) return;
    emit(state.copyWith(status: OrdersListStatus.loadingMore));
    await _load(emit, reset: false);
  }

  Future<void> _onSearchChanged(
    OrdersListSearchChanged event,
    Emitter<OrdersListState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    await _load(emit, reset: true);
  }

  void _onTabChanged(
    OrdersListTabChanged event,
    Emitter<OrdersListState> emit,
  ) {
    emit(state.copyWith(
      tab: event.tab,
      visibleOrders: _filterVisible(state.orders, event.tab),
      status: _filterVisible(state.orders, event.tab).isEmpty
          ? OrdersListStatus.empty
          : OrdersListStatus.success,
    ));
  }

  Future<void> _onFavoriteToggled(
    OrdersListFavoriteToggled event,
    Emitter<OrdersListState> emit,
  ) async {
    await _repository.toggleFavorite(event.orderId);
    final favorites = await _repository.getFavoriteIds();
    emit(state.copyWith(
      favoriteIds: favorites,
      visibleOrders: _filterVisible(state.orders, state.tab),
    ));
  }

  Future<void> _onDelete(
    OrdersListDeleteRequested event,
    Emitter<OrdersListState> emit,
  ) async {
    try {
      await _repository.deleteOrder(event.orderId);
      final orders = state.orders.where((o) => o.id != event.orderId).toList();
      emit(state.copyWith(
        orders: orders,
        visibleOrders: _filterVisible(orders, state.tab),
        stats: _computeStats(orders),
        status: _filterVisible(orders, state.tab).isEmpty
            ? OrdersListStatus.empty
            : OrdersListStatus.success,
      ));
    } on OrdersFailure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  Future<void> _onClose(
    OrdersListCloseRequested event,
    Emitter<OrdersListState> emit,
  ) async {
    try {
      await _repository.closeOrder(event.orderId);
      final orders = state.orders
          .map(
            (o) => o.id == event.orderId
                ? o.copyWith(status: OrderStatus.closed)
                : o,
          )
          .toList();
      emit(state.copyWith(
        orders: orders,
        visibleOrders: _filterVisible(orders, state.tab),
        stats: _computeStats(orders),
      ));
    } on OrdersFailure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  Future<void> _load(Emitter<OrdersListState> emit, {required bool reset}) async {
    if (reset) {
      emit(state.copyWith(
        status: OrdersListStatus.loading,
        orders: [],
        visibleOrders: [],
        page: 1,
        hasMore: true,
        clearFailure: true,
      ));
    }

    try {
      final page = reset ? 1 : state.page;
      final filter = <String, dynamic>{};
      if (state.authorId != null) {
        filter['author'] = state.authorId;
      } else if (state.tab == OrdersTab.myRequests && _currentUserId != null) {
        filter['author'] = _currentUserId;
      }
      if (state.partCategoryId != null && state.partCategoryId!.isNotEmpty) {
        filter['partCategory'] = state.partCategoryId;
      }
      if (state.matchSellerCategories) {
        filter['matchSellerCategories'] = true;
      }

      final result = await _repository.getOrders(
        page: page,
        limit: 12,
        filter: filter.isEmpty ? null : filter,
        search: state.searchQuery,
      );

      final merged = reset
          ? result.items
          : [
              ...state.orders,
              ...result.items.where(
                (n) => !state.orders.any((o) => o.id == n.id),
              ),
            ];

      final visible = _filterVisible(merged, state.tab);

      emit(state.copyWith(
        status: visible.isEmpty ? OrdersListStatus.empty : OrdersListStatus.success,
        orders: merged,
        visibleOrders: visible,
        page: page + 1,
        hasMore: result.hasNextPage,
        stats: _computeStats(merged),
        clearFailure: true,
      ));
    } on OrdersFailure catch (f) {
      emit(state.copyWith(status: OrdersListStatus.error, failure: f));
    } catch (e) {
      emit(state.copyWith(
        status: OrdersListStatus.error,
        failure: OrdersServerFailure(e.toString()),
      ));
    }
  }

  List<Order> _filterVisible(List<Order> orders, OrdersTab tab) {
    switch (tab) {
      case OrdersTab.all:
        return orders;
      case OrdersTab.myRequests:
        if (_currentUserId == null) return [];
        return orders.where((o) => o.author?.id == _currentUserId).toList();
      case OrdersTab.responded:
        return orders
            .where((o) => state.respondedIds.contains(o.id))
            .toList();
      case OrdersTab.favorites:
        return orders.where((o) => state.favoriteIds.contains(o.id)).toList();
    }
  }

  OrderStats _computeStats(List<Order> orders) {
    var active = 0;
    var closed = 0;
    var responses = 0;
    for (final o in orders) {
      if (o.status == OrderStatus.closed) {
        closed++;
      } else {
        active++;
      }
      responses += o.responseCount;
    }
    return OrderStats(
      activeRequests: active,
      totalResponses: responses,
      closedRequests: closed,
    );
  }
}
