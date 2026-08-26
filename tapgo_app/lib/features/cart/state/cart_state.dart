import '../models/cart.dart';

enum CartStatus { initial, loading, refreshing, ready, failure }

class CartState {
  const CartState({
    this.status = CartStatus.initial,
    this.cart = const Cart(id: 'local-cart'),
    this.errorMessage,
  });

  const CartState.initial() : this();

  final CartStatus status;
  final Cart cart;
  final String? errorMessage;

  bool get isLoading =>
      status == CartStatus.initial || status == CartStatus.loading;

  bool get isRefreshing => status == CartStatus.refreshing;

  bool get hasFailed => status == CartStatus.failure;

  bool get isEmpty => cart.isEmpty;

  bool get allSelected =>
      cart.items.isNotEmpty && cart.items.every((item) => item.isSelected);

  bool get hasSelection => cart.items.any((item) => item.isSelected);

  int get selectedCount => cart.selectedCount;

  double get selectedSubtotal => cart.subtotal;

  CartState copyWith({
    CartStatus? status,
    Cart? cart,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
