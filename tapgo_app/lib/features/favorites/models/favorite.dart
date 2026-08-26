import '../../product/models/product.dart';

/// Saved product entry for My Favorite screens.
class Favorite {
  const Favorite({
    required this.id,
    required this.productId,
    this.product,
    this.createdAt,
  });

  final String id;
  final String productId;
  final Product? product;
  final DateTime? createdAt;

  Favorite copyWith({
    String? id,
    String? productId,
    Product? product,
    DateTime? createdAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Favorite.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    return Favorite(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      product: productJson is Map
          ? Product.fromJson(Map<String, dynamic>.from(productJson))
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product': product?.toJson(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
