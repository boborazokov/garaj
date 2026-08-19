import 'package:my_auto/core/model/category_names.dart';

class CategoryNode {
  CategoryNode({
    required this.id,
    required this.names,
    required this.type,
    this.iconUrl,
    this.parentId,
    this.children = const [],
  });

  final String id;
  final CategoryNames names;
  final String type;
  final String? iconUrl;
  final String? parentId;
  final List<CategoryNode> children;

  String localizedName(String languageCode) => names.forLocale(languageCode);

  String compactName(String languageCode, {int maxChars = 22}) =>
      names.compactForLocale(languageCode, maxChars: maxChars);

  bool matchesSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [names.en, names.ru, names.uz]
        .any((s) => s.toLowerCase().contains(q));
  }

  factory CategoryNode.fromJson(Map<String, dynamic> json) {
    final kids = (json['children'] as List?) ?? [];
    return CategoryNode(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      names: CategoryNames.fromJson(
        json['names'],
        legacyName: json['name']?.toString(),
      ),
      type: _normalizeType(json['type']),
      iconUrl: json['iconUrl']?.toString(),
      parentId: json['parentId']?.toString(),
      children: kids
          .map((e) => CategoryNode.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  static String _normalizeType(dynamic raw) {
    final t = raw?.toString().trim() ?? '';
    if (t.isEmpty) return '';
    final upper = t.toUpperCase();
    if (upper.contains('.')) {
      return upper.split('.').last;
    }
    return upper;
  }

  bool get isBrand => type == 'BRAND';
  bool get isModel => type == 'MODEL';
  bool get isPart => type == 'PART';

  List<CategoryNode> get models =>
      children.where((c) => c.isModel).toList();

  List<CategoryNode> get brands =>
      isBrand ? [this] : children.where((c) => c.isBrand).toList();

  List<CategoryNode> modelsForBrand(String brandId) {
    final brand = findById(brandId);
    if (brand == null) return [];
    return brand.models;
  }

  List<CategoryNode> partsForModel(String modelId) {
    final model = findById(modelId);
    if (model == null) return [];
    return model.children.where((c) => c.isPart).toList();
  }

  CategoryNode? findById(String id) {
    if (id.isEmpty) return null;
    if (this.id == id) return this;
    for (final c in children) {
      final found = c.findById(id);
      if (found != null) return found;
    }
    return null;
  }
}

extension CategoryForestX on List<CategoryNode> {
  List<CategoryNode> modelsForBrand(String brandId) {
    for (final root in this) {
      final hit = root.findById(brandId);
      if (hit != null) return hit.models;
    }
    return [];
  }
}
