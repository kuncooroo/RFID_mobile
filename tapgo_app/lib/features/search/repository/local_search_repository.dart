import '../../product/models/product.dart';
import '../models/search_filter.dart';
import 'mock_search_repository.dart';
import 'search_repository.dart';

/// Local search stand-in until Laravel search endpoints are wired.
class LocalSearchRepository implements SearchRepository {
  LocalSearchRepository() : _delegate = MockSearchRepository();

  final MockSearchRepository _delegate;

  @override
  Future<List<String>> fetchRecent() => _delegate.fetchRecent();

  @override
  Future<List<String>> fetchPopular() => _delegate.fetchPopular();

  @override
  Future<List<String>> fetchSuggestions(String query) =>
      _delegate.fetchSuggestions(query);

  @override
  Future<SearchFilterOptions> fetchFilterOptions() =>
      _delegate.fetchFilterOptions();

  @override
  Future<List<Product>> search(SearchFilter filter) =>
      _delegate.search(filter);

  @override
  Future<void> saveRecentQuery(String query) =>
      _delegate.saveRecentQuery(query);

  @override
  Future<void> clearRecent() => _delegate.clearRecent();

  @override
  Future<void> removeRecentQuery(String query) =>
      _delegate.removeRecentQuery(query);

  @override
  Future<void> toggleFavorite(String productId) =>
      _delegate.toggleFavorite(productId);
}
