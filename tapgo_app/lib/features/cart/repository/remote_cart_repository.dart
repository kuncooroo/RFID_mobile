import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../../product/models/product.dart';
import '../models/cart.dart';
import 'cart_repository.dart';

class RemoteCartRepository implements CartRepository {
  RemoteCartRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<Cart> fetchCart() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.cart,
      parser: _asMap,
    );
    return Cart.fromJson(data);
  }

  @override
  Future<Cart> addItem({
    required Product product,
    int quantity = 1,
    String? colorName,
    String? size,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.cartItems,
      data: {
        'product_id': int.tryParse(product.id) ?? product.id,
        'quantity': quantity,
        if (colorName != null) 'color_name': colorName,
        if (size != null) 'size': size,
      },
      parser: _asMap,
    );
    return Cart.fromJson(data);
  }

  @override
  Future<Cart> updateQty(String itemId, int quantity) async {
    final data = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.cartItem(itemId),
      data: {'quantity': quantity},
      parser: _asMap,
    );
    return Cart.fromJson(data);
  }

  @override
  Future<Cart> toggleSelect(String itemId) async {
    final cart = await fetchCart();
    final item = cart.items.firstWhere((e) => e.id == itemId);
    final data = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.cartItem(itemId),
      data: {'is_selected': !item.isSelected},
      parser: _asMap,
    );
    return Cart.fromJson(data);
  }

  @override
  Future<Cart> selectAll(bool selected) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.cartSelectAll,
      data: {'selected': selected},
      parser: _asMap,
    );
    return Cart.fromJson(data);
  }

  @override
  Future<Cart> removeItem(String itemId) async {
    final data = await _api.delete<Map<String, dynamic>>(
      ApiEndpoints.cartItem(itemId),
      parser: _asMap,
    );
    return Cart.fromJson(data);
  }

  @override
  Future<Cart> removeItems(List<String> itemIds) async {
    Cart? cart;
    for (final id in itemIds) {
      cart = await removeItem(id);
    }
    return cart ?? await fetchCart();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
