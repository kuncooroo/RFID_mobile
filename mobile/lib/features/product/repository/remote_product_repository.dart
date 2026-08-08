import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../models/product.dart';
import 'product_repository.dart';

class RemoteProductRepository implements ProductRepository {
  RemoteProductRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<Product> fetchProduct(String id) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.product(id),
      parser: (d) => d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{},
    );
    return Product.fromJson(data);
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
}
