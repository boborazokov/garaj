import 'package:equatable/equatable.dart';

class OrderStats extends Equatable {
  const OrderStats({
    this.activeRequests = 0,
    this.totalResponses = 0,
    this.closedRequests = 0,
  });

  final int activeRequests;
  final int totalResponses;
  final int closedRequests;

  @override
  List<Object?> get props => [activeRequests, totalResponses, closedRequests];
}
