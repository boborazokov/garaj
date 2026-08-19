import 'package:equatable/equatable.dart';

sealed class OrdersFailure extends Equatable {
  const OrdersFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class OrdersNetworkFailure extends OrdersFailure {
  const OrdersNetworkFailure() : super('No internet connection');
}

final class OrdersAuthFailure extends OrdersFailure {
  const OrdersAuthFailure() : super('Please sign in');
}

final class OrdersServerFailure extends OrdersFailure {
  const OrdersServerFailure([String msg = 'Something went wrong']) : super(msg);
}

final class OrdersValidationFailure extends OrdersFailure {
  const OrdersValidationFailure(super.message);
}
