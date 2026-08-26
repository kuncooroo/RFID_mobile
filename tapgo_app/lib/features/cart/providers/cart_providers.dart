import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import '../models/cart.dart';
import '../repository/cart_repository.dart';
import '../repository/mock_cart_repository.dart';
import '../state/cart_state.dart';
import '../../../src/network/api_client.dart';
import '../repository/remote_cart_repository.dart';

/// Pass `--dart-define=USE_MOCK_CART=true` to force the mock repository.
const bool kUseMockCartRepository = bool.fromEnvironment(
  'USE_MOCK_CART',
  defaultValue: false,
);

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  if (kUseMockCartRepository) {
    return MockCartRepository();
  }
  return RemoteCartRepository(api: ref.watch(apiClientProvider));
});

final cartControllerProvider =
    NotifierProvider<CartController, CartState>(CartController.new);

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState.initial();

  Future<void> load() async {
    if (state.status == CartStatus.loading) return;
    state = state.copyWith(status: CartStatus.loading, clearError: true);
    await _fetch(status: CartStatus.ready);
  }

  Future<void> addProduct({
    required Product product,
    int quantity = 1,
    String? colorName,
    String? size,
  }) async {
    try {
      final cart = await ref.read(cartRepositoryProvider).addItem(
            product: product,
            quantity: quantity,
            colorName: colorName,
            size: size,
          );
      state = state.copyWith(status: CartStatus.ready, cart: cart);
    } catch (error) {
      state = state.copyWith(
        status: CartStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: CartStatus.refreshing, clearError: true);
    await _fetch(status: CartStatus.ready);
  }

  Future<void> _fetch({required CartStatus status}) async {
    try {
      final cart = await ref.read(cartRepositoryProvider).fetchCart();
      state = state.copyWith(status: status, cart: cart);
    } catch (error) {
      state = state.copyWith(
        status: CartStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> updateQty(String itemId, int quantity) async {
    final previous = state.cart;
    state = state.copyWith(
      cart: _optimisticQty(previous, itemId, quantity),
    );
    try {
      final cart = await ref
          .read(cartRepositoryProvider)
          .updateQty(itemId, quantity);
      state = state.copyWith(cart: cart);
    } catch (error) {
      state = state.copyWith(
        cart: previous,
        status: CartStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> toggleSelect(String itemId) async {
    final previous = state.cart;
    state = state.copyWith(
      cart: _optimisticToggle(previous, itemId),
    );
    try {
      final cart = await ref.read(cartRepositoryProvider).toggleSelect(itemId);
      state = state.copyWith(cart: cart);
    } catch (error) {
      state = state.copyWith(
        cart: previous,
        status: CartStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> selectAll(bool selected) async {
    final previous = state.cart;
    state = state.copyWith(
      cart: Cart(
        id: previous.id,
        currency: previous.currency,
        items: previous.items
            .map((item) => item.copyWith(isSelected: selected))
            .toList(),
      ),
    );
    try {
      final cart = await ref.read(cartRepositoryProvider).selectAll(selected);
      state = state.copyWith(cart: cart);
    } catch (error) {
      state = state.copyWith(
        cart: previous,
        status: CartStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> removeItem(String itemId) async {
    final previous = state.cart;
    state = state.copyWith(
      cart: previous.copyWith(
        items: previous.items.where((item) => item.id != itemId).toList(),
      ),
    );
    try {
      final cart = await ref.read(cartRepositoryProvider).removeItem(itemId);
      state = state.copyWith(cart: cart);
    } catch (error) {
      state = state.copyWith(
        cart: previous,
        status: CartStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> removeSelectedItems() async {
    final ids = selectedItems.map((item) => item.id).toList();
    if (ids.isEmpty) return;
    final previous = state.cart;
    state = state.copyWith(
      cart: previous.copyWith(
        items: previous.items.where((item) => !ids.contains(item.id)).toList(),
      ),
    );
    try {
      final cart = await ref.read(cartRepositoryProvider).removeItems(ids);
      state = state.copyWith(cart: cart);
    } catch (error) {
      state = state.copyWith(
        cart: previous,
        status: CartStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  List<CartItem> get selectedItems =>
      state.cart.items.where((item) => item.isSelected).toList();

  Cart _optimisticQty(Cart cart, String itemId, int quantity) {
    return cart.copyWith(
      items: cart.items.map((item) {
        if (item.id != itemId) return item;
        final clamped = quantity.clamp(1, item.maxQuantity);
        return item.copyWith(quantity: clamped);
      }).toList(),
    );
  }

  Cart _optimisticToggle(Cart cart, String itemId) {
    return cart.copyWith(
      items: cart.items.map((item) {
        if (item.id != itemId) return item;
        return item.copyWith(isSelected: !item.isSelected);
      }).toList(),
    );
  }
}
