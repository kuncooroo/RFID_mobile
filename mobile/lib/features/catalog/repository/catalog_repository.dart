import '../../product/models/product.dart';
import '../models/catalog_feed.dart';
import '../models/category.dart';

/// Contract for category browse and category product listings.
abstract class CatalogRepository {
  Future<CatalogFeed> fetchCatalog();

  Future<Category?> fetchCategory(String categoryId);

  Future<List<Product>> fetchProducts({String? categoryId});

  /// Optimistic local favorite toggle until Favorites feature owns persistence.
  Future<void> toggleFavorite(String productId);
}
