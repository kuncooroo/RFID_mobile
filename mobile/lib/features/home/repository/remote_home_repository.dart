import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../../../src/network/api_exception.dart';
import '../../catalog/models/category.dart';
import '../../product/models/product.dart';
import '../models/home_feed.dart';
import '../models/promotion.dart';
import 'home_repository.dart';

class RemoteHomeRepository implements HomeRepository {
  RemoteHomeRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<HomeFeed> fetchHomeFeed() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.home,
      parser: _asMap,
    );

    final promotions = _mapList(data['promotions'], Promotion.fromJson);
    final categories = _mapList(data['categories'], Category.fromJson);
    final newArrivals = _mapList(data['new_arrivals'], Product.fromJson);

    return HomeFeed(
      promotions: promotions,
      categories: categories,
      newArrivals: newArrivals,
      categoryProducts: newArrivals,
    );
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    try {
      await _api.delete<dynamic>(ApiEndpoints.favoriteProduct(productId));
    } on ApiException catch (e) {
      if (e.isNotFound || e.statusCode == 422) {
        await _api.post<dynamic>(
          ApiEndpoints.favorites,
          data: {'product_id': int.tryParse(productId) ?? productId},
        );
        return;
      }
      rethrow;
    }
  }

  List<T> _mapList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => mapper(Map<String, dynamic>.from(e)))
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
