import '../../product/models/product.dart';
import '../models/cart.dart';
import 'cart_repository.dart';
import 'mock_cart_repository.dart';

/// Local cart stand-in until Laravel cart endpoints are wired.
class LocalCartRepository implements CartRepository {
  LocalCartRepository() : _delegate = MockCartRepository();

  final MockCartRepository _delegate;

  @override
  Future<Cart> fetchCart() => _delegate.fetchCart();

  @override
  Future<Cart> addItem({
    required Product product,
    int quantity = 1,
    String? colorName,
    String? size,
  }) =>
      _delegate.addItem(
        product: product,
        quantity: quantity,
        colorName: colorName,
        size: size,
      );

  @override
  Future<Cart> updateQty(String itemId, int quantity) =>
      _delegate.updateQty(itemId, quantity);

  @override
  Future<Cart> toggleSelect(String itemId) => _delegate.toggleSelect(itemId);

  @override
  Future<Cart> selectAll(bool selected) => _delegate.selectAll(selected);

  @override
  Future<Cart> removeItem(String itemId) => _delegate.removeItem(itemId);

  @override
  Future<Cart> removeItems(List<String> itemIds) =>
      _delegate.removeItems(itemIds);
}
