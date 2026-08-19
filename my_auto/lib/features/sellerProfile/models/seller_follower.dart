class SellerFollower {
  const SellerFollower({
    required this.id,
    required this.name,
    this.username,
    this.image,
    required this.followedAt,
  });

  final String id;
  final String name;
  final String? username;
  final String? image;
  final DateTime followedAt;

  factory SellerFollower.fromJson(Map<String, dynamic> json) {
    return SellerFollower(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString(),
      image: json['image']?.toString(),
      followedAt: DateTime.tryParse(json['followedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class PaginatedSellerFollowers {
  const PaginatedSellerFollowers({
    required this.items,
    required this.hasNextPage,
    required this.totalDocs,
  });

  final List<SellerFollower> items;
  final bool hasNextPage;
  final int totalDocs;

  factory PaginatedSellerFollowers.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as List? ?? [];
    return PaginatedSellerFollowers(
      items: payload
          .map((e) => SellerFollower.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      hasNextPage: json['hasNextPage'] == true,
      totalDocs: (json['totalDocs'] as num?)?.toInt() ?? payload.length,
    );
  }
}
