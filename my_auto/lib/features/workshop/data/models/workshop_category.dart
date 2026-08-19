import 'package:my_auto/core/model/category_names.dart';

class WorkshopCategory {
  const WorkshopCategory({
    required this.id,
    required this.slug,
    required this.names,
    this.icon,
    this.color,
    this.popular = false,
    this.name = '',
  });

  final String id;
  final String slug;
  final CategoryNames names;
  final String? icon;
  final String? color;
  final bool popular;
  final String name;

  String localizedName(String languageCode) => names.forLocale(languageCode);

  factory WorkshopCategory.fromJson(Map<String, dynamic> json) {
    return WorkshopCategory(
      id: json['_id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      names: CategoryNames.fromJson(
        json['names'],
        legacyName: json['name']?.toString(),
      ),
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
      popular: json['popular'] == true,
      name: json['name']?.toString() ?? '',
    );
  }
}
