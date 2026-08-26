import '../../product/models/product.dart';

/// Shopping cart aggregate for My Cart screens.
class Cart {
  const Cart({required this.id, this.items = const [], this.currency = 'USD'});

  final String id;
  final List<CartItem> items;
  final String currency;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  int get selectedCount =>
      items.where((item) => item.isSelected).fold(0, (s, i) => s + i.quantity);

  double get subtotal => items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.lineTotal);

  bool get isEmpty => items.isEmpty;

  Cart copyWith({String? id, List<CartItem>? items, String? currency}) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      currency: currency ?? this.currency,
    );
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    return Cart(
      id: json['id'].toString(),
      items: itemsJson is List
          ? itemsJson
                .whereType<Map>()
                .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'currency': currency,
    };
  }
}

/// Single selectable line item inside [Cart].
class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
    this.brand,
    this.colorName,
    this.size,
    this.isSelected = true,
    this.product,
    this.maxQuantity = 99,
  });

  final String id;
  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;
  final String? brand;
  final String? colorName;
  final String? size;
  final bool isSelected;
  final Product? product;
  final int maxQuantity;

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? unitPrice,
    int? quantity,
    String? imageUrl,
    String? brand,
    String? colorName,
    String? size,
    bool? isSelected,
    Product? product,
    int? maxQuantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      brand: brand ?? this.brand,
      colorName: colorName ?? this.colorName,
      size: size ?? this.size,
      isSelected: isSelected ?? this.isSelected,
      product: product ?? this.product,
      maxQuantity: maxQuantity ?? this.maxQuantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    return CartItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      name:
          json['name'] as String? ??
          (productJson is Map ? productJson['name'] as String? : null) ??
          '',
      unitPrice:
          (json['unit_price'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['image_url'] as String?,
      brand: json['brand'] as String?,
      colorName: json['color_name'] as String? ?? json['color'] as String?,
      size: json['size'] as String?,
      isSelected: json['is_selected'] as bool? ?? true,
      product: productJson is Map
          ? Product.fromJson(Map<String, dynamic>.from(productJson))
          : null,
      maxQuantity: (json['max_quantity'] as num?)?.toInt() ?? 99,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'unit_price': unitPrice,
      'quantity': quantity,
      'image_url': imageUrl,
      'brand': brand,
      'color_name': colorName,
      'size': size,
      'is_selected': isSelected,
      'product': product?.toJson(),
      'max_quantity': maxQuantity,
    };
  }
}
