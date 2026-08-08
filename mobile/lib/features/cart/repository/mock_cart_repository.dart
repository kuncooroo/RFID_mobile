import '../../product/models/product.dart';
import '../models/cart.dart';
import 'cart_repository.dart';

/// Seeded cart repository for tests and UI demos.
class MockCartRepository implements CartRepository {
  MockCartRepository({
    this.delay = const Duration(milliseconds: 350),
    this.shouldFail = false,
    Cart? initialCart,
  }) : _cart = initialCart ?? _seedCart();

  final Duration delay;
  final bool shouldFail;
  Cart _cart;

  @override
  Future<Cart> fetchCart() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load cart');
    return _cart;
  }

  @override
  Future<Cart> addItem({
    required Product product,
    int quantity = 1,
    String? colorName,
    String? size,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final existingIndex = _cart.items.indexWhere(
      (item) =>
          item.productId == product.id &&
          item.colorName == colorName &&
          item.size == size,
    );
    if (existingIndex >= 0) {
      final existing = _cart.items[existingIndex];
      final nextQty = (existing.quantity + quantity).clamp(
        1,
        existing.maxQuantity,
      );
      final items = [..._cart.items];
      items[existingIndex] = existing.copyWith(quantity: nextQty);
      _cart = _cart.copyWith(items: items);
      return _cart;
    }

    final item = CartItem(
      id: 'ci-${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      name: product.name,
      brand: product.brand,
      unitPrice: product.displayPrice,
      quantity: quantity.clamp(1, 99),
      imageUrl: product.primaryImage.isEmpty ? null : product.primaryImage,
      colorName: colorName,
      size: size,
      isSelected: true,
      product: product,
      maxQuantity: product.stock > 0 ? product.stock : 99,
    );
    _cart = _cart.copyWith(items: [..._cart.items, item]);
    return _cart;
  }

  @override
  Future<Cart> updateQty(String itemId, int quantity) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final items = _cart.items.map((item) {
      if (item.id != itemId) return item;
      final clamped = quantity.clamp(1, item.maxQuantity);
      return item.copyWith(quantity: clamped);
    }).toList();
    _cart = _cart.copyWith(items: items);
    return _cart;
  }

  @override
  Future<Cart> toggleSelect(String itemId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final items = _cart.items.map((item) {
      if (item.id != itemId) return item;
      return item.copyWith(isSelected: !item.isSelected);
    }).toList();
    _cart = _cart.copyWith(items: items);
    return _cart;
  }

  @override
  Future<Cart> selectAll(bool selected) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final items = _cart.items
        .map((item) => item.copyWith(isSelected: selected))
        .toList();
    _cart = _cart.copyWith(items: items);
    return _cart;
  }

  @override
  Future<Cart> removeItem(String itemId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final items = _cart.items.where((item) => item.id != itemId).toList();
    _cart = _cart.copyWith(items: items);
    return _cart;
  }

  @override
  Future<Cart> removeItems(List<String> itemIds) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final ids = itemIds.toSet();
    final items = _cart.items.where((item) => !ids.contains(item.id)).toList();
    _cart = _cart.copyWith(items: items);
    return _cart;
  }
}

Cart _seedCart() {
  return Cart(
    id: 'cart-1',
    items: _seedCartItems,
  );
}

final _seedCartItems = <CartItem>[
  CartItem(
    id: 'ci-1',
    productId: 'p1',
    name: 'Quilted Mini Bag',
    brand: 'Maison Noir',
    unitPrice: 128,
    quantity: 1,
    imageUrl: 'https://picsum.photos/seed/kutuku-p1/600/600',
    isSelected: true,
    product: const Product(
      id: 'p1',
      name: 'Quilted Mini Bag',
      brand: 'Maison Noir',
      price: 128,
      rating: 4.8,
      reviewCount: 124,
      stock: 12,
      imageUrl: 'https://picsum.photos/seed/kutuku-p1/600/600',
    ),
  ),
  CartItem(
    id: 'ci-2',
    productId: 'p2',
    name: 'Classic Leather Watch',
    brand: 'Tempo',
    unitPrice: 179,
    quantity: 1,
    imageUrl: 'https://picsum.photos/seed/kutuku-p2/600/600',
    isSelected: true,
    product: const Product(
      id: 'p2',
      name: 'Classic Leather Watch',
      brand: 'Tempo',
      price: 210,
      discountPrice: 179,
      rating: 4.6,
      reviewCount: 89,
      stock: 8,
      imageUrl: 'https://picsum.photos/seed/kutuku-p2/600/600',
    ),
  ),
  CartItem(
    id: 'ci-3',
    productId: 'p3',
    name: 'City Runner Sneakers',
    brand: 'Stride',
    unitPrice: 96,
    quantity: 2,
    colorName: 'White',
    size: '42',
    imageUrl: 'https://picsum.photos/seed/kutuku-p3/600/600',
    isSelected: false,
    product: const Product(
      id: 'p3',
      name: 'City Runner Sneakers',
      brand: 'Stride',
      price: 96,
      rating: 4.5,
      reviewCount: 210,
      stock: 20,
      imageUrl: 'https://picsum.photos/seed/kutuku-p3/600/600',
    ),
  ),
];
