import 'package:equatable/equatable.dart';

import '../../domain/entities/order_response.dart';

sealed class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();
  @override
  List<Object?> get props => const [];
}

final class OrderDetailOpened extends OrderDetailEvent {
  const OrderDetailOpened(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

final class OrderDetailResponseAdded extends OrderDetailEvent {
  const OrderDetailResponseAdded(this.response);
  final OrderResponse response;
  @override
  List<Object?> get props => [response];
}

final class OrderDetailRespondSubmitted extends OrderDetailEvent {
  const OrderDetailRespondSubmitted({
    required this.text,
    this.offeredPrice,
    this.deliveryDays,
  });
  final String text;
  final int? offeredPrice;
  final int? deliveryDays;
  @override
  List<Object?> get props => [text, offeredPrice, deliveryDays];
}

final class OrderDetailCloseRequested extends OrderDetailEvent {
  const OrderDetailCloseRequested();
}

final class OrderDetailReopenRequested extends OrderDetailEvent {
  const OrderDetailReopenRequested();
}
