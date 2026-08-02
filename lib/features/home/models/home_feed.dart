import '../../catalog/models/category.dart';
import '../../product/models/product.dart';
import 'promotion.dart';

/// Aggregated payload for the Home tab (Home + Category segments).
class HomeFeed {
  const HomeFeed({
    this.promotions = const [],
    this.categories = const [],
    this.newArrivals = const [],
    this.categoryProducts = const [],
  });

  final List<Promotion> promotions;
  final List<Category> categories;
  final List<Product> newArrivals;

  /// Products shown when the Category segment is active.
  final List<Product> categoryProducts;

  bool get isEmpty =>
      promotions.isEmpty &&
      categories.isEmpty &&
      newArrivals.isEmpty &&
      categoryProducts.isEmpty;

  HomeFeed copyWith({
    List<Promotion>? promotions,
    List<Category>? categories,
    List<Product>? newArrivals,
    List<Product>? categoryProducts,
  }) {
    return HomeFeed(
      promotions: promotions ?? this.promotions,
      categories: categories ?? this.categories,
      newArrivals: newArrivals ?? this.newArrivals,
      categoryProducts: categoryProducts ?? this.categoryProducts,
    );
  }
}
