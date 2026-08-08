import '../models/home_feed.dart';

/// Contract for loading Home tab content.
abstract class HomeRepository {
  Future<HomeFeed> fetchHomeFeed();

  /// Optimistic local favorite toggle until Favorites feature owns persistence.
  Future<void> toggleFavorite(String productId);
}
