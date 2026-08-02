import '../../product/models/product.dart';
import '../../product/repository/mock_product_repository.dart';
import '../models/store.dart';
import 'store_repository.dart';

/// Seeded store detail data for tests and UI demos.
class MockStoreRepository implements StoreRepository {
  MockStoreRepository({
    this.delay = const Duration(milliseconds: 400),
    this.shouldFail = false,
  });

  final Duration delay;
  final bool shouldFail;

  final Set<String> _followingIds = {};

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
        .map((p) => p.copyWith())
        .toList();
  }

  @override
  Future<void> toggleFollow(String storeId) async {
    if (_followingIds.contains(storeId)) {
      _followingIds.remove(storeId);
    } else {
      _followingIds.add(storeId);
    }
  }

  bool isFollowing(String storeId) => _followingIds.contains(storeId);
}

const _seedStores = <Store>[
  Store(
    id: 'store-maison-noir',
    name: 'Maison Noir',
    logoUrl: 'https://picsum.photos/seed/kutuku-store-maison/200/200',
    bannerUrl: 'https://picsum.photos/seed/kutuku-store-maison-banner/800/300',
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
    bannerUrl: 'https://picsum.photos/seed/kutuku-store-urban-banner/800/300',
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
