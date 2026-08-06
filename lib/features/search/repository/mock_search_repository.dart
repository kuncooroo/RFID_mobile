import '../../product/models/product.dart';
import '../models/search_filter.dart';
import 'search_repository.dart';

/// Seeded search repository for tests and UI demos (Figma Search / Filter).
class MockSearchRepository implements SearchRepository {
  MockSearchRepository({
    this.delay = const Duration(milliseconds: 350),
    this.shouldFail = false,
  }) : _recentQueries = List<String>.from(_seedRecentQueries);

  final Duration delay;
  final bool shouldFail;
  final List<String> _recentQueries;
  final List<Product> _products = List<Product>.from(_seedProducts);
  final Set<String> _favoriteIds = {};

  static const filterColors = <SearchColorOption>[
    SearchColorOption(id: 'black', name: 'Black', hex: '#1A1A1A'),
    SearchColorOption(id: 'white', name: 'White', hex: '#F5F5F5'),
    SearchColorOption(id: 'red', name: 'Red', hex: '#E53935'),
    SearchColorOption(id: 'blue', name: 'Blue', hex: '#1E88E5'),
    SearchColorOption(id: 'green', name: 'Green', hex: '#43A047'),
    SearchColorOption(id: 'purple', name: 'Purple', hex: '#514EB7'),
  ];

  static const filterLocations = <String>[
    'Jakarta',
    'Bandung',
    'Surabaya',
    'Bali',
    'Yogyakarta',
  ];

  @override
  Future<List<String>> fetchRecent() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load recent searches');
    return List<String>.unmodifiable(_recentQueries);
  }

  @override
  Future<List<String>> fetchPopular() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (shouldFail) throw StateError('Unable to load popular searches');
    return List<String>.unmodifiable(_seedPopularQueries);
  }

  @override
  Future<List<String>> fetchSuggestions(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (shouldFail) throw StateError('Unable to load suggestions');
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const [];

    final productHints = _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(trimmed) ||
              (p.brand?.toLowerCase().contains(trimmed) ?? false),
        )
        .map((p) => p.name)
        .toList();

    final recentHints = _recentQueries
        .where((q) => q.toLowerCase().contains(trimmed))
        .toList();

    final popularHints = _seedPopularQueries
        .where((q) => q.toLowerCase().contains(trimmed))
        .toList();

    final combined = <String>{...recentHints, ...popularHints, ...productHints};
    return combined.take(8).toList();
  }

  @override
  Future<SearchFilterOptions> fetchFilterOptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return const SearchFilterOptions(
      colors: filterColors,
      locations: filterLocations,
      minPrice: 0,
      maxPrice: 300,
    );
  }

  @override
  Future<List<Product>> search(SearchFilter filter) async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to search products');

    var results = List<Product>.from(_products);
    final query = filter.query.trim().toLowerCase();

    if (query.isNotEmpty) {
      results = results
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                (p.brand?.toLowerCase().contains(query) ?? false) ||
                (p.categoryId?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    if (filter.categoryId != null && filter.categoryId!.isNotEmpty) {
      results = results
          .where((p) => p.categoryId == filter.categoryId)
          .toList();
    }

    if (filter.storeId != null && filter.storeId!.isNotEmpty) {
      results = results.where((p) => p.storeId == filter.storeId).toList();
    }

    if (filter.minPrice != null) {
      results = results
          .where((p) => p.displayPrice >= filter.minPrice!)
          .toList();
    }

    if (filter.maxPrice != null) {
      results = results
          .where((p) => p.displayPrice <= filter.maxPrice!)
          .toList();
    }

    if (filter.colorIds.isNotEmpty) {
      results = results.where((p) {
        final productColorIds = p.colors.map((c) => c.id).toSet();
        return filter.colorIds.any(productColorIds.contains);
      }).toList();
    }

    if (filter.locations.isNotEmpty) {
      results = results.where((p) {
        final locations = _productLocations[p.id] ?? const [];
        return filter.locations.any(locations.contains);
      }).toList();
    }

    results = _sortResults(results, filter.sort);
    return List<Product>.unmodifiable(
      results.map(
        (p) => p.copyWith(isFavorite: _favoriteIds.contains(p.id)),
      ),
    );
  }

  @override
  Future<void> saveRecentQuery(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _recentQueries.removeWhere((q) => q.toLowerCase() == trimmed.toLowerCase());
    _recentQueries.insert(0, trimmed);
    if (_recentQueries.length > 10) {
      _recentQueries.removeRange(10, _recentQueries.length);
    }
  }

  @override
  Future<void> clearRecent() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _recentQueries.clear();
  }

  @override
  Future<void> removeRecentQuery(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _recentQueries.removeWhere((q) => q == query);
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
  }

  List<Product> _sortResults(List<Product> items, SearchSort sort) {
    final sorted = List<Product>.from(items);
    switch (sort) {
      case SearchSort.all:
        return sorted;
      case SearchSort.latest:
        sorted.sort((a, b) => b.id.compareTo(a.id));
        return sorted;
      case SearchSort.mostPopular:
        sorted.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        return sorted;
      case SearchSort.cheapest:
        sorted.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
        return sorted;
    }
  }
}

const _seedRecentQueries = <String>[
  'sneakers',
  'watch',
  'bag',
  'lipstick',
  'boots',
];

