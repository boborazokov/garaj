import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:my_auto/core/errors/api_error_code.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_response.dart';
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
    final text = event.text.trim();
    if (text.isEmpty) {
      emit(state.copyWith(
        isSubmittingResponse: false,
        failure: OrdersValidationFailure(ApiErrorCode.validationFailed.wireValue),
      ));
      return;
    }

    emit(state.copyWith(isSubmittingResponse: true, clearFailure: true));
    try {
      final response = await _repository.respondToOrder(
        orderId: state.orderId,
        text: text,
        offeredPrice: event.offeredPrice,
        deliveryDays: event.deliveryDays,
      );
      final fresh = await _repository.getOrderResponses(state.orderId);
      final next = _withResponse(fresh, response, state.responses);
      emit(state.copyWith(
        isSubmittingResponse: false,
        responses: next,
        order: state.order?.copyWith(responseCount: next.length),
        clearFailure: true,
      ));
    } on OrdersFailure catch (f) {
      if (await _emitIfServerHasNewResponses(emit)) return;
      emit(state.copyWith(isSubmittingResponse: false, failure: f));
    } catch (e) {
      if (await _emitIfServerHasNewResponses(emit)) return;
      emit(state.copyWith(
        isSubmittingResponse: false,
        failure: OrdersServerFailure(e.toString()),
      ));
    }
  }

  /// The offer can be saved even when the mutation payload fails to parse.
  /// Reload the list so the screen does not stay on "0 offers".
  Future<bool> _emitIfServerHasNewResponses(
    Emitter<OrderDetailState> emit,
  ) async {
    final recovered = await _repository.getOrderResponses(state.orderId);
    if (recovered.length <= state.responses.length) return false;
    emit(state.copyWith(
      isSubmittingResponse: false,
      responses: recovered,
      order: state.order?.copyWith(responseCount: recovered.length),
      clearFailure: true,
    ));
    return true;
  }

  List<OrderResponse> _withResponse(
    List<OrderResponse> fresh,
    OrderResponse response,
    List<OrderResponse> previous,
  ) {
    if (fresh.any((r) => r.id == response.id)) return fresh;
    final base = fresh.isNotEmpty ? fresh : previous;
    return [
      response,
      ...base.where((r) => r.id != response.id),
    ];
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
