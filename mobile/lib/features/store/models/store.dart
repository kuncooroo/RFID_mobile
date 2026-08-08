/// Merchant / store profile from Store Detail screens.
class Store {
  const Store({
    required this.id,
    required this.name,
    this.logoUrl,
    this.bannerUrl,
    this.description,
    this.isVerified = false,
    this.productCount = 0,
    this.followersCount = 0,
    this.rating = 0,
    this.location,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String? bannerUrl;
  final String? description;
  final bool isVerified;
  final int productCount;
  final int followersCount;
  final double rating;
  final String? location;

  Store copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? bannerUrl,
    String? description,
    bool? isVerified,
    int? productCount,
    int? followersCount,
    double? rating,
    String? location,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
      productCount: productCount ?? this.productCount,
      followersCount: followersCount ?? this.followersCount,
      rating: rating ?? this.rating,
      location: location ?? this.location,
    );
  }

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? json['avatar'] as String?,
      bannerUrl: json['banner_url'] as String?,
      description: json['description'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      productCount:
          (json['product_count'] as num?)?.toInt() ??
          (json['products_count'] as num?)?.toInt() ??
          0,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'description': description,
      'is_verified': isVerified,
      'product_count': productCount,
      'followers_count': followersCount,
      'rating': rating,
      'location': location,
    };
  }
}
