import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:my_auto/core/errors/api_error_code.dart';

import '../../domain/failures/orders_failure.dart';
import '../api/orders_api.dart';
import '../dto/order_dto.dart';
import '../dto/order_response_dto.dart';

class PaginatedOrdersDto {
  PaginatedOrdersDto({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
    required this.totalDocs,
  });

  final List<OrderDto> items;
  final int page;
  final int totalPages;
  final bool hasNextPage;
  final int totalDocs;
}

class OrdersRemoteDataSource {
  OrdersRemoteDataSource(this._client);

  final GraphQLClient _client;

  Future<PaginatedOrdersDto> getOrders({
    int page = 1,
    int limit = 12,
    Map<String, dynamic>? filter,
    String? search,
    String? viewerRegion,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getOrdersQuery),
        variables: {
          'pagination': {'page': page, 'limit': limit},
          'filter': filter ?? {},
          'search': search?.trim().isEmpty == true ? null : search?.trim(),
          'sort': 'NEWEST',
          if (viewerRegion != null && viewerRegion.isNotEmpty)
            'viewerRegion': viewerRegion,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _throwOnError(result);

    final data = result.data!['getOrders'] as Map<String, dynamic>;
    final payload = (data['payload'] as List? ?? [])
        .map((e) => OrderDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return PaginatedOrdersDto(
      items: payload,
      page: (data['page'] as num?)?.toInt() ?? page,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
      hasNextPage: data['hasNextPage'] == true,
      totalDocs: (data['totalDocs'] as num?)?.toInt() ?? payload.length,
    );
  }

  Future<OrderDto> getOrderById(String orderId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getOrderByIdQuery),
        variables: {'orderId': orderId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _throwOnError(result);
    return OrderDto.fromJson(
      Map<String, dynamic>.from(result.data!['getOrderById'] as Map),
    );
  }

  Future<Map<String, dynamic>> getSellerMatchingOrdersOverview() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getSellerMatchingOrdersOverviewQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _throwOnError(result);
    return Map<String, dynamic>.from(
      result.data!['getSellerMatchingOrdersOverview'] as Map,
    );
  }

  Future<List<OrderResponseDto>> getOrderResponses(String orderId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getOrderResponsesQuery),
        variables: {'orderId': orderId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _throwOnError(result);
    final list = result.data?['getOrderResponses'] as List? ?? [];
    return list
        .map(
          (e) => OrderResponseDto.fromJson(
            Map<String, dynamic>.from(e as Map),
            orderId: orderId,
          ),
        )
        .toList();
  }

  Future<String> createOrder(Map<String, dynamic> data) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(createOrderMutation),
        variables: {'data': data},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    _throwOnError(result);
    return result.data!['createOrder']['_id'].toString();
  }

  Future<OrderResponseDto> respondToOrder(Map<String, dynamic> data) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(respondToOrderMutation),
        variables: {'data': data},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    _throwOnError(result);
    final raw = Map<String, dynamic>.from(
      result.data!['respondToOrder'] as Map,
    );
    return OrderResponseDto.fromJson(raw, orderId: data['orderId'].toString());
  }

  Future<void> closeOrder(String orderId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(closeOrderMutation),
        variables: {'orderId': orderId},
      ),
    );
    _throwOnError(result);
  }

  Future<void> reopenOrder(String orderId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(reopenOrderMutation),
        variables: {'orderId': orderId},
      ),
    );
    _throwOnError(result);
  }

  Future<void> deleteOrder(String orderId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(deleteOrderMutation),
        variables: {'orderId': orderId},
      ),
    );
    _throwOnError(result);
  }

  Stream<OrderDto> watchOrderUpdated(String orderId) {
    return _client
        .subscribe(
          SubscriptionOptions(
            document: gql(orderUpdatedSubscription),
            variables: {'orderId': orderId},
          ),
        )
        .where((r) => !r.hasException && r.data != null)
        .map(
          (r) => OrderDto.fromJson(
            Map<String, dynamic>.from(r.data!['orderUpdated'] as Map),
          ),
        );
  }

  Stream<OrderResponseDto> watchOrderResponseAdded(String orderId) {
    return _client
        .subscribe(
          SubscriptionOptions(
            document: gql(orderResponseAddedSubscription),
            variables: {'orderId': orderId},
          ),
        )
        .where((r) => !r.hasException && r.data != null)
        .map(
          (r) => OrderResponseDto.fromJson(
            Map<String, dynamic>.from(r.data!['orderResponseAdded'] as Map),
            orderId: orderId,
          ),
        );
  }

  void _throwOnError(QueryResult result) {
    if (!result.hasException) return;
    final ex = result.exception!;
    if (ex.linkException is NetworkException) {
      throw const OrdersNetworkFailure();
    }
    final errors = ex.graphqlErrors;
    if (errors.isNotEmpty) {
      final first = errors.first;
      final extCode = first.extensions?['code']?.toString();
      final apiCode = ApiErrorCode.tryParse(extCode);
      if (extCode == 'UNAUTHENTICATED' ||
          apiCode == ApiErrorCode.authUnauthorized) {
        throw const OrdersAuthFailure();
      }
      throw OrdersValidationFailure(apiCode?.wireValue ?? extCode ?? first.message);
    }
    throw OrdersServerFailure(ex.toString());
  }
}
