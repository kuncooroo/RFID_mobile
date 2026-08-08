import '../../product/models/product.dart';
import '../../product/repository/mock_product_repository.dart';
import '../models/store.dart';
import 'store_repository.dart';

/// Seeded store detail data for tests and UI demos (Figma Store — Detail).
class MockStoreRepository implements StoreRepository {
  MockStoreRepository({
    this.delay = const Duration(milliseconds: 400),
    this.shouldFail = false,
  });

  final Duration delay;
  final bool shouldFail;

  final Set<String> _followingIds = {};
  final Set<String> _favoriteIds = {};

  @override
  Future<Store> fetchStore(String id) async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw StateError('Unable to load store');
    }

    final store = _seedStores.where((s) => s.id == id).firstOrNull;
    if (store == null) {
      throw StateError('Store not found: $id');
    }
    return store;
  }

  @override
  Future<List<Product>> fetchStoreProducts(String id) async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw StateError('Unable to load store products');
    }

    return seedProductDetails
        .where((p) => p.storeId == id)
        .map((p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id)))
        .toList();
  }

  @override
  Future<bool> isFollowing(String storeId) async {
    return _followingIds.contains(storeId);
  }

  @override
  Future<void> toggleFollow(String storeId) async {
    if (_followingIds.contains(storeId)) {
      _followingIds.remove(storeId);
    } else {
      _followingIds.add(storeId);
    }
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

const _seedStores = <Store>[
  Store(
    id: 'store-maison-noir',
    name: 'Maison Noir',
    logoUrl: 'https://picsum.photos/seed/kutuku-store-maison/200/200',
    bannerUrl: 'https://picsum.photos/seed/kutuku-store-maison-banner/800/320',
    description:
        'Curated luxury accessories and timeless fashion essentials. '
        'Maison Noir brings Parisian elegance to everyday style.',
    isVerified: true,
    productCount: 4,
    followersCount: 12840,
    rating: 4.8,
    location: 'Paris, France',
  ),
  Store(
    id: 'store-urban-lab',
    name: 'Urban Lab',
    logoUrl: 'https://picsum.photos/seed/kutuku-store-urban/200/200',
    bannerUrl: 'https://picsum.photos/seed/kutuku-store-urban-banner/800/320',
    description:
        'Street-inspired footwear and beauty drops for the modern city explorer. '
        'Urban Lab blends function with bold design.',
    isVerified: true,
    productCount: 4,
    followersCount: 9560,
    rating: 4.6,
    location: 'New York, USA',
  ),
];
