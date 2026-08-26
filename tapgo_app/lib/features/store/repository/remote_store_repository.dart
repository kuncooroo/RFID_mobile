import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../../product/models/product.dart';
import '../models/store.dart';
import 'store_repository.dart';

class RemoteStoreRepository implements StoreRepository {
  RemoteStoreRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;
  final Set<String> _following = {};

  @override
  Future<Store> fetchStore(String id) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.store(id),
      parser: (d) => d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{},
    );
    return Store.fromJson(data);
  }

  @override
  Future<List<Product>> fetchStoreProducts(String id) async {
    final data = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.storeProducts(id),
      parser: (d) {
        if (d is! List) return <Map<String, dynamic>>[];
        return d
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      },
    );
    return data.map(Product.fromJson).toList();
  }

  @override
  Future<bool> isFollowing(String storeId) async => _following.contains(storeId);

  @override
  Future<void> toggleFollow(String storeId) async {
    if (_following.contains(storeId)) {
      _following.remove(storeId);
    } else {
      _following.add(storeId);
    }
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
