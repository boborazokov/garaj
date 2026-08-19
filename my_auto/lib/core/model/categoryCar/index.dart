import 'package:my_auto/core/model/category_names.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';

class CategoryCar {
  final String id;
  final CategoryNames names;

  final String name;

  final String? iconUrl;
  final String? icon;
  final String? key;

  CategoryCar({
    required this.id,
    required this.names,
    required this.name,
    this.iconUrl,
    this.icon,
    this.key,
  });

  String localizedName(String languageCode) => names.forLocale(languageCode);

  String compactName(String languageCode, {int maxChars = 22}) =>
      names.compactForLocale(languageCode, maxChars: maxChars);

  factory CategoryCar.fromJson(Map<String, dynamic> json) {
    final legacyName = json['name']?.toString();
    final names = CategoryNames.fromJson(json['names'], legacyName: legacyName);
    final rawIcon = json['iconUrl']?.toString();
    final iconUrl = resolveMediaUrl(
      rawIcon == null || rawIcon.isEmpty ? null : rawIcon,
      mediaBase: fileUrl,
    );
    final display = legacyName?.trim().isNotEmpty == true
        ? legacyName!.trim()
        : names.forLocale('ru');
    return CategoryCar(
      id: json['_id'].toString(),
      names: names,
      name: display,
      iconUrl: iconUrl,
      icon: json['icon']?.toString(),
      key: json['key']?.toString(),
    );
  }
}
