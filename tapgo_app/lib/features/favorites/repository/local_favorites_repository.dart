import '../models/favorite.dart';
import 'favorites_repository.dart';
import 'mock_favorites_repository.dart';

/// Local favorites stand-in until Laravel favorites endpoints are wired.
class LocalFavoritesRepository implements FavoritesRepository {
  LocalFavoritesRepository() : _delegate = MockFavoritesRepository();

  final MockFavoritesRepository _delegate;

  @override
  Future<List<Favorite>> fetchFavorites() => _delegate.fetchFavorites();

  @override
  Future<void> removeFavorite(String productId) =>
      _delegate.removeFavorite(productId);

  @override
  Future<void> clearFavorites() => _delegate.clearFavorites();
}
