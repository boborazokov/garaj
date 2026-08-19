import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';

class Workshop {
  final String id;
  final String? activeUntil;
  final String? createdAt;
  final List<String> images;
  final String? location;
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
    this.openFrom,
    this.openUntil,
    this.status,
    this.description,
    this.title,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
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
      openFrom:
          json['openFrom'] != null ? DateTime.parse(json['openFrom']) : null,
      openUntil:
          json['openUntil'] != null ? DateTime.parse(json['openUntil']) : null,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }
}
