import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_response.dart';
import '../../domain/failures/orders_failure.dart';

enum OrderDetailStatus { initial, loading, success, error }

class OrderDetailState extends Equatable {
  const OrderDetailState({
    this.status = OrderDetailStatus.initial,
    this.order,
    this.responses = const [],
    this.isSubmittingResponse = false,
    this.failure,
    this.orderId = '',
  });

  final OrderDetailStatus status;
  final Order? order;
  final List<OrderResponse> responses;
  final bool isSubmittingResponse;
  final OrdersFailure? failure;
  final String orderId;

  OrderDetailState copyWith({
    OrderDetailStatus? status,
    Order? order,
    List<OrderResponse>? responses,
    bool? isSubmittingResponse,
    OrdersFailure? failure,
    String? orderId,
    bool clearFailure = false,
  }) {
    return OrderDetailState(
      status: status ?? this.status,
      order: order ?? this.order,
      responses: responses ?? this.responses,
      isSubmittingResponse: isSubmittingResponse ?? this.isSubmittingResponse,
      failure: clearFailure ? null : (failure ?? this.failure),
      orderId: orderId ?? this.orderId,
    );
  }

  @override
  List<Object?> get props => [status, order?.id, responses.length, isSubmittingResponse];
}
