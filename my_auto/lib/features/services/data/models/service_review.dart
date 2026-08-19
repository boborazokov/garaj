class ServiceReview {
  const ServiceReview({
    required this.id,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.userName,
  });

  final String id;
  final double rating;
  final String text;
  final DateTime createdAt;
  final String? userName;

  factory ServiceReview.fromJson(Map<String, dynamic> json) {
    return ServiceReview(
      id: json['_id']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      text: json['text']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      userName: (json['user'] as Map?)?['name']?.toString(),
    );
  }
}
