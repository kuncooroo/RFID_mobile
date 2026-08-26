/// Product catalog category used on Home Category tab and Search filters.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.slug,
    this.imageUrl,
    this.iconUrl,
    this.parentId,
    this.productCount = 0,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? slug;
  final String? imageUrl;
  final String? iconUrl;
  final String? parentId;
  final int productCount;
  final int sortOrder;
  final bool isActive;

  Category copyWith({
    String? id,
    String? name,
    String? slug,
    String? imageUrl,
    String? iconUrl,
    String? parentId,
    int? productCount,
    int? sortOrder,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      parentId: parentId ?? this.parentId,
      productCount: productCount ?? this.productCount,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
      iconUrl: json['icon_url'] as String?,
      parentId: json['parent_id']?.toString(),
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image_url': imageUrl,
      'icon_url': iconUrl,
      'parent_id': parentId,
      'product_count': productCount,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
