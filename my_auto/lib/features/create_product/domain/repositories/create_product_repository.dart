import 'dart:io';

import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/create_product/data/models/category_node.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';

abstract class CreateProductRepository {
  Future<List<CategoryNode>> fetchCategoryTree();
  Future<List<CategoryNode>> fetchPartCategories();
  Future<List<CategoryNode>> fetchModelsForBrand(String brandId);
  Future<String> createPart(CreateProductDraft draft);
  Future<void> updatePart(String partId, CreateProductDraft draft);
  Future<List<String>> uploadImages({
    required String partId,
    required List<File> files,
    void Function(double progress)? onProgress,
  });
  CreateProductDraft draftFromPart(Part part);
}
