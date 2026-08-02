import '../../product/models/product.dart';
import '../models/favorite.dart';
import 'favorites_repository.dart';

/// Seeded favorites repository for tests and UI demos.
class MockFavoritesRepository implements FavoritesRepository {
  MockFavoritesRepository({
    this.delay = const Duration(milliseconds: 350),
    this.shouldFail = false,
  }) : _items = List<Favorite>.from(_seedFavorites);

  final Duration delay;
  final bool shouldFail;
  final List<Favorite> _items;

  @override
  Future<List<Favorite>> fetchFavorites() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load favorites');
    return List<Favorite>.unmodifiable(_items);
  }

  @override
  Future<void> removeFavorite(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _items.removeWhere((f) => f.productId == productId || f.id == productId);
  }

  @override
  Future<void> clearFavorites() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _items.clear();
  }
}

final _seedFavorites = <Favorite>[
  Favorite(
    id: 'fav-1',
    productId: 'p1',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    product: const Product(
      id: 'p1',
      name: 'Quilted Mini Bag',
      brand: 'Maison Noir',
      price: 128,
      isFavorite: true,
      rating: 4.8,
      reviewCount: 124,
      stock: 12,
      imageUrl: 'https://picsum.photos/seed/kutuku-p1/600/600',
    ),
  ),
  Favorite(
    id: 'fav-2',
    productId: 'p2',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    product: const Product(
      id: 'p2',
      name: 'Classic Leather Watch',
      brand: 'Tempo',
      price: 210,
      discountPrice: 179,
      isFavorite: true,
      rating: 4.6,
      reviewCount: 89,
      stock: 8,
      imageUrl: 'https://picsum.photos/seed/kutuku-p2/600/600',
    ),
  ),
  Favorite(
    id: 'fav-3',
    productId: 'p3',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    product: const Product(
      id: 'p3',
      name: 'City Runner Sneakers',
      brand: 'Stride',
      price: 96,
      isFavorite: true,
      rating: 4.5,
      reviewCount: 210,
      stock: 20,
      imageUrl: 'https://picsum.photos/seed/kutuku-p3/600/600',
    ),
  ),
  Favorite(
    id: 'fav-4',
    productId: 'p6',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    product: const Product(
      id: 'p6',
      name: 'Matte Lipstick Set',
      brand: 'Bloom',
      price: 36,
      isFavorite: true,
      rating: 4.9,
      reviewCount: 302,
      stock: 50,
      imageUrl: 'https://picsum.photos/seed/kutuku-p6/600/600',
    ),
  ),
];
