import 'dart:io';

import '../entities/order.dart';
import '../entities/order_response.dart';
import '../entities/paginated_orders.dart';
import '../entities/seller_matching_orders.dart';

abstract class OrdersRepository {
  Future<PaginatedOrders> getOrders({
    int page = 1,
    int limit = 12,
    Map<String, dynamic>? filter,
    String? search,
    String? viewerRegion,
  });

  Future<Order> getOrderById(String orderId);

  Future<List<OrderResponse>> getOrderResponses(String orderId);

  Future<String> createOrder(Map<String, dynamic> data);

  Future<void> uploadOrderImages({
    required String orderId,
    required List<File> files,
    void Function(double progress)? onProgress,
  });

  Future<OrderResponse> respondToOrder({
    required String orderId,
    required String text,
    int? offeredPrice,
    int? deliveryDays,
  });

  Future<void> closeOrder(String orderId);

  Future<void> reopenOrder(String orderId);

  Future<void> deleteOrder(String orderId);

  Future<Set<String>> getFavoriteIds();

  Future<void> toggleFavorite(String orderId);

  Future<Set<String>> getRespondedOrderIds();

  Future<void> markResponded(String orderId);

  /// Active buyer requests grouped by the seller's listing categories.
  Future<SellerMatchingOrdersOverview> getSellerMatchingOrdersOverview();
}
