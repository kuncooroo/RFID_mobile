/// Home promo carousel banner entity.
class Promotion {
  const Promotion({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.storeName,
    this.discountPercent,
    this.productId,
    this.storeId,
    this.deepLink,
    this.backgroundColor,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? storeName;
  final double? discountPercent;
  final String? productId;
  final String? storeId;
  final String? deepLink;
  final String? backgroundColor;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;

  Promotion copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? storeName,
    double? discountPercent,
    String? productId,
    String? storeId,
    String? deepLink,
    String? backgroundColor,
    bool? isActive,
    DateTime? startsAt,
    DateTime? endsAt,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      storeName: storeName ?? this.storeName,
      discountPercent: discountPercent ?? this.discountPercent,
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
      deepLink: deepLink ?? this.deepLink,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isActive: isActive ?? this.isActive,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
    );
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
      storeName: json['store_name'] as String?,
      discountPercent: (json['discount_percent'] as num?)?.toDouble(),
      productId: json['product_id']?.toString(),
      storeId: json['store_id']?.toString(),
      deepLink: json['deep_link'] as String?,
      backgroundColor: json['background_color'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      startsAt: json['starts_at'] != null
          ? DateTime.tryParse(json['starts_at'].toString())
          : null,
      endsAt: json['ends_at'] != null
          ? DateTime.tryParse(json['ends_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'store_name': storeName,
      'discount_percent': discountPercent,
      'product_id': productId,
      'store_id': storeId,
      'deep_link': deepLink,
      'background_color': backgroundColor,
      'is_active': isActive,
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
    };
  }
}
