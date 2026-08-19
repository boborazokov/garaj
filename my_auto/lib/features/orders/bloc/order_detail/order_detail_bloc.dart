import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/failures/orders_failure.dart';
import '../../domain/repositories/orders_repository.dart';
import 'order_detail_event.dart';
import 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  OrderDetailBloc({required OrdersRepository repository})
      : _repository = repository,
        super(const OrderDetailState()) {
    on<OrderDetailOpened>(_onOpened);
    on<OrderDetailResponseAdded>(_onResponseAdded);
    on<OrderDetailRespondSubmitted>(_onRespond);
    on<OrderDetailCloseRequested>(_onClose);
    on<OrderDetailReopenRequested>(_onReopen);
  }

  final OrdersRepository _repository;
  StreamSubscription? _responseSub;

  Future<void> _onOpened(
    OrderDetailOpened event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(state.copyWith(
      orderId: event.orderId,
      status: OrderDetailStatus.loading,
      clearFailure: true,
    ));

    try {
      final order = await _repository.getOrderById(event.orderId);
      final responses = await _repository.getOrderResponses(event.orderId);
      emit(state.copyWith(
        status: OrderDetailStatus.success,
        order: order.copyWith(responseCount: responses.length),
        responses: responses,
      ));

      _responseSub?.cancel();
    } on OrdersFailure catch (f) {
      emit(state.copyWith(status: OrderDetailStatus.error, failure: f));
    } catch (e) {
      emit(state.copyWith(
        status: OrderDetailStatus.error,
        failure: OrdersServerFailure(e.toString()),
      ));
    }
  }

  void _onResponseAdded(
    OrderDetailResponseAdded event,
    Emitter<OrderDetailState> emit,
  ) {
    if (state.responses.any((r) => r.id == event.response.id)) return;
    final next = [event.response, ...state.responses];
    emit(state.copyWith(
      responses: next,
      order: state.order?.copyWith(responseCount: next.length),
    ));
  }

  Future<void> _onRespond(
    OrderDetailRespondSubmitted event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(state.copyWith(isSubmittingResponse: true));
    try {
      final response = await _repository.respondToOrder(
        orderId: state.orderId,
        text: event.text,
        offeredPrice: event.offeredPrice,
        deliveryDays: event.deliveryDays,
      );
      add(OrderDetailResponseAdded(response));
    } on OrdersFailure catch (f) {
      emit(state.copyWith(failure: f));
    } finally {
      emit(state.copyWith(isSubmittingResponse: false, clearFailure: true));
    }
  }

  Future<void> _onClose(
    OrderDetailCloseRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    try {
      await _repository.closeOrder(state.orderId);
      emit(state.copyWith(
        order: state.order?.copyWith(status: OrderStatus.closed),
      ));
    } on OrdersFailure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  Future<void> _onReopen(
    OrderDetailReopenRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    try {
      await _repository.reopenOrder(state.orderId);
      emit(state.copyWith(
        order: state.order?.copyWith(status: OrderStatus.active),
      ));
    } on OrdersFailure catch (f) {
      emit(state.copyWith(failure: f));
    }
  }

  @override
  Future<void> close() async {
    await _responseSub?.cancel();
    return super.close();
  }
}