const _seedPopularQueries = <String>[
  'new arrivals',
  'summer dress',
  'running shoes',
  'tote bag',
  'leather jacket',
];

const _productLocations = <String, List<String>>{
  'p1': ['Jakarta', 'Bandung'],
  'p2': ['Jakarta', 'Surabaya'],
  'p3': ['Bandung', 'Bali'],
  'p4': ['Jakarta', 'Yogyakarta'],
  'p5': ['Surabaya', 'Bali'],
  'p6': ['Jakarta', 'Bandung'],
  'p7': ['Bandung', 'Yogyakarta'],
  'p8': ['Jakarta', 'Surabaya'],
};

const _seedProducts = <Product>[
  Product(
    id: 'p1',
    name: 'Quilted Mini Bag',
    brand: 'Maison Noir',
    price: 128,
    categoryId: 'cat-bags',
    storeId: 'store-maison-noir',
    rating: 4.8,
    reviewCount: 124,
    stock: 12,
    imageUrl: 'https://picsum.photos/seed/kutuku-p1/600/600',
    colors: [
      ProductColor(id: 'black', name: 'Black', hex: '#1A1A1A'),
      ProductColor(id: 'purple', name: 'Purple', hex: '#514EB7'),
    ],
  ),
  Product(
    id: 'p2',
    name: 'Classic Leather Watch',
    brand: 'Tempo',
    price: 210,
    discountPrice: 179,
    categoryId: 'cat-fashion',
    storeId: 'store-urban-lab',
    rating: 4.6,
    reviewCount: 89,
    stock: 8,
    imageUrl: 'https://picsum.photos/seed/kutuku-p2/600/600',
    colors: [
      ProductColor(id: 'black', name: 'Black', hex: '#1A1A1A'),
      ProductColor(id: 'blue', name: 'Blue', hex: '#1E88E5'),
    ],
  ),
  Product(
    id: 'p3',
    name: 'City Runner Sneakers',
    brand: 'Stride',
    price: 96,
    categoryId: 'cat-shoes',
    storeId: 'store-urban-lab',
    rating: 4.5,
    reviewCount: 210,
    stock: 20,
    imageUrl: 'https://picsum.photos/seed/kutuku-p3/600/600',
    colors: [
      ProductColor(id: 'white', name: 'White', hex: '#F5F5F5'),
      ProductColor(id: 'red', name: 'Red', hex: '#E53935'),
    ],
  ),
  Product(
    id: 'p4',
    name: 'Silk Scarf',
    brand: 'Luma',
    price: 48,
    categoryId: 'cat-fashion',
    storeId: 'store-maison-noir',
    rating: 4.7,
    reviewCount: 56,
    stock: 30,
    imageUrl: 'https://picsum.photos/seed/kutuku-p4/600/600',
    colors: [
      ProductColor(id: 'red', name: 'Red', hex: '#E53935'),
      ProductColor(id: 'green', name: 'Green', hex: '#43A047'),
    ],
  ),
  Product(
    id: 'p5',
    name: 'Crossbody Tote',
    brand: 'Carry Co',
    price: 74,
    categoryId: 'cat-bags',
    storeId: 'store-maison-noir',
    rating: 4.4,
    reviewCount: 41,
    stock: 15,
    imageUrl: 'https://picsum.photos/seed/kutuku-p5/600/600',
    colors: [
      ProductColor(id: 'green', name: 'Green', hex: '#43A047'),
      ProductColor(id: 'black', name: 'Black', hex: '#1A1A1A'),
    ],
  ),
  Product(
    id: 'p6',
    name: 'Matte Lipstick Set',
    brand: 'Bloom',
    price: 36,
    categoryId: 'cat-beauty',
    storeId: 'store-urban-lab',
    rating: 4.9,
    reviewCount: 302,
    stock: 50,
    imageUrl: 'https://picsum.photos/seed/kutuku-p6/600/600',
    colors: [
      ProductColor(id: 'red', name: 'Red', hex: '#E53935'),
      ProductColor(id: 'purple', name: 'Purple', hex: '#514EB7'),
    ],
  ),
  Product(
    id: 'p7',
    name: 'Chelsea Boots',
    brand: 'Stride',
    price: 145,
    categoryId: 'cat-shoes',
    storeId: 'store-urban-lab',
    rating: 4.6,
    reviewCount: 77,
    stock: 9,
    imageUrl: 'https://picsum.photos/seed/kutuku-p7/600/600',
    colors: [
      ProductColor(id: 'black', name: 'Black', hex: '#1A1A1A'),
      ProductColor(id: 'blue', name: 'Blue', hex: '#1E88E5'),
    ],
  ),
  Product(
    id: 'p8',
    name: 'Linen Shirt',
    brand: 'Luma',
    price: 58,
    discountPrice: 49,
    categoryId: 'cat-fashion',
    storeId: 'store-maison-noir',
    rating: 4.3,
    reviewCount: 63,
    stock: 22,
    imageUrl: 'https://picsum.photos/seed/kutuku-p8/600/600',
    colors: [
      ProductColor(id: 'white', name: 'White', hex: '#F5F5F5'),
      ProductColor(id: 'blue', name: 'Blue', hex: '#1E88E5'),
    ],
  ),
];
