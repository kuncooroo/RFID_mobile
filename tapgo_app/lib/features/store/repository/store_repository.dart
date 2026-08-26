import '../../product/models/product.dart';
import '../models/store.dart';

/// Store detail data access.
abstract class StoreRepository {
  Future<Store> fetchStore(String id);

  Future<List<Product>> fetchStoreProducts(String id);

  Future<bool> isFollowing(String storeId);

  Future<void> toggleFollow(String storeId);

  Future<void> toggleFavorite(String productId);
}
