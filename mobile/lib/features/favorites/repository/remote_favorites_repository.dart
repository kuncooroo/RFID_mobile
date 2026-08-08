import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../models/favorite.dart';
import 'favorites_repository.dart';

class RemoteFavoritesRepository implements FavoritesRepository {
  RemoteFavoritesRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<List<Favorite>> fetchFavorites() async {
    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.favorites,
      parser: _asList,
    );
    return list.map(Favorite.fromJson).toList();
  }

  @override
  Future<void> removeFavorite(String productId) async {
    await _api.delete<dynamic>(ApiEndpoints.favoriteProduct(productId));
  }

  @override
  Future<void> clearFavorites() async {
    await _api.delete<dynamic>(ApiEndpoints.favorites);
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
