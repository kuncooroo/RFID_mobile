import '../../product/models/product.dart';
import '../models/store.dart';

/// Store detail data access.
abstract interface class StoreRepository {
  Future<Store> fetchStore(String id);

  Future<List<Product>> fetchStoreProducts(String id);

  Future<void> toggleFollow(String storeId);
}
