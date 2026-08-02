import '../models/product.dart';
import 'product_repository.dart';

/// Seeded product detail data for tests and UI demos.
class MockProductRepository implements ProductRepository {
  MockProductRepository({
    this.delay = const Duration(milliseconds: 400),
    this.shouldFail = false,
  });

  final Duration delay;
  final bool shouldFail;

  final Set<String> _favoriteIds = {};

  @override
  Future<Product> fetchProduct(String id) async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw StateError('Unable to load product');
    }

    final product = _seedProducts.where((p) => p.id == id).firstOrNull;
    if (product == null) {
      throw StateError('Product not found: $id');
    }

    return product.copyWith(isFavorite: _favoriteIds.contains(id));
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
  }
}

/// Shared seed products with rich detail for Product Detail screens.
const seedProductDetails = <Product>[
  Product(
    id: 'p1',
    name: 'Quilted Mini Bag',
    brand: 'Maison Noir',
    price: 128,
    description:
        'A compact quilted mini bag crafted from soft vegan leather with a gold-tone chain strap. '
        'Perfect for evenings out or minimalist daily carry. Features an interior zip pocket and '
        'magnetic flap closure for secure storage.',
    imageUrl: 'https://picsum.photos/seed/kutuku-p1/600/600',
    images: [
      'https://picsum.photos/seed/kutuku-p1/600/600',
      'https://picsum.photos/seed/kutuku-p1a/600/600',
      'https://picsum.photos/seed/kutuku-p1b/600/600',
    ],
    categoryId: 'cat-bags',
    storeId: 'store-maison-noir',
    rating: 4.8,
    reviewCount: 124,
    stock: 12,
    colors: [
      ProductColor(id: 'c1-black', name: 'Black', hex: '#21201E'),
      ProductColor(id: 'c1-cream', name: 'Cream', hex: '#F5F0E8'),
      ProductColor(id: 'c1-burgundy', name: 'Burgundy', hex: '#6B2737'),
    ],
    sizes: [],
  ),
  Product(
    id: 'p2',
    name: 'Classic Leather Watch',
    brand: 'Tempo',
    price: 210,
    discountPrice: 179,
    description:
        'Minimalist leather-strap watch with a brushed stainless case and sapphire crystal. '
        'Water resistant to 50m with Japanese quartz movement for reliable precision.',
    imageUrl: 'https://picsum.photos/seed/kutuku-p2/600/600',
    images: [
      'https://picsum.photos/seed/kutuku-p2/600/600',
      'https://picsum.photos/seed/kutuku-p2a/600/600',
    ],
    categoryId: 'cat-fashion',
    storeId: 'store-urban-lab',
    rating: 4.6,
    reviewCount: 89,
    stock: 8,
    colors: [
      ProductColor(id: 'c2-silver', name: 'Silver', hex: '#C0C0C0'),
      ProductColor(id: 'c2-gold', name: 'Gold', hex: '#D4AF37'),
    ],
    sizes: [],
  ),
  Product(
    id: 'p3',
    name: 'City Runner Sneakers',
    brand: 'Stride',
    price: 96,
    description:
        'Lightweight city runners with breathable mesh upper and responsive foam midsole. '
        'Designed for all-day comfort on urban commutes. Reflective accents for low-light visibility.',
    imageUrl: 'https://picsum.photos/seed/kutuku-p3/600/600',
    images: [
      'https://picsum.photos/seed/kutuku-p3/600/600',
      'https://picsum.photos/seed/kutuku-p3a/600/600',
      'https://picsum.photos/seed/kutuku-p3b/600/600',
      'https://picsum.photos/seed/kutuku-p3c/600/600',
    ],
    categoryId: 'cat-shoes',
    storeId: 'store-urban-lab',
    rating: 4.5,
    reviewCount: 210,
    stock: 20,
    colors: [
      ProductColor(id: 'c3-white', name: 'White', hex: '#FFFFFF'),
      ProductColor(id: 'c3-navy', name: 'Navy', hex: '#1B2A4A'),
      ProductColor(id: 'c3-grey', name: 'Grey', hex: '#9E9E9E'),
    ],
    sizes: ['38', '39', '40', '41', '42', '43'],
  ),
  Product(
    id: 'p4',
    name: 'Silk Scarf',
    brand: 'Luma',
    price: 48,
    description:
        'Hand-finished silk scarf with an abstract botanical print. Lightweight and versatile — '
        'wear it around the neck, as a head wrap, or tied to your bag.',
    imageUrl: 'https://picsum.photos/seed/kutuku-p4/600/600',
    images: [
      'https://picsum.photos/seed/kutuku-p4/600/600',
      'https://picsum.photos/seed/kutuku-p4a/600/600',
    ],
    categoryId: 'cat-fashion',
    storeId: 'store-maison-noir',
    rating: 4.7,
    reviewCount: 56,
    stock: 30,
    colors: [
      ProductColor(id: 'c4-rose', name: 'Rose', hex: '#E8A0BF'),
      ProductColor(id: 'c4-sage', name: 'Sage', hex: '#8FA68E'),
    ],
    sizes: [],
  ),
  Product(
    id: 'p5',
    name: 'Crossbody Tote',
    brand: 'Carry Co',
    price: 74,
    description:
        'Structured crossbody tote in durable canvas with leather trim. Adjustable strap and '
        'multiple interior compartments keep essentials organized on the go.',
    imageUrl: 'https://picsum.photos/seed/kutuku-p5/600/600',
    images: [
      'https://picsum.photos/seed/kutuku-p5/600/600',
      'https://picsum.photos/seed/kutuku-p5a/600/600',
    ],
    categoryId: 'cat-bags',
    storeId: 'store-maison-noir',
    rating: 4.4,
    reviewCount: 41,
    stock: 15,
    colors: [
      ProductColor(id: 'c5-tan', name: 'Tan', hex: '#C4A77D'),
      ProductColor(id: 'c5-black', name: 'Black', hex: '#21201E'),
    ],
    sizes: [],
  ),
  Product(
    id: 'p6',
    name: 'Matte Lipstick Set',
    brand: 'Bloom',
    price: 36,
    description:
        'A curated trio of long-wear matte lipsticks in universally flattering shades. '
        'Creamy formula with a velvety finish that lasts up to 8 hours without drying.',
    imageUrl: 'https://picsum.photos/seed/kutuku-p6/600/600',
    images: [
      'https://picsum.photos/seed/kutuku-p6/600/600',
      'https://picsum.photos/seed/kutuku-p6a/600/600',
    ],
    categoryId: 'cat-beauty',
    storeId: 'store-urban-lab',
    rating: 4.9,
    reviewCount: 302,
    stock: 50,
    colors: [
      ProductColor(id: 'c6-set', name: 'Classic Set', hex: '#C0392B'),
    ],
    sizes: [],
  ),
  Product(
    id: 'p7',
    name: 'Chelsea Boots',
    brand: 'Stride',
    price: 145,
    description:
        'Classic Chelsea boots in polished leather with elastic side panels and pull tab. '
        'Goodyear-welted sole for durability and easy resoling.',
    imageUrl: 'https://picsum.photos/seed/kutuku-p7/600/600',
    images: [
      'https://picsum.photos/seed/kutuku-p7/600/600',
      'https://picsum.photos/seed/kutuku-p7a/600/600',
      'https://picsum.photos/seed/kutuku-p7b/600/600',
    ],
    categoryId: 'cat-shoes',
    storeId: 'store-urban-lab',
    rating: 4.6,
    reviewCount: 77,
    stock: 9,
    colors: [
      ProductColor(id: 'c7-brown', name: 'Brown', hex: '#5C4033'),
      ProductColor(id: 'c7-black', name: 'Black', hex: '#21201E'),
    ],
    sizes: ['39', '40', '41', '42', '43', '44'],
  ),
  Product(
    id: 'p8',
    name: 'Linen Shirt',
    brand: 'Luma',
    price: 58,
    discountPrice: 49,
    description:
        'Relaxed-fit linen shirt with a soft washed finish. Breathable and perfect for warm weather. '
        'Mother-of-pearl buttons and a curved hem for a refined casual look.',
    imageUrl: 'https://picsum.photos/seed/kutuku-p8/600/600',
    images: [
      'https://picsum.photos/seed/kutuku-p8/600/600',
      'https://picsum.photos/seed/kutuku-p8a/600/600',
    ],
    categoryId: 'cat-fashion',
    storeId: 'store-maison-noir',
    rating: 4.3,
    reviewCount: 63,
    stock: 22,
    colors: [
      ProductColor(id: 'c8-white', name: 'White', hex: '#FFFFFF'),
      ProductColor(id: 'c8-sky', name: 'Sky', hex: '#87CEEB'),
      ProductColor(id: 'c8-stone', name: 'Stone', hex: '#B8B0A4'),
    ],
    sizes: ['S', 'M', 'L', 'XL'],
  ),
];

final List<Product> _seedProducts = List<Product>.from(seedProductDetails);
