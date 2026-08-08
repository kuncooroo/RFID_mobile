import '../models/product.dart';
import '../models/review.dart';

/// Product detail data access.
abstract interface class ProductRepository {
  Future<Product> fetchProduct(String id);

  Future<List<Review>> fetchReviews(String productId);

  Future<void> toggleFavorite(String productId);
}
