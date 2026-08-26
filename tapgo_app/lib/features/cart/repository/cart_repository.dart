import '../../product/models/product.dart';
import '../models/cart.dart';

/// Contract for My Cart operations.
abstract class CartRepository {
  Future<Cart> fetchCart();

  Future<Cart> addItem({
    required Product product,
    int quantity = 1,
    String? colorName,
    String? size,
  });

  Future<Cart> updateQty(String itemId, int quantity);

  Future<Cart> toggleSelect(String itemId);

  Future<Cart> selectAll(bool selected);

  Future<Cart> removeItem(String itemId);

  Future<Cart> removeItems(List<String> itemIds);
}
