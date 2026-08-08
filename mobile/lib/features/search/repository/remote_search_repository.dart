import 'dart:convert';

import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../../../src/storage/secure_storage_service.dart';
import '../../product/models/product.dart';
import '../models/search_filter.dart';
import 'search_repository.dart';

class RemoteSearchRepository implements SearchRepository {
  RemoteSearchRepository({
    required ApiClient api,
    required SecureStorageService storage,
  }) : _api = api,
       _storage = storage;

  final ApiClient _api;
  final SecureStorageService _storage;
  static const _recentKey = 'search_recent_queries';

  @override
  Future<List<String>> fetchRecent() async {
    final raw = await _storage.read(_recentKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<String>> fetchPopular() async {
    final products = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.products,
      query: {'sort': 'rating', 'per_page': 8},
      parser: _asList,
    );
    return products
        .map((e) => e['name']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Future<List<String>> fetchSuggestions(String query) async {
    if (query.trim().isEmpty) return const [];
    final products = await search(SearchFilter(query: query));
    return products.map((p) => p.name).take(8).toList();
  }

  @override
  Future<SearchFilterOptions> fetchFilterOptions() async {
    return const SearchFilterOptions(
      colors: [],
      locations: ['Jakarta', 'Bandung', 'Surabaya'],
      minPrice: 0,
      maxPrice: 1000,
    );
  }

  @override
  Future<List<Product>> search(SearchFilter filter) async {
    final query = <String, dynamic>{
      if (filter.query.trim().isNotEmpty) 'q': filter.query.trim(),
      if (filter.categoryId != null) 'category_id': filter.categoryId,
      if (filter.storeId != null) 'store_id': filter.storeId,
      if (filter.minPrice != null) 'min_price': filter.minPrice,
      if (filter.maxPrice != null) 'max_price': filter.maxPrice,
      if (filter.colorIds.isNotEmpty) 'color_ids': filter.colorIds,
      if (filter.locations.isNotEmpty) 'locations': filter.locations,
      'sort': _mapSort(filter.sort),
      'per_page': 30,
    };

    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.products,
      query: query,
      parser: _asList,
    );
    return list.map(Product.fromJson).toList();
  }

  @override
  Future<void> saveRecentQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final recent = await fetchRecent();
    final next = [trimmed, ...recent.where((e) => e != trimmed)].take(10);
    await _storage.write(_recentKey, jsonEncode(next.toList()));
  }

  @override
  Future<void> clearRecent() async {
    await _storage.delete(_recentKey);
  }

  @override
  Future<void> removeRecentQuery(String query) async {
    final recent = await fetchRecent();
    final next = recent.where((e) => e != query).toList();
    await _storage.write(_recentKey, jsonEncode(next));
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    try {
      await _api.delete<dynamic>(ApiEndpoints.favoriteProduct(productId));
    } catch (_) {
      await _api.post<dynamic>(
        ApiEndpoints.favorites,
        data: {'product_id': int.tryParse(productId) ?? productId},
      );
    }
  }

  String _mapSort(SearchSort sort) {
    return switch (sort) {
      SearchSort.all => 'all',
      SearchSort.latest => 'newest',
      SearchSort.mostPopular => 'rating',
      SearchSort.cheapest => 'price_asc',
    };
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
