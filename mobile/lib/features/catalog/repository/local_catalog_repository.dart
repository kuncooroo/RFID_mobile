import '../../product/models/product.dart';
import '../models/catalog_feed.dart';
import '../models/category.dart';
import 'catalog_repository.dart';
import 'mock_catalog_repository.dart';

/// Local catalog stand-in until Laravel category endpoints are wired.
class LocalCatalogRepository implements CatalogRepository {
  LocalCatalogRepository() : _delegate = MockCatalogRepository();

  final MockCatalogRepository _delegate;

  @override
  Future<CatalogFeed> fetchCatalog() => _delegate.fetchCatalog();

  @override
  Future<Category?> fetchCategory(String categoryId) =>
      _delegate.fetchCategory(categoryId);

  @override
  Future<List<Product>> fetchProducts({String? categoryId}) =>
      _delegate.fetchProducts(categoryId: categoryId);

  @override
  Future<void> toggleFavorite(String productId) =>
      _delegate.toggleFavorite(productId);
}
