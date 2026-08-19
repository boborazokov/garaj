import 'package:my_auto/features/create_product/data/models/category_node.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';

/// Rule-based “smart” helpers — no paid AI APIs.
class SmartListingService {
  String? recommendedCategoryName(CreateProductDraft draft) {
    final title = draft.title.toLowerCase();
    const rules = {
      'brake': 'Brake',
      'engine': 'Engine',
      'filter': 'Filter',
      'oil': 'Oil',
      'tire': 'Tire',
      'battery': 'Battery',
      'mirror': 'Mirror',
      'bumper': 'Bumper',
      'headlight': 'Light',
    };
    for (final entry in rules.entries) {
      if (title.contains(entry.key)) return entry.value;
    }
    return draft.vehicle.partCategoryName;
  }

  CategoryNode? matchPartCategory(List<CategoryNode> parts, String? hint) {
    if (hint == null || hint.isEmpty) return null;
    final lower = hint.toLowerCase();
    for (final p in parts) {
      if (p.names.en.toLowerCase().contains(lower) ||
          p.names.ru.toLowerCase().contains(lower) ||
          p.names.uz.toLowerCase().contains(lower)) {
        return p;
      }
    }
    return null;
  }

  List<String> autoTags(CreateProductDraft draft) {
    final tags = <String>{};
    if (draft.condition == ProductCondition.newPart) tags.add('new');
    if (draft.negotiable) tags.add('negotiable');
    if (draft.vehicle.brandName != null) {
      tags.add(draft.vehicle.brandName!.toLowerCase());
    }
    if (draft.vehicle.modelName != null) {
      tags.add(draft.vehicle.modelName!.toLowerCase());
    }
  return tags.take(6).toList();
  }

  String? duplicateWarning(CreateProductDraft draft, List<String> recentTitles) {
    final t = draft.title.trim().toLowerCase();
    if (t.length < 4) return null;
    for (final other in recentTitles) {
      if (other.toLowerCase() == t) {
        return 'You recently posted a listing with the same title';
      }
    }
    return null;
  }
}
