import 'package:my_auto/core/model/category_names.dart';

class SellerMatchingCategoryStat {
  const SellerMatchingCategoryStat({
    required this.categoryId,
    required this.orderCount,
    required this.listingsCount,
    required this.names,
    this.icon,
    this.key,
  });

  final String categoryId;
  final int orderCount;
  final int listingsCount;
  final CategoryNames names;
  final String? icon;
  final String? key;

  factory SellerMatchingCategoryStat.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] is Map
        ? Map<String, dynamic>.from(json['category'] as Map)
        : <String, dynamic>{};
    return SellerMatchingCategoryStat(
      categoryId: json['categoryId']?.toString() ??
          cat['_id']?.toString() ??
          '',
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      listingsCount: (json['listingsCount'] as num?)?.toInt() ?? 0,
      names: CategoryNames.fromJson(cat['names']),
      icon: cat['icon']?.toString(),
      key: cat['key']?.toString(),
    );
  }
}

class SellerMatchingOrdersOverview {
  const SellerMatchingOrdersOverview({
    required this.categories,
    required this.totalMatchingOrders,
  });

  final List<SellerMatchingCategoryStat> categories;
  final int totalMatchingOrders;

  factory SellerMatchingOrdersOverview.fromJson(Map<String, dynamic> json) {
    final cats = (json['categories'] as List? ?? [])
        .whereType<Map>()
        .map((e) => SellerMatchingCategoryStat.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .where((e) => e.categoryId.isNotEmpty)
        .toList();
    return SellerMatchingOrdersOverview(
      categories: cats,
      totalMatchingOrders:
          (json['totalMatchingOrders'] as num?)?.toInt() ?? 0,
    );
  }
}
