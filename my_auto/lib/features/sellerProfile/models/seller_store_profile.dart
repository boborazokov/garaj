class SellerSocialLinks {
  final String? telegram;
  final String? instagram;
  final String? website;
  final String? youtube;
  final String? facebook;

  const SellerSocialLinks({
    this.telegram,
    this.instagram,
    this.website,
    this.youtube,
    this.facebook,
  });

  factory SellerSocialLinks.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SellerSocialLinks();
    String? pick(String key) {
      final v = json[key]?.toString().trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    return SellerSocialLinks(
      telegram: pick('telegram'),
      instagram: pick('instagram'),
      website: pick('website'),
      youtube: pick('youtube'),
      facebook: pick('facebook'),
    );
  }

  bool get hasAny =>
      [telegram, instagram, website, youtube, facebook].any((v) => v != null);

  Map<String, String?> toJson() => {
        'telegram': telegram,
        'instagram': instagram,
        'website': website,
        'youtube': youtube,
        'facebook': facebook,
      };
}

class SellerPrivacySettings {
  final bool showPhone;
  final bool showEmail;
  final bool showLocation;
  final bool allowMessages;

  const SellerPrivacySettings({
    this.showPhone = false,
    this.showEmail = false,
    this.showLocation = true,
    this.allowMessages = true,
  });

  factory SellerPrivacySettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SellerPrivacySettings();
    return SellerPrivacySettings(
      showPhone: json['showPhone'] == true,
      showEmail: json['showEmail'] == true,
      showLocation: json['showLocation'] != false,
      allowMessages: json['allowMessages'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'showPhone': showPhone,
        'showEmail': showEmail,
        'showLocation': showLocation,
        'allowMessages': allowMessages,
      };
}

class SellerStoreStats {
  final int totalProducts;
  final int activeProducts;
  final int categoriesCount;
  final int profileViews;

  const SellerStoreStats({
    required this.totalProducts,
    required this.activeProducts,
    required this.categoriesCount,
    required this.profileViews,
  });

  factory SellerStoreStats.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return SellerStoreStats(
      totalProducts: n(json['totalProducts']),
      activeProducts: n(json['activeProducts']),
      categoriesCount: n(json['categoriesCount']),
      profileViews: n(json['profileViews']),
    );
  }
}

class SellerCategoryStat {
  final String categoryId;
  final String name;
  final String? slug;
  final int productCount;

  const SellerCategoryStat({
    required this.categoryId,
    required this.name,
    this.slug,
    required this.productCount,
  });

  factory SellerCategoryStat.fromJson(Map<String, dynamic> json) {
    return SellerCategoryStat(
      categoryId: json['categoryId']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class SellerStoreProfile {
  final String id;
  final String name;
  final String? image;
  final String? banner;
  final String? phone;
  final String? country;
  final String? region;
  final String? city;
  final String? address;
  final SellerSocialLinks? socialLinks;
  final bool verified;
  final DateTime createdAt;
  final SellerStoreStats stats;
  final List<SellerCategoryStat> categories;
  final bool isOwnProfile;
  final bool allowMessages;

  const SellerStoreProfile({
    required this.id,
    required this.name,
    this.image,
    this.banner,
    this.phone,
    this.country,
    this.region,
    this.city,
    this.address,
    this.socialLinks,
    this.verified = false,
    required this.createdAt,
    required this.stats,
    this.categories = const [],
    this.isOwnProfile = false,
    this.allowMessages = true,
  });

  factory SellerStoreProfile.fromJson(Map<String, dynamic> json) {
    return SellerStoreProfile(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      banner: json['banner']?.toString(),
      phone: json['phone']?.toString(),
      country: json['country']?.toString(),
      region: json['region']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      socialLinks: json['socialLinks'] != null
          ? SellerSocialLinks.fromJson(
              Map<String, dynamic>.from(json['socialLinks'] as Map),
            )
          : null,
      verified: json['verified'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      stats: SellerStoreStats.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map? ?? {}),
      ),
      categories: (json['categories'] as List? ?? [])
          .map((e) => SellerCategoryStat.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
      isOwnProfile: json['isOwnProfile'] == true,
      allowMessages: json['allowMessages'] != false,
    );
  }

  SellerStoreProfile copyWith({
    SellerStoreStats? stats,
  }) {
    return SellerStoreProfile(
      id: id,
      name: name,
      image: image,
      banner: banner,
      phone: phone,
      country: country,
      region: region,
      city: city,
      address: address,
      socialLinks: socialLinks,
      verified: verified,
      createdAt: createdAt,
      stats: stats ?? this.stats,
      categories: categories,
      isOwnProfile: isOwnProfile,
      allowMessages: allowMessages,
    );
  }

  String? get locationLabel {
    final parts = [
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
      if (region != null && region!.trim().isNotEmpty) region!.trim(),
      if (country != null && country!.trim().isNotEmpty) country!.trim(),
    ];
    if (parts.isEmpty && address != null && address!.trim().isNotEmpty) {
      return address!.trim();
    }
    return parts.isEmpty ? null : parts.join(', ');
  }
}
