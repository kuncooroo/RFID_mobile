import '../../product/models/product.dart';
import '../models/store.dart';
import 'mock_store_repository.dart';
import 'store_repository.dart';

/// Local store stand-in until Laravel store endpoints are wired.
class LocalStoreRepository implements StoreRepository {
  LocalStoreRepository() : _delegate = MockStoreRepository();

  final MockStoreRepository _delegate;

  @override
  Future<Store> fetchStore(String id) => _delegate.fetchStore(id);

  @override
  Future<List<Product>> fetchStoreProducts(String id) =>
      _delegate.fetchStoreProducts(id);

  @override
  Future<bool> isFollowing(String storeId) => _delegate.isFollowing(storeId);

  @override
  Future<void> toggleFollow(String storeId) =>
      _delegate.toggleFollow(storeId);

  @override
  Future<void> toggleFavorite(String productId) =>
      _delegate.toggleFavorite(productId);
}
