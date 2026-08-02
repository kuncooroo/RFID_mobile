import '../../product/models/product.dart';
import '../models/search_filter.dart';

/// Contract for Search suggestions, history, and product queries.
abstract class SearchRepository {
  Future<List<String>> fetchRecent();

  Future<List<String>> fetchSuggestions(String query);

  Future<List<Product>> search(SearchFilter filter);

  Future<void> saveRecentQuery(String query);

  Future<void> clearRecent();

  Future<void> removeRecentQuery(String query);
}
