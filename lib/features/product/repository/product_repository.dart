import '../models/product.dart';

/// Product detail data access.
abstract interface class ProductRepository {
  Future<Product> fetchProduct(String id);

  Future<void> toggleFavorite(String productId);
}
