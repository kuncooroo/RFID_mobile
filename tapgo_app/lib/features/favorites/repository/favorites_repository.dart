import '../models/favorite.dart';

/// Contract for My Favorite list operations.
abstract class FavoritesRepository {
  Future<List<Favorite>> fetchFavorites();

  Future<void> removeFavorite(String productId);

  Future<void> clearFavorites();
}
