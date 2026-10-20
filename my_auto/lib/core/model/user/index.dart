class AuthOutput {
  AuthOutput({
    required this.accessToken,
    required this.user,
    this.refreshToken,
    this.sessionId,
    this.tokenVersion,
  });

  /// Legacy alias — same as [accessToken].
  String get token => accessToken;

  final String accessToken;
  final String? refreshToken;
  final String? sessionId;
  final int? tokenVersion;
  final User user;

  factory AuthOutput.fromJson(Map<String, dynamic> json) {
    final access = (json['accessToken'] ?? json['token'] ?? '').toString();
    return AuthOutput(
      accessToken: access,
      refreshToken: json['refreshToken'] as String?,
      sessionId: json['sessionId'] as String?,
      tokenVersion: (json['tokenVersion'] as num?)?.toInt(),
      user: User.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        if (refreshToken != null) 'refreshToken': refreshToken,
        if (sessionId != null) 'sessionId': sessionId,
        if (tokenVersion != null) 'tokenVersion': tokenVersion,
        'user': user.toJson(),
      };
}

class User {
  final String phone;
  final String name;
  final String id;
  final String? image;
  final String? country;
  final String? region;
  final String? city;
  final String? address;
  final Map<String, String?>? socialLinks;
  final Map<String, bool>? privacy;

  User({
    required this.phone,
    required this.name,
    required this.id,
    this.image,
    this.country,
    this.region,
    this.city,
    this.address,
    this.socialLinks,
    this.privacy,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    Map<String, String?>? links;
    if (json['socialLinks'] is Map) {
      final m = Map<String, dynamic>.from(json['socialLinks'] as Map);
      links = m.map((k, v) => MapEntry(k, v?.toString()));
    }
    Map<String, bool>? privacyMap;
    if (json['privacy'] is Map) {
      final m = Map<String, dynamic>.from(json['privacy'] as Map);
      privacyMap = m.map((k, v) => MapEntry(k, v == true));
    }

    return User(
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      id: json['_id']?.toString() ?? '',
      image: json['image']?.toString(),
      country: json['country']?.toString(),
      region: json['region']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      socialLinks: links,
      privacy: privacyMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'name': name,
      '_id': id,
      if (image != null) 'image': image,
      if (country != null) 'country': country,
      if (region != null) 'region': region,
      if (city != null) 'city': city,
      if (address != null) 'address': address,
      if (socialLinks != null) 'socialLinks': socialLinks,
      if (privacy != null) 'privacy': privacy,
    };
  }
}
