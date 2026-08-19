import 'dart:io';

import 'package:my_auto/core/provider/add/uploudImageService.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_response.dart';
import '../../domain/entities/paginated_orders.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_local_datasource.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl({
    required OrdersRemoteDataSource remote,
    required OrdersLocalDataSource local,
    UploadService? uploadService,
  })  : _remote = remote,
        _local = local,
        _upload = uploadService ?? UploadService();

  final OrdersRemoteDataSource _remote;
  final OrdersLocalDataSource _local;
  final UploadService _upload;

  @override
  Future<PaginatedOrders> getOrders({
    int page = 1,
    int limit = 12,
    Map<String, dynamic>? filter,
    String? search,
    String? viewerRegion,
  }) async {
    final dto = await _remote.getOrders(
      page: page,
      limit: limit,
      filter: filter,
      search: search,
      viewerRegion: viewerRegion,
    );
    return PaginatedOrders(
      items: dto.items.map((e) => e.toEntity()).toList(),
      page: dto.page,
      totalPages: dto.totalPages,
      hasNextPage: dto.hasNextPage,
      totalDocs: dto.totalDocs,
    );
  }

  @override
  Future<Order> getOrderById(String orderId) async {
    final dto = await _remote.getOrderById(orderId);
    return dto.toEntity();
  }

  @override
  Future<List<OrderResponse>> getOrderResponses(String orderId) async {
    try {
      final list = await _remote.getOrderResponses(orderId);
      return list.map((e) => e.toEntity(orderId)).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> createOrder(Map<String, dynamic> data) async {
    final id = await _remote.createOrder(data);
    await _local.clearDraft();
    return id;
  }

  @override
  Future<void> uploadOrderImages({
    required String orderId,
    required List<File> files,
    void Function(double progress)? onProgress,
  }) async {
    if (files.isEmpty) return;
    await _upload.uploadFilesWithProgress(
      files: files,
      targetId: orderId,
      targetType: 'order',
      onProgress: onProgress ?? (_) {},
    );
  }

  @override
  Future<OrderResponse> respondToOrder({
    required String orderId,
    required String text,
    int? offeredPrice,
    int? deliveryDays,
  }) async {
    final dto = await _remote.respondToOrder({
      'orderId': orderId,
      'text': text,
      if (offeredPrice != null) 'offeredPrice': offeredPrice,
      if (deliveryDays != null) 'deliveryDays': deliveryDays,
    });
    await markResponded(orderId);
    return dto.toEntity(orderId);
  }

  @override
  Future<void> closeOrder(String orderId) => _remote.closeOrder(orderId);

  @override
  Future<void> reopenOrder(String orderId) => _remote.reopenOrder(orderId);

  @override
  Future<void> deleteOrder(String orderId) => _remote.deleteOrder(orderId);

  @override
  Future<Set<String>> getFavoriteIds() => _local.getFavoriteIds();

  @override
  Future<void> toggleFavorite(String orderId) async {
    final ids = await getFavoriteIds();
    if (ids.contains(orderId)) {
      ids.remove(orderId);
    } else {
      ids.add(orderId);
    }
    await _local.saveFavoriteIds(ids);
  }

  @override
  Future<Set<String>> getRespondedOrderIds() => _local.getRespondedOrderIds();

  @override
  Future<void> markResponded(String orderId) async {
    final ids = await getRespondedOrderIds();
    ids.add(orderId);
    await _local.saveRespondedOrderIds(ids);
  }
}
