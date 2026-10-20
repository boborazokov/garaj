import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/place_label.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';

class Workshop {
  final String id;
  final String? activeUntil;
  final String? createdAt;
  final List<String> images;
  final String? location;
  final String? address;
  final String? city;
  final DateTime? openFrom;
  final DateTime? openUntil;
  final String? title;
  final String? status;
  final String? description;

  Workshop({
    required this.id,
    this.activeUntil,
    this.createdAt,
    this.images = const [],
    this.location,
    this.address,
    this.city,
    this.openFrom,
    this.openUntil,
    this.status,
    this.description,
    this.title,
  });

  /// Street / city for UI — never raw lat,lng.
  String get displayPlace => humanPlaceLabel(
        address: address,
        city: city,
        region: city,
        location: location,
        fallback: '',
      );

  factory Workshop.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString();
    final title = json['title']?.toString();
    return Workshop(
      id: json['_id'] as String,
      activeUntil: json['activeUntil'] as String?,
      createdAt: json['createdAt'] as String?,
      status: json['status'] as String?,
      images: (json['images'] as List?)
              ?.map(
                (e) => normalizeStoragePath(e.toString(), mediaBase: fileUrl),
              )
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      location: json['location']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      openFrom:
          json['openFrom'] != null ? DateTime.parse(json['openFrom']) : null,
      openUntil:
          json['openUntil'] != null ? DateTime.parse(json['openUntil']) : null,
      title: (title != null && title.trim().isNotEmpty)
          ? title
          : (name != null && name.trim().isNotEmpty ? name : null),
      description: json['description'] as String?,
    );
  }
}
