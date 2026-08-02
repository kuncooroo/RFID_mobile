import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/providers/cart_providers.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../repository/checkout_repository.dart';
import '../repository/local_checkout_repository.dart';
import '../repository/mock_checkout_repository.dart';
import '../state/checkout_state.dart';

/// Pass `--dart-define=USE_MOCK_CHECKOUT=true` to force the mock repository.
const bool kUseMockCheckoutRepository = bool.fromEnvironment(
  'USE_MOCK_CHECKOUT',
  defaultValue: false,
);

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  if (kUseMockCheckoutRepository) {
    return MockCheckoutRepository();
  }
  return LocalCheckoutRepository();
});

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutState>(
      CheckoutController.new,
    );

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState.initial();

  Future<void> loadAddresses() async {
    if (state.status == CheckoutStatus.loading) return;
    state = state.copyWith(status: CheckoutStatus.loading, clearError: true);
    try {
      final addresses = await ref
          .read(checkoutRepositoryProvider)
          .fetchAddresses();
      final defaultAddress = _defaultAddress(addresses);
      state = state.copyWith(
        status: CheckoutStatus.ready,
        addresses: addresses,
        selectedAddressId: defaultAddress?.id,
      );
    } catch (error) {
      state = state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadPaymentMethods() async {
    state = state.copyWith(clearError: true);
    try {
      final methods = await ref
          .read(checkoutRepositoryProvider)
          .fetchPaymentMethods();
      final defaultMethod = _defaultPaymentMethod(methods);
      state = state.copyWith(
        status: CheckoutStatus.ready,
        paymentMethods: methods,
        selectedPaymentId: state.selectedPaymentId ?? defaultMethod?.id,
      );
    } catch (error) {
      state = state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  void selectAddress(String addressId) {
    state = state.copyWith(selectedAddressId: addressId);
  }

  void selectPaymentMethod(String paymentMethodId) {
    state = state.copyWith(selectedPaymentId: paymentMethodId);
  }

  Future<PaymentMethod?> addCard(NewCardInput input) async {
    state = state.copyWith(clearError: true);
    try {
      final method = await ref.read(checkoutRepositoryProvider).addCard(input);
      final methods = [...state.paymentMethods, method];
      state = state.copyWith(
        paymentMethods: methods,
        selectedPaymentId: method.id,
      );
      return method;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return null;
    }
  }

  Future<String?> placeOrder() async {
    final addressId = state.selectedAddressId;
    final paymentId = state.selectedPaymentId;
    if (addressId == null || paymentId == null) return null;

    final cartState = ref.read(cartControllerProvider);
    final selectedItems = cartState.cart.items
        .where((item) => item.isSelected)
        .toList();
    if (selectedItems.isEmpty) {
      state = state.copyWith(errorMessage: 'No items selected for checkout.');
      return null;
    }

    state = state.copyWith(placingOrder: true, clearError: true);
    try {
      final orderId = await ref.read(checkoutRepositoryProvider).placeOrder(
        addressId: addressId,
        paymentMethodId: paymentId,
        cartItemIds: selectedItems.map((item) => item.id).toList(),
        total: cartState.selectedSubtotal,
      );
      state = state.copyWith(
        placingOrder: false,
        placedOrderId: orderId,
      );
      return orderId;
    } catch (error) {
      state = state.copyWith(
        placingOrder: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  void resetPlacedOrder() {
    state = state.copyWith(clearPlacedOrderId: true);
  }
}

Address? _defaultAddress(List<Address> addresses) {
  for (final address in addresses) {
    if (address.isDefault) return address;
  }
  return addresses.isNotEmpty ? addresses.first : null;
}

PaymentMethod? _defaultPaymentMethod(List<PaymentMethod> methods) {
  for (final method in methods) {
    if (method.isDefault) return method;
  }
  return methods.isNotEmpty ? methods.first : null;
}
