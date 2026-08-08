import '../../catalog/models/category.dart';
import '../../product/models/product.dart';
import '../models/home_feed.dart';
import '../models/promotion.dart';
import 'home_repository.dart';

/// Seeded home feed for tests and UI demos.
class MockHomeRepository implements HomeRepository {
  MockHomeRepository({
    this.delay = const Duration(milliseconds: 450),
    this.shouldFail = false,
  });

  final Duration delay;
  final bool shouldFail;

  late final List<Product> _products = List<Product>.from(_seedProducts);
  final Set<String> _favoriteIds = {};

  @override
  Future<HomeFeed> fetchHomeFeed() async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw StateError('Unable to load home feed');
    }

    final products = _products
        .map((p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id)))
        .toList();

    return HomeFeed(
      promotions: _seedPromotions,
      categories: _seedCategories,
      newArrivals: products.take(6).toList(),
      categoryProducts: products,
    );
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

const _seedPromotions = <Promotion>[
  Promotion(
    id: 'promo-1',
    title: '30% Off Summer Sale',
    subtitle: 'On selected fashion items',
    storeName: 'Kutuku Store',
    discountPercent: 30,
    imageUrl: 'https://picsum.photos/seed/kutuku-promo1/800/400',
  ),
  Promotion(
    id: 'promo-2',
    title: 'New Arrivals Drop',
    subtitle: 'Fresh styles this week',
    storeName: 'Urban Lab',
    imageUrl: 'https://picsum.photos/seed/kutuku-promo2/800/400',
  ),
  Promotion(
    id: 'promo-3',
    title: 'Free Shipping',
    subtitle: 'Orders over \$50',
    storeName: 'Kutuku',
    imageUrl: 'https://picsum.photos/seed/kutuku-promo3/800/400',
  ),
];

const _seedCategories = <Category>[
  Category(id: 'cat-all', name: 'All', productCount: 8, sortOrder: 0),
  Category(id: 'cat-fashion', name: 'Fashion', productCount: 3, sortOrder: 1),
  Category(id: 'cat-shoes', name: 'Shoes', productCount: 2, sortOrder: 2),
  Category(id: 'cat-bags', name: 'Bags', productCount: 2, sortOrder: 3),
  Category(id: 'cat-beauty', name: 'Beauty', productCount: 1, sortOrder: 4),
];

const _seedProducts = <Product>[
  Product(
    id: 'p1',
    name: 'Quilted Mini Bag',
    brand: 'Maison Noir',
    price: 128,
    categoryId: 'cat-bags',
    rating: 4.8,
    reviewCount: 124,
    stock: 12,
    imageUrl: 'https://picsum.photos/seed/kutuku-p1/600/600',
  ),
  Product(
    id: 'p2',
    name: 'Classic Leather Watch',
    brand: 'Tempo',
    price: 210,
    discountPrice: 179,
    categoryId: 'cat-fashion',
    rating: 4.6,
    reviewCount: 89,
    stock: 8,
    imageUrl: 'https://picsum.photos/seed/kutuku-p2/600/600',
  ),
  Product(
    id: 'p3',
    name: 'City Runner Sneakers',
    brand: 'Stride',
    price: 96,
    categoryId: 'cat-shoes',
    rating: 4.5,
    reviewCount: 210,
    stock: 20,
    imageUrl: 'https://picsum.photos/seed/kutuku-p3/600/600',
  ),
  Product(
    id: 'p4',
    name: 'Silk Scarf',
    brand: 'Luma',
    price: 48,
    categoryId: 'cat-fashion',
    rating: 4.7,
    reviewCount: 56,
    stock: 30,
    imageUrl: 'https://picsum.photos/seed/kutuku-p4/600/600',
  ),
  Product(
    id: 'p5',
    name: 'Crossbody Tote',
    brand: 'Carry Co',
    price: 74,
    categoryId: 'cat-bags',
    rating: 4.4,
    reviewCount: 41,
    stock: 15,
    imageUrl: 'https://picsum.photos/seed/kutuku-p5/600/600',
  ),
  Product(
    id: 'p6',
    name: 'Matte Lipstick Set',
    brand: 'Bloom',
    price: 36,
    categoryId: 'cat-beauty',
    rating: 4.9,
    reviewCount: 302,
    stock: 50,
    imageUrl: 'https://picsum.photos/seed/kutuku-p6/600/600',
  ),
  Product(
    id: 'p7',
    name: 'Chelsea Boots',
    brand: 'Stride',
    price: 145,
    categoryId: 'cat-shoes',
    rating: 4.6,
    reviewCount: 77,
    stock: 9,
    imageUrl: 'https://picsum.photos/seed/kutuku-p7/600/600',
  ),
  Product(
    id: 'p8',
    name: 'Linen Shirt',
    brand: 'Luma',
    price: 58,
    discountPrice: 49,
    categoryId: 'cat-fashion',
    rating: 4.3,
    reviewCount: 63,
    stock: 22,
    imageUrl: 'https://picsum.photos/seed/kutuku-p8/600/600',
  ),
];
