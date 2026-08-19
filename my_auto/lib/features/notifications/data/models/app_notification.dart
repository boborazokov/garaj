class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.deepLink,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String? deepLink;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      deepLink: json['deepLink']?.toString(),
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  AppNotification markRead() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        deepLink: deepLink,
        isRead: true,
        createdAt: createdAt,
      );
}

class PaginatedAppNotifications {
  const PaginatedAppNotifications({
    required this.items,
    required this.hasNextPage,
    required this.totalDocs,
  });

  final List<AppNotification> items;
  final bool hasNextPage;
  final int totalDocs;

  factory PaginatedAppNotifications.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as List? ?? [];
    return PaginatedAppNotifications(
      items: payload
          .map(
            (e) => AppNotification.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      hasNextPage: json['hasNextPage'] == true,
      totalDocs: (json['totalDocs'] as num?)?.toInt() ?? payload.length,
    );
  }
}
