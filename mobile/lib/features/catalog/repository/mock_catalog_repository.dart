import '../../product/models/product.dart';
import '../models/catalog_feed.dart';
import '../models/category.dart';
import 'catalog_repository.dart';

/// Seeded catalog matching Kutuku Homescreen — Category banners.
class MockCatalogRepository implements CatalogRepository {
  MockCatalogRepository({
    this.delay = const Duration(milliseconds: 400),
    this.shouldFail = false,
  });

  final Duration delay;
  final bool shouldFail;

  late final List<Product> _products = List<Product>.from(_seedProducts);
  final Set<String> _favoriteIds = {};

  @override
  Future<CatalogFeed> fetchCatalog() async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw StateError('Unable to load catalog');
    }
    return const CatalogFeed(categories: _seedCategories);
  }

  @override
  Future<Category?> fetchCategory(String categoryId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (shouldFail) {
      throw StateError('Unable to load category');
    }
    for (final category in _seedCategories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  @override
  Future<List<Product>> fetchProducts({String? categoryId}) async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw StateError('Unable to load category products');
    }

    final products = _products
        .map((p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id)))
        .toList();

    if (categoryId == null ||
        categoryId.isEmpty ||
        categoryId == 'cat-all' ||
        categoryId == 'cat-new-arrivals') {
      return products;
    }

    return products.where((p) => p.categoryId == categoryId).toList();
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

/// Figma Homescreen Category banners (node 1:21).
const _seedCategories = <Category>[
  Category(
    id: 'cat-new-arrivals',
    name: 'New Arrivals',
    productCount: 208,
    sortOrder: 0,
    imageUrl: 'https://picsum.photos/seed/kutuku-cat-new/600/600',
  ),
  Category(
    id: 'cat-clothes',
    name: 'Clothes',
    productCount: 358,
    sortOrder: 1,
    imageUrl: 'https://picsum.photos/seed/kutuku-cat-clothes/600/600',
  ),
  Category(
    id: 'cat-bags',
    name: 'Bags',
    productCount: 160,
    sortOrder: 2,
    imageUrl: 'https://picsum.photos/seed/kutuku-cat-bags/600/600',
  ),
  Category(
    id: 'cat-shoes',
    name: 'Shoes',
    productCount: 230,
    sortOrder: 3,
    imageUrl: 'https://picsum.photos/seed/kutuku-cat-shoes/600/600',
  ),
  Category(
    id: 'cat-electronics',
    name: 'Electronics',
    productCount: 142,
    sortOrder: 4,
    imageUrl: 'https://picsum.photos/seed/kutuku-cat-electronics/600/600',
  ),
];

const _seedProducts = <Product>[
  Product(
    id: 'cp1',
    name: 'Oversized Cotton Tee',
    brand: 'Luma',
    price: 42,
    categoryId: 'cat-clothes',
    rating: 4.7,
    reviewCount: 186,
    stock: 40,
    imageUrl: 'https://picsum.photos/seed/kutuku-cp1/600/600',
  ),
  Product(
    id: 'cp2',
    name: 'Relaxed Linen Shirt',
    brand: 'Maison Noir',
    price: 68,
    discountPrice: 54,
    categoryId: 'cat-clothes',
    rating: 4.5,
    reviewCount: 92,
    stock: 18,
    imageUrl: 'https://picsum.photos/seed/kutuku-cp2/600/600',
  ),
  Product(
    id: 'cp3',
    name: 'Pleated Midi Dress',
    brand: 'Kutuku',
    price: 98,
    categoryId: 'cat-clothes',
    rating: 4.8,
    reviewCount: 214,
    stock: 12,
    imageUrl: 'https://picsum.photos/seed/kutuku-cp3/600/600',
  ),
  Product(
    id: 'cp4',
    name: 'Quilted Mini Bag',
    brand: 'Carry Co',
    price: 128,
    categoryId: 'cat-bags',
    rating: 4.8,
    reviewCount: 124,
    stock: 12,
    imageUrl: 'https://picsum.photos/seed/kutuku-cp4/600/600',
  ),
  Product(
    id: 'cp5',
    name: 'Crossbody Tote',
    brand: 'Carry Co',
    price: 74,
    categoryId: 'cat-bags',
    rating: 4.4,
    reviewCount: 41,
    stock: 15,
    imageUrl: 'https://picsum.photos/seed/kutuku-cp5/600/600',
  ),
  Product(
    id: 'cp6',
    name: 'City Runner Sneakers',
    brand: 'Stride',
    price: 96,
    categoryId: 'cat-shoes',
    rating: 4.5,
    reviewCount: 210,
    stock: 20,
    imageUrl: 'https://picsum.photos/seed/kutuku-cp6/600/600',
  ),
  Product(
    id: 'cp7',
    name: 'Chelsea Boots',
    brand: 'Stride',
    price: 145,
    categoryId: 'cat-shoes',
    rating: 4.6,
    reviewCount: 77,
    stock: 9,
    imageUrl: 'https://picsum.photos/seed/kutuku-cp7/600/600',
  ),
  Product(
    id: 'cp8',
    name: 'Studio Headphones',
    brand: 'Aural',
    price: 189,
    discountPrice: 159,
    categoryId: 'cat-electronics',
    rating: 4.9,
    reviewCount: 340,
    stock: 25,
    imageUrl: 'https://picsum.photos/seed/kutuku-cp8/600/600',
  ),
  Product(
    id: 'cp9',
    name: 'Wireless Earbuds',
    brand: 'Aural',
    price: 79,
    categoryId: 'cat-electronics',
    rating: 4.6,
    reviewCount: 158,
    stock: 60,
    imageUrl: 'https://picsum.photos/seed/kutuku-cp9/600/600',
  ),
  Product(
    id: 'cp10',
    name: 'Silk Scarf',
    brand: 'Luma',
    price: 48,
    categoryId: 'cat-clothes',
    rating: 4.7,
    reviewCount: 56,
    stock: 30,
    imageUrl: 'https://picsum.photos/seed/kutuku-cp10/600/600',
  ),
];
