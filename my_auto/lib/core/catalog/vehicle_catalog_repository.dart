import 'package:my_auto/features/create_product/data/models/category_node.dart';
import 'package:my_auto/features/create_product/data/repositories/create_product_repository_impl.dart';
import 'package:my_auto/features/create_product/domain/repositories/create_product_repository.dart';

class VehicleCatalogException implements Exception {
  VehicleCatalogException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VehicleCatalogData {
  const VehicleCatalogData({
    required this.brands,
    required this.partCategories,
  });

  final List<CategoryNode> brands;
  final List<CategoryNode> partCategories;

  bool get isReady => brands.isNotEmpty && partCategories.isNotEmpty;
}

/// Loads brand → model tree and part categories from the backend GraphQL API.
class VehicleCatalogRepository {
  VehicleCatalogRepository({CreateProductRepository? productRepo})
      : _productRepo = productRepo ?? CreateProductRepositoryImpl();

  final CreateProductRepository _productRepo;

  List<CategoryNode>? _cacheBrands;
  List<CategoryNode>? _cacheParts;

  Future<VehicleCatalogData> load({bool forceRefresh = false}) async {
    if (!forceRefresh && _cacheBrands != null && _cacheParts != null) {
      return VehicleCatalogData(
        brands: _cacheBrands!,
        partCategories: _cacheParts!,
      );
    }

    final brands = await _productRepo.fetchCategoryTree();
    final partCategories = await _productRepo.fetchPartCategories();

    if (brands.isEmpty && partCategories.isEmpty) {
      throw VehicleCatalogException(
        'Vehicle catalog is empty. Add brands, models and part categories on the server.',
      );
    }

    _cacheBrands = brands;
    _cacheParts = partCategories;

    return VehicleCatalogData(
      brands: brands,
      partCategories: partCategories,
    );
  }

  Future<List<CategoryNode>> modelsForBrand(String brandId) async {
    if (brandId.isEmpty) return [];

    if (_cacheBrands == null) {
      await load();
    }

    final fromTree = _cacheBrands?.modelsForBrand(brandId) ?? [];
    if (fromTree.isNotEmpty) return fromTree;

    return _productRepo.fetchModelsForBrand(brandId);
  }

  void clearCache() {
    _cacheBrands = null;
    _cacheParts = null;
  }
}
