import '../models/product.dart';
import 'product_repository.dart';
import 'mock_product_repository.dart';

/// Local product stand-in until Laravel product endpoints are wired.
class LocalProductRepository implements ProductRepository {
  LocalProductRepository() : _delegate = MockProductRepository();

  final MockProductRepository _delegate;

  @override
  Future<Product> fetchProduct(String id) => _delegate.fetchProduct(id);

  @override
  Future<void> toggleFavorite(String productId) =>
      _delegate.toggleFavorite(productId);
}
