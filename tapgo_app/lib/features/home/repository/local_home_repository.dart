import '../models/home_feed.dart';
import 'home_repository.dart';
import 'mock_home_repository.dart';

/// Local home stand-in until Laravel home endpoints are wired.
class LocalHomeRepository implements HomeRepository {
  LocalHomeRepository() : _delegate = MockHomeRepository();

  final MockHomeRepository _delegate;

  @override
  Future<HomeFeed> fetchHomeFeed() => _delegate.fetchHomeFeed();

  @override
  Future<void> toggleFavorite(String productId) =>
      _delegate.toggleFavorite(productId);
}
