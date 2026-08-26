import '../../product/models/product.dart';
import '../models/search_filter.dart';

/// Contract for Search suggestions, history, filters, and product queries.
abstract class SearchRepository {
  Future<List<String>> fetchRecent();

  Future<List<String>> fetchPopular();

  Future<List<String>> fetchSuggestions(String query);

  Future<SearchFilterOptions> fetchFilterOptions();

  Future<List<Product>> search(SearchFilter filter);

  Future<void> saveRecentQuery(String query);

  Future<void> clearRecent();

  Future<void> removeRecentQuery(String query);

  Future<void> toggleFavorite(String productId);
}
