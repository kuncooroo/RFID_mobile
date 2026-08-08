import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../../product/models/product.dart';
import '../models/catalog_feed.dart';
import '../models/category.dart';
import 'catalog_repository.dart';

class RemoteCatalogRepository implements CatalogRepository {
  RemoteCatalogRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<CatalogFeed> fetchCatalog() async {
    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.categories,
      parser: _asList,
    );
    return CatalogFeed(
      categories: list.map(Category.fromJson).toList(),
    );
  }

  @override
  Future<Category?> fetchCategory(String categoryId) async {
    try {
      final data = await _api.get<Map<String, dynamic>>(
        ApiEndpoints.category(categoryId),
        parser: _asMap,
      );
      return Category.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Product>> fetchProducts({String? categoryId}) async {
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'cat-all') {
      final list = await _api.get<List<Map<String, dynamic>>>(
        ApiEndpoints.categoryProducts(categoryId),
        parser: _asList,
      );
      return list.map(Product.fromJson).toList();
    }

    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.products,
      parser: _asList,
    );
    return list.map(Product.fromJson).toList();
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

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
