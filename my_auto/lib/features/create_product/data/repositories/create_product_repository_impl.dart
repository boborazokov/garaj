import 'dart:io';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/provider/add/uploudImageService.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/create_product/data/create_product_api.dart';
import 'package:my_auto/features/create_product/data/models/category_node.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:my_auto/features/create_product/domain/repositories/create_product_repository.dart';
import 'package:my_auto/features/profile/screens/my_products/api/index.dart'
    as profile_api;

class CreateProductRepositoryImpl implements CreateProductRepository {
  CreateProductRepositoryImpl({
    GraphQLClient? client,
    UploadService? uploadService,
  })  : _client = client ?? GraphQLConfig.client(),
        _upload = uploadService ?? UploadService();

  final GraphQLClient _client;
  final UploadService _upload;

  @override
  Future<List<CategoryNode>> fetchCategoryTree() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getCategoryTreeQuery),
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
    );
    if (result.hasException) return [];
    final list = result.data?['getCategoryTree'] as List? ?? [];
    return list
        .map((e) => CategoryNode.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<CategoryNode>> fetchModelsForBrand(String brandId) async {
    if (brandId.isEmpty) return [];

    List<CategoryNode> parseList(List? raw) => (raw ?? [])
        .map((e) => CategoryNode.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((n) => n.isModel)
        .toList();

    final scoped = await _client.query(
      QueryOptions(
        document: gql(getModelsForBrandQuery),
        variables: {'parentId': brandId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (!scoped.hasException) {
      final list = parseList(scoped.data?['getCategories'] as List?);
      if (list.isNotEmpty) return list;
    }

    final all = await _client.query(
      QueryOptions(
        document: gql(getAllModelsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (all.hasException) return [];
    return parseList(all.data?['getCategories'] as List?)
        .where((m) => m.parentId == brandId)
        .toList();
  }

  @override
  Future<List<CategoryNode>> fetchPartCategories() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getPartCategoriesQuery),
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
    );
    if (result.hasException) return [];
    final list = result.data?['getCategories'] as List? ?? [];
    return list
        .map((e) => CategoryNode.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<String> createPart(CreateProductDraft draft) async {
    final data = _toPartInput(draft);
    final result = await _client.mutate(
      MutationOptions(
        document: gql(createPartMutation),
        variables: {'data': data, 'images': []},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors;
      final msg = (errors != null && errors.isNotEmpty)
          ? errors.first.message
          : result.exception.toString();
      throw Exception(msg);
    }
    final id = result.data?['createPart']?['_id']?.toString();
    if (id == null) throw Exception('Failed to create listing');
    return id;
  }

  @override
  Future<void> updatePart(String partId, CreateProductDraft draft) async {
    final data = _toPartUpdateInput(draft);
    final result = await _client.mutate(
      MutationOptions(
        document: gql(profile_api.updatePartById),
        variables: {'partId': partId, 'data': data, 'images': []},
      ),
    );
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  @override
  Future<List<String>> uploadImages({
    required String partId,
    required List<File> files,
    void Function(double progress)? onProgress,
  }) async {
    if (files.isEmpty) return [];
    try {
      final urls = await _upload.uploadFilesWithProgress(
        files: files,
        targetId: partId,
        targetType: 'part',
        onProgress: onProgress ?? (_) {},
      );
      // REST `/upload/multiple` already attaches images to the part on the server.
      return urls;
    } catch (e) {
      throw Exception('Photo upload failed: $e');
    }
  }

  @override
  CreateProductDraft draftFromPart(Part part) {
    DeliveryOption delivery;
    switch (part.delivery) {
      case 'Included':
      case 'Yes':
        delivery = DeliveryOption.included;
        break;
      case 'By agreement':
        delivery = DeliveryOption.byAgreement;
        break;
      default:
        delivery = DeliveryOption.notIncluded;
    }

    return CreateProductDraft(
      editingPartId: part.id,
      title: part.name,
      description: part.description,
      price: part.price,
      currency: part.currency,
      negotiable: part.negotiable ?? false,
      quantity: part.quantity,
      condition:
          part.condition == true ? ProductCondition.newPart : ProductCondition.used,
      delivery: delivery,
      location: part.location,
      region: part.region ?? '',
      vehicle: VehicleSelection(
        brandId: part.brand?.id,
        brandName: part.brand?.name,
        modelId: part.carModel?.id,
        modelName: part.carModel?.name,
        partCategoryId: part.category?.id,
        partCategoryName: part.category?.name,
      ),
      photos: part.images
          .map(
            (url) => ProductPhoto(
              id: url,
              networkUrl: url,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> _toPartInput(CreateProductDraft draft) {
    final categoryId = draft.categoryId;
    if (categoryId == null || categoryId.isEmpty) {
      throw Exception('Category is required');
    }

    return {
      'name': draft.title.trim(),
      'description': _buildDescription(draft),
      'category': categoryId,
      if (draft.vehicle.brandId != null) 'brand': draft.vehicle.brandId,
      if (draft.vehicle.modelId != null) 'carModel': draft.vehicle.modelId,
      'price': draft.price ?? 0,
      'quantity': draft.quantity,
      'currency': draft.currency,
      'isNegotiable': draft.negotiable,
      'isNew': draft.condition == ProductCondition.newPart,
      'deliveryCondition': _deliveryApi(draft.delivery),
      if (draft.location.isNotEmpty) 'location': draft.location,
      if (draft.region.isNotEmpty) 'region': draft.region,
    };
  }

  Map<String, dynamic> _toPartUpdateInput(CreateProductDraft draft) =>
      _toPartInput(draft);

  String _buildDescription(CreateProductDraft draft) {
    final parts = <String>[
      draft.description.trim().isEmpty
          ? draft.title.trim()
          : draft.description.trim(),
    ];
    if (draft.vehicle.year != null) {
      parts.add('Year: ${draft.vehicle.year}');
    }
    if (draft.tags.isNotEmpty) {
      parts.add('Tags: ${draft.tags.join(', ')}');
    }
    return parts.where((p) => p.isNotEmpty).join('\n\n');
  }

  String _deliveryApi(DeliveryOption d) => d.apiValue;
}
