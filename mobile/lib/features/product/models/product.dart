/// Sellable product shown on Home, Search, Store, Detail, Favorites, and Cart.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.brand,
    this.description,
    this.imageUrl,
    this.images = const [],
    this.categoryId,
    this.storeId,
    this.rating = 0,
    this.reviewCount = 0,
    this.stock = 0,
    this.isFavorite = false,
    this.colors = const [],
    this.sizes = const [],
    this.currency = 'USD',
    this.discountPrice,
  });

  final String id;
  final String name;
  final double price;
  final String? brand;
  final String? description;
  final String? imageUrl;
  final List<String> images;
  final String? categoryId;
  final String? storeId;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isFavorite;
  final List<ProductColor> colors;
  final List<String> sizes;
  final String currency;
  final double? discountPrice;

  bool get inStock => stock > 0;
  bool get hasDiscount =>
      discountPrice != null && discountPrice! > 0 && discountPrice! < price;
  double get displayPrice => hasDiscount ? discountPrice! : price;
  String get primaryImage =>
      imageUrl ?? (images.isNotEmpty ? images.first : '');

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? brand,
    String? description,
    String? imageUrl,
    List<String>? images,
    String? categoryId,
    String? storeId,
    double? rating,
    int? reviewCount,
    int? stock,
    bool? isFavorite,
    List<ProductColor>? colors,
    List<String>? sizes,
    String? currency,
    double? discountPrice,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      isFavorite: isFavorite ?? this.isFavorite,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      currency: currency ?? this.currency,
      discountPrice: discountPrice ?? this.discountPrice,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'];
    final colorsJson = json['colors'];
    final sizesJson = json['sizes'];

    return Product(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String? ?? json['thumbnail'] as String?,
      images: imagesJson is List
          ? imagesJson.map((e) => e.toString()).toList()
          : const [],
      categoryId: json['category_id']?.toString(),
      storeId: json['store_id']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount:
          (json['review_count'] as num?)?.toInt() ??
          (json['reviews_count'] as num?)?.toInt() ??
          0,
      stock:
          (json['stock'] as num?)?.toInt() ??
          (json['stock_quantity'] as num?)?.toInt() ??
          0,
      isFavorite: json['is_favorite'] as bool? ?? false,
      colors: colorsJson is List
          ? colorsJson
                .whereType<Map>()
                .map((e) => ProductColor.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      sizes: sizesJson is List
          ? sizesJson.map((e) => e.toString()).toList()
          : const [],
      currency: json['currency'] as String? ?? 'USD',
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'brand': brand,
      'description': description,
      'image_url': imageUrl,
      'images': images,
      'category_id': categoryId,
      'store_id': storeId,
      'rating': rating,
      'review_count': reviewCount,
      'stock': stock,
      'is_favorite': isFavorite,
      'colors': colors.map((e) => e.toJson()).toList(),
      'sizes': sizes,
      'currency': currency,
      'discount_price': discountPrice,
    };
  }
}

/// Color variant swatch on Product Detail / Filter.
class ProductColor {
  const ProductColor({required this.id, required this.name, required this.hex});

  final String id;
  final String name;
  final String hex;

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      hex: json['hex'] as String? ?? json['color'] as String? ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'hex': hex};
  }
}
